import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'academico.dart';
import 'avisos.dart';
import 'database.dart';
import 'diario_db.dart';

/// Programa los avisos de Mi diario.
///
/// En el celular (APK) quedan programados en el sistema y llegan aunque la
/// app esté cerrada. En la web el navegador no deja programarlos, así que se
/// muestran mientras la pestaña está abierta (y como notificación del
/// navegador si el profesor dio permiso).
class Recordatorios {
  Recordatorios._();
  static final instancia = Recordatorios._();

  final _plugin = FlutterLocalNotificationsPlugin();
  KipuDb? _db;
  bool _listo = false;

  /// Aviso que se muestra dentro de la app (web, o con la app abierta).
  final enApp = ValueNotifier<Aviso?>(null);

  /// Próximos avisos calculados (para mostrarlos en Mi diario).
  final proximos = ValueNotifier<List<Aviso>>(const []);

  List<Aviso> _avisos = const [];
  String _firma = '';
  final _mostrados = <String>{};
  Timer? _reloj;
  Timer? _espera;
  StreamSubscription<void>? _cambios;

  static const _canal = AndroidNotificationDetails(
    'kipu_diario',
    'Mi diario',
    channelDescription: 'Recordatorios de la agenda, clases y pendientes',
    importance: Importance.high,
    priority: Priority.high,
  );

  bool get _web => kIsWeb;
  bool get _android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  WebFlutterLocalNotificationsPlugin? get _webPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        WebFlutterLocalNotificationsPlugin
      >();

  /// Se llama una vez al abrir la app.
  Future<void> iniciar(KipuDb db) async {
    _db = db;
    if (_web || _android) {
      try {
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            web: WebInitializationSettings(),
          ),
        );
        _listo = true;
      } catch (e) {
        debugPrint('Recordatorios: $e');
      }
    }
    // Cada cambio en la agenda, horario, pendientes o ajustes recalcula.
    _cambios = db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.eventos,
            db.horarios,
            db.pendientes,
            db.estudiantes,
            db.ajustes,
            db.colegios,
          },
        )
        .watch()
        .listen((_) {
          _espera?.cancel();
          _espera = Timer(const Duration(seconds: 2), reprogramar);
        });
    _reloj = Timer.periodic(const Duration(seconds: 20), (_) => _revisar());
  }

  void cerrar() {
    _cambios?.cancel();
    _reloj?.cancel();
    _espera?.cancel();
  }

  /// ¿Ya puede mostrar notificaciones del sistema o del navegador?
  Future<bool> tienePermiso() async {
    if (!_listo) return false;
    try {
      if (_web) {
        return _webPlugin?.permissionStatus == WebNotificationPermission.granted;
      }
      if (_android) return await _androidPlugin?.areNotificationsEnabled() ?? false;
    } catch (_) {}
    return false;
  }

  /// Pide permiso. Solo después de que el profesor toque algo.
  Future<bool> pedirPermiso() async {
    if (!_listo) return false;
    try {
      if (_web) return await _webPlugin?.requestNotificationsPermission() ?? false;
      if (_android) {
        return await _androidPlugin?.requestNotificationsPermission() ?? false;
      }
    } catch (e) {
      debugPrint('Recordatorios: $e');
    }
    return false;
  }

  /// Android: ¿puede avisar a la hora exacta?
  Future<bool> avisoExacto() async {
    if (!_android || !_listo) return true;
    try {
      return await _androidPlugin?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> pedirAvisoExacto() async {
    if (!_android || !_listo) return;
    try {
      await _androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {}
    await reprogramar(forzar: true);
  }

  bool get esWeb => _web;

  Future<DatosAvisos> _datos(KipuDb db) async {
    final anio = DateTime.now().year;
    return DatosAvisos(
      colegios: {
        for (final c in await db.verColegios().first) c.id: c.nombre,
      },
      eventos: await db.verTodosEventos().first,
      clases: await db.verHorario().first,
      cumples: await db.estudiantesConCumple(),
      periodos: (await db.verConfigAcademica(anio).first).periodos,
      pendientes: await db.verPendientes().first,
      ajustes: AjustesAvisos.deTexto(await db.leerAjuste(claveAvisos)),
    );
  }

  /// Recalcula los avisos de las próximas dos semanas.
  Future<void> reprogramar({bool forzar = false}) async {
    final db = _db;
    if (db == null) return;
    final ahora = DateTime.now();
    final lista = calcularAvisos(
      await _datos(db),
      ahora.subtract(const Duration(minutes: 2)),
      ahora.add(const Duration(days: 14)),
    );
    proximos.value = [
      for (final a in lista)
        if (!a.cuando.isBefore(ahora)) a,
    ];
    final firma = lista.join('|');
    if (firma == _firma && !forzar) return;
    _firma = firma;
    _avisos = lista;
    if (!_android || !_listo) return;
    try {
      final exacto = await avisoExacto();
      await _plugin.cancelAllPendingNotifications();
      var id = 1;
      // Android limita cuántas alarmas tiene una app: las 60 más cercanas.
      for (final a in proximos.value.take(60)) {
        await _plugin.zonedSchedule(
          id: id++,
          title: a.titulo,
          body: a.cuerpo,
          scheduledDate: tz.TZDateTime.from(a.cuando, tz.UTC),
          notificationDetails: const NotificationDetails(android: _canal),
          androidScheduleMode: exacto
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Recordatorios: $e');
    }
  }

  /// Web (o app abierta): muestra los avisos que ya tocan.
  Future<void> _revisar() async {
    if (_android) return; // en Android los muestra el sistema
    final ahora = DateTime.now();
    for (final a in _avisos) {
      if (a.cuando.isAfter(ahora)) break;
      // Solo los de los últimos 2 minutos, para no repetir viejos.
      if (ahora.difference(a.cuando).inMinutes > 2) continue;
      if (!_mostrados.add(a.clave)) continue;
      enApp.value = a;
      if (await tienePermiso()) {
        try {
          await _plugin.show(
            id: _mostrados.length,
            title: a.titulo,
            body: a.cuerpo,
            notificationDetails: const NotificationDetails(
              web: WebNotificationDetails(),
            ),
          );
        } catch (_) {}
      }
    }
  }
}

/// Atajo.
final recordatorios = Recordatorios.instancia;
