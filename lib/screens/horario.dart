import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/ventana.dart';
import 'cursos.dart' show colorColegio;
import 'horario_datos.dart';
import 'horario_exportar.dart';

/// Horario semanal: una tabla por colegio con sus horas y recreos, y una
/// página «Todos mis colegios» que junta la semana día por día.
class PantallaHorario extends StatefulWidget {
  const PantallaHorario({super.key});

  @override
  State<PantallaHorario> createState() => _PantallaHorarioState();
}

class _PantallaHorarioState extends State<PantallaHorario> {
  final _colegios = db.verColegios();
  final _clases = db.verHorario();
  final _franjas = db.verFranjas();
  final _avisoAjuste = db.verAjuste('aviso_clase');

  /// 0 = todos mis colegios; 1.. = un colegio, en el orden de la lista.
  int _pagina = 0;

  /// Modo edición: muestra las casillas vacías con +, y deja cambiar las
  /// horas y agregar o quitar filas.
  bool _editando = false;
  late int _dia = DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday;
  DateTime _ahora = DateTime.now();
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    _reloj = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() => _ahora = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  String get _hora => hhmm(_ahora.hour * 60 + _ahora.minute);

  bool _esAhora(Horario h) =>
      h.dia == _ahora.weekday &&
      h.inicio.compareTo(_hora) <= 0 &&
      h.fin.compareTo(_hora) > 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Colegio>>(
      stream: _colegios,
      builder: (context, sc) => StreamBuilder<List<(Horario, CursoConColegio)>>(
        stream: _clases,
        builder: (context, sh) => StreamBuilder<List<Franja>>(
          stream: _franjas,
          builder: (context, sf) => StreamBuilder<String?>(
            stream: _avisoAjuste,
            builder: (context, sa) {
              if (!sc.hasData || !sh.hasData || !sf.hasData) {
                return const Scaffold(body: SizedBox.shrink());
              }
              return _pantalla(
                context,
                _Datos(
                  colegios: sc.data!,
                  clases: sh.data!,
                  franjas: sf.data!,
                  aviso: int.tryParse(sa.data ?? '') ?? 10,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _pantalla(BuildContext context, _Datos d) {
    final ancho = MediaQuery.sizeOf(context).width >= 900;
    if (d.colegios.isEmpty) {
      return Scaffold(
        appBar: ancho ? null : AppBar(title: const Text('Mi horario')),
        body: const _SinColegios(),
      );
    }
    if (_pagina > d.colegios.length) _pagina = 0;
    final colegio = _pagina == 0 ? null : d.colegios[_pagina - 1];
    final dias = diasVisibles(d.clases);
    if (!dias.contains(_dia)) _dia = 1;

    final banner = _Banner(
      datos: d,
      colegio: colegio,
      pagina: _pagina,
      compacto: !ancho,
      onCambiar: (p) => setState(() {
        _pagina = p;
        if (p == 0) _editando = false;
      }),
    );
    final menu = _Menu(onElegir: (o) => _menu(context, o, d, colegio));
    final filas = colegio == null
        ? const <FilaHorario>[]
        : filasDeColegio(colegio.id, d.franjas, d.clases);
    void editarFila(int i) => _editarFila(context, d, colegio!, filas, i);
    void agregarFila(bool recreo) =>
        _agregarFila(context, d, colegio!, filas, recreo);

    if (ancho) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mi horario',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            textoSemana(_ahora),
                            style: TextStyle(color: KipuColores.gris),
                          ),
                        ],
                      ),
                    ),
                    _BotonAviso(
                      minutos: d.aviso,
                      onTap: () => _recordatorios(context, d.aviso),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () => _alternarEdicion(context, d),
                      icon: KipuIcon(
                        _editando ? KipuIcono.check : KipuIcono.editar,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(_editando ? 'Listo' : 'Editar horario'),
                    ),
                    const SizedBox(width: 8),
                    menu,
                  ],
                ),
                const SizedBox(height: 16),
                banner,
                if (_editando) ...[
                  const SizedBox(height: 10),
                  const _AvisoEdicion(),
                ],
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: colegio == null
                        ? _SemanaTodos(
                            datos: d,
                            dias: dias,
                            ahora: _ahora,
                            esAhora: _esAhora,
                            onClase: (x) => _tocarClase(context, d, x),
                          )
                        : _TablaColegio(
                            datos: d,
                            colegio: colegio,
                            dias: dias,
                            ahora: _ahora,
                            esAhora: _esAhora,
                            onClase: (x) => _tocarClase(context, d, x),
                            onVacia: (dia, f) =>
                                _ponerEnVacia(context, d, colegio, dia, f),
                            editando: _editando,
                            onFila: editarFila,
                            onAgregarFila: agregarFila,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Celular: un día a la vez.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi horario'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: menu),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _alternarEdicion(context, d),
        icon: KipuIcon(
          _editando ? KipuIcono.check : KipuIcono.editar,
          color: Colors.white,
          size: 20,
        ),
        label: Text(_editando ? 'Listo' : 'Editar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          banner,
          if (_editando) ...[const SizedBox(height: 10), const _AvisoEdicion()],
          const SizedBox(height: 10),
          _DiasCelular(
            dias: dias,
            actual: _dia,
            hoy: _ahora,
            conClases: {
              for (final (h, c) in d.clases)
                if (colegio == null || c.colegio.id == colegio.id) h.dia,
            },
            onElegir: (x) => setState(() => _dia = x),
          ),
          const SizedBox(height: 12),
          if (colegio == null)
            _DiaTodos(
              datos: d,
              dia: _dia,
              esAhora: _esAhora,
              conHora: true,
              onClase: (x) => _tocarClase(context, d, x),
            )
          else
            _DiaColegio(
              datos: d,
              colegio: colegio,
              dia: _dia,
              esAhora: _esAhora,
              onClase: (x) => _tocarClase(context, d, x),
              onVacia: (f) => _ponerEnVacia(context, d, colegio, _dia, f),
              editando: _editando,
              onFila: editarFila,
              onAgregarFila: agregarFila,
            ),
        ],
      ),
    );
  }

  // Acciones

  Future<void> _alternarEdicion(BuildContext context, _Datos d) async {
    if (_editando) {
      setState(() => _editando = false);
      return;
    }
    if (_pagina == 0) {
      final c = await _elegirColegio(
        context,
        d.colegios,
        titulo: '¿Qué horario quieres editar?',
      );
      if (c == null) return;
      _pagina = d.colegios.indexWhere((x) => x.id == c.id) + 1;
    }
    setState(() => _editando = true);
  }

  /// Cambia la hora de una fila, la vuelve clase o recreo, o la quita.
  Future<void> _editarFila(
    BuildContext context,
    _Datos d,
    Colegio colegio,
    List<FilaHorario> filas,
    int i,
  ) async {
    final f = filas[i];
    final clases = f.recreo
        ? 0
        : d.clases
              .where(
                (x) => x.$2.colegio.id == colegio.id && x.$1.inicio == f.inicio,
              )
              .length;
    final r = await showDialog<(FilaHorario?,)>(
      context: context,
      builder: (_) => _VentanaFila(fila: f, clases: clases),
    );
    if (r == null) return;
    final nueva = r.$1;
    final lista = [...filas];
    if (nueva == null) {
      lista.removeAt(i);
    } else {
      lista[i] = nueva;
    }
    await _guardarFilas(colegio, lista, {
      for (final (j, x) in filas.indexed)
        if (!x.recreo)
          x.inicio: j != i
              ? (inicio: x.inicio, fin: x.fin)
              : (nueva == null || nueva.recreo)
              ? null
              : (inicio: nueva.inicio, fin: nueva.fin),
    });
  }

  Future<void> _agregarFila(
    BuildContext context,
    _Datos d,
    Colegio colegio,
    List<FilaHorario> filas,
    bool recreo,
  ) async {
    final inicio = filas.isEmpty ? '07:45' : filas.last.fin;
    final largo =
        filas
            .where((f) => !f.recreo)
            .map((f) => minutos(f.fin) - minutos(f.inicio))
            .lastOrNull ??
        45;
    final nueva = FilaHorario(
      inicio,
      hhmm(minutos(inicio) + (recreo ? 15 : largo)),
      recreo: recreo,
    );
    await _guardarFilas(colegio, [...filas, nueva], {});
  }

  Future<void> _guardarFilas(
    Colegio colegio,
    List<FilaHorario> filas,
    Map<String, ({String inicio, String fin})?> cambios,
  ) {
    filas.sort((a, b) => a.inicio.compareTo(b.inicio));
    return db.guardarFranjas(colegio.id, [
      for (final f in filas) (inicio: f.inicio, fin: f.fin, recreo: f.recreo),
    ], cambios);
  }

  void _menu(BuildContext context, String opcion, _Datos d, Colegio? colegio) {
    switch (opcion) {
      case 'franjas':
        if (colegio != null) {
          _horasYRecreos(context, d, colegio);
        } else {
          _elegirColegio(context, d.colegios).then((c) {
            if (c != null && context.mounted) _horasYRecreos(context, d, c);
          });
        }
      case 'clase':
        _agregarClase(context, d, colegio);
      case 'aviso':
        _recordatorios(context, d.aviso);
      case 'pdf':
        _descargar(d, colegio);
    }
  }

  Future<void> _descargar(_Datos d, Colegio? colegio) async {
    final docente = await db.leerAjuste('nombre') ?? '';
    final bytes = await pdfHorario(
      colegio: colegio,
      colegios: d.colegios,
      clases: d.clases,
      franjas: d.franjas,
      docente: docente,
      semana: textoSemana(DateTime.now()),
    );
    final nombre = colegio == null
        ? 'horario-todos-mis-colegios'
        : 'horario-${colegio.nombre}'.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9áéíóúñ]+'),
            '-',
          );
    await FilePicker.saveFile(
      fileName: '$nombre.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  Future<void> _ponerEnVacia(
    BuildContext context,
    _Datos d,
    Colegio colegio,
    int dia,
    FilaHorario f,
  ) async {
    final cursos = await db.verCursos().first;
    if (!context.mounted) return;
    final delColegio = [
      for (final c in cursos)
        if (c.colegio.id == colegio.id) c,
    ];
    if (delColegio.isEmpty) {
      _aviso(
        context,
        'Primero crea un curso de ${colegio.nombre} en Mis cursos.',
      );
      return;
    }
    final elegido = await _elegirCurso(
      context,
      delColegio,
      '${diasLargos[dia - 1]} · ${f.inicio} – ${f.fin}',
      colorColegio(d.colegios, colegio.id),
    );
    if (elegido == null) return;
    await db.ponerClase(elegido.curso.id, dia, f.inicio, f.fin);
  }

