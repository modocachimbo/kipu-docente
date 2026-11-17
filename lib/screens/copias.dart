import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:intl/intl.dart';

import '../data/colores_notas.dart';
import '../data/copias.dart';
import '../data/drive.dart';
import '../data/local/copias_local.dart';
import '../data/recordatorios.dart';
import '../data/respaldo.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/kipu_icono.dart';

const _verde = Color(0xFF16A37F);
const _ambar = Color(0xFFE07B1F);
const _rojo = Color(0xFFC2334A);
const _azulDrive = Color(0xFF1A73E8);

String _fecha(DateTime d) {
  final hoy = DateUtils.dateOnly(DateTime.now());
  final dia = DateUtils.dateOnly(d);
  final hora = DateFormat('HH:mm').format(d);
  if (dia == hoy) return 'hoy, $hora';
  if (hoy.difference(dia).inDays == 1) return 'ayer, $hora';
  return '${DateFormat("d MMM yyyy", 'es_PE').format(d).replaceAll('.', '')}, $hora';
}

String _tamano(int b) => b < 1024 * 1024
    ? '${(b / 1024).ceil()} KB'
    : '${(b / 1024 / 1024).toStringAsFixed(1).replaceAll('.', ',')} MB';

/// Copias de seguridad y sincronización con Google Drive.
class PantallaCopias extends StatefulWidget {
  const PantallaCopias({super.key});

  @override
  State<PantallaCopias> createState() => _PantallaCopiasState();
}

class _PantallaCopiasState extends State<PantallaCopias> {
  List<ArchivoLocal> _locales = const [];

  @override
  void initState() {
    super.initState();
    _leerLocales();
    copias.revisarOtrosEquipos();
  }

  Future<void> _leerLocales() async {
    try {
      final l = await listarLocal();
      if (mounted) setState(() => _locales = l);
    } catch (_) {
      // Sin carpeta disponible: se muestra vacío.
    }
  }

