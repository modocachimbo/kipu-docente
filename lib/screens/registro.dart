import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import '../data/academico.dart';
import '../data/database.dart';
import '../data/paises.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'asistencia.dart';
import 'cursos.dart' show colorColegio, confirmar;
import 'estudiantes.dart';
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
  late final _equipos = db.verEquipos(_cursoId);
  late final _conducta = db.verConductaDelDia(_cursoId, _hoy);
  late final _asistencia = db.verAsistencia(_cursoId, _hoy);
  late final _config = db.verAnioActivo().asyncExpand(db.verConfigAcademica);
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
                  (conducta) => _Escucha<Map<int, int>>(
                    _equipos,
                    (equipos) => _Escucha<Map<int, String>>(
                      _asistencia,
                      (asistencia) => _pantalla(
                        context,
                        ancho: ancho,
                        colores: colores,
                        config: config,
                        estudiantes: estudiantes,
                        columnas: columnas ?? const [],
                        notas: notas ?? const {},
                        conducta: conducta ?? const {},
                        equipos: equipos ?? const {},
                        asistencia: asistencia ?? const {},
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
    required Map<int, int> equipos,
    required Map<int, String> asistencia,
  }) {
    final cur = widget.datos.curso;
    final periodos = config?.periodos ?? periodosDe('bimestre');
    final escalas = {for (final e in config?.escalas ?? peru.escalas) e.id: e};
    final escalaDefecto = config?.escalaPorDefecto ?? peru.escalas.first.id;
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
        c.tipo == 'nota' ? escalas[c.escala ?? escalaDefecto] : null;

    void nuevaColumna() => _formColumna(
      context,
      cursoId: _cursoId,
      periodo: _periodo,
      escalas: escalas.values.toList(),
      escalaDefecto: escalaDefecto,
      colores: colores,
      codigoSugerido: 'N${columnas.where((c) => c.tipo == 'nota').length + 1}',
    );

    Future<void> accion(String v) => _accionRegistro(
      context,
      v,
      datos: widget.datos,
      periodo: _periodo,
      periodos: periodos,
      colores: colores,
      estudiantes: delPeriodo,
      equipos: equipos,
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
        equipos: equipos,
        colores: colores,
        escalaDe: escalaDe,
        onNueva: nuevaColumna,
        onEstudiante: (e) =>
            editarEstudiante(context, _cursoId, e, _periodo, nombrePeriodo),
        onConducta: (e) => _anotarConducta(context, e, colores),
        onColumna: (c) => _menuColumna(
          context,
          c,
          columnas,
          colores: colores,
          escalas: escalas.values.toList(),
          escalaDefecto: escalaDefecto,
        ),
        onCelda: (e, c) {
          if (c.tipo != 'nota') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Las columnas calculadas se configurarán pronto.',
                ),
              ),
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
            equipos: equipos,
            colores: colores,
          );
        },
      );
    }

    return Scaffold(
      drawer: const MenuCajon(),
      backgroundColor: KipuColores.fondo,
      // Sube un poco para no tapar la fila de medias.
      floatingActionButton: _BotonMas(
        colores: colores,
        sinEstudiantes: total == 0,
        elevar: total == 0 ? 0 : (ancho ? 54 : 46),
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

typedef _Opcion = (String accion, KipuIcono icono, String texto);

Future<void> _accionRegistro(
  BuildContext context,
  String v, {
  required CursoConColegio datos,
  required int periodo,
  required List<Periodo> periodos,
  required ColoresRegistro colores,
  required List<Estudiante> estudiantes,
  required Map<int, int> equipos,
  required VoidCallback nuevaColumna,
}) async {
  final id = datos.curso.id;
  String nombre(int p) =>
      p >= 1 && p <= periodos.length ? periodos[p - 1].nombre : '$p.° periodo';
  switch (v) {
    case 'columna':
      nuevaColumna();
    case 'azar':
      await _alumnoAlAzar(context, estudiantes, colores);
    case 'estudiante':
      await editarEstudiante(context, id, null, periodo, nombre);
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
      await _editarEquipos(context, id, estudiantes, equipos, colores);
    case 'colores':
      await _editarColores(context, id, colores);
  }
}

/// Botón flotante "+" que despliega todas las opciones de abajo hacia arriba.
class _BotonMas extends StatelessWidget {
  final ColoresRegistro colores;
  final bool sinEstudiantes;
  final double elevar;
  final ValueChanged<String> onAccion;
  const _BotonMas({
    required this.colores,
    required this.sinEstudiantes,
    required this.elevar,
    required this.onAccion,
  });

  static const _opciones = <_Opcion>[
    ('colores', KipuIcono.paleta, 'Colores del registro'),
    ('equipos', KipuIcono.equipo, 'Equipos'),
    ('columnas', KipuIcono.copia, 'Importar columnas'),
    ('importar', KipuIcono.pegar, 'Importar estudiantes'),
    ('estudiante', KipuIcono.secciones, 'Nuevo estudiante'),
    ('azar', KipuIcono.participa, 'Alumno al azar'),
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
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + elevar),
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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: elevar),
    child: FloatingActionButton(
      tooltip: 'Más opciones',
      backgroundColor: colores.calculadas,
      shape: const CircleBorder(),
      onPressed: () => _abrir(context),
      child: const KipuIcon(KipuIcono.agregar, size: 28, color: Colors.white),
    ),
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
  final Map<int, int> equipos;
  final ColoresRegistro colores;
  final Escala? Function(RegistroColumna) escalaDe;
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
    required this.equipos,
    required this.colores,
    required this.escalaDe,
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
    final pieH = ancho ? 50.0 : 44.0;

    Widget pie(RegistroColumna col, double ancho, {bool fijada = false}) =>
        _CeldaMedia(
          texto: col.tipo == 'nota'
              ? mediaColumna([
                  for (final e in w.estudiantes) ?w.notas[col.id]?[e.id],
                ], w.escalaDe(col))
              : null,
          escala: w.escalaDe(col),
          ancho: ancho,
          alto: pieH,
          fijada: fijada,
        );

    Widget lista(int i, Widget Function(Estudiante e, int i) fila) =>
        ListView.builder(
          controller: _v[i],
          padding: const EdgeInsets.only(bottom: 90),
          itemExtent: filaH,
          itemCount: w.estudiantes.length,
          itemBuilder: (_, k) => fila(w.estudiantes[k], k),
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
            ),
          ),
          Container(
            height: pieH,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: ancho ? 18 : 12),
            decoration: BoxDecoration(
              color: c.cabecera,
              border: const Border(top: BorderSide(color: _linea)),
            ),
            child: Text(
              ancho ? 'Media de la columna' : 'Media',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.tintaCabecera,
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
                          valor: w.notas[col.id]?[e.id],
                          escala: w.escalaDe(col),
                          calculada: col.tipo != 'nota',
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
                ),
              ),
              Container(
                height: pieH,
                decoration: BoxDecoration(
                  color: c.cabecera,
                  border: const Border(top: BorderSide(color: _linea)),
                ),
                child: Row(
                  children: [
                    for (final col in libres) pie(col, celdaW),
                    SizedBox(width: agregarW),
                  ],
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
                  valor: w.notas[fija.id]?[e.id],
                  escala: w.escalaDe(fija),
                  calculada: fija.tipo != 'nota',
                  fijada: true,
                  colores: c,
                  ancho: fijaW,
                  onTap: () => w.onCelda(e, fija),
                ),
              ),
            ),
            Container(
              height: pieH,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: .15)),
                ),
              ),
              child: pie(fija, fijaW, fijada: true),
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
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: pieH,
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.cabecera,
                          border: const Border(top: BorderSide(color: _linea)),
                        ),
                      ),
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
  final ColoresRegistro colores;
  final double ancho;
  final bool compacta;
  final VoidCallback onTap;

  const _CabeceraColumna({
    required this.columna,
    required this.escala,
    required this.colores,
    required this.ancho,
    required this.compacta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final col = columna;
    final calculada = col.tipo != 'nota';
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
    final detalle = calculada
        ? (col.fijada ? 'Fija · calculada' : 'Calculada')
        : [?fecha, escalaCorta(escala)].join(' · ');

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
                      col.fijada ? KipuIcono.chincheta : KipuIcono.calculadora,
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
  final Escala? escala;
  final bool calculada;
  final bool fijada;
  final ColoresRegistro colores;
  final double ancho;
  final VoidCallback onTap;

  const _Celda({
    required this.valor,
    required this.escala,
    required this.calculada,
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
          child: calculada && valor == null
              ? Text(
                  '—',
                  style: TextStyle(
                    color: fijada
                        ? Colors.white.withValues(alpha: .45)
                        : const Color(0xFFB0B4D0),
                  ),
                )
              : VistaNota(valor, escala, sobreOscuro: fijada),
        ),
      ),
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
                  KipuIcono.participa,
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

Future<T?> _hoja<T>(BuildContext context, Widget contenido) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(ctx).bottom + 20,
        ),
        child: SingleChildScrollView(child: contenido),
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
                fontSize: 18.5,
                fontWeight: FontWeight.w600,
              ),
            ),
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
}) => _hoja(
  context,
  _PonerNota(
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
  final RegistroColumna columna;
  final Escala escala;
  final List<Estudiante> estudiantes;
  final int inicio;
  final Map<int, String> notas;
  final Map<int, int> equipos;
  final ColoresRegistro colores;

  const _PonerNota({
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
      valor = n.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    for (final m in _integrantes) {
      await db.ponerNota(widget.columna.id, m.id, valor);
      if (valor == null) {
        _notas.remove(m.id);
      } else {
        _notas[m.id] = valor;
      }
    }
    _mover(1);
  }

  void _mover(int paso) {
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

  @override
  Widget build(BuildContext context) {
    final col = widget.columna;
    final esc = widget.escala;
    final base = widget.colores.calculadas;
    final total = widget.estudiantes.length;
    final siguiente = _i + 1 < total ? widget.estudiantes[_i + 1] : null;
    final subtitulo = [
      col.codigo,
      if ((col.tema ?? '').isNotEmpty) col.tema!,
      escalaCorta(esc),
    ].join(' · ');

    Widget contenido;
    if (esc.numerica) {
      Widget n(String t) => _Tecla(
        onTap: () => _tecla(t),
        child: Text(
          t,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      );
      contenido = Column(
        children: [
          Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _error == null
                  ? Color.lerp(base, Colors.white, .9)
                  : const Color(0xFFFCE8EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _texto.isEmpty ? ' ' : _texto,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: _error == null
                        ? widget.colores.tintaCabecera
                        : _rojo,
                  ),
                ),
                Container(width: 2, height: 34, color: base),
              ],
            ),
          ),
          SizedBox(
            height: 26,
            child: Center(
              child: Text(
                _error ?? 'Puedes escribir con el teclado y pulsar Enter',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _error == null ? KipuColores.gris : _rojo,
                ),
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.75,
            children: [
              n('1'),
              n('2'),
              n('3'),
              _Tecla(
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
              _Tecla(
                onTap: () => _guardar(null),
                child: const Text(
                  'Vacío',
                  style: TextStyle(fontSize: 14, color: KipuColores.gris),
                ),
              ),
              _Tecla(
                onTap: () => _mover(-1),
                child: const KipuIcon(
                  KipuIcono.izquierda,
                  size: 22,
                  color: KipuColores.gris,
                ),
              ),
              n('0'),
              _Tecla(
                fondo: base,
                onTap: () => _guardar(_texto.isEmpty ? null : _texto),
                child: const KipuIcon(
                  KipuIcono.flecha,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              _Tecla(
                fondo: base,
                onTap: () => _guardar(_texto.isEmpty ? null : _texto),
                child: const Text(
                  'Listo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
          Row(
            children: [
              Expanded(
                child: _Tecla(
                  alto: 48,
                  onTap: () => _mover(-1),
                  child: const Text(
                    'Anterior',
                    style: TextStyle(color: KipuColores.gris),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tecla(
                  alto: 48,
                  onTap: () => _guardar(null),
                  child: const Text(
                    'Dejar vacío',
                    style: TextStyle(color: KipuColores.gris),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Focus(
      focusNode: _foco,
      autofocus: true,
      onKeyEvent: _teclado,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CabezaHoja(
            avatar: _equipo ? null : AvatarEstudiante(_e, tam: 48),
            icono: _equipo ? KipuIcono.equipo : null,
            color: base,
            titulo: _equipo
                ? 'Equipo ${widget.equipos[_e.id]}'
                : '${tituloNombre(_e.apellidos)}, ${tituloNombre(_e.nombres).split(' ').first}',
            subtitulo: _equipo
                ? '$subtitulo\n${_integrantes.map((x) => tituloNombre(x.nombres).split(' ').first).join(', ')}'
                : subtitulo,
            cola: Text(
              '${_i + 1} de $total',
              style: const TextStyle(fontSize: 13, color: KipuColores.gris),
            ),
          ),
          const SizedBox(height: 16),
          contenido,
          if (siguiente != null && !_equipo) ...[
            const SizedBox(height: 12),
            Text(
              'Siguiente · ${tituloNombre(siguiente.apellidos)}, ${tituloNombre(siguiente.nombres).split(' ').first}',
              style: const TextStyle(fontSize: 13, color: KipuColores.gris),
            ),
          ],
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
  String codigoSugerido = '',
  RegistroColumna? columna,
}) => _hoja(
  context,
  _FormColumna(
    cursoId: cursoId,
    periodo: periodo,
    escalas: escalas,
    escalaDefecto: escalaDefecto,
    colores: colores,
    codigoSugerido: codigoSugerido,
    columna: columna,
  ),
);

class _FormColumna extends StatefulWidget {
  final int cursoId;
  final int periodo;
  final List<Escala> escalas;
  final String escalaDefecto;
  final ColoresRegistro colores;
  final String codigoSugerido;
  final RegistroColumna? columna;

  const _FormColumna({
    required this.cursoId,
    required this.periodo,
    required this.escalas,
    required this.escalaDefecto,
    required this.colores,
    required this.codigoSugerido,
    this.columna,
  });

  @override
  State<_FormColumna> createState() => _FormColumnaState();
}

class _FormColumnaState extends State<_FormColumna> {
  late String _tipo = widget.columna?.tipo ?? 'nota';
  late final _codigo = TextEditingController(
    text: widget.columna?.codigo ?? widget.codigoSugerido,
  );
  late final _tema = TextEditingController(text: widget.columna?.tema);
  late String? _fecha =
      widget.columna?.fecha ??
      (widget.columna == null ? claveFecha(DateTime.now()) : null);
  late String _escala = widget.columna?.escala ?? widget.escalaDefecto;
  late bool _enEquipo = widget.columna?.enEquipo ?? false;
  String? _error;

  Future<void> _guardar() async {
    final codigo = _codigo.text.trim();
    if (codigo.isEmpty) {
      setState(() => _error = 'Escribe un código corto, como F1 o T2');
      return;
    }
    final nota = _tipo == 'nota';
    final tema = _tema.text.trim();
    final datos = RegistroColumnasCompanion(
      cursoId: Value(widget.cursoId),
      periodo: Value(widget.periodo),
      codigo: Value(codigo),
      tema: Value(tema.isEmpty ? null : tema),
      fecha: Value(_fecha),
      tipo: Value(_tipo),
      escala: Value(nota ? _escala : null),
      enEquipo: Value(nota && _enEquipo),
    );
    if (widget.columna == null) {
      await db.crearColumna(datos.copyWith(orden: const Value(0)));
    } else {
      await db.editarColumna(widget.columna!.id, datos);
    }
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
    Widget tipo(String id, KipuIcono icono, String titulo, String detalle) {
      final on = _tipo == id;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _tipo = id;
            if (id == 'calculada' &&
                (_codigo.text.isEmpty ||
                    _codigo.text == widget.codigoSugerido)) {
              _codigo.text = 'Prom.';
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: on ? Color.lerp(base, Colors.white, .93) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: on ? base : const Color(0xFFE6E7F0),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KipuIcon(icono, size: 28, color: base),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detalle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: KipuColores.gris,
                  ),
                ),
              ],
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
        etiqueta('Tipo de columna'),
        Row(
          children: [
            tipo('nota', KipuIcono.notas, 'Nota', 'Pones la nota a mano'),
            const SizedBox(width: 10),
            tipo(
              'calculada',
              KipuIcono.calculadora,
              'Calculada',
              'Promedio · se configura después',
            ),
          ],
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
                onChanged: (_) => setState(() => _error = null),
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
        if (_tipo == 'nota') ...[
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
  required ColoresRegistro colores,
  required List<Escala> escalas,
  required String escalaDefecto,
}) async {
  final base = colores.calculadas;
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
          icono: col.tipo == 'nota' ? KipuIcono.notas : KipuIcono.calculadora,
          color: base,
          titulo: col.codigo,
          subtitulo: [
            if ((col.tema ?? '').isNotEmpty) col.tema!,
            col.tipo == 'nota' ? 'Columna de notas' : 'Columna calculada',
          ].join(' · '),
        ),
        const SizedBox(height: 10),
        opcion(KipuIcono.editar, 'Editar columna', 'editar'),
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
  Map<int, int> equipos,
  ColoresRegistro colores,
) => _hoja(
  context,
  _Equipos(
    cursoId: cursoId,
    estudiantes: estudiantes,
    equipos: equipos,
    colores: colores,
  ),
);

class _Equipos extends StatefulWidget {
  final int cursoId;
  final List<Estudiante> estudiantes;
  final Map<int, int> equipos;
  final ColoresRegistro colores;
  const _Equipos({
    required this.cursoId,
    required this.estudiantes,
    required this.equipos,
    required this.colores,
  });

  @override
  State<_Equipos> createState() => _EquiposState();
}

class _EquiposState extends State<_Equipos> {
  late final Map<int, int> _eq = {...widget.equipos};
  late int _cantidad = max(4, _eq.values.fold(0, max));

  void _alAzar() => setState(() {
    final l = [...widget.estudiantes]..shuffle();
    _eq.clear();
    for (var i = 0; i < l.length; i++) {
      _eq[l[i].id] = i % _cantidad + 1;
    }
  });

  @override
  Widget build(BuildContext context) {
    final base = widget.colores.calculadas;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabezaHoja(
          icono: KipuIcono.equipo,
          color: base,
          titulo: 'Equipos',
          subtitulo: 'En las columnas "En equipo" la nota va a todo el equipo',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text('Cantidad de equipos', style: TextStyle(fontSize: 14)),
            const Spacer(),
            IconButton(
              onPressed: _cantidad > 2
                  ? () => setState(() => _cantidad--)
                  : null,
              icon: KipuIcon(KipuIcono.izquierda, size: 20, color: base),
            ),
            Text(
              '$_cantidad',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            IconButton(
              onPressed: _cantidad < 12
                  ? () => setState(() => _cantidad++)
                  : null,
              icon: KipuIcon(KipuIcono.derecha, size: 20, color: base),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: _alAzar,
              child: const Text('Al azar'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .45,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final e in widget.estudiantes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      AvatarEstudiante(e, tam: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres).split(' ').first}',
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
                              child: Text('Equipo $k'),
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
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: base),
                onPressed: () async {
                  _eq.removeWhere((_, v) => v > _cantidad);
                  await db.guardarEquipos(widget.cursoId, _eq);
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