  Future<void> _tocarClase(
    BuildContext context,
    _Datos d,
    (Horario, CursoConColegio) x,
  ) async {
    final (h, c) = x;
    final color = colorColegio(d.colegios, c.colegio.id);
    final opcion = await ventanaCentrada<String>(
      context: context,
      ancho: 400,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.curso.nombre} · ${aula(c.curso)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${diasLargos[h.dia - 1]} ${h.inicio} – ${h.fin} · '
                        '${c.colegio.nombre}',
                        style: TextStyle(color: KipuColores.gris),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final (id, icono, texto) in [
            ('cambiar', KipuIcono.cursos, 'Cambiar de curso'),
            ('mover', KipuIcono.horario, 'Mover a otro día u hora'),
            ('quitar', KipuIcono.borrar, 'Quitar del horario'),
          ])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 22),
              leading: KipuIcon(
                icono,
                color: id == 'quitar'
                    ? const Color(0xFFD9475A)
                    : KipuColores.morado,
              ),
              title: Text(
                texto,
                style: TextStyle(
                  color: id == 'quitar' ? const Color(0xFFD9475A) : null,
                ),
              ),
              onTap: () => Navigator.pop(ctx, id),
            ),
        ],
      ),
    );
    if (opcion == null || !context.mounted) return;
    switch (opcion) {
      case 'quitar':
        await db.quitarClase(h.id);
      case 'mover':
        await _agregarClase(context, d, c.colegio, mover: x);
      case 'cambiar':
        final cursos = await db.verCursos().first;
        if (!context.mounted) return;
        final nuevo = await _elegirCurso(
          context,
          [
            for (final k in cursos)
              if (k.colegio.id == c.colegio.id) k,
          ],
          '${diasLargos[h.dia - 1]} · ${h.inicio} – ${h.fin}',
          color,
          actual: c.curso.id,
        );
        if (nuevo != null) {
          await db.ponerClase(
            nuevo.curso.id,
            h.dia,
            h.inicio,
            h.fin,
            reemplaza: h.id,
          );
        }
    }
  }

  Future<void> _agregarClase(
    BuildContext context,
    _Datos d,
    Colegio? colegio, {
    (Horario, CursoConColegio)? mover,
  }) async {
    final cursos = await db.verCursos().first;
    if (!context.mounted) return;
    if (cursos.isEmpty) {
      _aviso(context, 'Primero crea un curso en Mis cursos.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => _VentanaClase(
        datos: d,
        cursos: cursos,
        colegio: colegio ?? mover?.$2.colegio,
        dia: mover?.$1.dia ?? _dia,
        mover: mover,
      ),
    );
  }

  Future<void> _horasYRecreos(
    BuildContext context,
    _Datos d,
    Colegio colegio,
  ) => showDialog<void>(
    context: context,
    builder: (ctx) => _VentanaFranjas(
      colegio: colegio,
      filas: filasDeColegio(colegio.id, d.franjas, d.clases),
      clases: [
        for (final x in d.clases)
          if (x.$2.colegio.id == colegio.id) x.$1,
      ],
    ),
  );

  Future<void> _recordatorios(BuildContext context, int actual) =>
      showDialog<void>(
        context: context,
        builder: (ctx) => _VentanaAviso(actual: actual),
      );

  void _aviso(BuildContext context, String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
      );
}

