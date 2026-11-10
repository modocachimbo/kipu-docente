import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/academico.dart';
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
  TipoInstrumento.rubrica => KipuIcono.ficha,
  TipoInstrumento.cotejo => KipuIcono.check,
  TipoInstrumento.escala => KipuIcono.promedio,
  TipoInstrumento.prueba => KipuIcono.apuntes,
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

/// Sección «Evaluación»: biblioteca del docente y dos colecciones de
/// ejemplos (CNEB para colegios públicos y libre para privados).
class PantallaEvaluacion extends StatefulWidget {
  const PantallaEvaluacion({super.key});

  @override
  State<PantallaEvaluacion> createState() => _PantallaEvaluacionState();
}

class _PantallaEvaluacionState extends State<PantallaEvaluacion> {
  late final Stream<List<Instrumento>> _biblioteca;
  late final Stream<Map<int, String>> _gestiones = db.verGestiones();
  _Vista _vista = _Vista.mios;
  TipoInstrumento? _tipo;
  String? _nivel;
  String? _area;
  String _buscar = '';

  @override
  void initState() {
    super.initState();
    _biblioteca = Stream.fromFuture(
      db.prepararBiblioteca(),
    ).asyncExpand((_) => db.verBiblioteca());
  }

  List<Instrumento> _coleccion(_Vista v, List<Instrumento>? mios) =>
      switch (v) {
        _Vista.mios => mios ?? const [],
        _Vista.cneb => coleccionCneb,
        _Vista.libre => ejemplosInstrumentos,
      };

  bool _pasa(Instrumento i, {bool conArea = true}) {
    final q = normalizar(_buscar);
    return (_tipo == null || i.tipo == _tipo) &&
        (_nivel == null || i.niveles.isEmpty || i.niveles.contains(_nivel)) &&
        (!conArea || _area == null || i.area == _area) &&
        (q.isEmpty ||
            normalizar(
              '${i.nombre} ${i.area} ${i.descripcion} '
              '${i.competencias.map((c) => competenciaPorId(c)?.nombre ?? '').join(' ')} '
              '${i.items.map((x) => x.texto).join(' ')}',
            ).contains(q));
  }

