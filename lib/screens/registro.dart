import 'dart:convert' show jsonEncode;
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import '../data/academico.dart';
import '../data/calculo.dart' show Calculo, TipoCalculo, validarFormula;
import '../data/cneb.dart';
import '../data/columnas.dart';
import '../data/columnas_db.dart';
import '../data/database.dart';
import '../data/evaluacion_db.dart';
import '../data/instrumentos.dart';
import '../data/paises.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'asistencia.dart';
import 'cursos.dart' show colorColegio, confirmar;
import 'estudiantes.dart';
import 'calculo_form.dart' show EditorCalculo, mostrarDesglose;
import 'evaluacion.dart' show iconoDe, PantallaEvaluacion;
import 'ficha_estudiante.dart';
import 'instrumento_editor.dart' show evaluarConInstrumento;
import 'registro_exportar.dart';
import 'shell.dart' show MenuCajon;

const _rojo = Color(0xFFC2334A);
const _verde = Color(0xFF0E7A5F);
const _linea = Color(0xFFEDEEF5);

/// Registro auxiliar libre de un curso: estudiantes con nombres fijos a la
/// izquierda y columnas que el docente crea en el orden que quiera.
class RegistroCurso extends StatefulWidget {
  final CursoConColegio datos;
  const RegistroCurso({super.key, required this.datos});

  @override
  State<RegistroCurso> createState() => _RegistroCursoState();
}

class _RegistroCursoState extends State<RegistroCurso> {
  int get _cursoId => widget.datos.curso.id;
  final _hoy = claveFecha(DateTime.now());
  int _periodo = 1;
  String _buscar = '';

  late final _colegios = db.verColegios();
  late final _estudiantes = db.verEstudiantes(_cursoId);
  late final _colores = db.verColoresRegistro(_cursoId);
  late final _grupos = db.verGruposEquipos(_cursoId);
  late final _conducta = db.verConductaDelDia(_cursoId, _hoy);
  late final _asistencia = db.verAsistencia(_cursoId, _hoy);
  late final _config = db.verAnioActivo().asyncExpand(db.verConfigAcademica);
  late final _instrumentos = db.verInstrumentosDeColumnas();
  late final _gestion = db.verGestion(widget.datos.colegio.id);
  late final _configsCol = db.verConfigsColumnas();
  late final _comentarios = db.verComentariosNotas();

  /// Lo último que se usó para recalcular asistencia y participación; si
  /// cambia (otro periodo, nuevas marcas de hoy…), se vuelve a calcular.
  String _firmaAuto = '';
  late Stream<List<RegistroColumna>> _columnas;
  late Stream<Map<int, Map<int, String>>> _notas;

  @override
  void initState() {
    super.initState();
    _abrirPeriodo(1);
    db.periodoRegistro(_cursoId).then((p) {
      if (mounted && p != _periodo) setState(() => _abrirPeriodo(p));
    });
  }

  void _abrirPeriodo(int p) {
    _periodo = p;
    _columnas = db.verColumnas(_cursoId, p);
    _notas = db.verNotasRegistro(_cursoId, p);
  }

