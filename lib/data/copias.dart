import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';

import 'database.dart';
import 'drive.dart';
import 'local/copias_local.dart';
import 'respaldo.dart';

/// Cada cuánto se hace la copia automática.
enum Frecuencia { cambios, diaria, semanal }

/// Lo que el docente eligió (se guarda solo en este equipo).
class AjustesCopias {
  final bool automatica;
  final Frecuencia frecuencia;

  /// Cuántas copias se conservan (en el equipo y en Drive).
  final int conservar;

  /// En Drive no se borra ninguna.
  final bool todasEnDrive;

  const AjustesCopias({
    this.automatica = true,
    this.frecuencia = Frecuencia.cambios,
    this.conservar = 10,
    this.todasEnDrive = false,
  });

  AjustesCopias copiar({
    bool? automatica,
    Frecuencia? frecuencia,
    int? conservar,
    bool? todasEnDrive,
  }) => AjustesCopias(
    automatica: automatica ?? this.automatica,
    frecuencia: frecuencia ?? this.frecuencia,
    conservar: conservar ?? this.conservar,
    todasEnDrive: todasEnDrive ?? this.todasEnDrive,
  );

  String aTexto() => jsonEncode({
    'automatica': automatica,
    'frecuencia': frecuencia.name,
    'conservar': conservar,
    'todasEnDrive': todasEnDrive,
  });

  static AjustesCopias deTexto(String? s) {
    if (s == null || s.isEmpty) return const AjustesCopias();
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return AjustesCopias(
        automatica: m['automatica'] != false,
        frecuencia: Frecuencia.values.firstWhere(
          (f) => f.name == m['frecuencia'],
          orElse: () => Frecuencia.cambios,
        ),
        conservar: (m['conservar'] as num?)?.toInt() ?? 10,
        todasEnDrive: m['todasEnDrive'] == true,
      );
    } catch (_) {
      return const AjustesCopias();
    }
  }

  /// Desde cuándo toca otra copia.
  Duration get intervalo => switch (frecuencia) {
    Frecuencia.cambios => const Duration(minutes: 3),
    Frecuencia.diaria => const Duration(days: 1),
    Frecuencia.semanal => const Duration(days: 7),
  };
}

/// Cómo están las copias, para la pantalla.
class EstadoCopias {
  final DateTime? ultima;
  final DateTime? ultimaDrive;

  /// Correo de la cuenta de Google conectada (null = no conectada).
  final String? cuentaDrive;

  /// Hay cambios sin subir a Drive y hace falta tocar «Conectar» (web).
  final bool driveEspera;
  final bool trabajando;
  final String? error;

  /// Copia más nueva hecha en otro equipo.
  final ArchivoDrive? otraMasNueva;

  const EstadoCopias({
    this.ultima,
    this.ultimaDrive,
    this.cuentaDrive,
    this.driveEspera = false,
    this.trabajando = false,
    this.error,
    this.otraMasNueva,
  });

  EstadoCopias con({
    DateTime? ultima,
    DateTime? ultimaDrive,
    String? cuentaDrive,
    bool quitarCuenta = false,
    bool? driveEspera,
    bool? trabajando,
    String? error,
    bool quitarError = false,
    ArchivoDrive? otraMasNueva,
    bool quitarOtra = false,
  }) => EstadoCopias(
    ultima: ultima ?? this.ultima,
    ultimaDrive: ultimaDrive ?? this.ultimaDrive,
    cuentaDrive: quitarCuenta ? null : (cuentaDrive ?? this.cuentaDrive),
    driveEspera: driveEspera ?? this.driveEspera,
    trabajando: trabajando ?? this.trabajando,
    error: quitarError ? null : (error ?? this.error),
    otraMasNueva: quitarOtra ? null : (otraMasNueva ?? this.otraMasNueva),
  );

  /// Copia en la nube de los últimos 3 días.
  bool get protegido =>
      ultimaDrive != null &&
      DateTime.now().difference(ultimaDrive!) < const Duration(days: 3);
}

const _claveAjustes = 'respaldo_ajustes';
const _claveEstado = 'respaldo_estado';
const _claveDispositivo = 'respaldo_dispositivo';

