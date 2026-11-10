import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/academico.dart';
import '../data/calculo.dart' show equivalenciasPorDefecto;
import '../data/cneb.dart';
import '../data/evaluacion_db.dart';
import '../data/instrumentos.dart';
import '../data/instrumentos_ejemplos.dart';
import '../data/instrumentos_excel.dart';
import '../data/paises.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/ventana.dart';
import 'cursos.dart' show confirmar;
import 'instrumento_editor.dart';
import 'instrumento_pdf.dart';

const _mimeExcel =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
const _rojo = Color(0xFFC2334A);
const _linea = Color(0xFFE6E7F0);

KipuIcono iconoDe(TipoInstrumento t) => switch (t) {
  TipoInstrumento.rubrica => KipuIcono.rubrica,
  TipoInstrumento.cotejo => KipuIcono.cotejo,
  TipoInstrumento.escala => KipuIcono.escalaValoracion,
  TipoInstrumento.prueba => KipuIcono.examen,
};

/// Color de un nivel de logro: del rojo (en inicio) al morado (destacado),
/// pasando por ámbar y azul, como la escala AD/A/B/C.
Color colorNivel(int posicion, int total, {bool ascendente = true}) {
  const tonos = [
    Color(0xFFC2334A),
    Color(0xFFB86E00),
    Color(0xFF2557C7),
    Color(0xFF5B4BD6),
  ];
  if (total <= 1) return tonos.last;
  final t = (ascendente ? posicion : total - 1 - posicion) / (total - 1);
  final x = t * (tonos.length - 1);
  final i = x.floor().clamp(0, tonos.length - 2).toInt();
  return Color.lerp(tonos[i], tonos[i + 1], x - i)!;
}

String numeroCorto(double n) => n == n.roundToDouble()
    ? n.round().toString()
    : n.toStringAsFixed(1).replaceAll('.', ',');

/// Las tres pestañas de la sección.
enum _Vista { mios, cneb, libre }

/// Carpeta abierta especial: los instrumentos que no tienen carpeta.
const _sinCarpeta = '';

/// Sección «Evaluación»: biblioteca del docente (con carpetas) y dos
/// colecciones de ejemplos (CNEB para colegios públicos y libre para
/// privados).
class PantallaEvaluacion extends StatefulWidget {
  const PantallaEvaluacion({super.key});

  @override
  State<PantallaEvaluacion> createState() => _PantallaEvaluacionState();
}

class _PantallaEvaluacionState extends State<PantallaEvaluacion> {
  late final Stream<List<Instrumento>> _biblioteca;
  late final Stream<List<Carpeta>> _carpetas = db.verCarpetas();
  late final Stream<List<String>> _recientes = db.verRecientes();
  late final Stream<Map<int, String>> _gestiones = db.verGestiones();
  _Vista _vista = _Vista.mios;

  /// Carpeta abierta en Mi biblioteca (null = vista de carpetas).
  String? _carpeta;
  bool _buscando = false;
  String _buscar = '';
  final _campoBuscar = TextEditingController();

  @override
  void initState() {
    super.initState();
    _biblioteca = Stream.fromFuture(
      db.prepararBiblioteca(),
    ).asyncExpand((_) => db.verBiblioteca());
  }

  @override
  void dispose() {
    _campoBuscar.dispose();
    super.dispose();
  }

  bool _pasa(Instrumento i) {
    final q = normalizar(_buscar);
    if (q.isEmpty) return true;
    return normalizar(
      '${i.nombre} ${i.area} ${i.descripcion} ${i.tipo.nombre} '
      '${i.niveles.join(' ')} '
      '${i.competencias.map((c) => competenciaPorId(c)?.nombre ?? '').join(' ')} '
      '${i.items.map((x) => x.texto).join(' ')}',
    ).contains(q);
  }