  void _aviso(String t, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t),
        backgroundColor: error ? _rojo : null,
      ),
    );
  }

  Future<void> _crearAhora() async {
    final e = copias.estado.value;
    if (!hayCarpetaLocal && e.cuentaDrive == null) {
      // Web sin Drive: la copia es el archivo que se descarga.
      await _descargar();
      return;
    }
    try {
      await copias.crear();
      await _leerLocales();
      final x = copias.estado.value;
      if (!mounted) return;
      if (x.error != null) {
        _aviso('No se pudo completar: ${x.error}', error: true);
      } else {
        _aviso(x.cuentaDrive != null && x.ultimaDrive != null &&
                DateTime.now().difference(x.ultimaDrive!).inMinutes < 1
            ? 'Copia guardada en este equipo y en Google Drive.'
            : 'Copia guardada.');
      }
    } on DriveSinPermiso {
      if (mounted) _aviso('Toca «Conectar» para volver a dar permiso a Drive.');
    }
  }

  Future<void> _descargar({bool anonima = false}) async {
    try {
      final c = await db.crearCopia(
        dispositivo: copias.dispositivo,
        anonima: anonima,
      );
      await FilePicker.saveFile(
        fileName: c.nombreArchivo,
        bytes: c.bytes,
        mimeType: 'application/octet-stream',
      );
      if (!anonima && !hayCarpetaLocal) {
        // En la web, descargar cuenta como copia hecha.
        copias.estado.value = copias.estado.value.con(ultima: DateTime.now());
      }
    } catch (e) {
      if (mounted) _aviso('No se pudo crear el archivo: $e', error: true);
    }
  }

  Future<void> _conectar() async {
    try {
      await copias.conectarDrive();
      if (mounted) _aviso('Google Drive conectado. Ya se guardó la primera copia.');
    } catch (e) {
      if (mounted) {
        _aviso('No se pudo conectar con Google Drive. Inténtalo otra vez.',
            error: true);
      }
    }
  }

  Future<void> _desconectar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Desconectar Google Drive?'),
        content: const Text(
          'Las copias que ya están en tu Drive se quedan ahí. Kipu dejará de '
          'subir copias nuevas hasta que lo vuelvas a conectar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
    if (ok == true) await copias.desconectarDrive();
  }

  /// Muestra qué trae la copia y pide confirmar antes de reemplazar todo.
  Future<void> _restaurar(Future<Uint8List> Function() leer, {String? origen}) async {
    Uint8List bytes;
    InfoCopia info;
    try {
      bytes = await leer();
      info = db.leerInfo(bytes);
    } on CopiaInvalida catch (e) {
      if (mounted) _aviso(e.mensaje, error: true);
      return;
    } catch (e) {
      if (mounted) _aviso('No se pudo leer la copia: $e', error: true);
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const KipuIcon(KipuIcono.refrescar, size: 34, color: _ambar),
        title: const Text('¿Restaurar esta copia?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Dato('Fecha', _fecha(info.fecha)),
            _Dato('Hecha en', info.dispositivo.isEmpty ? '—' : info.dispositivo),
            _Dato('Contiene', '${info.cursos} cursos · ${info.estudiantes} estudiantes'),
            if (origen != null) _Dato('Desde', origen),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                info.anonima
                    ? 'Es una copia anónima de soporte: los nombres no son los '
                          'reales. Reemplazará todo lo de este equipo.'
                    : 'Reemplazará todo lo que hay en este equipo por lo de la '
                          'copia. ${hayCarpetaLocal ? 'Antes guardaremos una copia de lo actual, por si acaso.' : 'Si quieres conservar lo actual, descarga antes una copia.'}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _ambar),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await copias.restaurar(bytes);
      // Lo que se lee una sola vez al abrir Kipu.
      estiloActual.value = estiloPorId(await db.leerAjuste('estilo'));
      coloresNotas.value = ColoresNotas.deTexto(
        await db.leerAjuste(claveColoresNotas),
      );
      await recordatorios.reprogramar(forzar: true);
      await _leerLocales();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _aviso('Listo: se restauró la copia del ${_fecha(info.fecha)}.');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _aviso('No se pudo restaurar: $e', error: true);
    }
  }

  Future<void> _desdeArchivo() async {
    final f = await FilePicker.pickFile(type: FileType.any);
    if (f == null) return;
    await _restaurar(() => f.xFile.readAsBytes(), origen: f.xFile.name);
  }

  Future<void> _verDrive() async {
    List<ArchivoDrive> lista;
    try {
      lista = await drive.listar();
    } on DriveSinPermiso {
      if (mounted) _aviso('Toca «Conectar» para volver a dar permiso a Drive.');
      return;
    } catch (e) {
      if (mounted) _aviso('$e', error: true);
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ListaCopias(
        titulo: 'Copias en Google Drive',
        subtitulo: 'Carpeta «$nombreCarpetaDrive» de tu Drive',
        filas: [
          for (final f in lista)
            (
              f.nombre,
              '${_fecha(f.fecha)} · ${f.dispositivo == copias.dispositivo ? 'este equipo' : f.dispositivo} · ${_tamano(f.tamano)}',
              () {
                Navigator.pop(ctx);
                _restaurar(() => drive.descargar(f.id), origen: 'Google Drive');
              },
            ),
        ],
      ),
    );
  }

  Future<void> _verLocales() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ListaCopias(
        titulo: 'Copias en este equipo',
        subtitulo: 'Se borran si desinstalas Kipu: por eso conviene Drive.',
        filas: [
          for (final f in _locales)
            (
              f.nombre,
              '${_fecha(f.fecha)} · ${_tamano(f.tamano)}',
              () {
                Navigator.pop(ctx);
                _restaurar(() => leerLocal(f.ruta), origen: 'este equipo');
              },
            ),
        ],
      ),
    );
  }

  Future<void> _ajustes() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AjustesCopias(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copias de seguridad'),
        actions: [
          IconButton(
            tooltip: 'Ajustes de las copias',
            onPressed: _ajustes,
            icon: KipuIcon(KipuIcono.engranaje, color: KipuColores.tinta),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<EstadoCopias>(
        valueListenable: copias.estado,
        builder: (context, e, _) => FloatingActionButton.extended(
          onPressed: e.trabajando ? null : _crearAhora,
          icon: e.trabajando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const KipuIcon(KipuIcono.copia, color: Colors.white),
          label: Text(
            e.trabajando
                ? 'Guardando…'
                : (!hayCarpetaLocal && e.cuentaDrive == null
                      ? 'Descargar copia'
                      : 'Crear copia ahora'),
          ),
        ),
      ),
      body: ValueListenableBuilder<EstadoCopias>(
        valueListenable: copias.estado,
        builder: (context, e, _) => ValueListenableBuilder<AjustesCopias>(
          valueListenable: copias.ajustes,
          builder: (context, a, _) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                children: [
                  if (e.otraMasNueva != null) _OtraMasNueva(
                    e.otraMasNueva!,
                    onRestaurar: () => _restaurar(
                      () => drive.descargar(e.otraMasNueva!.id),
                      origen: 'Google Drive · ${e.otraMasNueva!.dispositivo}',
                    ),
                    onIgnorar: copias.ignorarOtra,
                  ),
                  _Estado(e, a),
                  const SizedBox(height: 12),
                  _Drive(
                    e,
                    onConectar: _conectar,
                    onDesconectar: _desconectar,
                    onVer: _verDrive,
                  ),
                  const SizedBox(height: 12),
                  _Equipo(
                    locales: _locales,
                    onVer: _verLocales,
                  ),
                  const SizedBox(height: 18),
                  _Boton(
                    icono: KipuIcono.descargar,
                    texto: 'Descargar una copia (archivo .kipu)',
                    detalle: 'Para guardarla en una USB, en tu correo o pasarla a otro equipo.',
                    onTap: _descargar,
                  ),
                  _Boton(
                    icono: KipuIcono.refrescar,
                    texto: 'Restaurar desde un archivo…',
                    detalle: 'Abre una copia .kipu y reemplaza los datos de este equipo.',
                    onTap: _desdeArchivo,
                  ),
                  _Boton(
                    icono: KipuIcono.candado,
                    texto: 'Copia anónima para soporte',
                    detalle: 'Sin nombres, DNI, teléfonos, fotos ni anotaciones: para '
                        'enviarla si algo falla, sin exponer a tus estudiantes.',
                    onTap: () => _descargar(anonima: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String a;
  final String b;
  const _Dato(this.a, this.b);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(a, style: const TextStyle(color: KipuColores.gris)),
        ),
        Expanded(
          child: Text(b, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

class _Tarjeta extends StatelessWidget {
  final Widget child;
  final Color? borde;
  const _Tarjeta({required this.child, this.borde});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: borde == null ? null : Border.all(color: borde!, width: 1.4),
    ),
    child: child,
  );
}

class _Icono extends StatelessWidget {
  final KipuIcono icono;
  final Color color;
  const _Icono(this.icono, this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: Color.lerp(color, Colors.white, .86),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(child: KipuIcon(icono, size: 24, color: color)),
  );
}

/// Arriba: si los datos están protegidos y la copia automática.
class _Estado extends StatelessWidget {
  final EstadoCopias e;
  final AjustesCopias a;
  const _Estado(this.e, this.a);

  @override
  Widget build(BuildContext context) {
    final (color, titulo, detalle) = e.protegido
        ? (
            _verde,
            'Tus datos están protegidos',
            'Última copia en Google Drive: ${_fecha(e.ultimaDrive!)}',
          )
        : e.ultima != null
        ? (
            _ambar,
            e.cuentaDrive == null
                ? 'Solo hay copia en este equipo'
                : 'Falta subir la copia a Drive',
            'Última copia: ${_fecha(e.ultima!)}. '
                '${e.cuentaDrive == null ? 'Conecta Google Drive para no perder nada si se pierde o se malogra el equipo.' : 'Toca «Crear copia ahora».'}',
          )
        : (
            _rojo,
            'Todavía no hay copias',
            hayCarpetaLocal
                ? 'Toca «Crear copia ahora» o conecta Google Drive.'
                : 'Tus datos viven solo en este navegador: si borras sus datos '
                      'se pierden. Conecta Google Drive o descarga una copia.',
          );
    final frec = switch (a.frecuencia) {
      Frecuencia.cambios => 'Unos minutos después de cada cambio',
      Frecuencia.diaria => 'Una vez al día',
      Frecuencia.semanal => 'Una vez a la semana',
    };
    return _Tarjeta(
      borde: Color.lerp(color, Colors.white, .6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Icono(
                e.protegido ? KipuIcono.check : KipuIcono.aviso,
                color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KipuColores.gris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (e.driveEspera && e.cuentaDrive != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Hay cambios sin subir a Drive. Google pide confirmar de nuevo: '
                'toca «Crear copia ahora».',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
          if (e.error != null) ...[
            const SizedBox(height: 10),
            Text(
              'La última copia falló: ${e.error}',
              style: const TextStyle(fontSize: 12.5, color: _rojo),
            ),
          ],
          const Divider(height: 26),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Copia automática',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      a.automatica
                          ? '$frec · conserva las ${a.conservar} más recientes'
                          : 'Apagada: solo cuando tocas el botón',
                      style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
              Switch(
                value: a.automatica,
                onChanged: (v) => copias.cambiarAjustes(a.copiar(automatica: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtraMasNueva extends StatelessWidget {
  final ArchivoDrive f;
  final VoidCallback onRestaurar;
  final VoidCallback onIgnorar;
  const _OtraMasNueva(this.f, {required this.onRestaurar, required this.onIgnorar});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _Tarjeta(
      borde: _azulDrive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _Icono(KipuIcono.celular, _azulDrive),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hay una copia más nueva de otro equipo',
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${f.dispositivo} · ${_fecha(f.fecha)} · ${f.estudiantes} estudiantes',
                      style: const TextStyle(fontSize: 13, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Trabajaste en otro celular o computadora? Restaura esa copia '
            'para tener aquí lo mismo. Ojo: reemplaza lo de este equipo.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onIgnorar, child: const Text('Ahora no')),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _azulDrive),
                onPressed: onRestaurar,
                child: const Text('Ver y restaurar'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Drive extends StatelessWidget {
  final EstadoCopias e;
  final VoidCallback onConectar;
  final VoidCallback onDesconectar;
  final VoidCallback onVer;
  const _Drive(
    this.e, {
    required this.onConectar,
    required this.onDesconectar,
    required this.onVer,
  });

  @override
  Widget build(BuildContext context) {
    final conectado = e.cuentaDrive != null;
    return _Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _Icono(KipuIcono.copia, _azulDrive),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Google Drive',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      !drive.disponible
                          ? 'Disponible muy pronto'
                          : conectado
                          ? e.cuentaDrive!
                          : 'No conectado',
                      style: const TextStyle(fontSize: 13, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
              if (drive.disponible && !conectado)
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _azulDrive),
                  onPressed: onConectar,
                  child: const Text('Conectar'),
                ),
              if (conectado)
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'ver' ? onVer() : onDesconectar(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'ver', child: Text('Ver copias y restaurar')),
                    PopupMenuItem(value: 'salir', child: Text('Desconectar')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conectado
                ? 'Las copias se guardan en la carpeta «$nombreCarpetaDrive» de tu '
                      'Drive. Kipu solo puede ver los archivos que él mismo crea.'
                      '${e.ultimaDrive == null ? '' : ' Última: ${_fecha(e.ultimaDrive!)}.'}'
                : 'Guarda tus copias en tu propio Google Drive: si pierdes o cambias '
                      'de celular, entras con la misma cuenta y recuperas todo. '
                      'Kipu solo puede ver los archivos que él mismo crea.',
            style: const TextStyle(fontSize: 13),
          ),
          if (conectado) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onVer,
                icon: const KipuIcon(KipuIcono.refrescar, size: 18, color: _azulDrive),
                label: const Text('Ver copias y restaurar'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Equipo extends StatelessWidget {
  final List<ArchivoLocal> locales;
  final VoidCallback onVer;
  const _Equipo({required this.locales, required this.onVer});

  @override
  Widget build(BuildContext context) {
    if (!hayCarpetaLocal) {
      return const _Tarjeta(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Icono(KipuIcono.aviso, _ambar),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Este navegador',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'En la web tus datos se guardan dentro del navegador. Si '
                    'borras el historial con «datos de sitios» o usas otro '
                    'navegador, no estarán. Conecta Google Drive o descarga '
                    'una copia de vez en cuando.',
                    style: TextStyle(fontSize: 13, color: KipuColores.gris),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final total = locales.fold<int>(0, (s, f) => s + f.tamano);
    Widget dato(String v, String t) => Expanded(
      child: Column(
        children: [
          Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(
            t.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: .6,
              color: KipuColores.gris,
            ),
          ),
        ],
      ),
    );
    return _Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Icono(KipuIcono.celular, KipuColores.morado),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Este equipo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Sirven si algo sale mal, pero se borran al desinstalar Kipu.',
                      style: TextStyle(fontSize: 13, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
              if (locales.isNotEmpty)
                TextButton(onPressed: onVer, child: const Text('Ver')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              dato('${locales.length}', 'copias'),
              dato(_tamano(total), 'ocupado'),
              dato(
                locales.isEmpty
                    ? '—'
                    : DateFormat('d MMM HH:mm', 'es_PE')
                          .format(locales.first.fecha)
                          .replaceAll('.', ''),
                'última',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  final KipuIcono icono;
  final String texto;
  final String detalle;
  final VoidCallback onTap;
  const _Boton({
    required this.icono,
    required this.texto,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              KipuIcon(icono, size: 22, color: KipuColores.morado),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      detalle,
                      style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
              const KipuIcon(KipuIcono.derecha, size: 16, color: KipuColores.gris),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ListaCopias extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<(String, String, VoidCallback)> filas;
  const _ListaCopias({
    required this.titulo,
    required this.subtitulo,
    required this.filas,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(subtitulo, style: const TextStyle(fontSize: 13, color: KipuColores.gris)),
              ],
            ),
          ),
          if (filas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'Todavía no hay copias.',
                textAlign: TextAlign.center,
                style: TextStyle(color: KipuColores.gris),
              ),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
              children: [
                for (final (n, d, tap) in filas)
                  ListTile(
                    leading: const KipuIcon(KipuIcono.copia, color: KipuColores.gris),
                    title: Text(n, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(d),
                    trailing: TextButton(onPressed: tap, child: const Text('Restaurar')),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _AjustesCopias extends StatelessWidget {
  const _AjustesCopias();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AjustesCopias>(
    valueListenable: copias.ajustes,
    builder: (context, a, _) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajustes de las copias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            const Text('Frecuencia', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (f, t) in const [
                  (Frecuencia.cambios, 'Después de cada cambio'),
                  (Frecuencia.diaria, 'Diaria'),
                  (Frecuencia.semanal, 'Semanal'),
                ])
                  ChoiceChip(
                    label: Text(t),
                    selected: a.frecuencia == f,
                    onSelected: (_) => copias.cambiarAjustes(a.copiar(frecuencia: f)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Copias a conservar', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                for (final n in const [5, 10, 20, 30])
                  ChoiceChip(
                    label: Text('$n'),
                    selected: a.conservar == n,
                    onSelected: (_) => copias.cambiarAjustes(a.copiar(conservar: n)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mantener todas las copias en Google Drive'),
              subtitle: const Text('No se borra ninguna; ocupa más espacio en tu Drive.'),
              value: a.todasEnDrive,
              onChanged: (v) => copias.cambiarAjustes(a.copiar(todasEnDrive: v)),
            ),
            const SizedBox(height: 4),
            Text(
              'Nombre de este equipo en las copias: ${copias.dispositivo}',
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
          ],
        ),
      ),
    ),
  );
}