/// Hace las copias automáticas y guarda el estado.
class ServicioCopias {
  ServicioCopias._();
  static final instancia = ServicioCopias._();

  KipuDb? _db;
  final estado = ValueNotifier(const EstadoCopias());
  final ajustes = ValueNotifier(const AjustesCopias());
  String _dispositivo = '';
  String? _huella;
  Timer? _espera;
  Timer? _reloj;
  StreamSubscription<void>? _cambios;
  bool _ocupado = false;

  String get dispositivo => _dispositivo;

  Future<void> iniciar(KipuDb db) async {
    _db = db;
    ajustes.value = AjustesCopias.deTexto(await db.leerAjuste(_claveAjustes));
    _dispositivo = await db.leerAjuste(_claveDispositivo) ?? '';
    if (_dispositivo.isEmpty) {
      final n = Random().nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
      _dispositivo = '${kIsWeb ? 'Navegador' : 'Celular'} $n';
      await db.guardarAjuste(_claveDispositivo, _dispositivo);
    }
    _leerEstado(await db.leerAjuste(_claveEstado));

    // Cualquier cambio en los datos programa una copia.
    _cambios = db
        .tableUpdates(TableUpdateQuery.any())
        .listen((_) => _programar());
    _reloj = Timer.periodic(const Duration(minutes: 30), (_) => _programar());
    // Al abrir: ¿hay una copia más nueva de otro equipo? ¿toca copia?
    Timer(const Duration(seconds: 20), () async {
      await revisarOtrosEquipos();
      _programar();
    });
  }

  void cerrar() {
    _cambios?.cancel();
    _espera?.cancel();
    _reloj?.cancel();
  }