  void _aviso(String t, {SnackBarAction? accion}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t), action: accion));
  }

  void _cerrarBusqueda() => setState(() {
    _buscando = false;
    _buscar = '';
    _campoBuscar.clear();
  });

  // ───────────── Instrumentos ─────────────

  /// Abre el editor. [carpeta] es donde se guarda uno nuevo; si es null se
  /// acomoda solo según su nombre.
  Future<void> _editar(
    Instrumento ins, {
    bool nuevo = false,
    String? carpeta,
  }) async {
    final r = await Navigator.push<Instrumento>(
      context,
      MaterialPageRoute(
        builder: (_) => EditorInstrumento(inicial: ins, nuevo: nuevo),
      ),
    );
    if (r == null) return;
    var guardar = r;
    if (nuevo) {
      final destino =
          carpeta ?? carpetaSugerida(r, await db.leerCarpetas());
      guardar = r.copiar(carpeta: destino);
    }
    await db.guardarInstrumento(guardar);
    final carpetas = await db.leerCarpetas();
    final nombre = carpetas
        .where((c) => c.id == guardar.carpeta)
        .map((c) => c.nombre)
        .firstOrNull;
    _aviso(
      nuevo
          ? '«${r.nombre}» se guardó en ${nombre == null ? 'tu biblioteca' : '«$nombre»'}'
          : 'Cambios guardados',
    );
  }

  Future<void> _duplicar(Instrumento ins) async {
    final copia = duplicar(
      ins,
      nombre: '${ins.nombre} (copia)',
    ).copiar(carpeta: ins.carpeta);
    await db.guardarInstrumento(copia);
    _aviso(
      'Se creó «${copia.nombre}»',
      accion: SnackBarAction(label: 'Editar', onPressed: () => _editar(copia)),
    );
  }

  Future<void> _eliminar(Instrumento ins, int posicion) async {
    if (!await confirmar(
      context,
      '¿Eliminar «${ins.nombre}»?',
      'Las columnas del registro que ya lo usan no cambian: cada una guarda '
          'su propia copia del instrumento y sus notas.',
    )) {
      return;
    }
    await db.borrarInstrumento(ins.id);
    _aviso(
      'Se eliminó «${ins.nombre}»',
      accion: SnackBarAction(
        label: 'Deshacer',
        onPressed: () => db.restaurarInstrumento(ins, posicion),
      ),
    );
  }

  Future<void> _mover(Instrumento ins) async {
    final destino = await _elegirCarpeta(
      titulo: 'Mover «${ins.nombre}» a…',
      actual: ins.carpeta,
    );
    if (destino == null) return;
    await db.moverACarpeta([ins.id], destino);
    _aviso('Se movió «${ins.nombre}»');
  }

  /// Agrega instrumentos de una colección a la biblioteca, en la carpeta que
  /// elija el docente.
  Future<void> _agregar(List<Instrumento> lista, Set<String> agregados) async {
    final pendientes = [
      for (final e in lista)
        if (!agregados.contains(e.id)) e,
    ];
    if (pendientes.isEmpty) {
      _aviso('Ya están en tu biblioteca');
      return;
    }
    final carpetas = await db.leerCarpetas();
    final sugerida = carpetaSugerida(pendientes.first, carpetas);
    if (!mounted) return;
    final destino = await _elegirCarpeta(
      titulo: pendientes.length == 1
          ? '¿En qué carpeta guardas «${pendientes.first.nombre}»?'
          : '¿En qué carpeta guardas estos ${pendientes.length}?',
      actual: sugerida,
      accion: 'Agregar',
    );
    if (destino == null) return;
    final nuevos = [
      for (final e in pendientes)
        duplicar(e, ejemplo: true).copiar(carpeta: destino),
    ];
    for (final n in nuevos.reversed) {
      await db.guardarInstrumento(n);
    }
    final nombre = carpetas
        .where((c) => c.id == destino)
        .map((c) => c.nombre)
        .firstOrNull;
    _aviso(
      nuevos.length == 1
          ? '«${nuevos.first.nombre}» se agregó a ${nombre == null ? 'tu biblioteca' : '«$nombre»'}'
          : 'Se agregaron ${nuevos.length} instrumentos',
      accion: SnackBarAction(
        label: 'Ver',
        onPressed: () => setState(() {
          _vista = _Vista.mios;
          _carpeta = destino;
          _cerrarBusqueda();
        }),
      ),
    );
  }

  Future<void> _descargar(Instrumento ins, {bool plantilla = false}) async {
    try {
      await FilePicker.saveFile(
        fileName: plantilla
            ? 'plantilla-${nombreArchivo(ins).split('-mi-').first.replaceAll('.xlsx', '')}.xlsx'
            : nombreArchivo(ins),
        bytes: excelDeInstrumento(ins),
        mimeType: _mimeExcel,
      );
    } catch (_) {
      _aviso('No se pudo guardar el archivo. Inténtalo de nuevo.');
    }
  }

  Future<void> _pdf(Instrumento ins) async {
    var conClave = false;
    if (ins.tipo == TipoInstrumento.prueba) {
      final r = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Descargar examen en PDF'),
          content: const Text(
            '¿Para los estudiantes (sin respuestas) o la versión del docente '
            'con la clave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Con clave'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Para estudiantes'),
            ),
          ],
        ),
      );
      if (r == null) return;
      conClave = r;
    }
    try {
      final bytes = await pdfInstrumento(ins, conClave: conClave);
      await FilePicker.saveFile(
        fileName: nombreArchivo(ins, ext: 'pdf').replaceFirst(
          '.pdf',
          conClave ? '-clave.pdf' : '.pdf',
        ),
        bytes: bytes,
        mimeType: 'application/pdf',
      );
    } catch (_) {
      _aviso('No se pudo crear el PDF. Inténtalo de nuevo.');
    }
  }

  Future<void> _subir({String? carpeta}) async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    if (f == null || !mounted) return;
    final nombre = f.xFile.name.toLowerCase();
    final l = leerArchivo(
      await f.xFile.readAsBytes(),
      esCsv: nombre.endsWith('.csv'),
    );
    if (!mounted) return;
    if (!l.ok) {
      await _mostrarLista(
        'No se pudo subir',
        'Corrige esto en tu archivo y vuelve a subirlo:',
        l.errores,
        error: true,
      );
      return;
    }
    if (l.avisos.isNotEmpty) {
      await _mostrarLista(
        'Revisa antes de guardar',
        'El archivo se leyó bien. Ten en cuenta:',
        l.avisos,
      );
    }
    if (mounted) await _editar(l.instrumento!, nuevo: true, carpeta: carpeta);
  }

  Future<void> _mostrarLista(
    String titulo,
    String intro,
    List<String> lineas, {
    bool error = false,
  }) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(intro),
            const SizedBox(height: 10),
            for (final l in lineas)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: KipuIcon(
                        error ? KipuIcono.aviso : KipuIcono.check,
                        size: 16,
                        color: error ? _rojo : KipuColores.morado,
                      ),
                    ),
                    Expanded(child: Text(l)),
                  ],
                ),
              ),
            if (error) ...[
              const SizedBox(height: 6),
              const Text(
                'Consejo: descarga la plantilla desde el botón Crear para ver '
                'el formato.',
                style: TextStyle(fontSize: 13, color: KipuColores.gris),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );

  Future<void> _crear() async {
    // Dentro de una carpeta, lo que se crea o sube se guarda ahí.
    final enCarpeta = _vista == _Vista.mios && _carpeta != null && !_buscando
        ? _carpeta
        : null;
    final v = await ventanaCentrada<String>(
      context: context,
      builder: (ctx) {
        Widget opcion(String id, KipuIcono i, String t, String s) => ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: KipuColores.moradoClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: KipuIcon(i, size: 22, color: KipuColores.moradoOscuro),
            ),
          ),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(s, style: const TextStyle(fontSize: 12.5)),
          onTap: () => Navigator.pop(ctx, id),
        );
        Widget titulo(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Text(
            t,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: .6,
              fontWeight: FontWeight.w600,
              color: KipuColores.gris,
            ),
          ),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                'Crear instrumento',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            if (_vista == _Vista.mios && _carpeta == null && !_buscando)
              opcion(
                'carpeta',
                KipuIcono.agregar,
                'Nueva carpeta',
                'Para ordenar tus instrumentos: cuadernos, exposiciones…',
              ),
            titulo('DESDE CERO'),
            for (final t in TipoInstrumento.values)
              opcion('nuevo:${t.name}', iconoDe(t), t.nombre, t.ayuda),
            titulo('DESDE EXCEL O GOOGLE SHEETS'),
            opcion(
              'subir',
              KipuIcono.copia,
              'Subir archivo',
              'Un .xlsx o .csv hecho con la plantilla de Kipu',
            ),
            for (final t in TipoInstrumento.values)
              opcion(
                'plantilla:${t.name}',
                KipuIcono.descargar,
                'Plantilla: ${t.nombre.toLowerCase()}',
                'Descárgala, llénala en la computadora y súbela',
              ),
            titulo('O PARTE DE UN EJEMPLO'),
            opcion(
              'cneb',
              KipuIcono.libro,
              'Colección CNEB (colegio público)',
              '${coleccionCneb.length} instrumentos por área y competencia',
            ),
            opcion(
              'libre',
              KipuIcono.libro,
              'Colección libre (colegio privado)',
              '${ejemplosInstrumentos.length} instrumentos y exámenes',
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
    if (v == null || !mounted) return;
    if (v == 'carpeta') return _nuevaCarpeta();
    if (v == 'subir') return _subir(carpeta: enCarpeta);
    if (v == 'cneb') return setState(() => _vista = _Vista.cneb);
    if (v == 'libre') return setState(() => _vista = _Vista.libre);
    final partes = v.split(':');
    final t = TipoInstrumento.values.byName(partes[1]);
    if (partes[0] == 'nuevo') {
      return _editar(Instrumento.nuevo(t), nuevo: true, carpeta: enCarpeta);
    }
    return _descargar(plantillaDe(t), plantilla: true);
  }

  Future<void> _verDeColeccion(Instrumento e, bool agregado) async {
    final r = await ventanaCentrada<String>(
      context: context,
      ancho: 760,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VistaInstrumento(e),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'pdf'),
                  child: const Text('Descargar PDF'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
                FilledButton(
                  onPressed: agregado
                      ? null
                      : () => Navigator.pop(ctx, 'agregar'),
                  child: Text(
                    agregado
                        ? 'Ya está en tu biblioteca'
                        : 'Agregar a mi biblioteca',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (r == 'agregar') await _agregar([e], const {});
    if (r == 'pdf') await _pdf(e);
  }

  // ───────────── Carpetas ─────────────

  Future<void> _nuevaCarpeta() async {
    final r = await _formCarpeta(context);
    if (r == null) return;
    final c = await db.crearCarpeta(r.$1, r.$2);
    if (mounted) setState(() => _carpeta = c.id);
  }

  Future<void> _accionCarpeta(Carpeta c, String accion, int cantidad) async {
    switch (accion) {
      case 'editar':
        final r = await _formCarpeta(context, carpeta: c);
        if (r != null) await db.editarCarpeta(c.copiar(nombre: r.$1, color: r.$2));
      case 'eliminar':
        if (await confirmar(
          context,
          '¿Eliminar la carpeta «${c.nombre}»?',
          cantidad == 0
              ? 'La carpeta está vacía.'
              : 'Sus $cantidad instrumentos no se borran: pasan a «Sin carpeta».',
        )) {
          await db.borrarCarpeta(c.id);
          if (mounted) setState(() => _carpeta = null);
        }
    }
  }

  /// Lista de carpetas para elegir destino. Devuelve el id ('' = sin
  /// carpeta) o null si se cancela.
  Future<String?> _elegirCarpeta({
    required String titulo,
    required String actual,
    String accion = 'Mover',
  }) async {
    var carpetas = await db.leerCarpetas();
    if (!mounted) return null;
    var elegida = actual;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(titulo),
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
          content: SizedBox(
            width: 420,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in carpetas)
                  _OpcionCarpeta(
                    nombre: c.nombre,
                    color: Color(c.color),
                    activo: elegida == c.id,
                    onTap: () => setState(() => elegida = c.id),
                  ),
                _OpcionCarpeta(
                  nombre: 'Sin carpeta',
                  color: KipuColores.gris,
                  activo: elegida == _sinCarpeta,
                  onTap: () => setState(() => elegida = _sinCarpeta),
                ),
                ListTile(
                  leading: KipuIcon(KipuIcono.agregar, color: KipuColores.morado),
                  title: const Text('Nueva carpeta'),
                  onTap: () async {
                    final r = await _formCarpeta(ctx);
                    if (r == null) return;
                    final c = await db.crearCarpeta(r.$1, r.$2);
                    carpetas = [...carpetas, c];
                    setState(() => elegida = c.id);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, elegida),
              child: Text(accion),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── Pantalla ─────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buscando
            ? TextField(
                controller: _campoBuscar,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar instrumento, competencia o ítem',
                  isDense: true,
                ),
                onChanged: (t) => setState(() => _buscar = t),
              )
            : const Text('Evaluación'),
        actions: [
          if (_buscando)
            IconButton(
              tooltip: 'Cerrar búsqueda',
              onPressed: _cerrarBusqueda,
              icon: KipuIcon(KipuIcono.cerrar, color: KipuColores.tinta),
            )
          else ...[
            IconButton(
              tooltip: 'Buscar',
              onPressed: () => setState(() => _buscando = true),
              icon: KipuIcon(KipuIcono.buscar, color: KipuColores.tinta),
            ),
            IconButton(
              tooltip: 'Conversión a notas',
              onPressed: () => editarTramos(context),
              icon: KipuIcon(KipuIcono.ajustes, color: KipuColores.tinta),
            ),
          ],
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crear,
        icon: const KipuIcon(KipuIcono.agregar, color: Colors.white),
        label: const Text('Crear'),
      ),
      body: StreamBuilder<Map<int, String>>(
        stream: _gestiones,
        builder: (context, g) => StreamBuilder<List<Carpeta>>(
          stream: _carpetas,
          builder: (context, c) => StreamBuilder<List<String>>(
            stream: _recientes,
            builder: (context, r) => StreamBuilder<List<Instrumento>>(
              stream: _biblioteca,
              builder: (context, snap) => _cuerpo(
                mios: snap.data,
                carpetas: c.data ?? const [],
                recientes: r.data ?? const [],
                gestiones: g.data ?? const {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cuerpo({
    required List<Instrumento>? mios,
    required List<Carpeta> carpetas,
    required List<String> recientes,
    required Map<int, String> gestiones,
  }) {
    // Si todos los colegios son privados, la colección libre va primero.
    final privado =
        gestiones.isNotEmpty &&
        gestiones.values.every((v) => v == gestionPrivada);
    final pestanas = [
      _Vista.mios,
      if (privado) ...[_Vista.libre, _Vista.cneb] else ...[_Vista.cneb, _Vista.libre],
    ];
    final agregados = {for (final m in mios ?? const <Instrumento>[]) m.origen};

    final hijos = <Widget>[
      _Pestanas(
        pestanas: [
          for (final p in pestanas)
            (
              p,
              switch (p) {
                _Vista.mios => 'Mi biblioteca',
                _Vista.cneb => 'CNEB · Estatal',
                _Vista.libre => 'Libre · Privado',
              },
            ),
        ],
        actual: _vista,
        onCambio: (v) => setState(() {
          _vista = v;
          _carpeta = null;
        }),
      ),
      const SizedBox(height: 14),
    ];

    if (_vista == _Vista.mios) {
      if (mios == null) {
        hijos.add(
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      } else {
        hijos.addAll(
          _biblio(mios: mios, carpetas: carpetas, recientes: recientes),
        );
      }
    } else {
      hijos.addAll(_coleccionVista(agregados));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: hijos,
        ),
      ),
    );
  }

  Widget _tarjeta(
    Instrumento ins, {
    required bool coleccion,
    bool agregado = false,
    String? carpeta,
    List<Instrumento> mios = const [],
    Set<String> agregados = const {},
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: _TarjetaInstrumento(
      ins: ins,
      coleccion: coleccion,
      agregado: agregado,
      carpeta: carpeta,
      onTap: coleccion
          ? () => _verDeColeccion(ins, agregado)
          : () => _editar(ins),
      onAgregar: () => _agregar([ins], agregados),
      onAccion: (accion) {
        switch (accion) {
          case 'editar':
            _editar(ins);
          case 'mover':
            _mover(ins);
          case 'duplicar':
            _duplicar(ins);
          case 'excel':
            _descargar(ins);
          case 'pdf':
            _pdf(ins);
          case 'eliminar':
            _eliminar(ins, mios.indexOf(ins));
        }
      },
    ),
  );

  List<Widget> _biblio({
    required List<Instrumento> mios,
    required List<Carpeta> carpetas,
    required List<String> recientes,
  }) {
    final nombres = {for (final c in carpetas) c.id: c.nombre};
    // Un instrumento con una carpeta que ya no existe cuenta como sin carpeta.
    String carpetaDe(Instrumento i) =>
        nombres.containsKey(i.carpeta) ? i.carpeta : _sinCarpeta;

    // Buscando: lista plana de toda la biblioteca, con el nombre de la carpeta.
    if (_buscando && _buscar.trim().isNotEmpty) {
      final r = mios.where(_pasa).toList();
      return [
        _Contador('${r.length} en tu biblioteca'),
        if (r.isEmpty)
          const _VacioTexto('Nada coincide. Prueba en las colecciones CNEB o Libre.'),
        for (final i in r)
          _tarjeta(
            i,
            coleccion: false,
            carpeta: nombres[carpetaDe(i)],
            mios: mios,
          ),
      ];
    }

    // Dentro de una carpeta.
    final abierta = _carpeta;
    if (abierta != null) {
      final c = carpetas.where((x) => x.id == abierta).firstOrNull;
      final lista = [
        for (final i in mios)
          if (carpetaDe(i) == abierta) i,
      ];
      return [
        _CabeceraCarpeta(
          nombre: c?.nombre ?? 'Sin carpeta',
          color: c == null ? KipuColores.gris : Color(c.color),
          cantidad: lista.length,
          onVolver: () => setState(() => _carpeta = null),
          onAccion: c == null
              ? null
              : (a) => _accionCarpeta(c, a, lista.length),
        ),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          _CarpetaVacia(
            onCrear: _crear,
            onSubir: () => _subir(carpeta: abierta),
            onColeccion: () => setState(() {
              _vista = _Vista.cneb;
              _carpeta = null;
            }),
          )
        else
          for (final i in lista) _tarjeta(i, coleccion: false, mios: mios),
      ];
    }

    // Vista de carpetas.
    final porCarpeta = <String, int>{};
    for (final i in mios) {
      porCarpeta[carpetaDe(i)] = (porCarpeta[carpetaDe(i)] ?? 0) + 1;
    }
    final usados = [
      for (final id in recientes) ?mios.where((i) => i.id == id).firstOrNull,
    ];
    return [
      if (usados.isNotEmpty) ...[
        const _Titulo('USADOS HACE POCO'),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: usados.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, k) => _Reciente(
              ins: usados[k],
              onTap: () => _editar(usados[k]),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Row(
        children: [
          const Expanded(child: _Titulo('MIS CARPETAS')),
          TextButton(
            onPressed: _nuevaCarpeta,
            child: const Text('+ Nueva carpeta'),
          ),
        ],
      ),
      LayoutBuilder(
        builder: (context, caja) {
          final columnas = caja.maxWidth >= 720
              ? 4
              : (caja.maxWidth >= 480 ? 3 : 2);
          const espacio = 10.0;
          final ancho = (caja.maxWidth - espacio * (columnas - 1)) / columnas;
          final sinCarpeta = porCarpeta[_sinCarpeta] ?? 0;
          return Wrap(
            spacing: espacio,
            runSpacing: espacio,
            children: [
              for (final c in carpetas)
                SizedBox(
                  width: ancho,
                  child: _TarjetaCarpeta(
                    nombre: c.nombre,
                    color: Color(c.color),
                    cantidad: porCarpeta[c.id] ?? 0,
                    onTap: () => setState(() => _carpeta = c.id),
                    onAccion: (a) => _accionCarpeta(c, a, porCarpeta[c.id] ?? 0),
                  ),
                ),
              if (sinCarpeta > 0 || carpetas.isEmpty)
                SizedBox(
                  width: ancho,
                  child: _TarjetaCarpeta(
                    nombre: 'Sin carpeta',
                    color: KipuColores.gris,
                    cantidad: sinCarpeta,
                    onTap: () => setState(() => _carpeta = _sinCarpeta),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 14),
      Text(
        mios.isEmpty
            ? 'Tu biblioteca está vacía. Toca «Crear» o agrega instrumentos '
                  'de las colecciones CNEB o Libre.'
            : '${mios.length} instrumentos en total. Mantén tus rúbricas, '
                  'listas y exámenes ordenados por carpeta.',
        style: const TextStyle(fontSize: 13, color: KipuColores.gris),
      ),
    ];
  }

  /// CNEB y Libre: agrupados por área (en CNEB, por nivel dentro del área).
  List<Widget> _coleccionVista(Set<String> agregados) {
    final base = _vista == _Vista.cneb ? coleccionCneb : ejemplosInstrumentos;
    final lista = base.where(_pasa).toList();
    final grupos = <String, List<Instrumento>>{};
    for (final i in lista) {
      (grupos[i.area] ??= []).add(i);
    }
    final claves = grupos.keys.toList()..sort(_compararAreas);
    final abrir = claves.length <= 2 || _buscar.trim().isNotEmpty;
    final cneb = _vista == _Vista.cneb;
    return [
      _Aviso(
        cneb
            ? 'Dos instrumentos por competencia del Currículo Nacional, por '
                  'nivel y área. Sirven con letras (AD, A, B, C) o con números '
                  '(0 a 20): la columna del registro decide.'
            : 'Instrumentos y exámenes para el día a día, sin depender del '
                  'CNEB. Sirven con números (0 a 20) o con letras.',
      ),
      _Contador(
        '${lista.length} instrumentos'
        '${claves.length > 1 ? ' en ${claves.length} áreas' : ''}',
      ),
      if (lista.isEmpty) const _VacioTexto('Nada coincide con tu búsqueda.'),
      for (final a in claves)
        _Grupo(
          key: ValueKey('${_vista.name}-$a-$abrir'),
          titulo: a.isEmpty ? 'General' : a,
          cantidad: grupos[a]!.length,
          abierto: abrir,
          accion: TextButton(
            onPressed: grupos[a]!.every((e) => agregados.contains(e.id))
                ? null
                : () => _agregar(grupos[a]!, agregados),
            child: const Text('Agregar todos'),
          ),
          hijos: [
            for (final n in [...nivelesEducativos, ''])
              if (grupos[a]!.any((i) => _nivelPrincipal(i) == n)) ...[
                if (cneb && n.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                    child: Text(
                      n.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: .6,
                        fontWeight: FontWeight.w700,
                        color: KipuColores.morado,
                      ),
                    ),
                  ),
                for (final i in grupos[a]!)
                  if (_nivelPrincipal(i) == n)
                    _tarjeta(
                      i,
                      coleccion: true,
                      agregado: agregados.contains(i.id),
                      agregados: agregados,
                    ),
              ],
          ],
        ),
    ];
  }
}

String _nivelPrincipal(Instrumento i) =>
    i.niveles.isEmpty ? '' : i.niveles.first;

Future<(String, int)?> _formCarpeta(
  BuildContext context, {
  Carpeta? carpeta,
}) {
  final nombre = TextEditingController(text: carpeta?.nombre);
  var color = carpeta?.color ?? coloresCarpeta.first;
  String? error;
  return showDialog<(String, int)>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(carpeta == null ? 'Nueva carpeta' : 'Editar carpeta'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nombre,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Presentación de trabajos',
                  errorText: error,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in coloresCarpeta)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => color = c),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c == color
                                ? KipuColores.tinta
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final t = nombre.text.trim();
              if (t.isEmpty) {
                setState(() => error = 'Escribe un nombre');
                return;
              }
              Navigator.pop(ctx, (t, color));
            },
            child: Text(carpeta == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    ),
  );
}

int _compararAreas(String a, String b) {
  int pos(String x) {
    if (x.isEmpty) return 999;
    final i = ordenAreas.indexOf(x);
    return i < 0 ? 500 : i;
  }

  final d = pos(a).compareTo(pos(b));
  return d != 0 ? d : a.compareTo(b);
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: .6,
        fontWeight: FontWeight.w700,
        color: KipuColores.gris,
      ),
    ),
  );
}

class _Contador extends StatelessWidget {
  final String texto;
  const _Contador(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 13, color: KipuColores.gris),
    ),
  );
}

class _VacioTexto extends StatelessWidget {
  final String texto;
  const _VacioTexto(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
    child: Text(
      texto,
      textAlign: TextAlign.center,
      style: const TextStyle(color: KipuColores.gris),
    ),
  );
}

class _Aviso extends StatelessWidget {
  final String texto;
  const _Aviso(this.texto);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    decoration: BoxDecoration(
      color: KipuColores.moradoClaro,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      texto,
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 13, color: KipuColores.moradoOscuro),
    ),
  );
}

class _Pestanas extends StatelessWidget {
  final List<(_Vista, String)> pestanas;
  final _Vista actual;
  final ValueChanged<_Vista> onCambio;
  const _Pestanas({
    required this.pestanas,
    required this.actual,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          for (final (v, t) in pestanas)
            Expanded(
              child: Material(
                color: v == actual ? KipuColores.morado : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => onCambio(v),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 6,
                    ),
                    child: Text(
                      t,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: v == actual ? Colors.white : KipuColores.tinta,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaCarpeta extends StatelessWidget {
  final String nombre;
  final Color color;
  final int cantidad;
  final VoidCallback onTap;
  final ValueChanged<String>? onAccion;
  const _TarjetaCarpeta({
    required this.nombre,
    required this.color,
    required this.cantidad,
    required this.onTap,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: KipuIcon(KipuIcono.carpeta, color: color, size: 24),
                  ),
                  const Spacer(),
                  if (onAccion != null)
                    PopupMenuButton<String>(
                      tooltip: 'Opciones de la carpeta',
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: KipuColores.gris,
                      ),
                      onSelected: onAccion,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Text('Renombrar o cambiar color'),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar carpeta'),
                        ),
                      ],
                    )
                  else
                    const SizedBox(height: 40),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cantidad == 1 ? '1 instrumento' : '$cantidad instrumentos',
                style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabeceraCarpeta extends StatelessWidget {
  final String nombre;
  final Color color;
  final int cantidad;
  final VoidCallback onVolver;
  final ValueChanged<String>? onAccion;
  const _CabeceraCarpeta({
    required this.nombre,
    required this.color,
    required this.cantidad,
    required this.onVolver,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Volver a mis carpetas',
        onPressed: onVolver,
        icon: KipuIcon(KipuIcono.izquierda, color: KipuColores.tinta),
      ),
      KipuIcon(KipuIcono.carpeta, color: color, size: 26),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              cantidad == 1 ? '1 instrumento' : '$cantidad instrumentos',
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
          ],
        ),
      ),
      if (onAccion != null)
        PopupMenuButton<String>(
          tooltip: 'Opciones de la carpeta',
          onSelected: onAccion,
          icon: const Icon(Icons.more_vert),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Renombrar o cambiar color')),
            PopupMenuItem(value: 'eliminar', child: Text('Eliminar carpeta')),
          ],
        ),
    ],
  );
}

class _CarpetaVacia extends StatelessWidget {
  final VoidCallback onCrear;
  final VoidCallback onSubir;
  final VoidCallback onColeccion;
  const _CarpetaVacia({
    required this.onCrear,
    required this.onSubir,
    required this.onColeccion,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
    child: Column(
      children: [
        const Text(
          'Esta carpeta está vacía',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Crea un instrumento aquí, súbelo desde Excel o agrégalo de una '
          'colección.',
          textAlign: TextAlign.center,
          style: TextStyle(color: KipuColores.gris),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(onPressed: onCrear, child: const Text('Crear')),
            OutlinedButton(onPressed: onSubir, child: const Text('Subir Excel')),
            OutlinedButton(onPressed: onColeccion, child: const Text('Ver colecciones')),
          ],
        ),
      ],
    ),
  );
}

class _OpcionCarpeta extends StatelessWidget {
  final String nombre;
  final Color color;
  final bool activo;
  final VoidCallback onTap;
  const _OpcionCarpeta({
    required this.nombre,
    required this.color,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: KipuIcon(KipuIcono.carpeta, color: color),
    title: Text(
      nombre,
      style: TextStyle(fontWeight: activo ? FontWeight.w700 : FontWeight.w400),
    ),
    trailing: activo
        ? KipuIcon(KipuIcono.check, color: KipuColores.morado, size: 20)
        : null,
    selected: activo,
    onTap: onTap,
  );
}

class _Reciente extends StatelessWidget {
  final Instrumento ins;
  final VoidCallback onTap;
  const _Reciente({required this.ins, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              KipuIcon(iconoDe(ins.tipo), color: KipuColores.morado),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ins.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ins.tipo.nombre,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Grupo extends StatelessWidget {
  final String titulo;
  final int cantidad;
  final bool abierto;
  final Widget? accion;
  final List<Widget> hijos;
  const _Grupo({
    super.key,
    required this.titulo,
    required this.cantidad,
    required this.abierto,
    required this.hijos,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: abierto,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: KipuColores.moradoClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cantidad',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KipuColores.moradoOscuro,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?accion,
              const KipuIcon(KipuIcono.abajo, size: 20, color: KipuColores.gris),
            ],
          ),
          children: hijos,
        ),
      ),
    );
  }
}

class _TarjetaInstrumento extends StatelessWidget {
  final Instrumento ins;
  final bool coleccion;
  final bool agregado;

  /// Nombre de la carpeta, solo en los resultados de búsqueda.
  final String? carpeta;
  final VoidCallback onTap;
  final VoidCallback onAgregar;
  final ValueChanged<String> onAccion;
  const _TarjetaInstrumento({
    required this.ins,
    required this.coleccion,
    required this.agregado,
    this.carpeta,
    required this.onTap,
    required this.onAgregar,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final comps = [
      for (final c in ins.competencias) ?competenciaPorId(c)?.nombre,
    ];
    final etiquetas = [
      if (carpeta != null) 'Carpeta: $carpeta',
      ...ins.niveles,
      if (ins.noObservado) 'No observado',
      if (ins.ponderada &&
          ins.tipo != TipoInstrumento.rubrica &&
          ins.tipo != TipoInstrumento.prueba)
        'Ponderada',
    ];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: KipuColores.moradoClaro,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: KipuIcon(
                    iconoDe(ins.tipo),
                    size: 24,
                    color: KipuColores.moradoOscuro,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ins.nombre.isEmpty ? 'Sin nombre' : ins.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${ins.tipo.nombre} · ${ins.resumen}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KipuColores.moradoOscuro,
                      ),
                    ),
                    if (comps.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        comps.join(' · '),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: KipuColores.gris,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (coleccion && ins.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ins.descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ],
                    if (etiquetas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final e in etiquetas)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: KipuColores.fondo,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(e, style: const TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (coleccion)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: agregado
                      ? Tooltip(
                          message: 'Ya está en tu biblioteca',
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: KipuIcon(
                              KipuIcono.check,
                              size: 22,
                              color: KipuColores.morado,
                            ),
                          ),
                        )
                      : FilledButton.tonal(
                          onPressed: onAgregar,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('Agregar'),
                        ),
                )
              else
                PopupMenuButton<String>(
                  tooltip: 'Opciones',
                  onSelected: onAccion,
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'mover', child: Text('Mover a carpeta')),
                    PopupMenuItem(value: 'duplicar', child: Text('Duplicar')),
                    PopupMenuItem(value: 'pdf', child: Text('Descargar PDF')),
                    PopupMenuItem(
                      value: 'excel',
                      child: Text('Descargar en Excel'),
                    ),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────── Conversión a la escala ─────────────────────

/// Cuánto % hace falta para cada letra. El Minedu no fija estos valores,
/// así que el docente (o su colegio) los puede cambiar.
Future<void> editarTramos(BuildContext context) async {
  final anio = await db.verAnioActivo().first;
  final config = await db.verConfigAcademica(anio).first;
  final letras = [
    for (final e in config.escalas)
      if (!e.numerica) e,
  ];
  final actuales = {for (final e in letras) e.id: await db.leerTramos(e)};
  final equivalencias = {
    for (final e in letras) e.id: await db.leerEquivalencias(e),
  };
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => Ventana(
      icono: KipuIcono.ajustes,
      titulo: 'Conversión a notas',
      subtitulo: 'Del % logrado a la escala del registro',
      contenido: _Tramos(
        escalas: letras,
        actuales: actuales,
        equivalencias: equivalencias,
        config: config,
      ),
    ),
  );
}

class _Tramos extends StatefulWidget {
  final List<Escala> escalas;
  final Map<String, List<double>> actuales;
  final Map<String, List<double>> equivalencias;
  final ConfigAcademica config;
  const _Tramos({
    required this.escalas,
    required this.actuales,
    required this.equivalencias,
    required this.config,
  });

  @override
  State<_Tramos> createState() => _TramosState();
}

class _TramosState extends State<_Tramos> {
  late final Map<String, List<TextEditingController>> _c = {
    for (final e in widget.escalas)
      e.id: [
        for (final t in widget.actuales[e.id]!)
          TextEditingController(text: t.round().toString()),
      ],
  };
  late final Map<String, List<TextEditingController>> _eq = {
    for (final e in widget.escalas)
      e.id: [
        for (final t in widget.equivalencias[e.id]!)
          TextEditingController(text: numeroCorto(t)),
      ],
  };
  String? _error;

  @override
  void dispose() {
    for (final l in _eq.values) {
      for (final c in l) {
        c.dispose();
      }
    }
    for (final l in _c.values) {
      for (final c in l) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final nuevos = <Escala, List<double>>{};
    for (final e in widget.escalas) {
      final l = <double>[];
      for (final c in _c[e.id]!) {
        final n = double.tryParse(c.text.replaceAll(',', '.').trim());
        if (n == null) {
          setState(() => _error = '${e.nombre}: escribe solo números');
          return;
        }
        l.add(n);
      }
      final err = validarTramos(l);
      if (err != null) {
        setState(() => _error = '${e.nombre}: $err');
        return;
      }
      nuevos[e] = l;
    }
    final eqs = <Escala, List<double>>{};
    for (final e in widget.escalas) {
      final l = <double>[];
      for (final c in _eq[e.id]!) {
        final n = double.tryParse(c.text.replaceAll(',', '.').trim());
        if (n == null || n < 0 || n > 20) {
          setState(
            () => _error = '${e.nombre}: cada letra debe valer de 0 a 20',
          );
          return;
        }
        l.add(n);
      }
      eqs[e] = l;
    }
    for (final x in nuevos.entries) {
      await db.guardarTramos(x.key, x.value);
    }
    for (final x in eqs.entries) {
      await db.guardarEquivalencias(x.key, x.value);
    }
    if (mounted) Navigator.pop(context);
  }

  void _restablecer() => setState(() {
    for (final e in widget.escalas) {
      final d = tramosPorDefecto(e);
      for (var i = 0; i < d.length; i++) {
        _c[e.id]![i].text = d[i].round().toString();
      }
      final q = equivalenciasPorDefecto(e);
      for (var i = 0; i < q.length && i < _eq[e.id]!.length; i++) {
        _eq[e.id]![i].text = numeroCorto(q[i]);
      }
    }
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Se usa en listas de cotejo, exámenes y cuando el instrumento no '
          'tiene tantos niveles como la escala. Una rúbrica de 4 niveles pasa '
          'a AD, A, B, C por su nivel promedio. En escalas numéricas: puntos '
          '÷ máximo × nota máxima.',
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 13, color: KipuColores.gris, height: 1.35),
        ),
        for (final e in widget.escalas) ...[
          const SizedBox(height: 16),
          Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (var i = 0; i < e.valores.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(e.valores[i].color).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      e.valores[i].codigo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(e.valores[i].color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (i < _c[e.id]!.length) ...[
                    const Text('desde'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 76,
                      child: TextField(
                        controller: _c[e.id]![i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          suffixText: '%',
                        ),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                    ),
                  ] else
                    Text(
                      'menos de ${_c[e.id]!.isEmpty ? 100 : _c[e.id]!.last.text} %',
                    ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      e.valores[i].descripcion,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 18),
        const Text(
          'Letras a número (para promedios)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cuando una columna calculada mezcla letras y números, cada letra '
          'vale esto sobre 20.',
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
        ),
        for (final e in widget.escalas) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < e.valores.length && i < _eq[e.id]!.length; i++)
                SizedBox(
                  width: e.valores[i].codigo.length > 3 ? 150 : 104,
                  child: TextField(
                    controller: _eq[e.id]![i],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixText: '${e.valores[i].codigo} = ',
                    ),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ),
            ],
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: _rojo)),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            TextButton(
              onPressed: _restablecer,
              child: const Text('Restablecer'),
            ),
            const Spacer(),
            FilledButton(onPressed: _guardar, child: const Text('Guardar')),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── Vista de lectura ─────────────────────────

/// Vista de solo lectura de un instrumento, con A− / A+. En pantallas
/// angostas la rúbrica se ve por criterio, en tarjetas.
class VistaInstrumento extends StatefulWidget {
  final Instrumento ins;
  const VistaInstrumento(this.ins, {super.key});

  @override
  State<VistaInstrumento> createState() => _VistaInstrumentoState();
}

class _VistaInstrumentoState extends State<VistaInstrumento> {
  double _zoom = 1;
  bool _clave = false;

  Instrumento get ins => widget.ins;

  @override
  Widget build(BuildContext context) {
    final z = _zoom;
    final comps = [
      for (final c in ins.competencias) ?competenciaPorId(c),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            KipuIcon(iconoDe(ins.tipo), color: KipuColores.morado, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                [ins.tipo.nombre, ...ins.niveles, if (ins.area.isNotEmpty) ins.area]
                    .join(' · ')
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  letterSpacing: .5,
                  fontWeight: FontWeight.w600,
                  color: KipuColores.morado,
                ),
              ),
            ),
            _BotonZoom(
              onMenos: _zoom > .8 ? () => setState(() => _zoom -= .1) : null,
              onMas: _zoom < 1.5 ? () => setState(() => _zoom += .1) : null,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          ins.nombre,
          style: TextStyle(fontSize: 20 * z, fontWeight: FontWeight.w700),
        ),
        for (final c in comps)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Competencia: ${c.nombre}',
              style: TextStyle(fontSize: 13 * z, color: KipuColores.moradoOscuro),
            ),
          ),
        if (ins.descripcion.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            ins.descripcion,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13.5 * z, color: KipuColores.gris, height: 1.4),
          ),
        ],
        const SizedBox(height: 14),
        switch (ins.tipo) {
          TipoInstrumento.rubrica => LayoutBuilder(
            builder: (context, c) => c.maxWidth < 600
                ? _RubricaTarjetas(ins: ins, zoom: z)
                : _RubricaTabla(ins: ins, zoom: z),
          ),
          TipoInstrumento.prueba => _VistaPrueba(
            ins: ins,
            zoom: z,
            clave: _clave,
            onClave: (v) => setState(() => _clave = v),
          ),
          _ => _VistaLista(ins: ins, zoom: z),
        },
      ],
    );
  }
}