Future<Colegio?> _elegirColegio(
  BuildContext context,
  List<Colegio> colegios, {
  String titulo = '¿De qué colegio?',
}) {
  if (colegios.length == 1) return Future.value(colegios.first);
  return ventanaCentrada<Colegio>(
    context: context,
    ancho: 400,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        for (final c in colegios)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 22),
            leading: CircleAvatar(
              radius: 8,
              backgroundColor: colorColegio(colegios, c.id),
            ),
            title: Text(c.nombre),
            subtitle: c.lugar == null ? null : Text(c.lugar!),
            onTap: () => Navigator.pop(ctx, c),
          ),
      ],
    ),
  );
}

Future<CursoConColegio?> _elegirCurso(
  BuildContext context,
  List<CursoConColegio> cursos,
  String cuando,
  Color color, {
  int? actual,
}) => ventanaCentrada<CursoConColegio>(
  context: context,
  ancho: 420,
  builder: (ctx) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué curso toca?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(cuando, style: TextStyle(color: KipuColores.gris)),
          ],
        ),
      ),
      for (final c in cursos)
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 22),
          selected: c.curso.id == actual,
          leading: Container(
            width: 44,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: claroDe(color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              aula(c.curso),
              style: TextStyle(
                color: oscuroDe(color),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          title: Text(c.curso.nombre),
          subtitle: Text(
            '${c.curso.grado} ${c.curso.seccion} · ${c.curso.nivel}',
          ),
          onTap: () => Navigator.pop(ctx, c),
        ),
    ],
  ),
);

class _Datos {
  final List<Colegio> colegios;
  final List<(Horario, CursoConColegio)> clases;
  final List<Franja> franjas;
  final int aviso;
  const _Datos({
    required this.colegios,
    required this.clases,
    required this.franjas,
    required this.aviso,
  });

  Color color(int colegioId) => colorColegio(colegios, colegioId);

  List<(Horario, CursoConColegio)> delDia(int dia, {int? colegioId}) => [
    for (final x in clases)
      if (x.$1.dia == dia &&
          (colegioId == null || x.$2.colegio.id == colegioId))
        x,
  ]..sort((a, b) => a.$1.inicio.compareTo(b.$1.inicio));
}

// Cabecera

class _BotonAviso extends StatelessWidget {
  final int minutos;
  final VoidCallback onTap;
  const _BotonAviso({required this.minutos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              KipuIcon(
                KipuIcono.campana,
                size: 20,
                color: minutos == 0 ? KipuColores.gris : KipuColores.morado,
              ),
              const SizedBox(width: 8),
              Text(
                minutos == 0 ? 'Sin avisos' : 'Aviso $minutos min antes',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final ValueChanged<String> onElegir;
  const _Menu({required this.onElegir});

  @override
  Widget build(BuildContext context) {
    PopupMenuItem<String> item(
      String id,
      KipuIcono icono,
      String titulo,
      String detalle,
    ) => PopupMenuItem(
      value: id,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: KipuColores.moradoClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: KipuIcon(icono, size: 19, color: KipuColores.morado),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                detalle,
                style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ],
          ),
        ],
      ),
    );
    return PopupMenuButton<String>(
      tooltip: 'Más opciones',
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: onElegir,
      itemBuilder: (_) => [
        item('clase', KipuIcono.agregar, 'Agregar clase', 'Curso, día y hora'),
        item(
          'franjas',
          KipuIcono.horario,
          'Horas y recreos',
          'De cada colegio',
        ),
        item(
          'aviso',
          KipuIcono.campana,
          'Recordatorios',
          'Antes de cada clase',
        ),
        const PopupMenuDivider(),
        item('pdf', KipuIcono.descargar, 'Descargar PDF', 'Lo que ves ahora'),
      ],
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.more_vert, color: KipuColores.gris),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final _Datos datos;
  final Colegio? colegio;
  final int pagina;
  final bool compacto;
  final ValueChanged<int> onCambiar;

  const _Banner({
    required this.datos,
    required this.colegio,
    required this.pagina,
    required this.compacto,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    final total = datos.colegios.length + 1;
    final c = colegio;
    final color = c == null ? KipuColores.morado : datos.color(c.id);
    final clases = [
      for (final x in datos.clases)
        if (c == null || x.$2.colegio.id == c.id) x.$1,
    ];
    final minTotal = clases.fold<int>(
      0,
      (s, h) => s + minutos(h.fin) - minutos(h.inicio),
    );
    final resumen =
        '${clases.length} ${clases.length == 1 ? 'clase' : 'clases'} por semana'
        '${minTotal > 0 ? ' · ${duracion(minTotal)}' : ''}';
    final titulo = c?.nombre ?? 'Todos mis colegios';
    final sub = c == null
        ? (compacto ? '${datos.colegios.length} colegios' : resumen)
        : compacto
        ? '${c.lugar ?? ''}${c.lugar == null ? '' : ' · '}$pagina de ${datos.colegios.length}'
        : '${c.lugar == null ? '' : '${c.lugar} · '}$resumen';

    Widget flecha(KipuIcono i, int destino, String tip) => Material(
      color: Colors.white.withValues(alpha: .2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onCambiar((destino + total) % total),
        child: Tooltip(
          message: tip,
          child: SizedBox(
            width: compacto ? 34 : 40,
            height: compacto ? 34 : 40,
            child: Center(
              child: KipuIcon(i, color: Colors.white, size: compacto ? 18 : 20),
            ),
          ),
        ),
      ),
    );

    final siguiente = pagina + 1 >= total
        ? 'Todos mis colegios'
        : datos.colegios[pagina].nombre;
    final anterior = pagina == 0
        ? datos.colegios.last.nombre
        : pagina == 1
        ? 'Todos mis colegios'
        : datos.colegios[pagina - 2].nombre;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 10 : 14,
        vertical: compacto ? 9 : 13,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compacto ? 16 : 20),
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, .14)!],
        ),
      ),
      child: Row(
        children: [
          flecha(KipuIcono.izquierda, pagina - 1, anterior),
          SizedBox(width: compacto ? 8 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: compacto
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compacto ? 17 : 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .85),
                    fontSize: compacto ? 12 : 13.5,
                  ),
                ),
              ],
            ),
          ),
          if (!compacto && c == null) ...[
            for (final k in datos.colegios)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: datos.color(k.id),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        k.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 18),
          ],
          if (!compacto) ...[
            for (var i = 0; i < total; i++)
              Container(
                width: i == pagina ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: i == pagina ? 1 : .4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            const SizedBox(width: 14),
          ] else
            const SizedBox(width: 8),
          flecha(KipuIcono.derecha, pagina + 1, siguiente),
        ],
      ),
    );
  }
}

