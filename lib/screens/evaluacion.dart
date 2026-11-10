import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/academico.dart';
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

const _mimeExcel =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

KipuIcono iconoDe(TipoInstrumento t) => switch (t) {
  TipoInstrumento.rubrica => KipuIcono.ficha,
  TipoInstrumento.cotejo => KipuIcono.check,
  TipoInstrumento.escala => KipuIcono.promedio,
};

/// Sección «Evaluación»: biblioteca de instrumentos del docente y ejemplos.
class PantallaEvaluacion extends StatefulWidget {
  const PantallaEvaluacion({super.key});

  @override
  State<PantallaEvaluacion> createState() => _PantallaEvaluacionState();
}

class _PantallaEvaluacionState extends State<PantallaEvaluacion> {
  late final Stream<List<Instrumento>> _biblioteca;
  bool _ejemplos = false;
  TipoInstrumento? _tipo;
  String? _nivel;
  String _buscar = '';

  @override
  void initState() {
    super.initState();
    _biblioteca = Stream.fromFuture(
      db.prepararBiblioteca(),
    ).asyncExpand((_) => db.verBiblioteca());
  }

  bool _pasa(Instrumento i) {
    final q = normalizar(_buscar);
    return (_tipo == null || i.tipo == _tipo) &&
        (_nivel == null || i.niveles.isEmpty || i.niveles.contains(_nivel)) &&
        (q.isEmpty ||
            normalizar(
              '${i.nombre} ${i.area} ${i.descripcion} '
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
    await db.guardarInstrumento(r.copiar(ejemplo: nuevo ? false : r.ejemplo));
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

  Future<void> _agregarEjemplo(Instrumento e) async {
    final copia = duplicar(e, ejemplo: true);
    await db.guardarInstrumento(copia);
    _aviso(
      '«${e.nombre}» se agregó a tu biblioteca',
      accion: SnackBarAction(label: 'Editar', onPressed: () => _editar(copia)),
    );
  }

  Future<void> _descargar(Instrumento ins, {bool plantilla = false}) async {
    try {
      await FilePicker.saveFile(
        fileName: plantilla
            ? 'plantilla-${nombreArchivo(ins).replaceFirst(RegExp(r'-mi-.*'), '')}.xlsx'
            : nombreArchivo(ins),
        bytes: excelDeInstrumento(ins),
        mimeType: _mimeExcel,
      );
    } catch (_) {
      _aviso('No se pudo guardar el archivo. Inténtalo de nuevo.');
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
                        color: error
                            ? const Color(0xFFC2334A)
                            : KipuColores.morado,
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
                'Plantilla de ${t.nombre.toLowerCase()}',
                'Descárgala, llénala en la computadora y súbela',
              ),
            titulo('O PARTE DE UN EJEMPLO'),
            opcion(
              'ejemplos',
              KipuIcono.libro,
              'Ver ${ejemplosInstrumentos.length} ejemplos',
              'Para Inicial, Primaria y Secundaria; los adaptas a tu aula',
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
    if (v == null || !mounted) return;
    if (v == 'subir') return _subir();
    if (v == 'ejemplos') return setState(() => _ejemplos = true);
    final partes = v.split(':');
    final t = TipoInstrumento.values.byName(partes[1]);
    if (partes[0] == 'nuevo') return _editar(Instrumento.nuevo(t), nuevo: true);
    return _descargar(plantillaDe(t), plantilla: true);
  }

  Future<void> _verEjemplo(Instrumento e) async {
    final agregar = await ventanaCentrada<bool>(
      context: context,
      ancho: 640,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VistaInstrumento(e),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Agregar a mi biblioteca'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (agregar == true) await _agregarEjemplo(e);
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
      body: StreamBuilder<List<Instrumento>>(
        stream: _biblioteca,
        builder: (context, snap) {
          final mios = snap.data;
          final lista = _ejemplos
              ? ejemplosInstrumentos.where(_pasa).toList()
              : (mios ?? const <Instrumento>[]).where(_pasa).toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                children: [
                  const Text(
                    'Rúbricas, listas de cotejo y escalas de valoración para '
                    'usar en el registro. Crea las tuyas, parte de un ejemplo '
                    'o súbelas desde Excel.',
                    style: TextStyle(color: KipuColores.gris),
                  ),
                  const SizedBox(height: 14),
                  _Pestanas(
                    ejemplos: _ejemplos,
                    mios: mios?.length,
                    onCambio: (v) => setState(() => _ejemplos = v),
                  ),
                  const SizedBox(height: 12),
                  _Filtros(
                    tipo: _tipo,
                    nivel: _nivel,
                    onTipo: (t) => setState(() => _tipo = t),
                    onNivel: (n) => setState(() => _nivel = n),
                    onBuscar: (t) => setState(() => _buscar = t),
                  ),
                  const SizedBox(height: 12),
                  if (!_ejemplos && mios == null)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (lista.isEmpty)
                    _Vacio(
                      ejemplos: _ejemplos,
                      filtrando:
                          _tipo != null || _nivel != null || _buscar.isNotEmpty,
                      onEjemplos: () => setState(() => _ejemplos = true),
                      onCrear: _crear,
                    )
                  else
                    for (final ins in lista)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaInstrumento(
                          ins: ins,
                          ejemplo: _ejemplos,
                          onTap: _ejemplos
                              ? () => _verEjemplo(ins)
                              : () => _editar(ins),
                          onAgregar: () => _agregarEjemplo(ins),
                          onAccion: (a) {
                            switch (a) {
                              case 'editar':
                                _editar(ins);
                              case 'duplicar':
                                _duplicar(ins);
                              case 'excel':
                                _descargar(ins);
                              case 'eliminar':
                                _eliminar(ins, (mios ?? const []).indexOf(ins));
                            }
                          },
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Pestanas extends StatelessWidget {
  final bool ejemplos;
  final int? mios;
  final ValueChanged<bool> onCambio;
  const _Pestanas({
    required this.ejemplos,
    required this.mios,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    Widget boton(String t, bool activo, VoidCallback tap) => Expanded(
      child: Material(
        color: activo ? KipuColores.morado : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Center(
              child: Text(
                t,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : KipuColores.tinta,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          boton(
            mios == null ? 'Mi biblioteca' : 'Mi biblioteca · $mios',
            !ejemplos,
            () => onCambio(false),
          ),
          boton(
            'Ejemplos · ${ejemplosInstrumentos.length}',
            ejemplos,
            () => onCambio(true),
          ),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final TipoInstrumento? tipo;
  final String? nivel;
  final ValueChanged<TipoInstrumento?> onTipo;
  final ValueChanged<String?> onNivel;
  final ValueChanged<String> onBuscar;
  const _Filtros({
    required this.tipo,
    required this.nivel,
    required this.onTipo,
    required this.onNivel,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String t, bool on, VoidCallback tap) => ChoiceChip(
      label: Text(t),
      selected: on,
      showCheckmark: false,
      selectedColor: KipuColores.moradoClaro,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: on ? KipuColores.morado : const Color(0xFFE6E7F0),
      ),
      labelStyle: TextStyle(
        color: on ? KipuColores.moradoOscuro : KipuColores.tinta,
        fontWeight: on ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => tap(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              chip('Todos', tipo == null, () => onTipo(null)),
              for (final t in TipoInstrumento.values) ...[
                const SizedBox(width: 6),
                chip(t.plural, tipo == t, () => onTipo(t)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              chip('Todo nivel', nivel == null, () => onNivel(null)),
              for (final n in nivelesEducativos) ...[
                const SizedBox(width: 6),
                chip(n, nivel == n, () => onNivel(n)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: onBuscar,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, área o ítem',
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

class _Vacio extends StatelessWidget {
  final bool ejemplos;
  final bool filtrando;
  final VoidCallback onEjemplos;
  final VoidCallback onCrear;
  const _Vacio({
    required this.ejemplos,
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
                ? 'Prueba con «Todos» o «Todo nivel».'
                : 'Empieza con un ejemplo y adáptalo, o crea uno desde cero.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: KipuColores.gris),
          ),
          if (!filtrando && !ejemplos) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onEjemplos,
                  child: const Text('Ver ejemplos'),
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
  final bool ejemplo;
  final VoidCallback onTap;
  final VoidCallback onAgregar;
  final ValueChanged<String> onAccion;
  const _TarjetaInstrumento({
    required this.ins,
    required this.ejemplo,
    required this.onTap,
    required this.onAgregar,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final etiquetas = [
      ...ins.niveles,
      if (ins.area.isNotEmpty) ins.area,
      if (ins.noObservado) 'No observado',
      if (ins.ponderada && ins.tipo != TipoInstrumento.rubrica) 'Ponderada',
      if (!ejemplo && ins.ejemplo) 'Ejemplo',
    ];
    return Card(
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ins.tipo.nombre} · ${ins.resumen}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: KipuColores.gris,
                      ),
                    ),
                    if (ejemplo && ins.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ins.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
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
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (ejemplo)
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: FilledButton.tonal(
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
          'Se usa en listas de cotejo y cuando el instrumento no tiene tantos '
          'niveles como la escala. Una rúbrica de 4 niveles pasa a AD, A, B, C '
          'por su nivel promedio. En escalas numéricas: puntos ÷ máximo × nota '
          'máxima.',
          style: TextStyle(fontSize: 13, color: KipuColores.gris),
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
          Text(_error!, style: const TextStyle(color: Color(0xFFC2334A))),
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

/// Vista de solo lectura de un instrumento (ejemplos y vista previa).
class VistaInstrumento extends StatelessWidget {
  final Instrumento ins;
  const VistaInstrumento(this.ins, {super.key});

  @override
  Widget build(BuildContext context) {
    final rubrica = ins.tipo == TipoInstrumento.rubrica;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KipuIcon(iconoDe(ins.tipo), color: KipuColores.morado),
            const SizedBox(width: 8),
            Text(
              ins.tipo.nombre.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: .6,
                fontWeight: FontWeight.w600,
                color: KipuColores.morado,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          ins.nombre,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (ins.descripcion.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(ins.descripcion, style: const TextStyle(color: KipuColores.gris)),
        ],
        const SizedBox(height: 14),
        if (rubrica)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(150),
              columnWidths: const {0: FixedColumnWidth(130)},
              border: TableBorder.all(
                color: const Color(0xFFE6E7F0),
                borderRadius: BorderRadius.circular(10),
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: KipuColores.moradoClaro),
                  children: [
                    const _CeldaTexto('Criterio', negrita: true),
                    for (final n in ins.escala)
                      _CeldaTexto(
                        '${n.nombre} · ${numeroCorto(n.puntos)}',
                        negrita: true,
                      ),
                  ],
                ),
                for (final it in ins.items)
                  TableRow(
                    children: [
                      _CeldaTexto(
                        ins.ponderada
                            ? '${it.texto} (${numeroCorto(it.peso)} %)'
                            : it.texto,
                        negrita: true,
                      ),
                      for (var k = 0; k < ins.escala.length; k++)
                        _CeldaTexto(
                          k < it.descriptores.length ? it.descriptores[k] : '',
                        ),
                    ],
                  ),
              ],
            ),
          )
        else ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final n in ins.escala)
                Chip(
                  label: Text('${n.nombre} · ${numeroCorto(n.puntos)}'),
                  visualDensity: VisualDensity.compact,
                ),
              if (ins.noObservado)
                const Chip(
                  label: Text('No observado'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final (k, it) in ins.items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${k + 1}.',
                      style: const TextStyle(color: KipuColores.gris),
                    ),
                  ),
                  Expanded(child: Text(it.texto)),
                  if (ins.ponderada)
                    Text(
                      '${numeroCorto(it.peso)} pts',
                      style: const TextStyle(color: KipuColores.gris),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _CeldaTexto extends StatelessWidget {
  final String texto;
  final bool negrita;
  const _CeldaTexto(this.texto, {this.negrita = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: negrita ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

String numeroCorto(double n) => n == n.roundToDouble()
    ? n.round().toString()
    : n.toStringAsFixed(1).replaceAll('.', ',');