class _BotonZoom extends StatelessWidget {
  final VoidCallback? onMenos;
  final VoidCallback? onMas;
  const _BotonZoom({this.onMenos, this.onMas});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: _linea),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Letra más chica',
          visualDensity: VisualDensity.compact,
          onPressed: onMenos,
          icon: const Text('A−', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        IconButton(
          tooltip: 'Letra más grande',
          visualDensity: VisualDensity.compact,
          onPressed: onMas,
          icon: const Text(
            'A+',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

class _RubricaTabla extends StatelessWidget {
  final Instrumento ins;
  final double zoom;
  const _RubricaTabla({required this.ins, required this.zoom});

  @override
  Widget build(BuildContext context) {
    final n = ins.escala.length;
    final suma = ins.items.fold<double>(0, (s, i) => s + ins.pesoDe(i));
    Widget celda(String t, {bool negrita = false, Color? color, bool centro = false}) =>
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            t,
            textAlign: centro ? TextAlign.center : TextAlign.justify,
            style: TextStyle(
              fontSize: 12.5 * zoom,
              height: 1.35,
              color: color,
              fontWeight: negrita ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = (c.maxWidth - 150 * zoom) / n;
        final col = ancho.clamp(130.0, 260.0).toDouble();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: FixedColumnWidth(col),
            columnWidths: {0: FixedColumnWidth(150 * zoom)},
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            border: TableBorder.symmetric(
              inside: const BorderSide(color: _linea),
              outside: const BorderSide(color: _linea),
            ),
            children: [
              TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: Container(
                      color: KipuColores.fondo,
                      child: celda('Criterio', negrita: true),
                    ),
                  ),
                  for (var k = 0; k < n; k++)
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.fill,
                      child: Container(
                        color: colorNivel(k, n).withValues(alpha: .12),
                        child: celda(
                          '${ins.escala[k].nombre}\n${numeroCorto(ins.escala[k].puntos)} pts',
                          negrita: true,
                          centro: true,
                          color: colorNivel(k, n),
                        ),
                      ),
                    ),
                ],
              ),
              for (final it in ins.items)
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.fill,
                      child: Container(
                      color: KipuColores.fondo.withValues(alpha: .6),
                      child: celda(
                        ins.ponderada && suma > 0
                            ? '${it.texto}\n${numeroCorto(ins.pesoDe(it) / suma * 100)} %'
                            : it.texto,
                        negrita: true,
                      ),
                    ),
                    ),
                    for (var k = 0; k < n; k++)
                      celda(k < it.descriptores.length ? it.descriptores[k] : ''),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RubricaTarjetas extends StatelessWidget {
  final Instrumento ins;
  final double zoom;
  const _RubricaTarjetas({required this.ins, required this.zoom});

  @override
  Widget build(BuildContext context) {
    final n = ins.escala.length;
    final suma = ins.items.fold<double>(0, (s, i) => s + ins.pesoDe(i));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, it) in ins.items.indexed)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: _linea),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${i + 1}. ${it.texto}',
                        style: TextStyle(
                          fontSize: 15 * zoom,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (ins.ponderada && suma > 0)
                      Text(
                        '${numeroCorto(ins.pesoDe(it) / suma * 100)} %',
                        style: TextStyle(
                          fontSize: 12.5 * zoom,
                          color: KipuColores.gris,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Del mejor nivel al más bajo.
                for (var k = n - 1; k >= 0; k--)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 92 * zoom,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorNivel(k, n).withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ins.escala[k].nombre,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5 * zoom,
                              fontWeight: FontWeight.w600,
                              color: colorNivel(k, n),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            k < it.descriptores.length ? it.descriptores[k] : '',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 13 * zoom, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VistaLista extends StatelessWidget {
  final Instrumento ins;
  final double zoom;
  const _VistaLista({required this.ins, required this.zoom});

  @override
  Widget build(BuildContext context) {
    final n = ins.escala.length;
    final cotejo = ins.tipo == TipoInstrumento.cotejo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var k = 0; k < n; k++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorNivel(k, n, ascendente: false).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cotejo
                      ? ins.escala[k].nombre
                      : '${ins.escala[k].nombre} · ${numeroCorto(ins.escala[k].puntos)}',
                  style: TextStyle(
                    fontSize: 12.5 * zoom,
                    fontWeight: FontWeight.w600,
                    color: colorNivel(k, n, ascendente: false),
                  ),
                ),
              ),
            if (ins.noObservado)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KipuColores.fondo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'No observado',
                  style: TextStyle(fontSize: 12.5 * zoom, color: KipuColores.gris),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final (k, it) in ins.items.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _linea)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28 * zoom,
                  child: Text(
                    '${k + 1}.',
                    style: TextStyle(
                      fontSize: 14 * zoom,
                      color: KipuColores.gris,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    it.texto,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 14 * zoom, height: 1.35),
                  ),
                ),
                if (ins.ponderada) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${numeroCorto(it.peso)} ${cotejo ? 'pts' : '×'}',
                    style: TextStyle(fontSize: 13 * zoom, color: KipuColores.gris),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _VistaPrueba extends StatelessWidget {
  final Instrumento ins;
  final double zoom;
  final bool clave;
  final ValueChanged<bool> onClave;
  const _VistaPrueba({
    required this.ins,
    required this.zoom,
    required this.clave,
    required this.onClave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Total: ${numeroCorto(ins.puntajeTotal)} puntos',
                style: TextStyle(fontSize: 14 * zoom, fontWeight: FontWeight.w600),
              ),
            ),
            const Text('Mostrar clave'),
            Switch(value: clave, onChanged: onClave),
          ],
        ),
        for (final (k, it) in ins.items.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _linea)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32 * zoom,
                  child: Text(
                    '${k + 1}.',
                    style: TextStyle(fontSize: 14 * zoom, color: KipuColores.gris),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.texto.isEmpty ? 'Pregunta ${k + 1}' : it.texto,
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 14 * zoom, height: 1.35),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        it.desarrollo
                            ? 'Desarrollo'
                            : '${it.letras.join('  ')}'
                                  '${clave && it.clave != null ? '   ·   Clave: ${it.letras[it.clave!]}' : ''}',
                        style: TextStyle(
                          fontSize: 12.5 * zoom,
                          color: clave && !it.desarrollo
                              ? KipuColores.moradoOscuro
                              : KipuColores.gris,
                          fontWeight: clave ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${numeroCorto(it.peso)} pts',
                  style: TextStyle(fontSize: 13 * zoom, color: KipuColores.gris),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