// Tabla de un colegio (PC)

const _anchoHora = 82.0;

class _CabeceraDia extends StatelessWidget {
  final int dia;
  final DateTime hoy;
  const _CabeceraDia({required this.dia, required this.hoy});

  @override
  Widget build(BuildContext context) {
    final esHoy = hoy.weekday == dia;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: esHoy ? KipuColores.morado : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            diasLargos[dia - 1].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: .6,
              fontSize: 13.5,
              color: esHoy ? Colors.white : KipuColores.gris,
            ),
          ),
          Text(
            '${diaDelMes(hoy, dia)}',
            style: TextStyle(
              fontSize: 11.5,
              color: esHoy
                  ? Colors.white.withValues(alpha: .85)
                  : KipuColores.gris,
            ),
          ),
        ],
      ),
    );
  }
}

class _TablaColegio extends StatelessWidget {
  final _Datos datos;
  final Colegio colegio;
  final List<int> dias;
  final DateTime ahora;
  final bool Function(Horario) esAhora;
  final ValueChanged<(Horario, CursoConColegio)> onClase;
  final void Function(int dia, FilaHorario fila) onVacia;
  final bool editando;
  final ValueChanged<int> onFila;
  final ValueChanged<bool> onAgregarFila;

  const _TablaColegio({
    required this.datos,
    required this.colegio,
    required this.dias,
    required this.ahora,
    required this.esAhora,
    required this.onClase,
    required this.onVacia,
    required this.editando,
    required this.onFila,
    required this.onAgregarFila,
  });