  void _leerEstado(String? s) {
    if (s == null || s.isEmpty) return;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      _huella = m['huella'] as String?;
      estado.value = EstadoCopias(
        ultima: DateTime.tryParse(m['ultima'] as String? ?? ''),
        ultimaDrive: DateTime.tryParse(m['ultimaDrive'] as String? ?? ''),
        cuentaDrive: m['cuenta'] as String?,
      );
    } catch (_) {}
  }

  Future<void> _guardarEstado() async {
    final e = estado.value;
    await _db?.guardarAjuste(
      _claveEstado,
      jsonEncode({
        'ultima': e.ultima?.toIso8601String(),
        'ultimaDrive': e.ultimaDrive?.toIso8601String(),
        'cuenta': e.cuentaDrive,
        'huella': _huella,
      }),
    );
  }

  Future<void> cambiarAjustes(AjustesCopias a) async {
    ajustes.value = a;
    await _db?.guardarAjuste(_claveAjustes, a.aTexto());
  }

  void _programar() {
    final a = ajustes.value;
    if (!a.automatica) return;
    final ultima = estado.value.ultima;
    final falta = ultima == null
        ? Duration.zero
        : a.intervalo - DateTime.now().difference(ultima);
    _espera?.cancel();
    // «Después de cada cambio»: espera a que el docente deje de escribir.
    final espera = a.frecuencia == Frecuencia.cambios
        ? const Duration(minutes: 3)
        : (falta.isNegative ? const Duration(seconds: 30) : falta);
    _espera = Timer(espera, () => crear(manual: false));
  }

  /// Hace una copia: en el equipo (celular) y en Drive si está conectado.
  /// Devuelve false si no hacía falta (no hubo cambios).
  Future<bool> crear({bool manual = true}) async {
    final db = _db;
    if (db == null || _ocupado) return false;
    final conDrive = estado.value.cuentaDrive != null && drive.disponible;
    // En la web sin Drive no hay dónde guardar solo (se descarga a mano).
    if (!hayCarpetaLocal && !conDrive) return false;
    _ocupado = true;
    estado.value = estado.value.con(trabajando: true, quitarError: true);
    try {
      final c = await db.crearCopia(dispositivo: _dispositivo);
      final igual = c.huella == _huella;
      if (igual && !manual && !estado.value.driveEspera) return false;
      if (!igual || manual) {
        if (hayCarpetaLocal) {
          await guardarLocal(c.nombreArchivo, c.bytes);
          await _limpiarLocal();
        }
        _huella = c.huella;
        if (hayCarpetaLocal) {
          estado.value = estado.value.con(ultima: c.info.fecha);
        }
      }
      await _subir(c, manual: manual);
      if (!hayCarpetaLocal && estado.value.ultimaDrive == c.info.fecha) {
        estado.value = estado.value.con(ultima: c.info.fecha);
      }
      await _guardarEstado();
      return true;
    } catch (e) {
      estado.value = estado.value.con(error: '$e');
      return false;
    } finally {
      _ocupado = false;
      estado.value = estado.value.con(trabajando: false);
    }
  }

  Future<void> _subir(Copia c, {required bool manual}) async {
    if (estado.value.cuentaDrive == null || !drive.disponible) return;
    if (!manual && !await drive.listoSinPreguntar()) {
      // En la web el permiso dura una hora: se pide tocar «Guardar en Drive».
      estado.value = estado.value.con(driveEspera: true);
      return;
    }
    try {
      await drive.subir(c);
      estado.value = estado.value.con(
        ultimaDrive: c.info.fecha,
        driveEspera: false,
      );
      await _limpiarDrive();
    } on DriveSinPermiso {
      estado.value = estado.value.con(driveEspera: true);
      if (manual) rethrow;
    }
  }

  Future<void> _limpiarLocal() async {
    final l = await listarLocal();
    for (final f in l.skip(ajustes.value.conservar)) {
      await borrarLocal(f.ruta);
    }
  }

  Future<void> _limpiarDrive() async {
    if (ajustes.value.todasEnDrive) return;
    final l = [
      for (final f in await drive.listar())
        if (!f.anonima && f.dispositivo == _dispositivo) f,
    ];
    for (final f in l.skip(ajustes.value.conservar)) {
      await drive.borrar(f.id);
    }
  }

  /// Toque en «Conectar Google Drive».
  Future<void> conectarDrive() async {
    final correo = await drive.conectar();
    estado.value = estado.value.con(cuentaDrive: correo, quitarError: true);
    await _guardarEstado();
    await revisarOtrosEquipos();
    // La primera copia en Drive sale de inmediato.
    await crear();
  }

  Future<void> desconectarDrive() async {
    await drive.desconectar();
    estado.value = estado.value.con(
      quitarCuenta: true,
      driveEspera: false,
      quitarOtra: true,
    );
    await _guardarEstado();
  }

  /// Busca en Drive una copia de otro equipo más nueva que lo de aquí.
  Future<void> revisarOtrosEquipos() async {
    if (estado.value.cuentaDrive == null || !drive.disponible) return;
    try {
      if (!await drive.listoSinPreguntar()) return;
      final otra = (await drive.listar())
          .where((f) => !f.anonima && f.dispositivo != _dispositivo)
          .firstOrNull;
      final mia = estado.value.ultima;
      if (otra != null && (mia == null || otra.fecha.isAfter(mia))) {
        estado.value = estado.value.con(otraMasNueva: otra);
      } else {
        estado.value = estado.value.con(quitarOtra: true);
      }
    } catch (_) {}
  }

  void ignorarOtra() =>
      estado.value = estado.value.con(quitarOtra: true);

  /// Restaura una copia. Antes guarda lo actual en el equipo, por si acaso.
  Future<InfoCopia> restaurar(Uint8List bytes) async {
    final db = _db!;
    _ocupado = true;
    try {
      // Valida antes de tocar nada.
      db.leerInfo(bytes);
      if (hayCarpetaLocal) {
        final antes = await db.crearCopia(dispositivo: _dispositivo);
        await guardarLocal('Antes de restaurar ${antes.nombreArchivo}', antes.bytes);
      }
      final info = await db.restaurarCopia(bytes);
      // Lo restaurado cuenta como la última copia de este equipo.
      final c = await db.crearCopia(dispositivo: _dispositivo);
      _huella = c.huella;
      estado.value = estado.value.con(ultima: DateTime.now(), quitarOtra: true);
      await _guardarEstado();
      return info;
    } finally {
      _ocupado = false;
    }
  }
}

final copias = ServicioCopias.instancia;