  void _cambiarPeriodo(int p) {
    setState(() => _abrirPeriodo(p));
    db.guardarPeriodoRegistro(_cursoId, p);
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width >= 900;
    return _Escucha<List<Colegio>>(
      _colegios,
      (colegios) => _Escucha<Map<String, dynamic>?>(_colores, (propios) {
        var colores = ColoresRegistro.delColegio(
          colegios == null
              ? KipuColores.morado
              : colorColegio(colegios, widget.datos.colegio.id),
        );
        if (propios != null) colores = colores.con(propios);
        return _Escucha<ConfigAcademica>(
          _config,
          (config) => _Escucha<List<Estudiante>>(
            _estudiantes,
            (estudiantes) => _Escucha<List<RegistroColumna>>(
              _columnas,
              (columnas) => _Escucha<Map<int, Map<int, String>>>(
                _notas,
                (notas) => _Escucha<Map<int, (int, int)>>(
                  _conducta,
                  (conducta) => _Escucha<List<GrupoEquipos>>(
                    _grupos,
                    (grupos) => _Escucha<Map<int, String>>(
                      _asistencia,
                      (asistencia) => _Escucha<Map<int, Instrumento>>(
                        _instrumentos,
                        (instrumentos) => _Escucha<String>(
                        _gestion,
                        (gestion) => _Escucha<Map<int, ConfigColumna>>(
                        _configsCol,
                        (configs) => _Escucha<Map<int, Map<int, String>>>(
                        _comentarios,
                        (comentarios) => _pantalla(
                        context,
                        comentarios: comentarios ?? const {},
                        configs: configs ?? const {},
                        gestion: gestion ?? gestionPublica,
                        instrumentos: instrumentos ?? const {},
                        ancho: ancho,
                        colores: colores,
                        config: config,
                        estudiantes: estudiantes,
                        columnas: columnas ?? const [],
                        notas: notas ?? const {},
                        conducta: conducta ?? const {},
                        grupos: grupos ?? const [],
                        asistencia: asistencia ?? const {},
                      ),
                      ),
                      ),
                      ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _pantalla(
    BuildContext context, {
    required bool ancho,
    required ColoresRegistro colores,
    required ConfigAcademica? config,
    required List<Estudiante>? estudiantes,
    required List<RegistroColumna> columnas,
    required Map<int, Map<int, String>> notas,
    required Map<int, (int, int)> conducta,
    required List<GrupoEquipos> grupos,
    required Map<int, String> asistencia,
    required Map<int, Instrumento> instrumentos,
    required String gestion,
    required Map<int, ConfigColumna> configs,
    required Map<int, Map<int, String>> comentarios,
  }) {
    final cur = widget.datos.curso;
    final periodos = config?.periodos ?? periodosDe('bimestre');
    final escalas = {for (final e in config?.escalas ?? peru.escalas) e.id: e};
    // En colegios privados se propone la escala de 0 a 20; el docente puede
    // elegir otra en cada columna.
    final escalaDefecto =
        gestion == gestionPrivada && escalas.containsKey('vigesimal')
        ? 'vigesimal'
        : config?.escalaPorDefecto ?? peru.escalas.first.id;
    final delPeriodo =
        (estudiantes ?? const <Estudiante>[])
            .where((e) => estaEnPeriodo(e, _periodo))
            .toList()
          ..sort((a, b) => claveOrden(a).compareTo(claveOrden(b)));
    final lista = delPeriodo
        .where(
          (e) =>
              _buscar.isEmpty ||
              '${e.apellidos} ${e.nombres}'.toLowerCase().contains(
                _buscar.toLowerCase(),
              ),
        )
        .toList();
    final total = delPeriodo.length;
    String nombrePeriodo(int p) => p >= 1 && p <= periodos.length
        ? periodos[p - 1].nombre
        : '$p.° periodo';
    final presentes = asistencia.values.where((v) => v == 'P' || v == 'T');

    Escala? escalaDe(RegistroColumna c) =>
        tieneEscala(c.tipo) ? escalas[c.escala ?? escalaDefecto] : null;
    // Escala de letras para mostrar «16 · A» en columnas numéricas.
    final letras = escalas.values
        .where((e) => !e.numerica && e.valores.length > 2)
        .firstOrNull;

    // Asistencia y participación se recalculan solas.
    // Las calculadas también: se recalculan cuando cambia cualquier nota.
    final autos = columnas
        .where((c) => esAutomatica(c.tipo) || c.tipo == 'calculada')
        .toList();
    final acad = config;
    if (acad != null && autos.isNotEmpty) {
      final hayCalculadas = autos.any((c) => c.tipo == 'calculada');
      final firma = [
        _periodo,
        for (final c in autos) '${c.id}:${c.escala}:${configs[c.id]?.aTexto()}',
        if (hayCalculadas) identityHashCode(notas),
        asistencia.entries.map((e) => '${e.key}${e.value}').join(),
        conducta.entries.map((e) => '${e.key}${e.value}').join(),
        estudiantes?.length,
      ].join('|');
      if (firma != _firmaAuto) {
        _firmaAuto = firma;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => db.actualizarAutomaticas(
            cursoId: _cursoId,
            periodo: _periodo,
            config: acad,
          ),
        );
      }
    }

    void nuevaColumna() => _formColumna(
      context,
      cursoId: _cursoId,
      periodo: _periodo,
      escalas: escalas.values.toList(),
      escalaDefecto: escalaDefecto,
      colores: colores,
      columnas: columnas,
      grupos: grupos,
    );

    Future<void> accion(String v) => _accionRegistro(
      context,
      v,
      datos: widget.datos,
      periodo: _periodo,
      periodos: periodos,
      colores: colores,
      estudiantes: delPeriodo,
      grupos: grupos,
      nuevaColumna: nuevaColumna,
    );

    final cabecera = _Cabecera(
      ancho: ancho,
      titulo: '${cur.nombre} · ${_gradoCorto(cur)}',
      subtitulo:
          '${widget.datos.colegio.nombre} · ${cur.nivel} · $total estudiantes',
      colores: colores,
      periodos: periodos,
      periodo: _periodo.clamp(1, periodos.length),
      onPeriodo: _cambiarPeriodo,
      asistencia: asistencia.isEmpty
          ? 'Hoy · sin pasar'
          : 'Hoy · ${presentes.length} de $total',
      onAsistencia: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text('Asistencia · ${cur.nombre}')),
            body: PasarLista(datos: widget.datos),
          ),
        ),
      ),
      onBuscar: (t) => setState(() => _buscar = t),
      onNuevaColumna: nuevaColumna,
      onDescargar: () => _descargarRegistro(
        context,
        datos: widget.datos,
        periodo: _periodo.clamp(1, periodos.length),
        periodos: periodos,
        estudiantes: estudiantes ?? const [],
        colores: colores,
        escalaDe: escalaDe,
      ),
    );

    Widget cuerpo;
    if (estudiantes == null) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (delPeriodo.isEmpty) {
      cuerpo = _SinEstudiantes(
        colores: colores,
        periodo: nombrePeriodo(_periodo),
        onAccion: accion,
      );
    } else {
      cuerpo = _Tabla(
        key: ValueKey(_periodo),
        ancho: ancho,
        estudiantes: lista,
        columnas: columnas,
        notas: notas,
        conducta: conducta,
        colores: colores,
        escalaDe: escalaDe,
        instrumentos: instrumentos,
        configs: configs,
        letras: letras,
        comentarios: comentarios,
        onNueva: nuevaColumna,
        onEstudiante: (e) => abrirFicha(
          context,
          datos: widget.datos,
          estudiante: e,
          periodo: _periodo,
          periodos: periodos,
          color: colores.base,
          escalaDe: escalaDe,
          onAnotar: (e) => _anotarConducta(context, e, colores),
        ),
        onConducta: (e) => _anotarConducta(context, e, colores),
        onColumna: (c) => _menuColumna(
          context,
          c,
          columnas,
          config: configs[c.id] ?? const ConfigColumna(),
          grupos: grupos,
          estudiantes: lista,
          colores: colores,
          escalas: escalas.values.toList(),
          escalaDefecto: escalaDefecto,
        ),
        onCelda: (e, c) {
          final cfg = configs[c.id] ?? const ConfigColumna();
          void aviso(String t, [SnackBarAction? a]) =>
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(t), action: a));
          if (c.tipo == 'calculada') {
            mostrarDesglose(
              context,
              columna: c,
              estudiante: e,
              escala: escalaDe(c) ?? escalas.values.first,
              cfg: cfg,
              actual: notas[c.id]?[e.id],
              base: colores.calculadas,
            );
            return;
          }
          if (esAutomatica(c.tipo)) {
            aviso(
              c.tipo == 'asistencia'
                  ? 'Esta nota se calcula sola con la asistencia del periodo: '
                        'presente y tarde cuentan, la falta baja el % y la '
                        'justificada no cuenta.'
                  : 'Esta nota se calcula sola con las participaciones (+) y '
                        '(−) del periodo. Con ${cfg.meta} (+) llega a la nota '
                        'máxima.',
            );
            return;
          }
          if (cfg.bloqueada) {
            aviso(
              'La columna ${c.codigo} está bloqueada.',
              SnackBarAction(
                label: 'Desbloquear',
                onPressed: () => db.guardarConfigColumna(
                  c.id,
                  cfg.copiar(bloqueada: false),
                ),
              ),
            );
            return;
          }
          final ins = instrumentos[c.id];
          if (ins != null) {
            evaluarConInstrumento(
              context,
              columna: c,
              instrumento: ins,
              escala: escalaDe(c) ?? escalas.values.first,
              estudiantes: lista,
              inicio: lista.indexOf(e),
              equipos: grupoDe(grupos, c)?.equipos ?? const {},
              color: colores.calculadas,
              decimales: cfg.decimales,
              redondeo: cfg.redondeo,
            );
            return;
          }
          _ponerNota(
            context,
            columna: c,
            escala: escalaDe(c) ?? escalas.values.first,
            estudiantes: lista,
            inicio: lista.indexOf(e),
            notas: notas[c.id] ?? const {},
            equipos: grupoDe(grupos, c)?.equipos ?? const {},
            colores: colores,
            config: cfg,
          );
        },
      );
    }

    return Scaffold(
      drawer: const MenuCajon(),
      backgroundColor: KipuColores.fondo,
      floatingActionButton: _BotonMas(
        colores: colores,
        sinEstudiantes: total == 0,
        onAccion: accion,
      ),
      body: SafeArea(
        child: Column(
          children: [
            cabecera,
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ancho ? 20 : 10,
                  0,
                  ancho ? 20 : 10,
                  ancho ? 20 : 10,
                ),
                child: cuerpo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "3.° año" + "B" → "3.° B".
String _gradoCorto(Curso c) {
  final g = c.grado.split(' ').first;
  return c.seccion == 'Única' ? g : '$g ${c.seccion}';
}

class _Escucha<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(T? dato) builder;
  const _Escucha(this.stream, this.builder);

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
    stream: stream,
    builder: (context, snap) => builder(snap.data),
  );
}

// ───────────────────────── Cabecera de la pantalla ─────────────────────────

class _Cabecera extends StatelessWidget {
  final bool ancho;
  final String titulo;
  final String subtitulo;
  final ColoresRegistro colores;
  final List<Periodo> periodos;
  final int periodo;
  final ValueChanged<int> onPeriodo;
  final String asistencia;
  final VoidCallback onAsistencia;
  final ValueChanged<String> onBuscar;
  final VoidCallback onNuevaColumna;

  final VoidCallback onDescargar;

  const _Cabecera({
    required this.ancho,
    required this.titulo,
    required this.subtitulo,
    required this.colores,
    required this.periodos,
    required this.periodo,
    required this.onPeriodo,
    required this.asistencia,
    required this.onAsistencia,
    required this.onBuscar,
    required this.onNuevaColumna,
    required this.onDescargar,
  });

  @override
  Widget build(BuildContext context) {
    final boton = Builder(
      builder: (ctx) => _BotonBlanco(
        tam: ancho ? 46 : 40,
        tooltip: 'Menú',
        onTap: () => Scaffold.of(ctx).openDrawer(),
        child: const KipuIcon(KipuIcono.menu, color: KipuColores.tinta),
      ),
    );
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: ancho ? 12 : 10,
              height: ancho ? 12 : 10,
              decoration: BoxDecoration(
                color: colores.calculadas,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: ancho ? 10 : 8),
            Flexible(
              child: Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ancho ? 24 : 17,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        Text(
          subtitulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ancho ? 13.5 : 12,
            color: KipuColores.gris,
          ),
        ),
      ],
    );
    final periodosW = _Periodos(
      periodos: periodos,
      elegido: periodo,
      onTap: onPeriodo,
      corto: !ancho,
    );

    if (ancho) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Row(
          children: [
            boton,
            Container(
              width: 1,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFFDADBE8),
            ),
            Expanded(child: textos),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: _Buscador(onBuscar)),
            const SizedBox(width: 12),
            periodosW,
            const SizedBox(width: 12),
            _BotonAsistencia(
              detalle: asistencia,
              color: colores.calculadas,
              onTap: onAsistencia,
            ),
            const SizedBox(width: 12),
            _BotonDescargar(color: colores.calculadas, onTap: onDescargar),
            const SizedBox(width: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colores.calculadas,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
              onPressed: onNuevaColumna,
              icon: const KipuIcon(
                KipuIcono.columna,
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Nueva columna'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              boton,
              const SizedBox(width: 10),
              Expanded(child: textos),
              const SizedBox(width: 8),
              Builder(
                builder: (ctx) => Tooltip(
                  message: 'Descargar registro',
                  child: Material(
                    color: colores.calculadas,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onDescargar,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: KipuIcon(
                            KipuIcono.descargar,
                            size: 21,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(child: periodosW),
              const SizedBox(width: 8),
              _BotonAsistencia(
                detalle: null,
                color: colores.calculadas,
                onTap: onAsistencia,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonBlanco extends StatelessWidget {
  final double tam;
  final String tooltip;
  final VoidCallback onTap;
  final Widget child;
  const _BotonBlanco({
    required this.tam,
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: tam,
          height: tam,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class _Buscador extends StatelessWidget {
  final ValueChanged<String> onBuscar;
  const _Buscador(this.onBuscar);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: TextField(
      onChanged: onBuscar,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar estudiante',
        hintStyle: const TextStyle(color: Color(0xFFA3A1B3), fontSize: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 6),
          child: KipuIcon(KipuIcono.buscar, size: 19, color: KipuColores.gris),
        ),
        prefixIconConstraints: const BoxConstraints(),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

class _Periodos extends StatelessWidget {
  final List<Periodo> periodos;
  final int elegido;
  final ValueChanged<int> onTap;
  final bool corto;
  const _Periodos({
    required this.periodos,
    required this.elegido,
    required this.onTap,
    required this.corto,
  });

  @override
  Widget build(BuildContext context) {
    String nombre(int i) {
      final n = periodos[i - 1].nombre;
      if (i != elegido) return n.split(' ').first;
      return corto
          ? '${n.split(' ').first} ${n.split(' ').last.substring(0, 3)}'
          : n;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= periodos.length; i++)
              GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(
                    horizontal: corto ? 10 : 14,
                    vertical: corto ? 7 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: i == elegido ? KipuColores.tinta : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    nombre(i),
                    style: TextStyle(
                      fontSize: corto ? 13 : 14,
                      fontWeight: i == elegido
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: i == elegido ? Colors.white : KipuColores.gris,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BotonAsistencia extends StatelessWidget {
  final String? detalle;
  final Color color;
  final VoidCallback onTap;
  const _BotonAsistencia({
    required this.detalle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: detalle == null ? 8 : 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KipuIcon(KipuIcono.asistencia, size: 22, color: color),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Asistencia',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (detalle != null)
                    Text(
                      detalle!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: KipuColores.gris,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Descargar el registro de notas ───────────────────────

const _rojoPdf = Color(0xFFE0475B);
const _verdeExcel = Color(0xFF1E8E5A);

/// Botón blanco con borde del color del curso: "Descargar · PDF o Excel".
class _BotonDescargar extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _BotonDescargar({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: color, width: 1.6),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 6, 14, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: KipuIcon(
                  KipuIcono.descargar,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 9),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descargar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  'PDF o Excel',
                  style: TextStyle(fontSize: 11.5, color: KipuColores.gris),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Etiqueta de formato: "PDF" en rojo, "XLSX" en verde.
/// Etiqueta de formato: "PDF" en rojo, "XLSX" en verde.
class _Formato extends StatelessWidget {
  final String texto;
  final Color color;
  const _Formato(this.texto, this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: Color.lerp(color, Colors.white, .88),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: .3,
          color: color,
        ),
      ),
    ),
  );
}

/// Miniatura de una hoja PDF con la tabla del registro.
class _MiniPdf extends StatelessWidget {
  final Color color;
  const _MiniPdf(this.color);

  @override
  Widget build(BuildContext context) {
    Widget fila(Color fondo, Color fin) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(flex: 3, child: Container(height: 5, color: fondo)),
          for (var i = 0; i < 3; i++) ...[
            const SizedBox(width: 2),
            Expanded(child: Container(height: 5, color: fondo)),
          ],
          const SizedBox(width: 2),
          Expanded(child: Container(height: 5, color: fin)),
        ],
      ),
    );
    final suave = Color.lerp(color, Colors.white, .75)!;
    return Container(
      width: 104,
      height: 120,
      padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: KipuColores.tinta.withValues(alpha: .14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 54, height: 6, color: color),
          const SizedBox(height: 4),
          Container(width: 36, height: 3.5, color: const Color(0xFFD5D4DE)),
          const SizedBox(height: 8),
          fila(suave, suave),
          for (var i = 0; i < 9; i++)
            fila(
              const Color(0xFFEDEDF2),
              Color.lerp(color, Colors.white, .85)!,
            ),
        ],
      ),
    );
  }
}

/// Miniatura de una hoja de Excel.
class _MiniExcel extends StatelessWidget {
  final Color color;
  const _MiniExcel(this.color);

  @override
  Widget build(BuildContext context) {
    const linea = Color(0xFFDDE7E1);
    return Container(
      width: 150,
      height: 112,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: KipuColores.tinta.withValues(alpha: .14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var f = 0; f < 9; f++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 6; c++)
                    Expanded(
                      flex: c == 0 ? 2 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: f == 0
                              ? color
                              : (c == 0 ? const Color(0xFFF2F7F4) : null),
                          border: const Border(
                            right: BorderSide(color: linea, width: .8),
                            bottom: BorderSide(color: linea, width: .8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Ventana de descarga: formato con vista previa y periodo. Los periodos sin
/// notas salen deshabilitados. Devuelve (formato, periodos elegidos).
class _PanelDescarga extends StatefulWidget {
  final String subtitulo;
  final List<Periodo> periodos;
  final int periodo;
  final Set<int> conNotas;
  final bool hoja;
  final Color color;
  const _PanelDescarga({
    required this.subtitulo,
    required this.periodos,
    required this.periodo,
    required this.conNotas,
    required this.hoja,
    required this.color,
  });

  @override
  State<_PanelDescarga> createState() => _PanelDescargaState();
}

class _PanelDescargaState extends State<_PanelDescarga> {
  var _formato = 'pdf';

  /// 0 = todo el año.
  late int _periodo = widget.conNotas.contains(widget.periodo)
      ? widget.periodo
      : (widget.conNotas.isEmpty
            ? widget.periodo
            : (widget.conNotas.toList()..sort()).first);

  bool get _hayNotas => widget.conNotas.isNotEmpty;
  Color get _color => _formato == 'pdf' ? _rojoPdf : _verdeExcel;

  Widget _tarjeta(String f) {
    final pdf = f == 'pdf';
    final color = pdf ? _rojoPdf : _verdeExcel;
    final activo = _formato == f;
    final chico = widget.hoja;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: activo ? color : _linea, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _formato = f),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: activo
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: .14),
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: chico ? 120 : 160,
                decoration: BoxDecoration(
                  color: Color.lerp(color, Colors.white, .9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: chico ? .8 : 1,
                    child: pdf ? _MiniPdf(widget.color) : _MiniExcel(color),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Formato(pdf ? 'PDF' : 'XLSX', color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pdf ? 'PDF' : 'Excel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          pdf
                              ? 'Para imprimir, firmar o enviar'
                              : 'Para editar o sacar cálculos',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: KipuColores.gris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activo ? color : const Color(0xFFD5D4DE),
                        width: activo ? 7 : 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(int p, String texto) {
    final habil = p == 0 ? _hayNotas : widget.conNotas.contains(p);
    final activo = habil && _periodo == p;
    final chip = Material(
      color: activo ? KipuColores.tinta : KipuColores.fondo,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: habil ? () => setState(() => _periodo = p) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
              color: activo
                  ? Colors.white
                  : (habil ? KipuColores.gris : const Color(0xFFC9C8D3)),
              decoration: habil ? null : TextDecoration.lineThrough,
              decorationColor: const Color(0xFFC9C8D3),
            ),
          ),
        ),
      ),
    );
    return habil ? chip : Tooltip(message: 'Sin notas todavía', child: chip);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    String corto(int i) {
      final n = w.periodos[i - 1].nombre.split(' ');
      return i == _periodo && n.length > 1
          ? '${n.first} ${n.last.substring(0, min(3, n.last.length))}'
          : n.first;
    }

    final chips = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 1; i <= w.periodos.length; i++) _chip(i, corto(i)),
        _chip(0, 'Todo el año'),
      ],
    );
    final periodo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periodo',
          style: TextStyle(
            fontSize: 13,
            color: KipuColores.gris,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        chips,
        if (!_hayNotas)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Todavía no hay notas en ningún periodo.',
              style: TextStyle(fontSize: 13, color: _rojo),
            ),
          ),
      ],
    );
    final descargar = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: _color,
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: _hayNotas
          ? () => Navigator.pop(context, (
              _formato,
              _periodo == 0 ? (w.conNotas.toList()..sort()) : [_periodo],
            ))
          : null,
      icon: const KipuIcon(KipuIcono.descargar, size: 20, color: Colors.white),
      label: Text(
        'Descargar ${_formato == 'pdf' ? 'PDF' : 'Excel'}',
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    );

    return Padding(
      padding: w.hoja
          ? const EdgeInsets.fromLTRB(16, 0, 16, 20)
          : const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Descargar registro de notas',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            w.subtitulo,
            style: const TextStyle(fontSize: 14, color: KipuColores.gris),
          ),
          const SizedBox(height: 18),
          if (w.hoja) ...[
            _tarjeta('pdf'),
            const SizedBox(height: 10),
            _tarjeta('xlsx'),
          ] else
            Row(
              children: [
                Expanded(child: _tarjeta('pdf')),
                const SizedBox(width: 16),
                Expanded(child: _tarjeta('xlsx')),
              ],
            ),
          const SizedBox(height: 18),
          periodo,
          const SizedBox(height: 20),
          if (w.hoja)
            descargar
          else
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: KipuColores.fondo,
                      foregroundColor: KipuColores.gris,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 15.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: descargar),
              ],
            ),
        ],
      ),
    );
  }
}

Future<void> _descargarRegistro(
  BuildContext context, {
  required CursoConColegio datos,
  required int periodo,
  required List<Periodo> periodos,
  required List<Estudiante> estudiantes,
  required ColoresRegistro colores,
  required Escala? Function(RegistroColumna) escalaDe,
}) async {
  final cur = datos.curso;
  final ancho = MediaQuery.sizeOf(context).width >= 700;
  final subtitulo =
      '${cur.nombre} · ${_gradoCorto(cur)} · ${datos.colegio.nombre}';

  final config = await db.verAnioActivo().asyncExpand(db.verConfigAcademica).first;
  final cfgs = await db.verConfigsColumnas().first;

  // Lo que hay en cada periodo, para saber cuáles se pueden descargar.
  final hojas = <int, HojaRegistro>{};
  for (var p = 1; p <= periodos.length; p++) {
    final columnas = await db.verColumnas(cur.id, p).first;
    // Asistencia y participación al día antes de descargar.
    await db.actualizarAutomaticas(cursoId: cur.id, periodo: p, config: config);
    final notas = await db.verNotasRegistro(cur.id, p).first;
    final lista = estudiantes.where((e) => estaEnPeriodo(e, p)).toList()
      ..sort((a, b) => claveOrden(a).compareTo(claveOrden(b)));
    hojas[p] = HojaRegistro(
      periodo: periodos[p - 1].nombre,
      estudiantes: lista,
      // Las calculadas todavía no tienen valores; las ocultas no van.
      columnas: [
        for (final c in columnas)
          if (tieneEscala(c.tipo) && !(cfgs[c.id]?.ocultaEnDescarga ?? false))
            c,
      ],
      notas: notas,
    );
  }
  final conNotas = {
    for (final MapEntry(key: p, value: h) in hojas.entries)
      if (h.columnas.any((c) => h.notas[c.id]?.isNotEmpty ?? false)) p,
  };
  if (!context.mounted) return;

  final panel = _PanelDescarga(
    subtitulo: subtitulo,
    periodos: periodos,
    periodo: periodo,
    conNotas: conNotas,
    hoja: !ancho,
    color: colores.calculadas,
  );
  final (String, List<int>)? elegido = ancho
      ? await showDialog(
          context: context,
          barrierColor: const Color(0x661F1B2E),
          builder: (_) => Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(child: panel),
            ),
          ),
        )
      : await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          showDragHandle: true,
          barrierColor: const Color(0x661F1B2E),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          builder: (ctx) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * .9,
            ),
            child: SafeArea(child: SingleChildScrollView(child: panel)),
          ),
        );
  if (elegido == null || !context.mounted) return;
  final (formato, elegidos) = elegido;

  final r = ReporteRegistro(
    colegio: datos.colegio.nombre,
    curso: cur,
    docente: await db.leerAjuste('nombre') ?? '',
    color: colores.calculadas,
    alcance: elegidos.length > 1
        ? 'Año completo'
        : periodos[elegidos.first - 1].nombre,
    hojas: [for (final p in elegidos) hojas[p]!],
    escalaDe: escalaDe,
  );
  try {
    if (formato == 'pdf') {
      await FilePicker.saveFile(
        fileName: '${r.archivo}.pdf',
        bytes: await pdfRegistro(r),
        mimeType: 'application/pdf',
      );
    } else {
      await FilePicker.saveFile(
        fileName: '${r.archivo}.xlsx',
        bytes: excelRegistro(r),
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo descargar el registro: $e')),
    );
  }
}

typedef _Opcion = (String accion, KipuIcono icono, String texto);

Future<void> _accionRegistro(
  BuildContext context,
  String v, {
  required CursoConColegio datos,
  required int periodo,
  required List<Periodo> periodos,
  required ColoresRegistro colores,
  required List<Estudiante> estudiantes,
  required List<GrupoEquipos> grupos,
  required VoidCallback nuevaColumna,
}) async {
  final id = datos.curso.id;
  switch (v) {
    case 'columna':
      nuevaColumna();
    case 'azar':
      await _alumnoAlAzar(context, estudiantes, colores);
    case 'estudiante':
      await abrirFicha(
        context,
        datos: datos,
        periodo: periodo,
        periodos: periodos,
        color: colores.base,
      );
    case 'importar':
      await importarEstudiantes(
        context,
        id,
        periodo: periodo,
        color: colores.calculadas,
      );
    case 'columnas':
      await _importarColumnas(context, datos, periodo, periodos, colores);
    case 'equipos':
      await _editarEquipos(context, id, estudiantes, grupos, colores);
    case 'colores':
      await _editarColores(context, id, colores);
  }
}

/// Botón flotante "+" que despliega todas las opciones de abajo hacia arriba.
class _BotonMas extends StatelessWidget {
  final ColoresRegistro colores;
  final bool sinEstudiantes;
  final ValueChanged<String> onAccion;
  const _BotonMas({
    required this.colores,
    required this.sinEstudiantes,
    required this.onAccion,
  });

  static const _opciones = <_Opcion>[
    ('colores', KipuIcono.paleta, 'Colores del registro'),
    ('equipos', KipuIcono.equipo, 'Equipos'),
    ('columnas', KipuIcono.copia, 'Importar columnas'),
    ('importar', KipuIcono.pegar, 'Importar estudiantes'),
    ('estudiante', KipuIcono.secciones, 'Nuevo estudiante'),
    ('azar', KipuIcono.dado, 'Alumno al azar'),
    ('columna', KipuIcono.columna, 'Nueva columna'),
  ];

  Future<void> _abrir(BuildContext context) async {
    final base = colores.calculadas;
    final v = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: KipuColores.tinta.withValues(alpha: .35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, _, _) => SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (accion, icono, texto) in _opciones)
                  if (!sinEstudiantes ||
                      const {'estudiante', 'importar'}.contains(accion))
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: accion == 'columna' ? 16 : 10,
                      ),
                      child: Material(
                        color: Colors.white,
                        elevation: 2,
                        shadowColor: KipuColores.tinta.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.pop(ctx, accion),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 18, 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                KipuIcon(icono, size: 22, color: base),
                                const SizedBox(width: 12),
                                Text(
                                  texto,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: KipuColores.tinta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: KipuColores.tinta,
                  shape: const CircleBorder(),
                  onPressed: () => Navigator.pop(ctx),
                  child: const KipuIcon(
                    KipuIcono.cerrar,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, .06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
    if (v != null) onAccion(v);
  }

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    tooltip: 'Más opciones',
    backgroundColor: colores.calculadas,
    shape: const CircleBorder(),
    onPressed: () => _abrir(context),
    child: const KipuIcon(KipuIcono.agregar, size: 28, color: Colors.white),
  );
}

class _SinEstudiantes extends StatelessWidget {
  final ColoresRegistro colores;
  final String periodo;
  final ValueChanged<String> onAccion;
  const _SinEstudiantes({
    required this.colores,
    required this.periodo,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    Widget opcion(
      KipuIcono icono,
      String titulo,
      String detalle,
      VoidCallback onTap, {
      bool principal = false,
    }) {
      final texto = principal ? Colors.white : KipuColores.tinta;
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Material(
          color: principal ? colores.calculadas : KipuColores.fondo,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  KipuIcon(
                    icono,
                    size: 28,
                    color: principal ? Colors.white : colores.calculadas,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: texto,
                          ),
                        ),
                        Text(
                          detalle,
                          style: TextStyle(
                            fontSize: 13,
                            color: texto.withValues(alpha: .75),
                          ),
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

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KipuIcon(
                KipuIcono.secciones,
                size: 54,
                color: colores.calculadas,
              ),
              const SizedBox(height: 14),
              Text(
                'Aún no hay estudiantes en el $periodo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Agrégalos una sola vez: siguen en los bimestres que vienen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: KipuColores.gris),
              ),
              const SizedBox(height: 6),
              opcion(
                KipuIcono.pegar,
                'Importar estudiantes',
                'Pega la lista o sube la plantilla de Excel',
                () => onAccion('importar'),
                principal: true,
              ),
              opcion(
                KipuIcono.secciones,
                'Agregar uno por uno',
                'Nombre, foto, DNI y apoderado',
                () => onAccion('estudiante'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────── Tabla ─────────────────────────────────

class _Tabla extends StatefulWidget {
  final bool ancho;
  final List<Estudiante> estudiantes;
  final List<RegistroColumna> columnas;
  final Map<int, Map<int, String>> notas;
  final Map<int, (int, int)> conducta;
  final ColoresRegistro colores;
  final Escala? Function(RegistroColumna) escalaDe;
  final Map<int, Instrumento> instrumentos;
  final Map<int, ConfigColumna> configs;
  final Escala? letras;
  final Map<int, Map<int, String>> comentarios;
  final VoidCallback onNueva;
  final ValueChanged<Estudiante> onEstudiante;
  final ValueChanged<Estudiante> onConducta;
  final ValueChanged<RegistroColumna> onColumna;
  final void Function(Estudiante, RegistroColumna) onCelda;

  const _Tabla({
    super.key,
    required this.ancho,
    required this.estudiantes,
    required this.columnas,
    required this.notas,
    required this.conducta,
    required this.colores,
    required this.escalaDe,
    this.instrumentos = const {},
    this.configs = const {},
    this.letras,
    this.comentarios = const {},
    required this.onNueva,
    required this.onEstudiante,
    required this.onConducta,
    required this.onColumna,
    required this.onCelda,
  });

  @override
  State<_Tabla> createState() => _TablaState();
}

class _TablaState extends State<_Tabla> {
  final _h = ScrollController();
  // Tres listas verticales (nombres, notas y columna fija) que se mueven juntas.
  final _v = [ScrollController(), ScrollController(), ScrollController()];
  bool _moviendo = false;

  @override
  void initState() {
    super.initState();
    for (final c in _v) {
      c.addListener(() => _unir(c));
    }
  }

  void _unir(ScrollController desde) {
    if (_moviendo) return;
    _moviendo = true;
    for (final c in _v) {
      if (c != desde && c.hasClients && c.offset != desde.offset) {
        c.jumpTo(desde.offset);
      }
    }
    _moviendo = false;
  }

  @override
  void dispose() {
    _h.dispose();
    for (final c in _v) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final ancho = w.ancho;
    final nombreW = ancho ? 330.0 : 176.0;
    final celdaW = ancho ? 120.0 : 64.0;
    final cabH = ancho ? 96.0 : 52.0;
    final filaH = ancho ? 58.0 : 54.0;
    final agregarW = ancho ? 84.0 : 60.0;
    final fijaW = ancho ? 132.0 : 72.0;
    final fija = w.columnas.where((c) => c.fijada).firstOrNull;
    final libres = w.columnas.where((c) => !c.fijada).toList();
    final c = w.colores;

    String? codigoDe(int? id) => id == null
        ? null
        : w.columnas.where((x) => x.id == id).firstOrNull?.codigo;

    // Columna que recupera a cada columna: {original: recuperación}.
    final recuperadaPor = <int, RegistroColumna>{};
    for (final x in w.columnas) {
      final r = w.configs[x.id]?.recupera;
      if (r != null) recuperadaPor[r] = x;
    }

    /// Nota que se ve: con recuperación, la que cuenta según el docente.
    (String?, bool) notaDe(RegistroColumna col, Estudiante e) {
      final v = w.notas[col.id]?[e.id];
      final rec = recuperadaPor[col.id];
      final esc = w.escalaDe(col);
      if (rec == null || esc == null) return (v, false);
      final r = w.notas[rec.id]?[e.id];
      final ef = notaConRecuperacion(
        v,
        r,
        esc,
        masAlta: w.configs[rec.id]?.recuperaMasAlta ?? true,
      );
      return (ef, ef != v);
    }

    String? letraDe(RegistroColumna col, String? v) {
      final esc = w.escalaDe(col);
      final l = w.letras;
      if (v == null || esc == null || l == null || !esc.numerica) return null;
      if (!(w.configs[col.id]?.mostrarLetra ?? false)) return null;
      return letraDeNumero(v, esc, l);
    }

    Widget pie(RegistroColumna col, double ancho, {bool fijada = false}) =>
        _CeldaMedia(
          texto: tieneEscala(col.tipo)
              ? mediaColumna([
                  for (final e in w.estudiantes) ?notaDe(col, e).$1,
                ], w.escalaDe(col))
              : null,
          escala: w.escalaDe(col),
          ancho: ancho,
          alto: filaH,
          fijada: fijada,
        );

    // La última fila de cada lista es la media, pegada al último estudiante.
    Widget lista(
      int i,
      Widget Function(Estudiante e, int i) fila,
      Widget media,
    ) => ListView.builder(
      controller: _v[i],
      padding: const EdgeInsets.only(bottom: 90),
      itemExtent: filaH,
      itemCount: w.estudiantes.length + 1,
      itemBuilder: (_, k) =>
          k < w.estudiantes.length ? fila(w.estudiantes[k], k) : media,
    );

    final nombres = AnimatedBuilder(
      animation: _h,
      builder: (_, child) => Container(
        width: nombreW,
        decoration: BoxDecoration(
          color: c.nombres,
          boxShadow: _h.hasClients && _h.offset > 2
              ? [
                  BoxShadow(
                    color: KipuColores.tinta.withValues(alpha: .12),
                    blurRadius: 14,
                    offset: const Offset(4, 0),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
      child: Column(
        children: [
          Container(
            height: cabH,
            color: c.cabecera,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(ancho ? 18 : 12, 0, 0, 12),
            child: Text(
              'Estudiante',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.tintaCabecera,
              ),
            ),
          ),
          Expanded(
            child: lista(
              0,
              (e, i) => _CeldaNombre(
                estudiante: e,
                numero: i + 1,
                ancho: ancho,
                conducta: w.conducta[e.id] ?? (0, 0),
                onTap: () => w.onEstudiante(e),
                onConducta: () => w.onConducta(e),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: ancho ? 18 : 12),
                color: c.cabecera,
                child: Text(
                  ancho ? 'Media de la columna' : 'Media',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.tintaCabecera,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final anchoNotas = libres.length * celdaW + agregarW;
    final notas = Scrollbar(
      controller: _h,
      thumbVisibility: ancho,
      child: SingleChildScrollView(
        controller: _h,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: anchoNotas,
          child: Column(
            children: [
              SizedBox(
                height: cabH,
                child: Row(
                  children: [
                    for (final col in libres)
                      _CabeceraColumna(
                        columna: col,
                        escala: w.escalaDe(col),
                        instrumento: w.instrumentos[col.id],
                        config: w.configs[col.id],
                        recupera: codigoDe(w.configs[col.id]?.recupera),
                        colores: c,
                        ancho: celdaW,
                        compacta: !ancho,
                        onTap: () => w.onColumna(col),
                      ),
                    Container(
                      width: agregarW,
                      color: c.cabecera,
                      alignment: Alignment.center,
                      child: _BotonAgregarColumna(
                        color: c.calculadas,
                        onTap: w.onNueva,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: lista(
                  1,
                  (e, _) => Row(
                    children: [
                      for (final col in libres)
                        _Celda(
                          valor: notaDe(col, e).$1,
                          recuperada: notaDe(col, e).$2,
                          comentario: w.comentarios[col.id]?[e.id],
                          letra: letraDe(col, notaDe(col, e).$1),
                          escala: w.escalaDe(col),
                          calculada: col.tipo == 'calculada',
                          automatica: esAutomatica(col.tipo),
                          colores: c,
                          ancho: celdaW,
                          onTap: () => w.onCelda(e, col),
                        ),
                      Container(
                        width: agregarW,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: _linea)),
                        ),
                      ),
                    ],
                  ),
                  ColoredBox(
                    color: c.cabecera,
                    child: Row(
                      children: [
                        for (final col in libres) pie(col, celdaW),
                        SizedBox(width: agregarW),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget? derecha;
    if (fija != null) {
      derecha = Container(
        width: fijaW,
        decoration: BoxDecoration(
          color: c.fijada,
          boxShadow: [
            BoxShadow(
              color: KipuColores.tinta.withValues(alpha: .16),
              blurRadius: 14,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: cabH,
              child: _CabeceraColumna(
                columna: fija,
                escala: w.escalaDe(fija),
                instrumento: w.instrumentos[fija.id],
                config: w.configs[fija.id],
                recupera: codigoDe(w.configs[fija.id]?.recupera),
                colores: c,
                ancho: fijaW,
                compacta: !ancho,
                onTap: () => w.onColumna(fija),
              ),
            ),
            Expanded(
              child: lista(
                2,
                (e, _) => _Celda(
                  valor: notaDe(fija, e).$1,
                  recuperada: notaDe(fija, e).$2,
                  comentario: w.comentarios[fija.id]?[e.id],
                  letra: letraDe(fija, notaDe(fija, e).$1),
                  escala: w.escalaDe(fija),
                  calculada: fija.tipo == 'calculada',
                  automatica: esAutomatica(fija.tipo),
                  fijada: true,
                  colores: c,
                  ancho: fijaW,
                  onTap: () => w.onCelda(e, fija),
                ),
                pie(fija, fijaW, fijada: true),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(ancho ? 22 : 18),
      child: ColoredBox(
        color: Colors.white,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: PointerDeviceKind.values.toSet(),
            scrollbars: false,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              nombres,
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: cabH,
                      child: ColoredBox(color: c.cabecera),
                    ),
                    Positioned.fill(child: notas),
                  ],
                ),
              ),
              ?derecha,
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonAgregarColumna extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _BotonAgregarColumna({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Nueva columna',
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(child: KipuIcon(KipuIcono.agregar, color: color)),
        ),
      ),
    ),
  );
}

class _CeldaNombre extends StatelessWidget {
  final Estudiante estudiante;
  final int numero;
  final bool ancho;
  final (int, int) conducta;
  final VoidCallback onTap;
  final VoidCallback onConducta;

  const _CeldaNombre({
    required this.estudiante,
    required this.numero,
    required this.ancho,
    required this.conducta,
    required this.onTap,
    required this.onConducta,
  });

  @override
  Widget build(BuildContext context) {
    final e = estudiante;
    final apellidos = ancho
        ? tituloNombre(e.apellidos)
        : apellidoCorto(e.apellidos);
    final nombres = ancho
        ? tituloNombre(e.nombres)
        : tituloNombre(e.nombres).split(' ').first;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _linea)),
        ),
        padding: EdgeInsets.only(left: ancho ? 12 : 8, right: ancho ? 12 : 6),
        child: Row(
          children: [
            if (ancho)
              SizedBox(
                width: 24,
                child: Text(
                  '$numero',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFA3A1B3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            AvatarEstudiante(e, tam: ancho ? 36 : 30),
            SizedBox(width: ancho ? 12 : 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apellidos,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ancho ? 15 : 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    nombres,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ancho ? 12.5 : 11.5,
                      color: KipuColores.gris,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            _ChipConducta(conducta: conducta, onTap: onConducta),
          ],
        ),
      ),
    );
  }
}

class _ChipConducta extends StatelessWidget {
  final (int, int) conducta;
  final VoidCallback onTap;
  const _ChipConducta({required this.conducta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (p, n) = conducta;
    final vacio = p == 0 && n == 0;
    final bien = p >= n;
    final color = vacio ? const Color(0xFFB5B3C4) : (bien ? _verde : _rojo);
    final fondo = vacio
        ? const Color(0xFFF0F1F6)
        : (bien ? const Color(0xFFDDF4EA) : const Color(0xFFFCE8EB));
    final texto = [if (p > 0) '+$p', if (n > 0) '−$n'].join(' ');
    return Tooltip(
      message: 'Conducta de hoy',
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: vacio ? 5 : 6,
              vertical: 5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KipuIcon(KipuIcono.sonrisa, size: 17, color: color),
                if (!vacio) ...[
                  const SizedBox(width: 3),
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CabeceraColumna extends StatelessWidget {
  final RegistroColumna columna;
  final Escala? escala;
  final Instrumento? instrumento;
  final ConfigColumna? config;

  /// Código de la columna que esta recupera.
  final String? recupera;
  final ColoresRegistro colores;
  final double ancho;
  final bool compacta;
  final VoidCallback onTap;

  const _CabeceraColumna({
    required this.columna,
    required this.escala,
    this.instrumento,
    this.config,
    this.recupera,
    required this.colores,
    required this.ancho,
    required this.compacta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final col = columna;
    final calculada = col.tipo == 'calculada';
    final fondo = col.fijada
        ? colores.fijada
        : (calculada ? colores.calculadas : colores.cabecera);
    final oscuro = col.fijada || calculada;
    final tinta = oscuro ? Colors.white : colores.tintaCabecera;
    final suave = oscuro
        ? Colors.white.withValues(alpha: .75)
        : KipuColores.gris;
    final fecha = col.fecha == null
        ? null
        : DateFormat('d MMM', 'es_PE').format(DateTime.parse(col.fecha!));
    final auto = esAutomatica(col.tipo);
    final detalle = auto
        ? [
            col.tipo == 'asistencia' ? 'Asistencia' : 'Participación',
            escalaCorta(escala),
          ].join(' · ')
        : calculada
        ? (col.fijada ? 'Fija · calculada' : 'Calculada')
        : [
            if (recupera != null) 'Recupera $recupera' else ?fecha,
            escalaCorta(escala),
          ].join(' · ');

    return Material(
      color: fondo,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: ancho,
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 6, 6, compacta ? 8 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!compacta && (calculada || col.fijada))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: KipuIcon(
                      col.fijada
                          ? KipuIcono.chincheta
                          : (col.tipo == 'asistencia'
                                ? KipuIcono.asistencia
                                : (col.tipo == 'participacion'
                                      ? KipuIcono.participa
                                      : KipuIcono.calculadora)),
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (compacta && col.fijada)
                      const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: KipuIcon(
                          KipuIcono.chincheta,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        col.codigo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compacta ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: tinta,
                        ),
                      ),
                    ),
                    if (esAutomatica(col.tipo)) ...[
                      const SizedBox(width: 3),
                      Tooltip(
                        message: col.tipo == 'asistencia'
                            ? 'Se llena sola con la asistencia'
                            : 'Se llena sola con los + y −',
                        child: KipuIcon(
                          col.tipo == 'asistencia'
                              ? KipuIcono.asistencia
                              : KipuIcono.participa,
                          size: compacta ? 13 : 15,
                          color: tinta,
                        ),
                      ),
                    ],
                    if (config?.bloqueada ?? false) ...[
                      const SizedBox(width: 3),
                      Tooltip(
                        message: 'Columna bloqueada',
                        child: KipuIcon(
                          KipuIcono.candado,
                          size: compacta ? 12 : 14,
                          color: tinta,
                        ),
                      ),
                    ],
                    if (instrumento != null && !calculada) ...[
                      const SizedBox(width: 3),
                      Tooltip(
                        message: '${instrumento!.tipo.nombre}: ${instrumento!.nombre}',
                        child: KipuIcon(
                          iconoDe(instrumento!.tipo),
                          size: compacta ? 13 : 15,
                          color: tinta,
                        ),
                      ),
                    ],
                    if (col.enEquipo) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE3EE),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Eq.',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB8336C),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!compacta) ...[
                  if ((col.tema ?? '').isNotEmpty)
                    Text(
                      col.tema!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: suave),
                    ),
                  Text(
                    detalle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: oscuro ? suave : const Color(0xFFA3A1B3),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Celda extends StatelessWidget {
  final String? valor;

  /// La nota que se ve viene de la columna de recuperación.
  final bool recuperada;

  /// Letra que acompaña a la nota numérica («16 · A»).
  final String? letra;

  /// Comentario de la nota: se marca con un punto en la esquina.
  final String? comentario;
  final Escala? escala;
  final bool calculada;

  /// Asistencia o participación: se llena sola; sin datos muestra «—».
  final bool automatica;
  final bool fijada;
  final ColoresRegistro colores;
  final double ancho;
  final VoidCallback onTap;

  const _Celda({
    required this.valor,
    this.recuperada = false,
    this.letra,
    this.comentario,
    required this.escala,
    required this.calculada,
    this.automatica = false,
    this.fijada = false,
    required this.colores,
    required this.ancho,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color? fondo = fijada
        ? null
        : (calculada ? colores.celdaCalculada : null);
    return Material(
      color: fondo ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: ancho,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: fijada ? Colors.white.withValues(alpha: .08) : _linea,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              (calculada || automatica) && valor == null
                  ? Text(
                      '—',
                      style: TextStyle(
                        color: fijada
                            ? Colors.white.withValues(alpha: .45)
                            : const Color(0xFFB0B4D0),
                      ),
                    )
                  : _conExtras(VistaNota(valor, escala, sobreOscuro: fijada)),
              if ((comentario ?? '').isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Tooltip(
                    message: comentario!,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9A23B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conExtras(Widget nota) {
    if (letra == null && !recuperada) return nota;
    final suave = fijada
        ? Colors.white.withValues(alpha: .75)
        : KipuColores.gris;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: nota),
        if (letra != null) ...[
          const SizedBox(width: 3),
          Text(
            letra!,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: suave,
            ),
          ),
        ],
        if (recuperada)
          Tooltip(
            message: 'Nota de la recuperación',
            child: Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 10),
              child: Text(
                'R',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: fijada ? Colors.white : const Color(0xFF0E7A5F),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Una nota tal como se ve en el registro, según su escala.
class VistaNota extends StatelessWidget {
  final String? valor;
  final Escala? escala;
  final bool sobreOscuro;
  const VistaNota(
    this.valor,
    this.escala, {
    super.key,
    this.sobreOscuro = false,
  });

  @override
  Widget build(BuildContext context) {
    final v = valor;
    final e = escala;
    if (v == null) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: sobreOscuro
                ? Colors.white.withValues(alpha: .25)
                : const Color(0xFFDCDDE8),
            width: 1.4,
          ),
        ),
      );
    }
    if (e == null || e.numerica) {
      final n = double.tryParse(v.replaceAll(',', '.'));
      final bajo = n != null && e?.aprueba != null && n < e!.aprueba!;
      final texto = mostrarNumero(v);
      if (bajo && !sobreOscuro) {
        return _Pastilla(texto, const Color(0xFFFCE8EB), _rojo);
      }
      return Text(
        texto,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: sobreOscuro ? Colors.white : KipuColores.tinta,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }
    final i = e.valores.indexWhere((x) => x.codigo == v);
    if (i < 0) return Text(v);
    final color = Color(e.valores[i].color);
    if (esSiNo(e)) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Color.lerp(color, Colors.white, .85),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: KipuIcon(
            i == 0 ? KipuIcono.check : KipuIcono.cerrar,
            size: 16,
            color: color,
          ),
        ),
      );
    }
    return i == 0
        ? _Pastilla(v, color, Colors.white)
        : _Pastilla(v, Color.lerp(color, Colors.white, .86)!, color);
  }
}

/// Media de una columna: promedio con un decimal si es numérica, la letra
/// más repetida si es por letras y "9 de 11" si es Logrado / No logrado.
String? mediaColumna(List<String> valores, Escala? e) {
  if (valores.isEmpty) return null;
  if (e == null || e.numerica) {
    final n = [
      for (final v in valores) ?double.tryParse(v.replaceAll(',', '.')),
    ];
    if (n.isEmpty) return null;
    final m = n.reduce((a, b) => a + b) / n.length;
    return m.toStringAsFixed(1).replaceAll('.', ',');
  }
  if (esSiNo(e)) {
    final si = valores.where((v) => v == e.valores.first.codigo).length;
    return '$si de ${valores.length}';
  }
  final cuenta = <String, int>{};
  for (final v in valores) {
    cuenta[v] = (cuenta[v] ?? 0) + 1;
  }
  // Ante empate gana la letra más alta de la escala.
  final orden = [for (final x in e.valores) x.codigo];
  return (cuenta.keys.toList()..sort((a, b) {
        final d = cuenta[b]!.compareTo(cuenta[a]!);
        return d != 0 ? d : orden.indexOf(a).compareTo(orden.indexOf(b));
      }))
      .first;
}

class _CeldaMedia extends StatelessWidget {
  final String? texto;
  final Escala? escala;
  final double ancho;
  final double alto;
  final bool fijada;
  const _CeldaMedia({
    required this.texto,
    required this.escala,
    required this.ancho,
    required this.alto,
    required this.fijada,
  });

  @override
  Widget build(BuildContext context) {
    final t = texto;
    final e = escala;
    var color = fijada ? Colors.white : KipuColores.tinta;
    if (t != null && !fijada && (e == null || e.numerica)) {
      final n = double.tryParse(t.replaceAll(',', '.'));
      if (n != null && e?.aprueba != null && n < e!.aprueba!) color = _rojo;
    }
    return SizedBox(
      width: ancho,
      height: alto,
      child: Center(
        child: Text(
          t ?? '—',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: t == null
                ? (fijada
                      ? Colors.white.withValues(alpha: .45)
                      : const Color(0xFFB0B4D0))
                : color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// "15.5" → "15,5"; "17.0" → "17".
String mostrarNumero(String v) {
  final n = double.tryParse(v.replaceAll(',', '.'));
  if (n == null) return v;
  return n == n.roundToDouble()
      ? n.toStringAsFixed(0)
      : n.toString().replaceAll('.', ',');
}

class _Pastilla extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color color;
  const _Pastilla(this.texto, this.fondo, this.color);

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 34),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ─────────────────────────────── Ventanas ───────────────────────────────

// Alumno al azar

Future<void> _alumnoAlAzar(
  BuildContext context,
  List<Estudiante> estudiantes,
  ColoresRegistro colores,
) async {
  if (estudiantes.isEmpty) return;
  await _hoja(context, _AlAzar(estudiantes: estudiantes, colores: colores));
}

/// Ya llamados en esta sesión, por curso: no se repite hasta que salgan todos.
final _llamados = <int, Set<int>>{};

class _AlAzar extends StatefulWidget {
  final List<Estudiante> estudiantes;
  final ColoresRegistro colores;
  const _AlAzar({required this.estudiantes, required this.colores});

  @override
  State<_AlAzar> createState() => _AlAzarState();
}

class _AlAzarState extends State<_AlAzar> {
  final _voz = FlutterTts();
  final _azar = Random();
  late Estudiante _e;
  bool _anotado = false;

  Set<int> get _ya => _llamados[widget.estudiantes.first.cursoId] ??= {};

  @override
  void initState() {
    super.initState();
    _voz.setLanguage('es-ES');
    _voz.setSpeechRate(.45);
    _siguiente();
  }

  @override
  void dispose() {
    _voz.stop();
    super.dispose();
  }

  void _siguiente() {
    var quedan = widget.estudiantes.where((e) => !_ya.contains(e.id)).toList();
    if (quedan.isEmpty) {
      _ya.clear();
      quedan = widget.estudiantes;
    }
    _e = quedan[_azar.nextInt(quedan.length)];
    _ya.add(_e.id);
    _anotado = false;
    _hablar();
  }

  void _hablar() => _voz.speak(
    '${tituloNombre(_e.nombres).split(' ').first} '
    '${tituloNombre(_e.apellidos).split(' ').first}',
  );

  @override
  Widget build(BuildContext context) {
    final base = widget.colores.calculadas;
    final faltan = widget.estudiantes.length - _ya.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Alumno al azar',
          style: TextStyle(
            fontSize: 14,
            color: base,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Column(
            key: ValueKey(_e.id),
            children: [
              AvatarEstudiante(_e, tam: 104),
              const SizedBox(height: 14),
              Text(
                tituloNombre(_e.nombres),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tituloNombre(_e.apellidos),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: KipuColores.gris),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: _hablar,
          icon: KipuIcon(KipuIcono.charla, size: 18, color: base),
          label: Text('Repetir nombre', style: TextStyle(color: base)),
        ),
        Text(
          faltan == 0
              ? 'Ya salieron todos; la próxima ronda empieza de nuevo'
              : 'Faltan $faltan por salir',
          style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: _verde,
                  side: BorderSide(
                    color: _anotado ? _verde : const Color(0xFFCFE9DD),
                  ),
                ),
                onPressed: _anotado
                    ? null
                    : () async {
                        await db.anotarConducta(
                          _e.id,
                          claveFecha(DateTime.now()),
                          true,
                          'Participa',
                        );
                        setState(() => _anotado = true);
                      },
                icon: KipuIcon(
                  _anotado ? KipuIcono.check : KipuIcono.participa,
                  size: 20,
                  color: _verde,
                ),
                label: Text(_anotado ? 'Anotado' : '+1 Participa'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: base,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => setState(_siguiente),
                icon: const KipuIcon(
                  KipuIcono.dado,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text('Otro alumno'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Importar columnas

Future<void> _importarColumnas(
  BuildContext context,
  CursoConColegio destino,
  int periodo,
  List<Periodo> periodos,
  ColoresRegistro colores,
) async {
  final todas = await db.todasLasColumnas();
  final cursos = await db.verCursos().first;
  if (!context.mounted) return;
  // Agrupadas por registro de origen: (curso, periodo).
  final grupos = <(int, int), List<RegistroColumna>>{};
  for (final c in todas) {
    if (c.cursoId == destino.curso.id && c.periodo == periodo) continue;
    (grupos[(c.cursoId, c.periodo)] ??= []).add(c);
  }
  CursoConColegio? curso(int id) =>
      cursos.where((c) => c.curso.id == id).firstOrNull;
  String nombre(int p) =>
      p >= 1 && p <= periodos.length ? periodos[p - 1].nombre : '$p.° periodo';
  final orden = grupos.keys.toList()
    ..sort((a, b) {
      // Primero este mismo curso, luego el mismo periodo en otras secciones.
      int peso((int, int) k) =>
          k.$1 == destino.curso.id ? 0 : (k.$2 == periodo ? 1 : 2);
      return peso(a).compareTo(peso(b));
    });
  final base = colores.calculadas;
  final elegido = await _hoja<(int, int)>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabezaHoja(
          icono: KipuIcono.copia,
          color: base,
          titulo: 'Importar columnas',
          subtitulo:
              'Se copian los códigos, temas y escalas, sin notas, al ${nombre(periodo)}',
        ),
        const SizedBox(height: 10),
        if (orden.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Todavía no hay otros registros con columnas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KipuColores.gris),
            ),
          ),
        for (final k in orden)
          if (curso(k.$1) case final c?)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: KipuIcon(
                k.$1 == destino.curso.id
                    ? KipuIcono.calendario
                    : KipuIcono.cursos,
                size: 26,
                color: base,
              ),
              title: Text(
                k.$1 == destino.curso.id
                    ? nombre(k.$2)
                    : '${c.curso.nombre} · ${_gradoCorto(c.curso)} · ${nombre(k.$2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                grupos[k]!.map((x) => x.codigo).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.pop(context, k),
            ),
      ],
    ),
  );
  if (elegido == null) return;
  await db.copiarColumnas(grupos[elegido]!, destino.curso.id, periodo);
}

/// Ventana centrada del registro (nota, conducta, equipos, colores...).
Future<T?> _hoja<T>(
  BuildContext context,
  Widget contenido, {
  double ancho = 480,
}) => showDialog<T>(
  context: context,
  barrierColor: const Color(0x661F1B2E),
  builder: (ctx) => Dialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ancho),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: contenido,
      ),
    ),
  ),
);

class _CabezaHoja extends StatelessWidget {
  final Widget? avatar;
  final KipuIcono? icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final Widget? cola;
  const _CabezaHoja({
    this.avatar,
    this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    this.cola,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ?avatar,
      if (icono != null) KipuIcon(icono!, size: 34, color: color),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: KipuColores.gris),
            ),
          ],
        ),
      ),
      ?cola,
      const SizedBox(width: 6),
      Material(
        color: KipuColores.fondo,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: KipuIcon(
                KipuIcono.cerrar,
                size: 18,
                color: KipuColores.gris,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _Tecla extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? fondo;
  final double alto;
  const _Tecla({
    required this.child,
    required this.onTap,
    this.fondo,
    this.alto = 54,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: fondo ?? KipuColores.fondo,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        height: alto,
        child: Center(child: child),
      ),
    ),
  );
}

// Poner nota

Future<void> _ponerNota(
  BuildContext context, {
  required RegistroColumna columna,
  required Escala escala,
  required List<Estudiante> estudiantes,
  required int inicio,
  required Map<int, String> notas,
  required Map<int, int> equipos,
  required ColoresRegistro colores,
  ConfigColumna config = const ConfigColumna(),
}) => _hoja(
  context,
  _PonerNota(
    config: config,
    columna: columna,
    escala: escala,
    estudiantes: estudiantes,
    inicio: inicio,
    notas: notas,
    equipos: equipos,
    colores: colores,
  ),
);

class _PonerNota extends StatefulWidget {
  final ConfigColumna config;
  final RegistroColumna columna;
  final Escala escala;
  final List<Estudiante> estudiantes;
  final int inicio;
  final Map<int, String> notas;
  final Map<int, int> equipos;
  final ColoresRegistro colores;

  const _PonerNota({
    this.config = const ConfigColumna(),
    required this.columna,
    required this.escala,
    required this.estudiantes,
    required this.inicio,
    required this.notas,
    required this.equipos,
    required this.colores,
  });

  @override
  State<_PonerNota> createState() => _PonerNotaState();
}

class _PonerNotaState extends State<_PonerNota> {
  late int _i = widget.inicio;
  late final Map<int, String> _notas = {...widget.notas};
  late String _texto = _actual() ?? '';
  String? _error;
  final _foco = FocusNode();

  /// Comentarios de esta columna: {estudiante: texto}.
  Map<int, String> _comentarios = {};
  final _coment = TextEditingController();
  final _focoComent = FocusNode();
  bool _verComentario = false;

  static const _frases = [
    'Entregó tarde',
    'No entregó',
    'No asistió',
    'Justificado',
    'Recuperación pendiente',
    'Copió',
  ];

  @override
  void initState() {
    super.initState();
    db.leerComentariosNota(widget.columna.id).then((m) {
      if (!mounted) return;
      setState(() {
        _comentarios = m;
        _abrirComentario();
      });
    });
  }

  void _abrirComentario() {
    _coment.text = _comentarios[_e.id] ?? '';
    _verComentario = _coment.text.isNotEmpty;
  }

  /// Guarda el comentario si cambió (para todo el equipo si es en equipo).
  Future<void> _guardarComentario() async {
    final t = _coment.text.trim();
    if (t == (_comentarios[_e.id] ?? '')) return;
    final ids = [for (final m in _integrantes) m.id];
    await db.guardarComentarioNota(widget.columna.id, ids, t);
    for (final id in ids) {
      if (t.isEmpty) {
        _comentarios.remove(id);
      } else {
        _comentarios[id] = t;
      }
    }
  }

  Estudiante get _e => widget.estudiantes[_i];
  bool get _equipo => widget.columna.enEquipo && widget.equipos[_e.id] != null;
  List<Estudiante> get _integrantes => _equipo
      ? widget.estudiantes
            .where((x) => widget.equipos[x.id] == widget.equipos[_e.id])
            .toList()
      : [_e];

  String? _actual() => _notas[widget.estudiantes[_i].id];

  @override
  void dispose() {
    _foco.dispose();
    _coment.dispose();
    _focoComent.dispose();
    super.dispose();
  }

  Future<void> _guardar(String? valor) async {
    final esc = widget.escala;
    if (valor != null && esc.numerica) {
      final n = double.tryParse(valor.replaceAll(',', '.'));
      final min = esc.minimo ?? 0, max = esc.maximo ?? 20;
      if (n == null || n < min || n > max) {
        setState(
          () => _error =
              'Escribe una nota de ${mostrarNumero('$min')} a ${mostrarNumero('$max')}',
        );
        return;
      }
      // Decimales y redondeo de la columna: 14,5 → 15 con «Normal».
      final cfg = widget.config;
      valor = numeroGuardado(
        redondear(n, cfg.decimales, cfg.redondeo),
        cfg.decimales,
      );
    }
    for (final m in _integrantes) {
      await db.ponerNota(widget.columna.id, m.id, valor);
      if (valor == null) {
        _notas.remove(m.id);
      } else {
        _notas[m.id] = valor;
      }
    }
    await _mover(1);
  }

  Future<void> _mover(int paso) async {
    // El comentario se guarda también al pasar de estudiante sin nota.
    await _guardarComentario();
    if (!mounted) return;
    var j = _i + paso;
    // En equipo se salta a los integrantes del mismo equipo.
    final eq = _equipo ? widget.equipos[_e.id] : null;
    while (eq != null &&
        j >= 0 &&
        j < widget.estudiantes.length &&
        widget.equipos[widget.estudiantes[j].id] == eq) {
      j += paso;
    }
    if (j < 0) return;
    if (j >= widget.estudiantes.length) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _i = j;
      _texto = _actual() ?? '';
      _error = null;
      _abrirComentario();
    });
  }

  void _tecla(String t) => setState(() {
    _error = null;
    if (t == '⌫') {
      if (_texto.isNotEmpty) _texto = _texto.substring(0, _texto.length - 1);
    } else if (t == ',') {
      if (!_texto.contains(',') && _texto.isNotEmpty) _texto += ',';
    } else if (_texto.length < 5) {
      _texto += t;
    }
  });

  KeyEventResult _teclado(FocusNode _, KeyEvent ev) {
    if (ev is! KeyDownEvent && ev is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    // Lo que se escribe en el comentario no va a la nota.
    if (_focoComent.hasFocus) return KeyEventResult.ignored;
    final k = ev.logicalKey;
    final ch = ev.character ?? '';
    final esc = widget.escala;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      if (esc.numerica) _guardar(_texto.isEmpty ? null : _texto);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      _mover(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      _mover(-1);
      return KeyEventResult.handled;
    }
    if (esc.numerica) {
      if (k == LogicalKeyboardKey.backspace) {
        _tecla('⌫');
      } else if (ch == ',' || ch == '.') {
        _tecla(',');
      } else if (RegExp(r'^\d$').hasMatch(ch)) {
        _tecla(ch);
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }
    // Letras: 1, 2, 3… eligen el valor en su orden.
    final n = int.tryParse(ch);
    if (n != null && n >= 1 && n <= esc.valores.length) {
      _guardar(esc.valores[n - 1].codigo);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Notas rápidas para escalas numéricas: 20 · 18 · 16 · 14 · 12 · 11 · 10.
  List<String> _rapidas(Escala e) {
    final lo = e.minimo ?? 0, hi = e.maximo ?? 20;
    final l = <double>[
      for (final f in const [1.0, .9, .8, .7, .6]) lo + (hi - lo) * f,
      ?e.aprueba,
      lo + (hi - lo) * .5,
    ];
    final r = <String>[];
    for (final n in l) {
      final t = numeroGuardado(n.roundToDouble(), 0);
      if (!r.contains(t)) r.add(t);
    }
    return r;
  }

  /// Nivel que corresponde a la nota que se está escribiendo.
  ValorEscala? _nivelDe(String texto, Escala e) {
    final n = double.tryParse(texto.replaceAll(',', '.'));
    if (n == null) return null;
    for (final v in e.valores) {
      if (v.desde != null && n >= v.desde!) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.columna;
    final esc = widget.escala;
    final base = widget.colores.calculadas;
    final total = widget.estudiantes.length;
    final conNota = widget.estudiantes.where((e) => _notas[e.id] != null).length;
    final antes = _actual();
    final siguiente = _i + 1 < total ? widget.estudiantes[_i + 1] : null;
    final subtitulo = [
      col.codigo,
      if ((col.tema ?? '').isNotEmpty) col.tema!,
      escalaCorta(esc),
    ].join(' · ');

    Widget contenido;
    if (esc.numerica) {
      final nivel = _nivelDe(_texto, esc);
      Widget n(String t, {String? ver}) => _Tecla(
        alto: 50,
        onTap: () => _tecla(t),
        child: Text(
          ver ?? t,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      );
      contenido = Column(
        children: [
          Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _error == null
                  ? Color.lerp(base, Colors.white, .9)
                  : const Color(0xFFFCE8EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _texto.isEmpty ? ' ' : _texto,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: _error == null
                              ? widget.colores.tintaCabecera
                              : _rojo,
                        ),
                      ),
                      Container(width: 2, height: 36, color: base),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: _texto.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar',
                          onPressed: () => setState(() {
                            _texto = '';
                            _error = null;
                          }),
                          icon: const KipuIcon(
                            KipuIcono.cerrar,
                            size: 18,
                            color: KipuColores.gris,
                          ),
                        ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: Center(
              child: Text(
                _error ??
                    (nivel != null
                        ? nivel.descripcion
                        : (antes != null
                              ? 'Nota actual: ${mostrarNumero(antes)}'
                              : 'Escribe la nota o elige una rápida')),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: nivel != null && _error == null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _error != null
                      ? _rojo
                      : (nivel != null ? Color(nivel.color) : KipuColores.gris),
                ),
              ),
            ),
          ),
          // Un toque guarda y pasa al siguiente.
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final r in _rapidas(esc))
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(
                        r,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _nivelDe(r, esc) == null
                              ? KipuColores.tinta
                              : Color(_nivelDe(r, esc)!.color),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE6E7F0)),
                      onPressed: () => _guardar(r),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.9,
            children: [
              n('1'),
              n('2'),
              n('3'),
              _Tecla(
                alto: 50,
                onTap: () => _tecla('⌫'),
                child: const KipuIcon(
                  KipuIcono.deshacer,
                  size: 22,
                  color: KipuColores.gris,
                ),
              ),
              n('4'),
              n('5'),
              n('6'),
              n(','),
              n('7'),
              n('8'),
              n('9'),
              n('0'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Tecla(
                  alto: 50,
                  onTap: () => _guardar(null),
                  child: const Text(
                    'Dejar vacía',
                    style: TextStyle(fontSize: 14, color: KipuColores.gris),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _Tecla(
                  alto: 50,
                  fondo: base,
                  onTap: () => _texto.isEmpty
                      ? _mover(1)
                      : _guardar(_texto),
                  child: Text(
                    _i + 1 >= total ? 'Guardar y terminar' : 'Guardar y seguir',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      final actual = _actual();
      contenido = Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: esSiNo(esc) ? 2.3 : 1.9,
            children: [
              for (var k = 0; k < esc.valores.length; k++)
                _BotonValor(
                  valor: esc.valores[k],
                  primero: k == 0,
                  elegido: actual == esc.valores[k].codigo,
                  atajo: k + 1,
                  onTap: () => _guardar(esc.valores[k].codigo),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _Tecla(
            alto: 46,
            onTap: () => _guardar(null),
            child: const Text(
              'Dejar vacía',
              style: TextStyle(color: KipuColores.gris),
            ),
          ),
        ],
      );
    }

    final comentario = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_verComentario)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _verComentario = true),
              icon: KipuIcon(KipuIcono.apuntes, size: 18, color: base),
              label: Text('Agregar comentario', style: TextStyle(color: base)),
            ),
          )
        else ...[
          TextField(
            controller: _coment,
            focusNode: _focoComent,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Comentario (opcional)',
              hintText: 'Se guarda junto con la nota',
              suffixIcon: _coment.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Quitar comentario',
                      onPressed: () => setState(() => _coment.clear()),
                      icon: const KipuIcon(
                        KipuIcono.cerrar,
                        size: 16,
                        color: KipuColores.gris,
                      ),
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in _frases)
                ActionChip(
                  label: Text(f, style: const TextStyle(fontSize: 12.5)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: KipuColores.fondo,
                  side: BorderSide.none,
                  onPressed: () => setState(() {
                    final t = _coment.text.trim();
                    _coment.text = t.isEmpty
                        ? f
                        : (t.contains(f) ? t : '$t · $f');
                  }),
                ),
            ],
          ),
        ],
      ],
    );

    return Focus(
      focusNode: _foco,
      autofocus: true,
      onKeyEvent: _teclado,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _CabezaHoja(
                  avatar: _equipo ? null : AvatarEstudiante(_e, tam: 48),
                  icono: _equipo ? KipuIcono.equipo : null,
                  color: base,
                  titulo: _equipo
                      ? 'Equipo ${widget.equipos[_e.id]}'
                      : '${tituloNombre(_e.apellidos)}, ${tituloNombre(_e.nombres).split(' ').first}',
                  subtitulo: _equipo
                      ? '$subtitulo\n${_integrantes.map((x) => tituloNombre(x.nombres).split(' ').first).join(', ')}'
                      : subtitulo,
                ),
              ),
              IconButton(
                tooltip: 'Anterior',
                onPressed: _i > 0 ? () => _mover(-1) : null,
                icon: const KipuIcon(KipuIcono.izquierda, color: KipuColores.tinta),
              ),
              IconButton(
                tooltip: 'Siguiente sin cambiar',
                onPressed: () => _mover(1),
                icon: const KipuIcon(KipuIcono.derecha, color: KipuColores.tinta),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Avance de la columna.
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : conNota / total,
                    minHeight: 6,
                    backgroundColor: KipuColores.fondo,
                    color: base,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_i + 1} de $total · $conNota con nota',
                style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ],
          ),
          const SizedBox(height: 14),
          contenido,
          const SizedBox(height: 6),
          comentario,
          if (siguiente != null && !_equipo)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Siguiente · ${tituloNombre(siguiente.apellidos)}, ${tituloNombre(siguiente.nombres).split(' ').first}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonValor extends StatelessWidget {
  final ValorEscala valor;
  final bool primero;
  final bool elegido;
  final int atajo;
  final VoidCallback onTap;
  const _BotonValor({
    required this.valor,
    required this.primero,
    required this.elegido,
    required this.atajo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Color(valor.color);
    final fondo = primero ? c : Color.lerp(c, Colors.white, .87)!;
    final texto = primero ? Colors.white : c;
    return Material(
      color: fondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: elegido
            ? const BorderSide(color: KipuColores.tinta, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      valor.codigo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: valor.codigo.length > 3 ? 20 : 30,
                        fontWeight: FontWeight.w600,
                        color: texto,
                        height: 1,
                      ),
                    ),
                  ),
                  Text(
                    '$atajo',
                    style: TextStyle(
                      fontSize: 12,
                      color: texto.withValues(alpha: .55),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (valor.descripcion.isNotEmpty)
                Text(
                  valor.descripcion,
                  style: TextStyle(
                    fontSize: 13,
                    color: texto.withValues(alpha: .85),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Columnas

Future<void> _formColumna(
  BuildContext context, {
  required int cursoId,
  required int periodo,
  required List<Escala> escalas,
  required String escalaDefecto,
  required ColoresRegistro colores,
  List<RegistroColumna> columnas = const [],
  RegistroColumna? columna,
  required List<GrupoEquipos> grupos,
}) => _hoja(
  context,
  _FormColumna(
    grupos: grupos,
    cursoId: cursoId,
    periodo: periodo,
    escalas: escalas,
    escalaDefecto: escalaDefecto,
    colores: colores,
    columnas: columnas,
    columna: columna,
  ),
);

class _FormColumna extends StatefulWidget {
  final int cursoId;
  final int periodo;
  final List<Escala> escalas;
  final String escalaDefecto;
  final ColoresRegistro colores;

  /// Las columnas del periodo: para el código libre y la recuperación.
  final List<RegistroColumna> columnas;
  final RegistroColumna? columna;
  final List<GrupoEquipos> grupos;

  const _FormColumna({
    required this.grupos,
    required this.cursoId,
    required this.periodo,
    required this.escalas,
    required this.escalaDefecto,
    required this.colores,
    this.columnas = const [],
    this.columna,
  });

  @override
  State<_FormColumna> createState() => _FormColumnaState();
}

class _FormColumnaState extends State<_FormColumna> {
  /// Cómo se evalúa: 'mano', 'instrumento', 'asistencia', 'participacion'
  /// (o 'calculada' en columnas que ya existían).
  late String _modo = switch (widget.columna?.tipo) {
    null || 'nota' => 'mano',
    final t => t,
  };
  String get _tipo =>
      _modo == 'mano' || _modo == 'instrumento' ? 'nota' : _modo;
  ConfigColumna _cfg = const ConfigColumna();
  Calculo get _calculo => _cfg.calculo ?? const Calculo();

  /// El código se va sugiriendo solo hasta que el docente lo cambie.
  late bool _codigoAuto = widget.columna == null;
  late final _codigo = TextEditingController(
    text: widget.columna?.codigo ?? _codigoSugerido(),
  );

  Escala get _escalaActual => widget.escalas.firstWhere(
    (e) => e.id == _escala,
    orElse: () => widget.escalas.first,
  );

  Escala? get _letras => widget.escalas
      .where((e) => !e.numerica && e.valores.length > 2)
      .firstOrNull;

  /// Columnas de notas del periodo que esta puede recuperar.
  List<RegistroColumna> get _recuperables => [
    for (final c in widget.columnas)
      if (c.tipo == 'nota' && c.id != widget.columna?.id) c,
  ];

  bool get _masOpcionesAbiertas =>
      _enEquipo ||
      _cfg.recupera != null ||
      _cfg.bloqueada ||
      _cfg.ocultaEnDescarga ||
      _cfg.decimales != 0 ||
      _cfg.redondeo != Redondeo.normal;

  String _codigoSugerido() => codigoLibre(
    prefijoCodigo(_modo, instrumento: _ins?.tipo),
    [
      for (final c in widget.columnas)
        if (c.id != widget.columna?.id) c.codigo,
    ],
  );

  void _cambiarModo(String m) => setState(() {
    _modo = m;
    // La calculada nueva propone nota numérica (0 a 20).
    if (m == 'calculada' &&
        widget.columna == null &&
        widget.escalas.any((e) => e.id == 'vigesimal')) {
      _escala = 'vigesimal';
    }
    if (_codigoAuto) _codigo.text = _codigoSugerido();
  });
  late final _tema = TextEditingController(text: widget.columna?.tema);
  late String? _fecha =
      widget.columna?.fecha ??
      (widget.columna == null ? claveFecha(DateTime.now()) : null);
  late String _escala = widget.columna?.escala ?? widget.escalaDefecto;
  late bool _enEquipo = widget.columna?.enEquipo ?? false;
  late int? _grupo = widget.columna == null || !widget.columna!.enEquipo
      ? widget.grupos.lastOrNull?.id
      : grupoDe(widget.grupos, widget.columna!)?.id;
  String? _error;

  /// Instrumento elegido para la columna, el que tenía al abrir y, si en la
  /// biblioteca hay una versión editada de ese mismo instrumento, esa.
  Instrumento? _ins;
  Instrumento? _insOriginal;
  Instrumento? _insNuevo;

  @override
  void initState() {
    super.initState();
    final col = widget.columna;
    if (col != null) {
      _cargarInstrumento(col.id);
      db.leerConfigColumna(col.id).then((c) {
        if (mounted) setState(() => _cfg = c);
      });
    }
  }

  Future<void> _cargarInstrumento(int columnaId) async {
    final ins = await db.instrumentoDeColumna(columnaId);
    if (ins == null) return;
    final bib = await db.leerBiblioteca();
    final nuevo = bib.where((x) => x.id == ins.id).firstOrNull;
    if (!mounted) return;
    setState(() {
      _ins = _insOriginal = ins;
      _modo = 'instrumento';
      _insNuevo =
          nuevo != null && jsonEncode(nuevo.aJson()) != jsonEncode(ins.aJson())
          ? nuevo
          : null;
    });
  }

  Future<void> _elegirInstrumento() async {
    await db.prepararBiblioteca();
    final bib = await db.leerBiblioteca();
    final carpetas = await db.leerCarpetas();
    // Agrupados por carpeta, en el orden de las carpetas.
    final grupos = <(String, List<Instrumento>)>[
      for (final c in carpetas)
        (c.nombre, [for (final i in bib) if (i.carpeta == c.id) i]),
      (
        'Sin carpeta',
        [
          for (final i in bib)
            if (!carpetas.any((c) => c.id == i.carpeta)) i,
        ],
      ),
    ];
    if (!mounted) return;
    final r = await showDialog<Object>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Instrumento de evaluación'),
        contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        content: SizedBox(
          width: 460,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: KipuIcon(KipuIcono.notas, color: KipuColores.gris),
                title: const Text('Ninguno'),
                subtitle: const Text('Pones la nota a mano'),
                selected: _ins == null,
                onTap: () => Navigator.pop(ctx, 'ninguno'),
              ),
              for (final (nombre, lista) in grupos)
                if (lista.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                    child: Text(
                      nombre.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w600,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                  for (final i in lista)
                    ListTile(
                      leading: KipuIcon(iconoDe(i.tipo), color: KipuColores.morado),
                      title: Text(i.nombre),
                      subtitle: Text('${i.tipo.nombre} · ${i.resumen}'),
                      selected: _ins?.id == i.id,
                      onTap: () => Navigator.pop(ctx, i),
                    ),
                ],
              if (bib.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Tu biblioteca está vacía. Crea una rúbrica, lista de '
                    'cotejo o escala en Evaluación.',
                    style: TextStyle(color: KipuColores.gris),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'evaluacion'),
            child: const Text('Crear o editar en Evaluación'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (!mounted || r == null) return;
    if (r == 'evaluacion') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PantallaEvaluacion()),
      );
      return;
    }
    setState(() {
      _ins = r is Instrumento ? r : null;
      _insNuevo = null;
      final ins = _ins;
      if (ins != null && _tema.text.trim().isEmpty) _tema.text = ins.nombre;
      if (ins != null && ins.competencias.isNotEmpty) {
        _cfg = _cfg.copiar(competencia: ins.competencias.first);
      }
      if (_codigoAuto) _codigo.text = _codigoSugerido();
    });
  }

  /// Guarda el instrumento de la columna. Si se cambia por otro y ya había
  /// estudiantes evaluados, avisa porque esas marcas se pierden.
  Future<bool> _guardarInstrumento(int columnaId, bool nota) async {
    final ins = nota ? _ins : null;
    if (ins?.id == _insOriginal?.id &&
        (ins == null || identical(ins, _insOriginal))) {
      return true;
    }
    if (_insOriginal != null && ins?.id != _insOriginal!.id) {
      final marcas = await db.leerMarcas(columnaId);
      if (marcas.isNotEmpty && mounted) {
        final ok = await confirmar(
          context,
          '¿Cambiar el instrumento?',
          'Ya evaluaste a ${marcas.length} con «${_insOriginal!.nombre}». '
              'Esas marcas se borrarán; las notas puestas se quedan hasta '
              'que vuelvas a evaluar.',
          accion: 'Cambiar',
        );
        if (!ok) return false;
      }
    }
    await db.vincularInstrumento(columnaId, ins);
    return true;
  }

  Future<void> _guardar() async {
    final codigo = _codigo.text.trim();
    if (codigo.isEmpty) {
      setState(() => _error = 'Escribe un código corto, como F1 o T2');
      return;
    }
    if (_modo == 'instrumento' && _ins == null) {
      setState(() => _error = 'Elige el instrumento con el que vas a evaluar');
      return;
    }
    if (_modo == 'calculada' && _calculo.tipo == TipoCalculo.formula) {
      final err = validarFormula(_calculo.formula);
      if (err != null) {
        setState(() => _error = 'Fórmula: $err');
        return;
      }
    }
    final nota = _tipo == 'nota';
    final conEscala = tieneEscala(_tipo);
    final tema = _tema.text.trim();
    final datos = RegistroColumnasCompanion(
      cursoId: Value(widget.cursoId),
      periodo: Value(widget.periodo),
      codigo: Value(codigo),
      tema: Value(tema.isEmpty ? null : tema),
      fecha: Value(_fecha),
      tipo: Value(_tipo),
      escala: Value(conEscala ? _escala : null),
      enEquipo: Value(nota && _enEquipo),
      grupo: Value(nota && _enEquipo ? _grupo : null),
    );
    final conInstrumento = _modo == 'instrumento';
    // Las opciones que no aplican a este tipo no se guardan.
    var cfg = nota
        ? _cfg
        : _cfg.copiar(sinRecupera: true, bloqueada: false);
    if (_modo == 'calculada') cfg = cfg.copiar(calculo: _calculo);
    int id;
    if (widget.columna == null) {
      id = await db.crearColumna(datos.copyWith(orden: const Value(0)));
      if (conInstrumento) await db.vincularInstrumento(id, _ins);
    } else {
      id = widget.columna!.id;
      if (!await _guardarInstrumento(id, conInstrumento)) return;
      await db.editarColumna(id, datos);
    }
    await db.guardarConfigColumna(id, cfg);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.colores.calculadas;
    Widget etiqueta(String t) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: KipuColores.gris,
        ),
      ),
    );
    Widget tipo(
      String id,
      KipuIcono icono,
      String titulo,
      String detalle,
      double ancho, {
      bool activo = true,
    }) {
      final on = _modo == id;
      return SizedBox(
        width: ancho,
        child: Opacity(
          opacity: activo ? 1 : .5,
          child: GestureDetector(
            onTap: activo ? () => _cambiarModo(id) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: on ? Color.lerp(base, Colors.white, .93) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: on ? base : const Color(0xFFE6E7F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KipuIcon(icono, size: 26, color: base),
                  const SizedBox(height: 6),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    detalle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: KipuColores.gris,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.columna == null ? 'Nueva columna' : 'Editar columna',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        etiqueta('¿Cómo vas a evaluar?'),
        LayoutBuilder(
          builder: (context, caja) {
            final w = (caja.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                tipo('mano', KipuIcono.notas, 'Nota a mano',
                    'Escribes o tocas la nota', w),
                tipo('instrumento', KipuIcono.rubrica, 'Con instrumento',
                    'Rúbrica, lista, escala o examen', w),
                tipo('asistencia', KipuIcono.asistencia, 'Asistencia',
                    'Se llena sola con el % del periodo', w),
                tipo('participacion', KipuIcono.participa, 'Participación',
                    'Sale de los + y − junto a los nombres', w),
                tipo('calculada', KipuIcono.calculadora, 'Calculada',
                    'Promedio, nivel, suma o fórmula', w),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 104,
              child: TextField(
                controller: _codigo,
                maxLength: 8,
                onChanged: (_) => setState(() {
                  _error = null;
                  _codigoAuto = false;
                }),
                decoration: const InputDecoration(
                  labelText: 'Código',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _tema,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Tema (opcional)'),
              ),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 12.5, color: _rojo),
            ),
          ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: KipuColores.morado.withValues(alpha: .45)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final f = await showDatePicker(
                context: context,
                initialDate: _fecha == null
                    ? DateTime.now()
                    : DateTime.parse(_fecha!),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (f != null) setState(() => _fecha = claveFecha(f));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  KipuIcon(KipuIcono.calendario, size: 22, color: base),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _fecha == null
                          ? 'Sin fecha'
                          : toBeginningOfSentenceCase(
                              DateFormat(
                                "EEEE d 'de' MMMM",
                                'es_PE',
                              ).format(DateTime.parse(_fecha!)),
                            ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (_fecha != null)
                    GestureDetector(
                      onTap: () => setState(() => _fecha = null),
                      child: const KipuIcon(
                        KipuIcono.cerrar,
                        size: 18,
                        color: KipuColores.gris,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_modo == 'instrumento') ...[
          etiqueta('Instrumento de evaluación'),
          _TarjetaElegirInstrumento(
            ins: _ins,
            base: base,
            onTap: _elegirInstrumento,
            onQuitar: _ins == null
                ? null
                : () => setState(() {
                    _ins = null;
                    _insNuevo = null;
                  }),
          ),
          if (_insNuevo != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Editaste este instrumento en tu biblioteca después de '
                      'usarlo aquí.',
                      style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _ins = _insNuevo;
                      _insNuevo = null;
                    }),
                    child: const Text('Usar la versión nueva'),
                  ),
                ],
              ),
            ),
          if (_cfg.competencia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Text(
                    'Competencia: ',
                    style: TextStyle(fontSize: 13, color: KipuColores.gris),
                  ),
                  Expanded(
                    child: Text(
                      competenciaPorId(_cfg.competencia)?.nombre ??
                          _cfg.competencia,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Quitar competencia',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        setState(() => _cfg = _cfg.copiar(competencia: '')),
                    icon: const KipuIcon(
                      KipuIcono.cerrar,
                      size: 16,
                      color: KipuColores.gris,
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (_modo == 'asistencia')
          _NotaAyuda(
            base: base,
            texto:
                'Presente (P) y tarde (T) cuentan como asistencia; la falta '
                '(F) baja el %; la justificada (J) no cuenta. Usa las fechas '
                'del periodo si las configuraste en Académica.',
          ),
        if (_modo == 'participacion') ...[
          _NotaAyuda(
            base: base,
            texto:
                'Cada (+) que anotas junto al nombre suma y cada (−) resta. '
                'Se cuentan las del periodo.',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Participaciones (+) para la nota máxima',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: _cfg.meta > 1
                    ? () => setState(
                        () => _cfg = _cfg.copiar(meta: _cfg.meta - 1),
                      )
                    : null,
                icon: const Text('−', style: TextStyle(fontSize: 20)),
              ),
              Text(
                '${_cfg.meta}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _cfg = _cfg.copiar(meta: _cfg.meta + 1)),
                icon: const Text('+', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ],
        if (tieneEscala(_tipo)) ...[
          etiqueta('Escala'),
          Row(
            children: [
              for (var k = 0; k < widget.escalas.length; k++) ...[
                if (k > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _escala = widget.escalas[k].id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _escala == widget.escalas[k].id
                            ? Color.lerp(base, Colors.white, .93)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _escala == widget.escalas[k].id
                              ? base
                              : const Color(0xFFE6E7F0),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            escalaCorta(widget.escalas[k]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.escalas[k].numerica
                                ? 'Numérica'
                                : (esSiNo(widget.escalas[k])
                                      ? 'Sí / No'
                                      : 'Letras'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: KipuColores.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_modo == 'calculada')
            EditorCalculo(
              cursoId: widget.cursoId,
              periodo: widget.periodo,
              columnaId: widget.columna?.id,
              calculo: _calculo,
              cfg: _cfg,
              salida: _escalaActual,
              base: base,
              onCambio: (c) => setState(() => _cfg = _cfg.copiar(calculo: c)),
            ),
          if (_escalaActual.numerica && _letras != null) ...[
            const SizedBox(height: 10),
            _Interruptor(
              base: base,
              icono: KipuIcono.notas,
              titulo: 'Mostrar también la letra',
              detalle:
                  'La celda muestra «16 · A». Sirve con las dos normas.',
              valor: _cfg.mostrarLetra,
              onCambio: (v) =>
                  setState(() => _cfg = _cfg.copiar(mostrarLetra: v)),
            ),
          ],
          if (_modo != 'calculada') ...[
          etiqueta('Así se verá'),
          _VistaPrevia(
            escala: _escalaActual,
            letras: _cfg.mostrarLetra ? _letras : null,
            config: _cfg,
            modo: _modo,
            base: base,
          ),
          ],
          const SizedBox(height: 10),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _masOpcionesAbiertas,
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              childrenPadding: EdgeInsets.zero,
              title: const Text(
                'Más opciones',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Decimales, equipo, recuperación, bloqueo y descarga',
                style: TextStyle(fontSize: 12, color: KipuColores.gris),
              ),
              children: [
                if (_escalaActual.numerica) ...[
                  etiqueta('Decimales y redondeo'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in const [0, 1, 2])
                        ChoiceChip(
                          label: Text(
                            d == 0 ? 'Sin decimales' : '$d decimal${d > 1 ? 'es' : ''}',
                          ),
                          selected: _cfg.decimales == d,
                          onSelected: (_) => setState(
                            () => _cfg = _cfg.copiar(decimales: d),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in Redondeo.values)
                        ChoiceChip(
                          label: Text(r.nombre),
                          selected: _cfg.redondeo == r,
                          onSelected: (_) => setState(
                            () => _cfg = _cfg.copiar(redondeo: r),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 2),
                    child: Text(
                      'Ejemplo: ${ejemploRedondeo(_cfg.decimales, _cfg.redondeo)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                ],
                if (_tipo == 'nota') ...[
                  const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6E7F0), width: 1.5),
            ),
            child: Row(
              children: [
                KipuIcon(KipuIcono.equipo, size: 24, color: base),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En equipo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Una nota por equipo para todos sus integrantes',
                        style: TextStyle(fontSize: 12, color: KipuColores.gris),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enEquipo,
                  activeThumbColor: Colors.white,
                  activeTrackColor: base,
                  onChanged: (v) => setState(() => _enEquipo = v),
                ),
              ],
            ),
          ),
          if (_enEquipo) ...[
            etiqueta('¿CON QUÉ EQUIPOS?'),
            if (widget.grupos.isEmpty)
              const Text(
                'Aún no armas equipos. Hazlo en el botón + → Equipos y '
                'luego elígelos aquí.',
                style: TextStyle(fontSize: 13, color: KipuColores.gris),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in widget.grupos.reversed)
                    ChoiceChip(
                      label: Text('${g.nombre} · ${g.cantidad} eq.'),
                      selected: g.id == _grupo,
                      showCheckmark: false,
                      selectedColor: base,
                      labelStyle: TextStyle(
                        color: g.id == _grupo
                            ? Colors.white
                            : KipuColores.tinta,
                        fontWeight: g.id == _grupo
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: g.id == _grupo ? base : const Color(0xFFE6E7F0),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (_) => setState(() => _grupo = g.id),
                    ),
                ],
              ),
          ],
                  etiqueta('Recuperación'),
                  DropdownButtonFormField<int?>(
                    initialValue: _recuperables.any((c) => c.id == _cfg.recupera)
                        ? _cfg.recupera
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Esta columna recupera a…',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Ninguna'),
                      ),
                      for (final c in _recuperables)
                        DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(
                            (c.tema ?? '').isEmpty
                                ? c.codigo
                                : '${c.codigo} · ${c.tema}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(
                      () => _cfg = v == null
                          ? _cfg.copiar(sinRecupera: true)
                          : _cfg.copiar(recupera: v),
                    ),
                  ),
                  if (_cfg.recupera != null) ...[
                    const SizedBox(height: 8),
                    _Interruptor(
                      base: base,
                      icono: KipuIcono.promedio,
                      titulo: 'Cuenta la nota más alta',
                      detalle: _cfg.recuperaMasAlta
                          ? 'Si sacó más en la recuperación, se ve esa nota.'
                          : 'La nota de recuperación reemplaza a la original.',
                      valor: _cfg.recuperaMasAlta,
                      onCambio: (v) => setState(
                        () => _cfg = _cfg.copiar(recuperaMasAlta: v),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _Interruptor(
                    base: base,
                    icono: KipuIcono.candado,
                    titulo: 'Bloquear',
                    detalle: 'Nadie cambia las notas por error hasta desbloquearla',
                    valor: _cfg.bloqueada,
                    onCambio: (v) =>
                        setState(() => _cfg = _cfg.copiar(bloqueada: v)),
                  ),
                ],
                const SizedBox(height: 10),
                _Interruptor(
                  base: base,
                  icono: KipuIcono.ojoCerrado,
                  titulo: 'No incluir en la descarga',
                  detalle: 'No sale en el PDF ni en el Excel del registro',
                  valor: _cfg.ocultaEnDescarga,
                  onCambio: (v) =>
                      setState(() => _cfg = _cfg.copiar(ocultaEnDescarga: v)),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
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
              flex: 2,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: base),
                onPressed: _guardar,
                child: Text(
                  widget.columna == null ? 'Crear columna' : 'Guardar',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _menuColumna(
  BuildContext context,
  RegistroColumna col,
  List<RegistroColumna> columnas, {
  ConfigColumna config = const ConfigColumna(),
  required List<GrupoEquipos> grupos,
  required List<Estudiante> estudiantes,
  required ColoresRegistro colores,
  required List<Escala> escalas,
  required String escalaDefecto,
}) async {
  final base = colores.calculadas;
  final grupo = grupoDe(grupos, col);
  // Orden de pantalla: las libres y al final la fijada.
  final orden = [
    ...columnas.where((c) => !c.fijada),
    ...columnas.where((c) => c.fijada),
  ];
  final i = orden.indexWhere((c) => c.id == col.id);
  Widget opcion(KipuIcono icono, String texto, String accion, {Color? c}) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: KipuIcon(icono, size: 24, color: c ?? base),
        title: Text(
          texto,
          style: TextStyle(fontWeight: FontWeight.w500, color: c),
        ),
        onTap: () => Navigator.pop(context, accion),
      );
  final accion = await _hoja<String>(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabezaHoja(
          icono: switch (col.tipo) {
            'nota' => KipuIcono.notas,
            'asistencia' => KipuIcono.asistencia,
            'participacion' => KipuIcono.participa,
            _ => KipuIcono.calculadora,
          },
          color: base,
          titulo: col.codigo,
          subtitulo: [
            if ((col.tema ?? '').isNotEmpty) col.tema!,
            switch (col.tipo) {
              'nota' => 'Columna de notas',
              'asistencia' => 'Asistencia del periodo',
              'participacion' => 'Participación del periodo',
              _ => 'Columna calculada',
            },
          ].join(' · '),
        ),
        const SizedBox(height: 10),
        if (grupo != null)
          opcion(KipuIcono.equipo, 'Ver integrantes de los equipos', 'equipos'),
        opcion(KipuIcono.editar, 'Editar columna', 'editar'),
        if (col.tipo == 'nota')
          opcion(
            KipuIcono.candado,
            config.bloqueada ? 'Desbloquear' : 'Bloquear para no cambiar notas',
            'bloquear',
          ),
        opcion(
          KipuIcono.chincheta,
          col.fijada ? 'Desfijar' : 'Fijar a la derecha',
          'fijar',
        ),
        if (!col.fijada && i > 0)
          opcion(KipuIcono.izquierda, 'Mover a la izquierda', 'izq'),
        if (!col.fijada && i < orden.length - 1 && !orden[i + 1].fijada)
          opcion(KipuIcono.derecha, 'Mover a la derecha', 'der'),
        opcion(KipuIcono.borrar, 'Eliminar columna', 'borrar', c: _rojo),
      ],
    ),
  );
  if (!context.mounted) return;
  switch (accion) {
    case 'editar':
      await _formColumna(
        context,
        cursoId: col.cursoId,
        periodo: col.periodo,
        escalas: escalas,
        escalaDefecto: escalaDefecto,
        colores: colores,
        columna: col,
        columnas: columnas,
        grupos: grupos,
      );
    case 'bloquear':
      await db.guardarConfigColumna(
        col.id,
        config.copiar(bloqueada: !config.bloqueada),
      );
    case 'equipos':
      await _hoja(
        context,
        _VerEquipos(
          grupo: grupo!,
          estudiantes: estudiantes,
          colores: colores,
          columna: col,
        ),
        ancho: 600,
      );
    case 'fijar':
      await db.fijarColumna(col, !col.fijada);
    case 'izq':
      await db.moverColumna(orden, i, -1);
    case 'der':
      await db.moverColumna(orden, i, 1);
    case 'borrar':
      if (await confirmar(
        context,
        '¿Eliminar la columna ${col.codigo}?',
        'Se borrarán también sus notas.',
      )) {
        await db.borrarColumna(col.id);
      }
  }
}

// Conducta

const _positivas = [
  (KipuIcono.participa, 'Participa'),
  (KipuIcono.corazon, 'Ayuda a un compañero'),
  (KipuIcono.equipo, 'Trabaja en equipo'),
  (KipuIcono.horario, 'Puntual'),
];
const _porMejorar = [
  (KipuIcono.mochila, 'No trae material'),
  (KipuIcono.charla, 'Interrumpe'),
  (KipuIcono.libro, 'Sin tarea'),
  (KipuIcono.celular, 'Usa el celular'),
];

Future<void> _anotarConducta(
  BuildContext context,
  Estudiante e,
  ColoresRegistro colores,
) {
  final hoy = claveFecha(DateTime.now());
  return _hoja(
    context,
    StreamBuilder<List<Conducta>>(
      stream: db.verConductas(e.id),
      builder: (ctx, snap) {
        final todas = snap.data ?? const <Conducta>[];
        final deHoy = todas.where((c) => c.fecha == hoy).toList();
        final p = deHoy.where((c) => c.positiva).length;
        final n = deHoy.length - p;
        Widget boton((KipuIcono, String) o, bool positiva) {
          final color = positiva ? _verde : _rojo;
          return Material(
            color: positiva ? const Color(0xFFEEF9F4) : const Color(0xFFFDF0F2),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => db.anotarConducta(e.id, hoy, positiva, o.$2),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    KipuIcon(o.$1, size: 22, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        o.$2,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color.lerp(color, Colors.black, .2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        Widget grilla(List<(KipuIcono, String)> l, bool positiva) =>
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.2,
              children: [for (final o in l) boton(o, positiva)],
            );
        Widget titulo(String t, Color c) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            t,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CabezaHoja(
              avatar: AvatarEstudiante(e, tam: 48),
              color: colores.calculadas,
              titulo:
                  '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres).split(' ').first}',
              subtitulo:
                  'Conducta · ${toBeginningOfSentenceCase(DateFormat("EEEE d 'de' MMMM", 'es_PE').format(DateTime.now()))}',
              cola: _ChipConducta(conducta: (p, n), onTap: () {}),
            ),
            titulo('Positivas', _verde),
            grilla(_positivas, true),
            titulo('Por mejorar', _rojo),
            grilla(_porMejorar, false),
            if (deHoy.isNotEmpty) ...[
              titulo('Anotado hoy · toca para quitar', KipuColores.gris),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in deHoy)
                    InputChip(
                      label: Text(c.motivo),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        color: c.positiva ? _verde : _rojo,
                      ),
                      backgroundColor: c.positiva
                          ? const Color(0xFFEEF9F4)
                          : const Color(0xFFFDF0F2),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      deleteIcon: KipuIcon(
                        KipuIcono.cerrar,
                        size: 15,
                        color: c.positiva ? _verde : _rojo,
                      ),
                      onDeleted: () => db.borrarConducta(c.id),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: KipuColores.fondo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'En total: +${todas.where((c) => c.positiva).length} · −${todas.where((c) => !c.positiva).length}. '
                'Más adelante podrá volverse una nota del registro.',
                style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colores.calculadas,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Listo'),
            ),
          ],
        );
      },
    ),
  );
}

// Equipos

Future<void> _editarEquipos(
  BuildContext context,
  int cursoId,
  List<Estudiante> estudiantes,
  List<GrupoEquipos> grupos,
  ColoresRegistro colores,
) => _hoja(
  context,
  _Equipos(
    cursoId: cursoId,
    estudiantes: estudiantes,
    grupos: grupos,
    colores: colores,
  ),
  ancho: 600,
);

String _nombreCorto(Estudiante e) =>
    '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres).split(' ').first}';

String _fechaCorta(String f) =>
    DateFormat('d MMM', 'es_PE').format(DateTime.parse(f)).replaceAll('.', '');

/// Equipos del curso: los de cada tema quedan guardados para volver a verlos
/// y para elegirlos en las columnas en equipo.
class _Equipos extends StatefulWidget {
  final int cursoId;
  final List<Estudiante> estudiantes;
  final List<GrupoEquipos> grupos;
  final ColoresRegistro colores;
  const _Equipos({
    required this.cursoId,
    required this.estudiantes,
    required this.grupos,
    required this.colores,
  });

  @override
  State<_Equipos> createState() => _EquiposState();
}

class _EquiposState extends State<_Equipos> {
  late var _grupos = [...widget.grupos];
  late final _usos = db.todasLasColumnas().then(
    (cs) => [
      for (final c in cs)
        if (c.cursoId == widget.cursoId && c.enEquipo) c,
    ],
  );

  // Editor: null = lista de equipos anteriores.
  GrupoEquipos? _editando;
  GrupoEquipos? _viendo;
  final _nombre = TextEditingController();
  final Map<int, int> _eq = {};
  int _cantidad = 4;

  Color get base => widget.colores.calculadas;

  void _editar(GrupoEquipos? g) => setState(() {
    final id = _grupos.fold(0, (a, x) => max(a, x.id)) + 1;
    _editando =
        g ??
        GrupoEquipos(
          id: id,
          nombre: '',
          creado: claveFecha(DateTime.now()),
          equipos: const {},
        );
    _viendo = null;
    _nombre.text = g?.nombre ?? '';
    _eq
      ..clear()
      ..addAll(g?.equipos ?? const {});
    _cantidad = max(g?.cantidad ?? 4, 2);
  });

  void _alAzar() => setState(() {
    final l = [...widget.estudiantes]..shuffle();
    _eq.clear();
    for (var i = 0; i < l.length; i++) {
      _eq[l[i].id] = i % _cantidad + 1;
    }
  });

  Future<void> _guardar() async {
    final g = _editando!;
    _eq.removeWhere((_, v) => v > _cantidad);
    final nombre = _nombre.text.trim().isEmpty
        ? 'Equipos ${_fechaCorta(g.creado)}'
        : _nombre.text.trim();
    final nuevo = g.copiar(nombre: nombre, equipos: {..._eq});
    final i = _grupos.indexWhere((x) => x.id == g.id);
    _grupos = [..._grupos];
    if (i < 0) {
      _grupos.add(nuevo);
    } else {
      _grupos[i] = nuevo;
    }
    await db.guardarGruposEquipos(widget.cursoId, _grupos);
    setState(() {
      _editando = null;
      _viendo = nuevo;
    });
  }

  Future<void> _borrar(GrupoEquipos g) async {
    if (!await confirmar(
      context,
      '¿Eliminar "${g.nombre}"?',
      'Las notas no se borran. Las columnas que los usaban pasan a usar los '
          'equipos más nuevos.',
    )) {
      return;
    }
    _grupos = _grupos.where((x) => x.id != g.id).toList();
    await db.guardarGruposEquipos(widget.cursoId, _grupos);
    setState(() {
      _editando = null;
      _viendo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_editando != null) return _editor();
    if (_viendo != null) {
      return _VerEquipos(
        grupo: _viendo!,
        estudiantes: widget.estudiantes,
        colores: widget.colores,
        onAtras: () => setState(() => _viendo = null),
        onEditar: () => _editar(_viendo),
      );
    }
    return _lista();
  }

  Widget _lista() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _CabezaHoja(
        icono: KipuIcono.equipo,
        color: base,
        titulo: 'Equipos',
        subtitulo: 'Arma equipos por tema y elígelos en cada columna en equipo',
      ),
      const SizedBox(height: 16),
      if (_grupos.isEmpty)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: KipuColores.fondo,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Aún no hay equipos. Arma los primeros: quedan guardados con su '
            'tema para volver a verlos cuando quieras.',
            style: TextStyle(fontSize: 13.5, color: KipuColores.gris),
          ),
        )
      else ...[
        const Text(
          'EQUIPOS ANTERIORES',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: .4,
            color: KipuColores.gris,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<RegistroColumna>>(
          future: _usos,
          builder: (context, snap) {
            final usos = snap.data ?? const <RegistroColumna>[];
            return Column(
              children: [
                for (final g in _grupos.reversed)
                  _TarjetaGrupo(
                    grupo: g,
                    usos: [
                      for (final c in usos)
                        if (grupoDe(_grupos, c)?.id == g.id) c,
                    ],
                    color: base,
                    onTap: () => setState(() => _viendo = g),
                  ),
              ],
            );
          },
        ),
      ],
      const SizedBox(height: 12),
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: base,
          minimumSize: const Size(0, 50),
        ),
        onPressed: () => _editar(null),
        icon: const KipuIcon(KipuIcono.agregar, size: 20, color: Colors.white),
        label: const Text('Armar nuevos equipos'),
      ),
    ],
  );

  Widget _editor() {
    final g = _editando!;
    final nuevo = !_grupos.any((x) => x.id == g.id);
    final conteo = <int, int>{};
    for (final v in _eq.values) {
      if (v <= _cantidad) conteo[v] = (conteo[v] ?? 0) + 1;
    }
    final sinEquipo = widget.estudiantes
        .where((e) => _eq[e.id] == null || _eq[e.id]! > _cantidad)
        .length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabezaHoja(
          icono: KipuIcono.equipo,
          color: base,
          titulo: nuevo ? 'Nuevos equipos' : 'Editar equipos',
          subtitulo: 'Ponles el tema o la actividad para ubicarlos después',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nombre,
          autofocus: nuevo,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Tema o actividad',
            hintText: 'Ej.: Exposición de enlaces químicos',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
          decoration: BoxDecoration(
            color: KipuColores.fondo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Cantidad de equipos',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: _cantidad > 2
                    ? () => setState(() => _cantidad--)
                    : null,
                icon: KipuIcon(KipuIcono.izquierda, size: 20, color: base),
              ),
              Text(
                '$_cantidad',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _cantidad < 12
                    ? () => setState(() => _cantidad++)
                    : null,
                icon: KipuIcon(KipuIcono.derecha, size: 20, color: base),
              ),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: base,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: _alAzar,
                icon: KipuIcon(KipuIcono.dado, size: 18, color: base),
                label: const Text('Al azar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var k = 1; k <= _cantidad; k++)
              _Pildora('Eq. $k · ${conteo[k] ?? 0}', _colorEquipo(k)),
            if (sinEquipo > 0)
              _Pildora('Sin equipo · $sinEquipo', KipuColores.gris),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .4,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final e in widget.estudiantes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      AvatarEstudiante(e, tam: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _nombreCorto(e),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      DropdownButton<int>(
                        value: _eq[e.id] != null && _eq[e.id]! <= _cantidad
                            ? _eq[e.id]
                            : 0,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(12),
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'Sin equipo',
                              style: TextStyle(color: KipuColores.gris),
                            ),
                          ),
                          for (var k = 1; k <= _cantidad; k++)
                            DropdownMenuItem(
                              value: k,
                              child: Text(
                                'Equipo $k',
                                style: TextStyle(
                                  color: _colorEquipo(k),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() {
                          if (v == null || v == 0) {
                            _eq.remove(e.id);
                          } else {
                            _eq[e.id] = v;
                          }
                        }),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (!nuevo) ...[
              IconButton.outlined(
                tooltip: 'Eliminar estos equipos',
                onPressed: () => _borrar(g),
                icon: const KipuIcon(KipuIcono.borrar, size: 21, color: _rojo),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _editando = null;
                  if (!nuevo) _viendo = g;
                }),
                child: const Text('Volver'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: base),
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _tonosEquipo = [
  Color(0xFF5B4BD6),
  Color(0xFF2557C7),
  Color(0xFF0E7A5F),
  Color(0xFFB8336C),
  Color(0xFFC25A16),
  Color(0xFF7A5A12),
];

Color _colorEquipo(int k) => _tonosEquipo[(k - 1) % _tonosEquipo.length];

class _Pildora extends StatelessWidget {
  final String texto;
  final Color color;
  const _Pildora(this.texto, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Color.lerp(color, Colors.white, .88),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

class _TarjetaGrupo extends StatelessWidget {
  final GrupoEquipos grupo;
  final List<RegistroColumna> usos;
  final Color color;
  final VoidCallback onTap;
  const _TarjetaGrupo({
    required this.grupo,
    required this.usos,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE6E7F0), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              KipuIcon(KipuIcono.equipo, size: 26, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grupo.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${grupo.cantidad} equipos · ${grupo.equipos.length} '
                      'estudiantes · ${_fechaCorta(grupo.creado)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                    if (usos.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          for (final c in usos)
                            _Pildora(
                              '${c.codigo} · ${c.periodo}.° per.',
                              color,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const KipuIcon(
                KipuIcono.derecha,
                size: 18,
                color: KipuColores.gris,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Quiénes integran cada equipo de un grupo, para llamarlos en clase.
class _VerEquipos extends StatelessWidget {
  final GrupoEquipos grupo;
  final List<Estudiante> estudiantes;
  final ColoresRegistro colores;
  final RegistroColumna? columna;
  final VoidCallback? onAtras;
  final VoidCallback? onEditar;
  const _VerEquipos({
    required this.grupo,
    required this.estudiantes,
    required this.colores,
    this.columna,
    this.onAtras,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final porId = {for (final e in estudiantes) e.id: e};
    final col = columna;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabezaHoja(
          icono: KipuIcono.equipo,
          color: colores.calculadas,
          titulo: grupo.nombre,
          subtitulo: [
            if (col != null) 'Columna ${col.codigo}',
            '${grupo.cantidad} equipos',
            'armados el ${_fechaCorta(grupo.creado)}',
          ].join(' · '),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final dos = c.maxWidth >= 400;
            final tarjetas = [
              for (final MapEntry(key: k, value: ids)
                  in grupo.integrantes.entries)
                Container(
                  width: dos ? (c.maxWidth - 8) / 2 : c.maxWidth,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Color.lerp(_colorEquipo(k), Colors.white, .93),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipo $k',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _colorEquipo(k),
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final id in ids)
                        if (porId[id] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                AvatarEstudiante(porId[id]!, tam: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _nombreCorto(porId[id]!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
            ];
            return Wrap(spacing: 8, runSpacing: 8, children: tarjetas);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onAtras ?? () => Navigator.pop(context),
                child: Text(onAtras == null ? 'Cerrar' : 'Volver'),
              ),
            ),
            if (onEditar != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colores.calculadas,
                  ),
                  onPressed: onEditar,
                  child: const Text('Editar equipos'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// Colores del registro

Future<void> _editarColores(
  BuildContext context,
  int cursoId,
  ColoresRegistro actuales,
) => _hoja(context, _Colores(cursoId: cursoId, actuales: actuales));

class _Colores extends StatefulWidget {
  final int cursoId;
  final ColoresRegistro actuales;
  const _Colores({required this.cursoId, required this.actuales});

  @override
  State<_Colores> createState() => _ColoresState();
}

class _ColoresState extends State<_Colores> {
  late var _c = widget.actuales;
  late final _colegio = ColoresRegistro.delColegio(widget.actuales.base);

  ColoresRegistro _con({
    Color? cabecera,
    Color? nombres,
    Color? calculadas,
    Color? fijada,
  }) => ColoresRegistro(
    base: _c.base,
    cabecera: cabecera ?? _c.cabecera,
    nombres: nombres ?? _c.nombres,
    calculadas: calculadas ?? _c.calculadas,
    fijada: fijada ?? _c.fijada,
    propios: true,
  );

  Widget _fila(
    String titulo,
    String detalle,
    List<Color> opciones,
    Color actual,
    ValueChanged<Color> elegir,
  ) {
    final lista = [
      ...opciones.where((c) => c.toARGB32() != actual.toARGB32()).take(4),
    ];
    lista.insert(0, actual);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _linea)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detalle,
                  style: const TextStyle(fontSize: 12, color: KipuColores.gris),
                ),
              ],
            ),
          ),
          for (final c in lista)
            GestureDetector(
              onTap: () => setState(() => elegir(c)),
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(left: 7),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: c.toARGB32() == actual.toARGB32()
                          ? KipuColores.tinta
                          : const Color(0xFFE3E4EE),
                      spreadRadius: c.toARGB32() == actual.toARGB32() ? 2 : 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = _colegio;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabezaHoja(
          icono: KipuIcono.paleta,
          color: _c.calculadas,
          titulo: 'Colores del registro',
          subtitulo: 'Solo para este curso',
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                Expanded(flex: 22, child: ColoredBox(color: _c.nombres)),
                Expanded(flex: 30, child: ColoredBox(color: _c.cabecera)),
                Expanded(flex: 10, child: ColoredBox(color: _c.calculadas)),
                Expanded(flex: 12, child: ColoredBox(color: _c.fijada)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        _fila(
          'Cabecera',
          'Fila de códigos y temas',
          [
            g.cabecera,
            const Color(0xFFE2ECFD),
            const Color(0xFFE3F5EE),
            const Color(0xFFFCE3EE),
            const Color(0xFFFDE9DB),
            const Color(0xFFEFEFF4),
          ],
          _c.cabecera,
          (c) => _c = _con(cabecera: c),
        ),
        _fila(
          'Fondo de nombres',
          'Columna fija de la izquierda',
          [
            g.nombres,
            const Color(0xFFEEF3FE),
            const Color(0xFFF1FAF6),
            const Color(0xFFF7F7F9),
            Colors.white,
          ],
          _c.nombres,
          (c) => _c = _con(nombres: c),
        ),
        _fila(
          'Columnas calculadas',
          'Promedios',
          [
            g.calculadas,
            const Color(0xFF3D7BF0),
            const Color(0xFF16A37F),
            const Color(0xFFE5508E),
            const Color(0xFFF07A2D),
          ],
          _c.calculadas,
          (c) => _c = _con(calculadas: c),
        ),
        _fila(
          'Columna fijada',
          'La que queda a la derecha',
          [
            g.fijada,
            const Color(0xFF1E3A8A),
            const Color(0xFF0B5E49),
            const Color(0xFF8E1F4E),
            KipuColores.tinta,
          ],
          _c.fijada,
          (c) => _c = _con(fijada: c),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await db.guardarColoresRegistro(widget.cursoId, null);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const KipuIcon(
                  KipuIcono.deshacer,
                  size: 18,
                  color: KipuColores.gris,
                ),
                label: const Text('Color del colegio'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _c.calculadas),
                onPressed: () async {
                  await db.guardarColoresRegistro(widget.cursoId, _c);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


/// Muestra el instrumento elegido para una columna (o «Ninguno»).
class _TarjetaElegirInstrumento extends StatelessWidget {
  final Instrumento? ins;
  final Color base;
  final VoidCallback onTap;
  final VoidCallback? onQuitar;
  const _TarjetaElegirInstrumento({
    required this.ins,
    required this.base,
    required this.onTap,
    this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final i = ins;
    return Material(
      color: i == null ? Colors.white : Color.lerp(base, Colors.white, .93),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: i == null ? const Color(0xFFE6E7F0) : base,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              KipuIcon(
                i == null ? KipuIcono.notas : iconoDe(i.tipo),
                size: 24,
                color: base,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i == null ? 'Ninguno: nota a mano' : i.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      i == null
                          ? 'Toca para usar una rúbrica, lista de cotejo o escala'
                          : '${i.tipo.nombre} · ${i.resumen}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: KipuColores.gris,
                      ),
                    ),
                  ],
                ),
              ),
              if (onQuitar != null)
                IconButton(
                  tooltip: 'Quitar instrumento',
                  onPressed: onQuitar,
                  icon: const KipuIcon(
                    KipuIcono.cerrar,
                    size: 18,
                    color: KipuColores.gris,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: KipuIcon(
                    KipuIcono.flecha,
                    size: 18,
                    color: KipuColores.gris,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Texto de ayuda con fondo suave.
class _NotaAyuda extends StatelessWidget {
  final String texto;
  final Color base;
  const _NotaAyuda({required this.texto, required this.base});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    decoration: BoxDecoration(
      color: Color.lerp(base, Colors.white, .92),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      texto,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 13, height: 1.35),
    ),
  );
}

/// Opción con interruptor, con el mismo estilo que «En equipo».
class _Interruptor extends StatelessWidget {
  final Color base;
  final KipuIcono icono;
  final String titulo;
  final String detalle;
  final bool valor;
  final ValueChanged<bool> onCambio;
  const _Interruptor({
    required this.base,
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.valor,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6E7F0), width: 1.5),
    ),
    child: Row(
      children: [
        KipuIcon(icono, size: 22, color: base),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                detalle,
                style: const TextStyle(fontSize: 12, color: KipuColores.gris),
              ),
            ],
          ),
        ),
        Switch(
          value: valor,
          activeThumbColor: Colors.white,
          activeTrackColor: base,
          onChanged: onCambio,
        ),
      ],
    ),
  );
}

/// Cómo se verá la celda con la escala y las opciones elegidas.
class _VistaPrevia extends StatelessWidget {
  final Escala escala;
  final Escala? letras;
  final ConfigColumna config;
  final String modo;
  final Color base;
  const _VistaPrevia({
    required this.escala,
    required this.letras,
    required this.config,
    required this.modo,
    required this.base,
  });

  @override
  Widget build(BuildContext context) {
    final String valor;
    final String explicacion;
    if (modo == 'asistencia' || modo == 'participacion') {
      const pct = 85.0;
      valor = valorDePorcentaje(
        pct,
        escala,
        decimales: config.decimales,
        redondeo: config.redondeo,
      );
      explicacion = modo == 'asistencia'
          ? 'Ejemplo: asistió al 85 % de las clases.'
          : 'Ejemplo: tiene el 85 % de la meta de participaciones.';
    } else if (escala.numerica) {
      final hi = escala.maximo ?? 20;
      final crudo = hi * .775;
      valor = numeroGuardado(
        redondear(crudo, config.decimales, config.redondeo),
        config.decimales,
      );
      explicacion =
          'Ejemplo: ${crudo.toString().replaceAll('.', ',')} se guarda como '
          '${valor.replaceAll('.', ',')}.';
    } else {
      valor = escala.valores.length > 1
          ? escala.valores[1].codigo
          : escala.valores.first.codigo;
      explicacion = 'Ejemplo de una nota con esta escala.';
    }
    final letra = letras == null ? null : letraDeNumero(valor, escala, letras!);
    return Row(
      children: [
        Container(
          width: 92,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E7F0), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VistaNota(valor, escala),
              if (letra != null) ...[
                const SizedBox(width: 4),
                Text(
                  letra,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KipuColores.gris,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            explicacion,
            style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
          ),
        ),
      ],
    );
  }
}