  @override
  Widget build(BuildContext context) {
    final filas = filasDeColegio(colegio.id, datos.franjas, datos.clases);
    final color = datos.color(colegio.id);
    final clases = {
      for (final x in datos.clases)
        if (x.$2.colegio.id == colegio.id) (x.$1.dia, x.$1.inicio): x,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(width: _anchoHora),
            for (final d in dias)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: _CabeceraDia(dia: d, hoy: ahora),
                ),
              ),
          ],
        ),
        for (final (i, f) in filas.indexed)
          if (f.recreo)
            Row(
              children: [
                _Hora(fila: f, editando: editando, onTap: () => onFila(i)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: GestureDetector(
                      onTap: editando ? () => onFila(i) : null,
                      child: _Recreo(
                        texto:
                            'RECREO   ${f.inicio} – ${f.fin} · '
                            '${duracion(minutos(f.fin) - minutos(f.inicio))}',
                        alto: 30,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                _Hora(fila: f, editando: editando, onTap: () => onFila(i)),
                for (final d in dias)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: SizedBox(
                        height: 78,
                        child: switch (clases[(d, f.inicio)]) {
                          final x? => _CeldaClase(
                            curso: x.$2.curso,
                            color: color,
                            ahora: esAhora(x.$1),
                            onTap: () => onClase(x),
                          ),
                          null when editando => _CeldaVacia(
                            onTap: () => onVacia(d, f),
                          ),
                          null => DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
              ],
            ),
        if (editando)
          Padding(
            padding: const EdgeInsets.only(left: _anchoHora, top: 6),
            child: _BotonesFila(onAgregar: onAgregarFila),
          ),
      ],
    );
  }
}

/// Hora de una fila. Al editar se ve como botón para cambiarla.
class _Hora extends StatelessWidget {
  final FilaHorario fila;
  final bool editando;
  final VoidCallback onTap;
  final double ancho;
  final CrossAxisAlignment alinear;

  const _Hora({
    required this.fila,
    required this.editando,
    required this.onTap,
    this.ancho = _anchoHora,
    this.alinear = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final f = fila;
    final texto = Column(
      crossAxisAlignment: alinear,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          f.inicio,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: f.recreo ? 12 : 13.5,
            color: editando ? KipuColores.morado : KipuColores.gris,
          ),
        ),
        if (!f.recreo)
          Text(
            f.fin,
            style: TextStyle(
              fontSize: 11.5,
              color: editando
                  ? KipuColores.morado.withValues(alpha: .7)
                  : const Color(0xFFA3A1B3),
            ),
          ),
      ],
    );
    if (!editando) return SizedBox(width: ancho, child: texto);
    return SizedBox(
      width: ancho,
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: KipuColores.morado.withValues(alpha: .35)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  texto,
                  const SizedBox(width: 4),
                  KipuIcon(
                    KipuIcono.editar,
                    size: 13,
                    color: KipuColores.morado,
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

class _BotonesFila extends StatelessWidget {
  final ValueChanged<bool> onAgregar;
  const _BotonesFila({required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    Widget boton(String texto, bool recreo) => OutlinedButton.icon(
      onPressed: () => onAgregar(recreo),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide(color: KipuColores.morado.withValues(alpha: .45)),
        backgroundColor: Colors.white,
      ),
      icon: KipuIcon(KipuIcono.agregar, size: 18, color: KipuColores.morado),
      label: Text(texto),
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [boton('Fila de clase', false), boton('Recreo', true)],
    );
  }
}

class _AvisoEdicion extends StatelessWidget {
  const _AvisoEdicion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KipuColores.moradoClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          KipuIcon(KipuIcono.editar, size: 18, color: KipuColores.morado),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Editando: toca una hora para cambiarla o quitarla, una casilla + '
              'para poner una clase, y agrega filas abajo.',
              style: TextStyle(
                color: KipuColores.moradoOscuro,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cambiar una fila: sus horas, si es clase o recreo, o quitarla.
class _VentanaFila extends StatefulWidget {
  final FilaHorario fila;
  final int clases; // clases puestas en esta hora
  const _VentanaFila({required this.fila, required this.clases});

  @override
  State<_VentanaFila> createState() => _VentanaFilaState();
}

class _VentanaFilaState extends State<_VentanaFila> {
  late String _inicio = widget.fila.inicio;
  late String _fin = widget.fila.fin;
  late bool _recreo = widget.fila.recreo;

  Future<void> _hora(bool esInicio) async {
    final nuevo = await _pedirHora(
      context,
      esInicio ? _inicio : _fin,
      esInicio ? 'EMPIEZA' : 'TERMINA',
    );
    if (nuevo == null) return;
    setState(() {
      if (esInicio) {
        final largo = minutos(_fin) - minutos(_inicio);
        _inicio = nuevo;
        _fin = hhmm(minutos(nuevo) + (largo > 0 ? largo : 45));
      } else {
        _fin = nuevo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final valido = _fin.compareTo(_inicio) > 0;
    Widget hora(String etiqueta, String valor, bool esInicio) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: TextStyle(color: KipuColores.gris)),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: () => _hora(esInicio),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(
                color: !esInicio && !valido
                    ? const Color(0xFFD9475A)
                    : KipuColores.morado.withValues(alpha: .45),
              ),
            ),
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: KipuColores.tinta,
              ),
            ),
          ),
        ],
      ),
    );
    return Ventana(
      icono: KipuIcono.horario,
      titulo: 'Cambiar hora',
      subtitulo: _recreo ? 'Recreo' : 'Hora de clase',
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Clase')),
              ButtonSegment(value: true, label: Text('Recreo')),
            ],
            selected: {_recreo},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _recreo = v.first),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              hora('Empieza', _inicio, true),
              const SizedBox(width: 12),
              hora('Termina', _fin, false),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valido
                ? 'Dura ${duracion(minutos(_fin) - minutos(_inicio))}'
                : 'La hora de fin debe ser después del inicio.',
            style: TextStyle(
              fontSize: 13,
              color: valido ? KipuColores.gris : const Color(0xFFD9475A),
            ),
          ),
          if (widget.clases > 0 && _recreo)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                widget.clases == 1
                    ? 'La clase de esta hora se quitará del horario.'
                    : 'Las ${widget.clases} clases de esta hora se quitarán del horario.',
                style: const TextStyle(color: Color(0xFFD9475A), fontSize: 13),
              ),
            ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context, (null,)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD9475A),
              ),
              icon: const KipuIcon(
                KipuIcono.borrar,
                size: 18,
                color: Color(0xFFD9475A),
              ),
              label: Text(switch (widget.clases) {
                0 => 'Quitar esta fila',
                1 => 'Quitar esta fila y su clase',
                final n => 'Quitar esta fila y sus $n clases',
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: valido
                      ? () => Navigator.pop(context, (
                          FilaHorario(_inicio, _fin, recreo: _recreo),
                        ))
                      : null,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<String?> _pedirHora(
  BuildContext context,
  String actual,
  String titulo,
) async {
  final m = minutos(actual);
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
    initialEntryMode: TimePickerEntryMode.input,
    helpText: titulo,
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  return t == null ? null : hhmm(t.hour * 60 + t.minute);
}

class _CeldaClase extends StatelessWidget {
  final Curso curso;
  final Color color;
  final bool ahora;
  final VoidCallback onTap;
  const _CeldaClase({
    required this.curso,
    required this.color,
    required this.ahora,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final osc = oscuroDe(color);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Material(
            color: claroDe(color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: ahora
                  ? BorderSide(color: color, width: 2.5)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      curso.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: osc,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _Chip(texto: aula(curso), color: osc),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (ahora) const Positioned(top: -8, right: -3, child: _Ahora()),
      ],
    );
  }
}

class _CeldaVacia extends StatelessWidget {
  final VoidCallback onTap;
  const _CeldaVacia({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE1E2EC), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Center(
          child: KipuIcon(
            KipuIcono.agregar,
            size: 20,
            color: Color(0xFFC9C8D6),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color color;
  const _Chip({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Ahora extends StatelessWidget {
  const _Ahora();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFD9475A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Text(
      'AHORA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Franja rayada de recreo.
class _Recreo extends StatelessWidget {
  final String texto;
  final double alto;
  const _Recreo({required this.texto, required this.alto});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CustomPaint(
        painter: const _Rayas(),
        child: SizedBox(
          height: alto,
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                color: KipuColores.gris,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Rayas extends CustomPainter {
  const _Rayas();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEEF0FA),
    );
    final p = Paint()
      ..color = const Color(0xFFE3E5F3)
      ..strokeWidth = 6;
    for (var x = -size.height; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(_Rayas oldDelegate) => false;
}

// Todos mis colegios (PC): columnas por día

class _SemanaTodos extends StatelessWidget {
  final _Datos datos;
  final List<int> dias;
  final DateTime ahora;
  final bool Function(Horario) esAhora;
  final ValueChanged<(Horario, CursoConColegio)> onClase;

  const _SemanaTodos({
    required this.datos,
    required this.dias,
    required this.ahora,
    required this.esAhora,
    required this.onClase,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in dias)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CabeceraDia(dia: d, hoy: ahora),
                  const SizedBox(height: 6),
                  _DiaTodos(
                    datos: datos,
                    dia: d,
                    esAhora: esAhora,
                    conHora: false,
                    onClase: onClase,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Clases de un día de todos los colegios, en orden, con lo que hay entre una
/// y otra (recreo, hora libre o cambio de colegio).
class _DiaTodos extends StatelessWidget {
  final _Datos datos;
  final int dia;
  final bool Function(Horario) esAhora;
  final bool conHora; // en el celular: hora a la izquierda y total al final
  final ValueChanged<(Horario, CursoConColegio)> onClase;

  const _DiaTodos({
    required this.datos,
    required this.dia,
    required this.esAhora,
    required this.conHora,
    required this.onClase,
  });

  @override
  Widget build(BuildContext context) {
    final lista = datos.delDia(dia);
    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'Sin clases',
          textAlign: TextAlign.center,
          style: TextStyle(color: KipuColores.gris),
        ),
      );
    }
    final total = lista.fold<int>(
      0,
      (s, x) => s + minutos(x.$1.fin) - minutos(x.$1.inicio),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lista.length; i++) ...[
          _Tarjeta(
            clase: lista[i],
            color: datos.color(lista[i].$2.colegio.id),
            ahora: esAhora(lista[i].$1),
            onTap: () => onClase(lista[i]),
          ),
          if (i < lista.length - 1)
            _Separador(
              texto: entreClases(lista[i], lista[i + 1], datos.franjas),
              cambio: lista[i].$2.colegio.id != lista[i + 1].$2.colegio.id,
              cruce: lista[i + 1].$1.inicio.compareTo(lista[i].$1.fin) < 0,
            ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${lista.length} ${lista.length == 1 ? 'clase' : 'clases'} · '
            '${duracion(total)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: KipuColores.gris),
          ),
        ),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final (Horario, CursoConColegio) clase;
  final Color color;
  final bool ahora;
  final VoidCallback onTap;

  /// Sin la hora ni el colegio, cuando ya se ven al lado.
  final bool compacta;

  const _Tarjeta({
    required this.clase,
    required this.color,
    required this.ahora,
    required this.onTap,
    this.compacta = false,
  });

  @override
  Widget build(BuildContext context) {
    final (h, c) = clase;
    final osc = oscuroDe(color);
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        Material(
          color: claroDe(color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: ahora
                ? BorderSide(color: color, width: 2.5)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: compacta
                  ? const EdgeInsets.fromLTRB(14, 13, 10, 13)
                  : const EdgeInsets.fromLTRB(12, 10, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compacta) ...[
                    Text(
                      '${h.inicio} – ${h.fin}',
                      style: TextStyle(
                        color: osc,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        c.curso.nombre,
                        style: TextStyle(
                          color: osc,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _Chip(texto: aula(c.curso), color: osc),
                    ],
                  ),
                  if (!compacta) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            c.colegio.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: osc,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (ahora) const Positioned(top: -8, right: -3, child: _Ahora()),
      ],
    );
  }
}

class _Separador extends StatelessWidget {
  final String? texto;
  final bool cambio;
  final bool cruce;
  const _Separador({
    required this.texto,
    required this.cambio,
    required this.cruce,
  });

  @override
  Widget build(BuildContext context) {
    if (texto == null) return const SizedBox(height: 6);
    final fuerte = cambio || cruce;
    final color = cruce
        ? const Color(0xFFD9475A)
        : cambio
        ? const Color(0xFFC25A16)
        : const Color(0xFF8E8BA3);
    final linea = Expanded(
      child: Container(
        height: 1.5,
        color: cruce
            ? const Color(0xFFF3B5BE)
            : cambio
            ? const Color(0xFFF6C8A6)
            : const Color(0xFFDCDDEA),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          linea,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              texto!,
              style: TextStyle(
                fontSize: 11.5,
                color: color,
                fontWeight: fuerte ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          linea,
        ],
      ),
    );
  }
}

// Celular

class _DiasCelular extends StatelessWidget {
  final List<int> dias;
  final int actual;
  final DateTime hoy;
  final Set<int> conClases;
  final ValueChanged<int> onElegir;

  const _DiasCelular({
    required this.dias,
    required this.actual,
    required this.hoy,
    required this.conClases,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final d in dias)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: d == actual ? KipuColores.morado : Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onElegir(d),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          diasCortos[d - 1],
                          style: TextStyle(
                            fontSize: 12,
                            color: d == actual
                                ? Colors.white
                                : (d == hoy.weekday
                                      ? KipuColores.morado
                                      : KipuColores.gris),
                            fontWeight: d == hoy.weekday
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        Text(
                          '${diaDelMes(hoy, d)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: d == actual
                                ? Colors.white
                                : KipuColores.tinta,
                          ),
                        ),
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !conClases.contains(d)
                                ? Colors.transparent
                                : d == actual
                                ? Colors.white
                                : KipuColores.morado,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Un día de un colegio en el celular: sus horas, recreos y horas libres.
class _DiaColegio extends StatelessWidget {
  final _Datos datos;
  final Colegio colegio;
  final int dia;
  final bool Function(Horario) esAhora;
  final ValueChanged<(Horario, CursoConColegio)> onClase;
  final ValueChanged<FilaHorario> onVacia;
  final bool editando;
  final ValueChanged<int> onFila;
  final ValueChanged<bool> onAgregarFila;

  const _DiaColegio({
    required this.datos,
    required this.colegio,
    required this.dia,
    required this.esAhora,
    required this.onClase,
    required this.onVacia,
    required this.editando,
    required this.onFila,
    required this.onAgregarFila,
  });

  @override
  Widget build(BuildContext context) {
    final filas = filasDeColegio(colegio.id, datos.franjas, datos.clases);
    final color = datos.color(colegio.id);
    final clases = {
      for (final x in datos.delDia(dia, colegioId: colegio.id)) x.$1.inicio: x,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, f) in filas.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: editando
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: editando ? 0 : (f.recreo ? 6 : 12),
                  ),
                  child: _Hora(
                    fila: f,
                    editando: editando,
                    onTap: () => onFila(i),
                    ancho: editando ? 70 : 50,
                    alinear: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: f.recreo
                      ? GestureDetector(
                          onTap: editando ? () => onFila(i) : null,
                          child: const _Recreo(texto: 'RECREO', alto: 28),
                        )
                      : switch (clases[f.inicio]) {
                          final x? => _Tarjeta(
                            clase: x,
                            color: color,
                            ahora: esAhora(x.$1),
                            onTap: () => onClase(x),
                            compacta: true,
                          ),
                          null when editando => SizedBox(
                            height: 52,
                            child: Material(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: Color(0xFFDCDDEA),
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => onVacia(f),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      KipuIcon(
                                        KipuIcono.agregar,
                                        size: 16,
                                        color: KipuColores.morado,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Poner clase',
                                        style: TextStyle(
                                          color: KipuColores.morado,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          null => SizedBox(
                            height: 46,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, top: 12),
                              child: Text(
                                'Libre',
                                style: TextStyle(
                                  color: const Color(0xFFA3A1B3),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        },
                ),
              ],
            ),
          ),
        if (editando)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _BotonesFila(onAgregar: onAgregarFila),
          ),
      ],
    );
  }
}

class _SinColegios extends StatelessWidget {
  const _SinColegios();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KipuIcon(KipuIcono.horario, size: 56, color: KipuColores.morado),
            const SizedBox(height: 14),
            const Text(
              'Tu horario empieza con tus cursos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Crea tu colegio y tus cursos en Mis cursos, y luego ponlos aquí '
              'en su día y hora.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KipuColores.gris),
            ),
          ],
        ),
      ),
    );
  }
}

// Ventanas

/// Agregar una clase (o mover una que ya está).
class _VentanaClase extends StatefulWidget {
  final _Datos datos;
  final List<CursoConColegio> cursos;
  final Colegio? colegio;
  final int dia;
  final (Horario, CursoConColegio)? mover;

  const _VentanaClase({
    required this.datos,
    required this.cursos,
    required this.colegio,
    required this.dia,
    required this.mover,
  });

  @override
  State<_VentanaClase> createState() => _VentanaClaseState();
}

class _VentanaClaseState extends State<_VentanaClase> {
  late final _conCursos = [
    for (final c in widget.datos.colegios)
      if (widget.cursos.any((k) => k.colegio.id == c.id)) c,
  ];
  late Colegio _colegio = _conCursos.firstWhere(
    (c) => c.id == widget.colegio?.id,
    orElse: () => _conCursos.first,
  );
  late int? _curso = widget.mover?.$2.curso.id;
  late int _dia = widget.dia;
  late FilaHorario? _fila = widget.mover == null
      ? null
      : FilaHorario(widget.mover!.$1.inicio, widget.mover!.$1.fin);

  Widget _titulo(String t, {bool primero = false}) => Padding(
    padding: EdgeInsets.only(top: primero ? 0 : 16, bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  ChoiceChip _opcion(
    String texto,
    bool elegido,
    VoidCallback onTap, {
    Color? color,
    String? detalle,
  }) => ChoiceChip(
    label: detalle == null
        ? Text(texto)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(texto),
              Text(
                detalle,
                style: TextStyle(
                  fontSize: 11,
                  color: elegido
                      ? Colors.white.withValues(alpha: .8)
                      : KipuColores.gris,
                ),
              ),
            ],
          ),
    selected: elegido,
    showCheckmark: false,
    onSelected: (_) => onTap(),
    selectedColor: color ?? KipuColores.morado,
    backgroundColor: Colors.white,
    side: BorderSide(
      color: elegido ? Colors.transparent : const Color(0xFFDCDDEA),
    ),
    labelStyle: TextStyle(
      color: elegido ? Colors.white : KipuColores.tinta,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    final d = widget.datos;
    final color = d.color(_colegio.id);
    final cursos = [
      for (final c in widget.cursos)
        if (c.colegio.id == _colegio.id) c,
    ];
    final filas = [
      for (final f in filasDeColegio(_colegio.id, d.franjas, d.clases))
        if (!f.recreo) f,
    ];
    final ocupadas = {
      for (final x in d.delDia(_dia, colegioId: _colegio.id))
        if (x.$1.id != widget.mover?.$1.id) x.$1.inicio: x.$2.curso,
    };
    final listo =
        _curso != null &&
        _fila != null &&
        cursos.any((c) => c.curso.id == _curso);

    return Ventana(
      icono: KipuIcono.horario,
      titulo: widget.mover == null ? 'Agregar clase' : 'Mover clase',
      subtitulo: 'Elige el curso, el día y la hora',
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_conCursos.length > 1 && widget.mover == null) ...[
            _titulo('Colegio', primero: true),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _conCursos)
                  _opcion(
                    c.nombre,
                    c.id == _colegio.id,
                    () => setState(() {
                      _colegio = c;
                      _curso = null;
                      _fila = null;
                    }),
                    color: d.color(c.id),
                  ),
              ],
            ),
          ],
          _titulo(
            'Curso',
            primero: _conCursos.length <= 1 || widget.mover != null,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in cursos)
                _opcion(
                  '${c.curso.nombre} ${aula(c.curso)}',
                  c.curso.id == _curso,
                  () => setState(() => _curso = c.curso.id),
                  color: color,
                ),
            ],
          ),
          _titulo('Día'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 1; i <= 6; i++)
                _opcion(
                  diasCortos[i - 1],
                  i == _dia,
                  () => setState(() => _dia = i),
                ),
            ],
          ),
          _titulo('Hora'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in filas)
                _opcion(
                  '${f.inicio} – ${f.fin}',
                  f.inicio == _fila?.inicio,
                  () => setState(() => _fila = f),
                  detalle: switch (ocupadas[f.inicio]) {
                    final c? => 'Ahora: ${c.nombre} ${aula(c)}',
                    null => 'Libre',
                  },
                ),
            ],
          ),
          if (_fila != null && ocupadas[_fila!.inicio] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Esta hora ya tiene una clase; la nueva la reemplaza.',
                style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ),
          if (_fila != null)
            if (cruceCon(
                  d.clases,
                  _colegio.id,
                  _dia,
                  _fila!.inicio,
                  _fila!.fin,
                  sinContar: widget.mover?.$1.id,
                )
                case (final h, final c))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Ojo: se cruza con ${c.curso.nombre} ${aula(c.curso)} de '
                  '${c.colegio.nombre} (${h.inicio} – ${h.fin}).',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFD9475A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: !listo
                      ? null
                      : () async {
                          await db.ponerClase(
                            _curso!,
                            _dia,
                            _fila!.inicio,
                            _fila!.fin,
                            reemplaza: widget.mover?.$1.id,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaEditable {
  final String? origen; // hora de inicio que tenía al abrir (solo clases)
  String inicio;
  String fin;
  bool recreo;
  _FilaEditable(this.origen, this.inicio, this.fin, this.recreo);
}

/// Horas de clase y recreos de un colegio.
class _VentanaFranjas extends StatefulWidget {
  final Colegio colegio;
  final List<FilaHorario> filas;
  final List<Horario> clases;

  const _VentanaFranjas({
    required this.colegio,
    required this.filas,
    required this.clases,
  });

  @override
  State<_VentanaFranjas> createState() => _VentanaFranjasState();
}

class _VentanaFranjasState extends State<_VentanaFranjas> {
  late final _filas = [
    for (final f in widget.filas)
      _FilaEditable(f.recreo ? null : f.inicio, f.inicio, f.fin, f.recreo),
  ];

  Future<void> _hora(_FilaEditable f, bool esInicio) async {
    final actual = minutos(esInicio ? f.inicio : f.fin);
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: actual ~/ 60, minute: actual % 60),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: esInicio ? 'EMPIEZA' : 'TERMINA',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t == null) return;
    setState(() {
      final nuevo = hhmm(t.hour * 60 + t.minute);
      if (esInicio) {
        final largo = minutos(f.fin) - minutos(f.inicio);
        f.inicio = nuevo;
        f.fin = hhmm(minutos(nuevo) + (largo > 0 ? largo : 45));
      } else {
        f.fin = nuevo;
      }
    });
  }

  void _agregar(bool recreo) {
    setState(() {
      final ultimo = _filas.isEmpty ? null : _filas.last;
      final inicio = ultimo?.fin ?? '07:45';
      final largoClase =
          _filas
              .where((f) => !f.recreo)
              .map((f) => minutos(f.fin) - minutos(f.inicio))
              .lastOrNull ??
          45;
      _filas.add(
        _FilaEditable(
          null,
          inicio,
          hhmm(minutos(inicio) + (recreo ? 15 : largoClase)),
          recreo,
        ),
      );
    });
  }

  int _clasesEn(String? inicio) => inicio == null
      ? 0
      : widget.clases.where((h) => h.inicio == inicio).length;

  @override
  Widget build(BuildContext context) {
    final errores = _filas.any((f) => f.fin.compareTo(f.inicio) <= 0);
    final quitadas = [
      for (final f in widget.filas)
        if (!f.recreo && !_filas.any((x) => x.origen == f.inicio && !x.recreo))
          f.inicio,
    ].fold<int>(0, (s, i) => s + _clasesEn(i));

    Widget botonHora(_FilaEditable f, bool esInicio) => OutlinedButton(
      onPressed: () => _hora(f, esInicio),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: const Size(0, 40),
        side: BorderSide(
          color: !esInicio && f.fin.compareTo(f.inicio) <= 0
              ? const Color(0xFFD9475A)
              : const Color(0xFFDCDDEA),
        ),
      ),
      child: Text(
        esInicio ? f.inicio : f.fin,
        style: TextStyle(color: KipuColores.tinta, fontWeight: FontWeight.w600),
      ),
    );

    return Ventana(
      icono: KipuIcono.horario,
      titulo: 'Horas y recreos',
      subtitulo: widget.colegio.nombre,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cada colegio tiene sus propias horas. Las clases que ya pusiste '
            'se mueven con su hora.',
            style: TextStyle(color: KipuColores.gris, fontSize: 13.5),
          ),
          const SizedBox(height: 12),
          for (final f in _filas)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                decoration: BoxDecoration(
                  color: f.recreo ? const Color(0xFFF1F2F8) : Colors.white,
                  border: Border.all(color: const Color(0xFFE6E7F0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: PopupMenuButton<bool>(
                        tooltip: 'Clase o recreo',
                        initialValue: f.recreo,
                        onSelected: (v) => setState(() => f.recreo = v),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: false, child: Text('Clase')),
                          PopupMenuItem(value: true, child: Text('Recreo')),
                        ],
                        child: Row(
                          children: [
                            Text(
                              f.recreo ? 'Recreo' : 'Clase',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: f.recreo
                                    ? KipuColores.gris
                                    : KipuColores.morado,
                              ),
                            ),
                            KipuIcon(
                              KipuIcono.abajo,
                              size: 16,
                              color: KipuColores.gris,
                            ),
                          ],
                        ),
                      ),
                    ),
                    botonHora(f, true),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('–'),
                    ),
                    botonHora(f, false),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Quitar',
                      onPressed: () => setState(() => _filas.remove(f)),
                      icon: KipuIcon(
                        KipuIcono.borrar,
                        size: 19,
                        color: KipuColores.gris,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _agregar(false),
                icon: KipuIcon(
                  KipuIcono.agregar,
                  size: 18,
                  color: KipuColores.morado,
                ),
                label: const Text('Hora de clase'),
              ),
              TextButton.icon(
                onPressed: () => _agregar(true),
                icon: KipuIcon(
                  KipuIcono.agregar,
                  size: 18,
                  color: KipuColores.morado,
                ),
                label: const Text('Recreo'),
              ),
            ],
          ),
          if (quitadas > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                quitadas == 1
                    ? 'Se quitará 1 clase que estaba en una hora que borraste.'
                    : 'Se quitarán $quitadas clases que estaban en horas que borraste.',
                style: const TextStyle(color: Color(0xFFD9475A), fontSize: 13),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: errores || _filas.isEmpty
                      ? null
                      : () async {
                          final cambios =
                              <String, ({String inicio, String fin})?>{};
                          for (final f in widget.filas) {
                            if (f.recreo) continue;
                            final x = _filas
                                .where((x) => x.origen == f.inicio && !x.recreo)
                                .firstOrNull;
                            cambios[f.inicio] = x == null
                                ? null
                                : (inicio: x.inicio, fin: x.fin);
                          }
                          final ordenadas = [..._filas]
                            ..sort((a, b) => a.inicio.compareTo(b.inicio));
                          await db.guardarFranjas(widget.colegio.id, [
                            for (final f in ordenadas)
                              (inicio: f.inicio, fin: f.fin, recreo: f.recreo),
                          ], cambios);
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VentanaAviso extends StatefulWidget {
  final int actual;
  const _VentanaAviso({required this.actual});

  @override
  State<_VentanaAviso> createState() => _VentanaAvisoState();
}

class _VentanaAvisoState extends State<_VentanaAviso> {
  late int _min = widget.actual;

  @override
  Widget build(BuildContext context) {
    return Ventana(
      icono: KipuIcono.campana,
      titulo: 'Recordatorios',
      subtitulo: 'Un aviso antes de cada clase',
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Cuánto antes te aviso?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in [0, 5, 10, 15, 30])
                ChoiceChip(
                  label: Text(m == 0 ? 'Sin aviso' : '$m min'),
                  selected: _min == m,
                  showCheckmark: false,
                  selectedColor: KipuColores.morado,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _min == m
                        ? Colors.transparent
                        : const Color(0xFFDCDDEA),
                  ),
                  labelStyle: TextStyle(
                    color: _min == m ? Colors.white : KipuColores.tinta,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (_) => setState(() => _min = m),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Kipu te muestra el aviso con el curso, el aula y el colegio '
            'mientras tienes la app abierta.',
            style: TextStyle(color: KipuColores.gris, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await db.guardarAjuste('aviso_clase', '$_min');
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