  void _aviso(String t, {SnackBarAction? accion}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t), action: accion));
  }

  Future<void> _editar(Instrumento ins, {bool nuevo = false}) async {
    final r = await Navigator.push<Instrumento>(
      context,
      MaterialPageRoute(
        builder: (_) => EditorInstrumento(inicial: ins, nuevo: nuevo),
      ),
    );
    if (r == null) return;
    await db.guardarInstrumento(r);
    _aviso(nuevo ? '«${r.nombre}» está en tu biblioteca' : 'Cambios guardados');
  }

  Future<void> _duplicar(Instrumento ins) async {
    final copia = duplicar(ins, nombre: '${ins.nombre} (copia)');
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

  Future<void> _agregar(List<Instrumento> lista, Set<String> agregados) async {
    final nuevos = [
      for (final e in lista)
        if (!agregados.contains(e.id)) duplicar(e, ejemplo: true),
    ];
    if (nuevos.isEmpty) {
      _aviso('Ya están en tu biblioteca');
      return;
    }
    for (final n in nuevos.reversed) {
      await db.guardarInstrumento(n);
    }
    _aviso(
      nuevos.length == 1
          ? '«${nuevos.first.nombre}» se agregó a tu biblioteca'
          : 'Se agregaron ${nuevos.length} instrumentos a tu biblioteca',
      accion: nuevos.length == 1
          ? SnackBarAction(
              label: 'Editar',
              onPressed: () => _editar(nuevos.first),
            )
          : SnackBarAction(
              label: 'Ver',
              onPressed: () => setState(() => _vista = _Vista.mios),
            ),
    );
  }

  Future<void> _descargar(Instrumento ins, {bool plantilla = false}) async {
    try {
      await FilePicker.saveFile(
        fileName: plantilla
            ? 'plantilla-${ins.tipo.nombre.toLowerCase().replaceAll(' ', '-').replaceAll('ú', 'u').replaceAll('á', 'a').replaceAll('ó', 'o')}.xlsx'
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

  Future<void> _subir() async {
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
    if (mounted) await _editar(l.instrumento!, nuevo: true);
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
    if (v == 'subir') return _subir();
    if (v == 'cneb') return setState(() => _vista = _Vista.cneb);
    if (v == 'libre') return setState(() => _vista = _Vista.libre);
    final partes = v.split(':');
    final t = TipoInstrumento.values.byName(partes[1]);
    if (partes[0] == 'nuevo') return _editar(Instrumento.nuevo(t), nuevo: true);
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
                  onPressed: agregado ? null : () => Navigator.pop(ctx, 'agregar'),
                  child: Text(agregado ? 'Ya está en tu biblioteca' : 'Agregar a mi biblioteca'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación'),
        actions: [
          TextButton.icon(
            onPressed: () => editarTramos(context),
            icon: KipuIcon(KipuIcono.ajustes, size: 20, color: KipuColores.morado),
            label: const Text('Conversión'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crear,
        icon: const KipuIcon(KipuIcono.agregar, color: Colors.white),
        label: const Text('Crear'),
      ),
      body: StreamBuilder<Map<int, String>>(
        stream: _gestiones,
        builder: (context, g) => StreamBuilder<List<Instrumento>>(
          stream: _biblioteca,
          builder: (context, snap) => _cuerpo(snap.data, g.data ?? const {}),
        ),
      ),
    );
  }

  Widget _cuerpo(List<Instrumento>? mios, Map<int, String> gestiones) {
    // Si todos los colegios son privados, la colección libre va primero.
    final privado =
        gestiones.isNotEmpty &&
        gestiones.values.every((v) => v == gestionPrivada);
    final pestanas = [
      _Vista.mios,
      if (privado) ...[_Vista.libre, _Vista.cneb] else ...[_Vista.cneb, _Vista.libre],
    ];
    final agregados = {for (final m in mios ?? const <Instrumento>[]) m.origen};
    final base = _coleccion(_vista, mios);
    final areas = <String>{
      for (final i in base)
        if (_pasa(i, conArea: false)) i.area,
    }.toList()..sort(_compararAreas);
    final lista = base.where(_pasa).toList();
    final grupos = <String, List<Instrumento>>{};
    for (final i in lista) {
      (grupos[i.area] ??= []).add(i);
    }
    final claves = grupos.keys.toList()..sort(_compararAreas);
    final coleccion = _vista != _Vista.mios;
    final filtrando =
        _tipo != null || _nivel != null || _area != null || _buscar.isNotEmpty;
    final abrir = !coleccion || claves.length <= 2 || _buscar.isNotEmpty || _area != null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            _Pestanas(
              pestanas: [
                for (final p in pestanas)
                  (
                    p,
                    switch (p) {
                      _Vista.mios => 'Mi biblioteca${mios == null ? '' : ' · ${mios.length}'}',
                      _Vista.cneb => 'CNEB · Estatal',
                      _Vista.libre => 'Libre · Privado',
                    },
                  ),
              ],
              actual: _vista,
              onCambio: (v) => setState(() {
                _vista = v;
                _area = null;
              }),
            ),
            const SizedBox(height: 12),
            if (coleccion)
              _Aviso(
                _vista == _Vista.cneb
                    ? 'Dos instrumentos por competencia del Currículo Nacional, '
                          'por nivel y área. Sirven con letras (AD, A, B, C) o con '
                          'números (0 a 20): la columna del registro decide.'
                    : 'Instrumentos y exámenes para el día a día, sin depender del '
                          'CNEB. Sirven con números (0 a 20) o con letras.',
              ),
            _Filtros(
              tipo: _tipo,
              nivel: _nivel,
              area: _area,
              areas: areas,
              onTipo: (t) => setState(() => _tipo = t),
              onNivel: (n) => setState(() {
                _nivel = n;
                _area = null;
              }),
              onArea: (a) => setState(() => _area = a),
              onBuscar: (t) => setState(() => _buscar = t),
            ),
            const SizedBox(height: 12),
            if (_vista == _Vista.mios && mios == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (lista.isEmpty)
              _Vacio(
                coleccion: coleccion,
                filtrando: filtrando,
                onEjemplos: () => setState(() => _vista = pestanas[1]),
                onCrear: _crear,
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  '${lista.length} ${lista.length == 1 ? 'instrumento' : 'instrumentos'}'
                  '${claves.length > 1 ? ' en ${claves.length} áreas' : ''}',
                  style: const TextStyle(fontSize: 13, color: KipuColores.gris),
                ),
              ),
              for (final a in claves)
                _Grupo(
                  key: ValueKey('${_vista.name}-$a-$abrir'),
                  titulo: a.isEmpty ? 'Sin área' : a,
                  cantidad: grupos[a]!.length,
                  abierto: abrir,
                  accion: coleccion
                      ? TextButton(
                          onPressed: grupos[a]!.every((e) => agregados.contains(e.id))
                              ? null
                              : () => _agregar(grupos[a]!, agregados),
                          child: const Text('Agregar todos'),
                        )
                      : null,
                  hijos: [
                    for (final ins in grupos[a]!)
                      _TarjetaInstrumento(
                        ins: ins,
                        coleccion: coleccion,
                        agregado: agregados.contains(ins.id),
                        onTap: coleccion
                            ? () => _verDeColeccion(ins, agregados.contains(ins.id))
                            : () => _editar(ins),
                        onAgregar: () => _agregar([ins], agregados),
                        onAccion: (accion) {
                          switch (accion) {
                            case 'editar':
                              _editar(ins);
                            case 'duplicar':
                              _duplicar(ins);
                            case 'excel':
                              _descargar(ins);
                            case 'pdf':
                              _pdf(ins);
                            case 'eliminar':
                              _eliminar(ins, (mios ?? const []).indexOf(ins));
                          }
                        },
                      ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
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

class _Filtros extends StatelessWidget {
  final TipoInstrumento? tipo;
  final String? nivel;
  final String? area;
  final List<String> areas;
  final ValueChanged<TipoInstrumento?> onTipo;
  final ValueChanged<String?> onNivel;
  final ValueChanged<String?> onArea;
  final ValueChanged<String> onBuscar;
  const _Filtros({
    required this.tipo,
    required this.nivel,
    required this.area,
    required this.areas,
    required this.onTipo,
    required this.onNivel,
    required this.onArea,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String t, bool on, VoidCallback tap) => Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(t),
        selected: on,
        showCheckmark: false,
        selectedColor: KipuColores.moradoClaro,
        backgroundColor: Colors.white,
        side: BorderSide(color: on ? KipuColores.morado : _linea),
        labelStyle: TextStyle(
          color: on ? KipuColores.moradoOscuro : KipuColores.tinta,
          fontWeight: on ? FontWeight.w600 : FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => tap(),
      ),
    );
    Widget fila(String etiqueta, List<Widget> hijos) => Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: .4,
              fontWeight: FontWeight.w600,
              color: KipuColores.gris,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: hijos),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fila('NIVEL', [
          chip('Todos', nivel == null, () => onNivel(null)),
          for (final n in nivelesEducativos)
            chip(n, nivel == n, () => onNivel(n)),
        ]),
        const SizedBox(height: 4),
        fila('TIPO', [
          chip('Todos', tipo == null, () => onTipo(null)),
          for (final t in TipoInstrumento.values)
            chip(t.plural, tipo == t, () => onTipo(t)),
        ]),
        if (areas.length > 1) ...[
          const SizedBox(height: 4),
          fila('ÁREA', [
            chip('Todas', area == null, () => onArea(null)),
            for (final a in areas)
              chip(a.isEmpty ? 'Sin área' : a, area == a, () => onArea(a)),
          ]),
        ],
        const SizedBox(height: 10),
        TextField(
          onChanged: onBuscar,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, competencia o ítem',
            isDense: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: KipuIcon(KipuIcono.buscar, size: 20, color: KipuColores.gris),
            ),
          ),
        ),
      ],
    );
  }
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
          children: [
            for (final h in hijos)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: h),
          ],
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  final bool coleccion;
  final bool filtrando;
  final VoidCallback onEjemplos;
  final VoidCallback onCrear;
  const _Vacio({
    required this.coleccion,
    required this.filtrando,
    required this.onEjemplos,
    required this.onCrear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
      child: Column(
        children: [
          KipuIcon(KipuIcono.ficha, size: 56, color: KipuColores.morado),
          const SizedBox(height: 12),
          Text(
            filtrando
                ? 'Nada coincide con esos filtros'
                : 'Tu biblioteca está vacía',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            filtrando
                ? 'Prueba con «Todos» en nivel, tipo o área.'
                : 'Agrega instrumentos de una colección o crea uno desde cero.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: KipuColores.gris),
          ),
          if (!filtrando && !coleccion) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onEjemplos,
                  child: const Text('Ver colecciones'),
                ),
                FilledButton(onPressed: onCrear, child: const Text('Crear')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaInstrumento extends StatelessWidget {
  final Instrumento ins;
  final bool coleccion;
  final bool agregado;
  final VoidCallback onTap;
  final VoidCallback onAgregar;
  final ValueChanged<String> onAccion;
  const _TarjetaInstrumento({
    required this.ins,
    required this.coleccion,
    required this.agregado,
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
      ...ins.niveles,
      if (ins.noObservado) 'No observado',
      if (ins.ponderada &&
          ins.tipo != TipoInstrumento.rubrica &&
          ins.tipo != TipoInstrumento.prueba)
        'Ponderada',
      if (!coleccion && ins.ejemplo) 'De la colección',
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
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => Ventana(
      icono: KipuIcono.ajustes,
      titulo: 'Conversión a notas',
      subtitulo: 'Del % logrado a la escala del registro',
      contenido: _Tramos(escalas: letras, actuales: actuales, config: config),
    ),
  );
}

class _Tramos extends StatefulWidget {
  final List<Escala> escalas;
  final Map<String, List<double>> actuales;
  final ConfigAcademica config;
  const _Tramos({
    required this.escalas,
    required this.actuales,
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
  String? _error;

  @override
  void dispose() {
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
    for (final x in nuevos.entries) {
      await db.guardarTramos(x.key, x.value);
    }
    if (mounted) Navigator.pop(context);
  }

  void _restablecer() => setState(() {
    for (final e in widget.escalas) {
      final d = tramosPorDefecto(e);
      for (var i = 0; i < d.length; i++) {
        _c[e.id]![i].text = d[i].round().toString();
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
        if (_error != null) ...[
          const SizedBox(height: 4),
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
