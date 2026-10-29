import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/academico.dart';
import '../data/database.dart';
import '../data/paises.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/calendario_rango.dart';
import '../widgets/kipu_icono.dart';
import 'cursos.dart' show confirmar;
import 'estudiantes.dart' show elegirFoto;

const _coral = Color(0xFFE0697A);
const _gris2 = Color(0xFFA3A1B3);
const _linea = Color(0xFFECEDF4);
const _campo = Color(0xFFF3F4FB);
const _parentescos = [
  'Madre',
  'Padre',
  'Abuelo/a',
  'Tío/a',
  'Hermano/a',
  'Otro',
];

/// Tonos de la ficha: todos salen del color del curso.
class _Tonos {
  final Color a;
  const _Tonos(this.a);
  Color get a50 => Color.lerp(a, Colors.white, .95)!;
  Color get a100 => Color.lerp(a, Colors.white, .89)!;
  Color get a200 => Color.lerp(a, Colors.white, .78)!;
  Color get a400 => Color.lerp(a, Colors.white, .45)!;
  Color get a700 => Color.lerp(a, Colors.black, .2)!;
}

/// Ficha del estudiante en una ventana centrada. En pantallas anchas va en dos
/// columnas (resumen y acceso a la izquierda, datos a la derecha); en el
/// celular, una columna con pestañas Resumen / Datos / Acceso.
Future<void> abrirFicha(
  BuildContext context, {
  required CursoConColegio datos,
  Estudiante? estudiante,
  required int periodo,
  required List<Periodo> periodos,
  required Color color,
  Escala? Function(RegistroColumna)? escalaDe,
  Future<void> Function(Estudiante)? onAnotar,
}) => showDialog(
  context: context,
  barrierColor: const Color(0x661F1B2E),
  builder: (_) => _Ficha(
    datos: datos,
    e: estudiante,
    periodo: periodo,
    periodos: periodos,
    t: _Tonos(color),
    escalaDe: escalaDe,
    onAnotar: onAnotar,
  ),
);

class _Ficha extends StatefulWidget {
  final CursoConColegio datos;
  final Estudiante? e;
  final int periodo;
  final List<Periodo> periodos;
  final _Tonos t;
  final Escala? Function(RegistroColumna)? escalaDe;
  final Future<void> Function(Estudiante)? onAnotar;

  const _Ficha({
    required this.datos,
    required this.e,
    required this.periodo,
    required this.periodos,
    required this.t,
    required this.escalaDe,
    required this.onAnotar,
  });

  @override
  State<_Ficha> createState() => _FichaState();
}

class _FichaState extends State<_Ficha> {
  Estudiante? get e => widget.e;
  _Tonos get t => widget.t;
  Curso get curso => widget.datos.curso;

  late final apellidos = TextEditingController(text: e?.apellidos);
  late final nombres = TextEditingController(text: e?.nombres);
  late final dni = TextEditingController(text: e?.dni);
  late final nacimiento = TextEditingController(
    text: e?.nacimiento == null ? '' : _aTexto(e!.nacimiento!),
  );
  late final observaciones = TextEditingController(text: e?.observaciones);
  late final apoderado = TextEditingController(text: e?.apoderado);
  late final telefono = TextEditingController(text: e?.telefono);
  late final apoderado2 = TextEditingController(text: e?.apoderado2);
  late final telefono2 = TextEditingController(text: e?.telefono2);
  late final tutor = TextEditingController(text: curso.tutor);
  late final tutorCelular = TextEditingController(text: curso.tutorCelular);
  late final codigo = TextEditingController(text: e?.codigo);
  late final clave = TextEditingController(text: e?.clave);

  late String? parentesco = e?.parentesco;
  late String? parentesco2 = e?.parentesco2;
  late bool conSegundo = (e?.apoderado2 ?? e?.telefono2) != null;
  late var foto = e?.foto;
  late var desde = e?.desde ?? widget.periodo;
  late var hasta = e?.hasta;
  late int? verPeriodo = widget.periodo;
  var pestana = 0;
  var guardando = false;
  final verClave = ValueNotifier(false);
  final errores = <String, String>{};

  @override
  void initState() {
    super.initState();
    for (final c in [apellidos, nombres, codigo]) {
      c.addListener(() => setState(() {}));
    }
    if (e == null) {
      db.nuevoCodigo().then((c) {
        if (mounted && codigo.text.isEmpty) codigo.text = c;
      });
      clave.text = nuevaClave();
    }
    // El tutor pudo cambiar desde otro curso de la sección.
    db.verCurso(curso.id).first.then((c) {
      if (!mounted) return;
      if (tutor.text.isEmpty) tutor.text = c.tutor ?? '';
      if (tutorCelular.text.isEmpty) tutorCelular.text = c.tutorCelular ?? '';
    });
  }

  String nombrePeriodo(int p) => p >= 1 && p <= widget.periodos.length
      ? widget.periodos[p - 1].nombre
      : '$p.° periodo';

  String get seccion => '${curso.grado} ${curso.seccion}';

  // Guardar

  Future<void> guardar() async {
    errores.clear();
    if (apellidos.text.trim().isEmpty) {
      errores['apellidos'] = 'Escribe los apellidos';
    }
    if (nombres.text.trim().isEmpty) errores['nombres'] = 'Escribe los nombres';
    final fecha = nacimiento.text.trim().isEmpty
        ? null
        : _aClave(nacimiento.text.trim());
    if (nacimiento.text.trim().isNotEmpty && fecha == null) {
      errores['nacimiento'] = 'Usa el formato dd/mm/aaaa';
    }
    var id = codigo.text.replaceAll(' ', '');
    if (id.isNotEmpty && id.length < 4) {
      errores['codigo'] = 'El ID debe tener al menos 4 números';
    } else if (id.isNotEmpty && await db.codigoOcupado(id, salvo: e?.id)) {
      errores['codigo'] = 'Ese ID ya lo tiene otro estudiante';
    }
    if (errores.isNotEmpty) {
      setState(() {
        if (errores.containsKey('codigo')) {
          pestana = 2;
        } else {
          pestana = 1;
        }
      });
      return;
    }
    setState(() => guardando = true);
    if (id.isEmpty) id = await db.nuevoCodigo();
    String? opc(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    await db.guardarEstudiante(
      EstudiantesCompanion(
        id: e == null ? const Value.absent() : Value(e!.id),
        cursoId: Value(curso.id),
        apellidos: Value(apellidos.text.trim().toUpperCase()),
        nombres: Value(nombres.text.trim()),
        dni: Value(opc(dni)),
        nacimiento: Value(fecha),
        observaciones: Value(opc(observaciones)),
        apoderado: Value(opc(apoderado)),
        parentesco: Value(parentesco),
        telefono: Value(opc(telefono)),
        apoderado2: Value(conSegundo ? opc(apoderado2) : null),
        parentesco2: Value(conSegundo ? parentesco2 : null),
        telefono2: Value(conSegundo ? opc(telefono2) : null),
        codigo: Value(id),
        clave: Value(opc(clave) ?? nuevaClave()),
        foto: Value(foto),
        desde: Value(desde),
        hasta: Value(hasta),
      ),
    );
    if (opc(tutor) != curso.tutor || opc(tutorCelular) != curso.tutorCelular) {
      await db.guardarTutor(curso, opc(tutor), opc(tutorCelular));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> eliminar() async {
    if (await confirmar(
      context,
      '¿Eliminar estudiante?',
      '${e!.apellidos}, ${e!.nombres}',
    )) {
      await db.borrarEstudiante(e!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  // Interfaz

  @override
  Widget build(BuildContext context) {
    final pantalla = MediaQuery.sizeOf(context);
    final ancha = pantalla.width >= 820;
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ancha ? 32 : 12,
        vertical: ancha ? 24 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ancha ? 1120 : 520,
          maxHeight: ancha ? 860 : 900,
        ),
        child: ancha ? _dosColumnas() : _unaColumna(),
      ),
    );
  }

  Widget _dosColumnas() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cabecera(compacta: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (e != null) ...[
                      _Resumen(estado: this, ancha: true),
                      const SizedBox(height: 18),
                    ],
                    ..._acceso(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const VerticalDivider(width: 1, thickness: 1, color: _linea),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 8, 26, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _datos(ancha: true),
                ),
              ),
            ),
            _pie(),
          ],
        ),
      ),
    ],
  );

  Widget _unaColumna() {
    final contenido = e == null
        ? [..._datos(ancha: false), const SizedBox(height: 6), ..._acceso()]
        : switch (pestana) {
            0 => [_Resumen(estado: this, ancha: false)],
            1 => _datos(ancha: false),
            _ => _acceso(),
          };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cabecera(compacta: true),
        if (e != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
            child: _Pestanas(
              opciones: const ['Resumen', 'Datos', 'Acceso'],
              valor: pestana,
              alertas: {
                if (errores.keys.any((k) => k != 'codigo')) 1,
                if (errores.containsKey('codigo')) 2,
              },
              onCambio: (i) => setState(() => pestana = i),
            ),
          ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: contenido,
            ),
          ),
        ),
        _pie(),
      ],
    );
  }

  Widget _cabecera({required bool compacta}) {
    final tam = compacta ? 80.0 : 100.0;
    final nombre = [
      nombres.text.trim(),
      _titulo(apellidos.text.trim()),
    ].where((x) => x.isNotEmpty).join(' ');
    final sub = [
      if (e == null) 'Toca la foto para ponerle una',
      curso.nombre,
      seccion,
      if (e != null && codigo.text.isNotEmpty) 'ID ${codigo.text}',
    ].join(' · ');
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        compacta ? 18 : 24,
        20,
        compacta ? 14 : 18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(t.a, Colors.white, .2)!,
            Color.lerp(t.a, Colors.black, .1)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: KipuIcon(
                      KipuIcono.cerrar,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              children: [
                _avatar(tam),
                SizedBox(height: compacta ? 10 : 12),
                Text(
                  nombre.isEmpty ? 'Nuevo estudiante' : nombre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compacta ? 19 : 22,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .86),
                    fontSize: 13,
                  ),
                ),
                if (e != null) ...[
                  const SizedBox(height: 10),
                  _pastillaRetiro(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(double tam) {
    final ini = [
      apellidos.text.trim(),
      nombres.text.trim(),
    ].where((x) => x.isNotEmpty).map((x) => x[0].toUpperCase()).join();
    return GestureDetector(
      onTap: () async {
        final f = await elegirFoto();
        if (f != null) setState(() => foto = f);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: tam,
            height: tam,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(tam * .32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x261F1B2E),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: foto != null
                ? Image.memory(foto!, fit: BoxFit.cover)
                : Center(
                    child: ini.isEmpty || e == null && ini.length < 2
                        ? KipuIcon(
                            KipuIcono.secciones,
                            size: tam * .44,
                            color: t.a,
                          )
                        : Text(
                            ini,
                            style: TextStyle(
                              fontSize: tam * .34,
                              fontWeight: FontWeight.w600,
                              color: t.a,
                            ),
                          ),
                  ),
          ),
          Positioned(
            right: -6,
            bottom: -6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: KipuColores.tinta,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Center(
                child: KipuIcon(
                  KipuIcono.camara,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (foto != null)
            Positioned(
              left: -6,
              top: -6,
              child: GestureDetector(
                onTap: () => setState(() => foto = null),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: KipuIcon(
                      KipuIcono.cerrar,
                      size: 14,
                      color: KipuColores.gris,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pastillaRetiro() {
    final texto = hasta == null
        ? 'En el curso desde el ${nombrePeriodo(desde)}'
        : 'Retirado desde el ${nombrePeriodo(hasta!)}';
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const KipuIcon(KipuIcono.calendario, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(
              () => hasta = hasta == null
                  ? (widget.periodo > desde ? widget.periodo : desde + 1)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                hasta == null ? 'Se retiró' : 'Deshacer',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _datos({required bool ancha}) {
    Widget par(Widget a, Widget b) => LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 420
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: 10),
                Expanded(child: b),
              ],
            )
          : Column(children: [a, const SizedBox(height: 10), b]),
    );
    final edad = _edad(_aClave(nacimiento.text.trim()));
    return [
      _Seccion(t: t, icono: KipuIcono.ficha, titulo: 'Datos del estudiante'),
      par(
        _Campo(
          t: t,
          etiqueta: 'Apellidos',
          controlador: apellidos,
          pista: 'Como en el SIAGIE',
          mayusculas: TextCapitalization.characters,
          autofoco: e == null && ancha,
          error: errores['apellidos'],
        ),
        _Campo(
          t: t,
          etiqueta: 'Nombres',
          controlador: nombres,
          pista: 'Nombres',
          mayusculas: TextCapitalization.words,
          error: errores['nombres'],
        ),
      ),
      const SizedBox(height: 10),
      par(
        _Campo(
          t: t,
          etiqueta: 'DNI',
          controlador: dni,
          pista: '8 dígitos',
          teclado: TextInputType.number,
          formato: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
        ),
        _Campo(
          t: t,
          etiqueta: 'Fecha de nacimiento',
          controlador: nacimiento,
          pista: 'dd/mm/aaaa',
          teclado: TextInputType.number,
          formato: [_FormatoFecha()],
          error: errores['nacimiento'],
          onCambio: (_) => setState(() {}),
          derecha: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (edad != null)
                Text(
                  '$edad años',
                  style: const TextStyle(fontSize: 13, color: KipuColores.gris),
                ),
              Tooltip(
                message: 'Su cumpleaños saldrá en tu calendario del inicio',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _elegirNacimiento,
                  icon: KipuIcon(KipuIcono.cumple, size: 22, color: t.a),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      _Seccion(t: t, icono: KipuIcono.apuntes, titulo: 'Observaciones'),
      _Campo(
        t: t,
        etiqueta: 'Salud, NEE, cómo aprende',
        controlador: observaciones,
        pista: 'Alergias, lentes, se sienta adelante, le gusta exponer…',
        lineas: 3,
        mayusculas: TextCapitalization.sentences,
      ),
      const SizedBox(height: 22),
      _Seccion(t: t, icono: KipuIcono.familia, titulo: 'Apoderados'),
      _Tarjeta(
        t: t,
        titulo: 'Apoderado 1',
        telefono: telefono.text,
        children: [
          _Campo(
            t: t,
            etiqueta: 'Nombre',
            controlador: apoderado,
            pista: 'Nombre completo',
            icono: KipuIcono.secciones,
            enTarjeta: true,
            mayusculas: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          _Chips(
            t: t,
            valor: parentesco,
            onCambio: (v) => setState(() => parentesco = v),
          ),
          const SizedBox(height: 10),
          _campoCelular(telefono),
        ],
      ),
      const SizedBox(height: 10),
      if (conSegundo)
        _Tarjeta(
          t: t,
          titulo: 'Apoderado 2',
          telefono: telefono2.text,
          onQuitar: () => setState(() => conSegundo = false),
          children: [
            _Campo(
              t: t,
              etiqueta: 'Nombre',
              controlador: apoderado2,
              pista: 'Nombre completo',
              icono: KipuIcono.secciones,
              enTarjeta: true,
              mayusculas: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            _Chips(
              t: t,
              valor: parentesco2,
              onCambio: (v) => setState(() => parentesco2 = v),
            ),
            const SizedBox(height: 10),
            _campoCelular(telefono2),
          ],
        )
      else
        _BotonPunteado(
          t: t,
          texto: 'Agregar apoderado 2',
          onTap: () => setState(() => conSegundo = true),
        ),
      const SizedBox(height: 22),
      _Seccion(t: t, icono: KipuIcono.estudiantes, titulo: 'Tutor/a del aula'),
      _Tarjeta(
        t: t,
        titulo: 'Para todo $seccion',
        insignia: true,
        telefono: tutorCelular.text,
        mensaje: tutor.text.isEmpty
            ? null
            : 'Hola ${tutor.text.trim()}, le escribo sobre '
                  '${nombres.text.trim()} ${_titulo(apellidos.text.trim())} '
                  '($seccion). ',
        children: [
          _Campo(
            t: t,
            etiqueta: 'Nombre',
            controlador: tutor,
            pista: 'Prof. nombre y apellido',
            icono: KipuIcono.secciones,
            enTarjeta: true,
            mayusculas: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          _campoCelular(tutorCelular),
          const SizedBox(height: 8),
          Text(
            'Se guarda una sola vez para todos los estudiantes de $seccion. '
            'Úsalo para avisar un incidente por llamada o WhatsApp.',
            style: const TextStyle(
              fontSize: 12,
              color: KipuColores.gris,
              height: 1.35,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _campoCelular(TextEditingController c) => _Campo(
    t: t,
    etiqueta: 'Celular',
    controlador: c,
    pista: '9 dígitos',
    icono: KipuIcono.llamar,
    enTarjeta: true,
    teclado: TextInputType.phone,
    formato: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(9),
    ],
    onCambio: (_) => setState(() {}),
  );

  Future<void> _elegirNacimiento() async {
    final hoy = DateTime.now();
    final f = await elegirFecha(
      context,
      icono: KipuIcono.cumple,
      titulo: 'Fecha de nacimiento',
      anio: hoy.year - 12,
      fecha: _aClave(nacimiento.text.trim()),
    );
    if (f != null) setState(() => nacimiento.text = _aTexto(f));
  }

  List<Widget> _acceso() {
    return [
      _Seccion(
        t: t,
        icono: KipuIcono.llave,
        titulo: 'Acceso a la app de estudio',
      ),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [t.a100, t.a50],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.a200, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ClaveCampo(
              t: t,
              etiqueta: 'ID del estudiante · solo números',
              icono: KipuIcono.numeral,
              controlador: codigo,
              teclado: TextInputType.number,
              formato: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              error: errores['codigo'],
              acciones: [
                (
                  KipuIcono.refrescar,
                  'Generar otro ID',
                  () async => codigo.text = await db.nuevoCodigo(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: verClave,
              builder: (context, ver, _) => _ClaveCampo(
                t: t,
                etiqueta: 'Contraseña inicial',
                icono: KipuIcono.candado,
                controlador: clave,
                oculto: !ver,
                acciones: [
                  (
                    ver ? KipuIcono.ojoCerrado : KipuIcono.ojo,
                    ver ? 'Ocultar' : 'Ver',
                    () => verClave.value = !ver,
                  ),
                  (
                    KipuIcono.refrescar,
                    'Generar otra contraseña',
                    () {
                      clave.text = nuevaClave();
                      verClave.value = true;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (e != null)
              Row(
                children: [
                  Expanded(
                    child: _BotonAcceso(
                      icono: KipuIcono.whatsapp,
                      texto: 'Enviar al apoderado',
                      fondo: const Color(0xFF1A9E5C),
                      tinta: Colors.white,
                      onTap: telefono.text.length < 9 ? null : _enviarAcceso,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _BotonAcceso(
                    icono: KipuIcono.copiar,
                    texto: 'Copiar',
                    fondo: Colors.white,
                    tinta: t.a,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _textoAcceso()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos de acceso copiados'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 2),
              child: Text(
                e == null
                    ? 'Se generan solos. Si tu colegio ya usa códigos, '
                          'escribe el suyo.'
                    : 'El ID es único. Al primer ingreso el estudiante '
                          'cambia su contraseña.',
                style: const TextStyle(
                  fontSize: 12,
                  color: KipuColores.gris,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  String _textoAcceso() =>
      'Datos de acceso de ${nombres.text.trim()} '
      '${_titulo(apellidos.text.trim())} a la app de estudio:\n'
      'ID: ${codigo.text}\nContraseña: ${clave.text}';

  void _enviarAcceso() => _whatsapp(telefono.text, 'Hola, ${_textoAcceso()}');

  Widget _pie() => Container(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _linea)),
    ),
    child: Row(
      children: [
        if (e != null) ...[
          SizedBox(
            width: 48,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFF2CDD3), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: eliminar,
              child: const KipuIcon(
                KipuIcono.borrar,
                size: 21,
                color: Color(0xFFC2334A),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              side: const BorderSide(color: Color(0xFFD9DAE6), width: 1.5),
              foregroundColor: KipuColores.tinta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: e == null ? 2 : 1,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              backgroundColor: t.a,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: guardando ? null : guardar,
            child: Text(e == null ? 'Agregar estudiante' : 'Guardar'),
          ),
        ),
      ],
    ),
  );
}

// Resumen del periodo

class _Resumen extends StatefulWidget {
  final _FichaState estado;
  final bool ancha;
  const _Resumen({required this.estado, required this.ancha});

  @override
  State<_Resumen> createState() => _ResumenState();
}

class _ResumenState extends State<_Resumen> {
  _FichaState get f => widget.estado;
  late Stream<ResumenFicha> _datos = _abrir();

  Stream<ResumenFicha> _abrir() {
    final ps = f.widget.periodos;
    final p = f.verPeriodo;
    final (desde, hasta) = p == null || p > ps.length
        ? (ps.firstOrNull?.inicio, ps.lastOrNull?.fin)
        : (ps[p - 1].inicio, ps[p - 1].fin);
    return db.verResumenFicha(f.e!, periodo: p, desde: desde, hasta: hasta);
  }

  @override
  Widget build(BuildContext context) {
    final t = f.t;
    final ps = f.widget.periodos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 1; i <= ps.length + 1; i++)
              Builder(
                builder: (context) {
                  final p = i > ps.length ? null : i;
                  final sel = f.verPeriodo == p;
                  final nombre = p == null
                      ? 'Año'
                      : sel
                      ? ps[i - 1].nombre
                      : '$i.°';
                  return Material(
                    color: sel ? KipuColores.tinta : _campo,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() {
                        f.verPeriodo = p;
                        _datos = _abrir();
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          nombre,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel ? Colors.white : KipuColores.gris,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<ResumenFicha>(
          stream: _datos,
          builder: (context, snap) {
            final r = snap.data;
            if (r == null) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _contenido(r, t);
          },
        ),
      ],
    );
  }

  Widget _contenido(ResumenFicha r, _Tonos t) {
    final p = r.asistencia['P'] ?? 0;
    final tard = r.asistencia['T'] ?? 0;
    final faltas = (r.asistencia['F'] ?? 0) + (r.asistencia['J'] ?? 0);
    final total = p + tard + faltas;
    final pct = total == 0 ? null : ((p + tard) * 100 / total).round();
    final notas = _estadisticas(r.notas);
    final leyenda = [
      (t.a, 'Presente', p),
      (t.a400, 'Tardanzas', tard),
      (_coral, 'Faltas', faltas),
    ];
    Widget item((Color, String, int) x) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: x.$1,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${x.$2} ${x.$3}',
          style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
        ),
      ],
    );
    Widget dato(String etiqueta, String? valor, Color color) => Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 14, color: KipuColores.gris),
        ),
        const Spacer(),
        Text(
          valor ?? '—',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
    final positivas = r.conductas.where((c) => c.positiva).length;
    final porMejorar = r.conductas.length - positivas;
    final esAnio = f.verPeriodo == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.a50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.a100, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Dona(
                    t: t,
                    tam: 108,
                    valores: [(p, t.a), (tard, t.a400), (faltas, _coral)],
                    centro: pct == null ? '—' : '$pct%',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        dato('Nota máx', notas.max, t.a),
                        const SizedBox(height: 6),
                        dato(
                          'Nota mín',
                          notas.min,
                          notas.minBaja ? _coral : KipuColores.tinta,
                        ),
                        const SizedBox(height: 6),
                        dato('Promedio', notas.media, KipuColores.tinta),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [for (final x in leyenda) item(x)],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final (i, x) in [
              (KipuIcono.notas, r.pendientes, 'Notas pendientes', t.a),
              (KipuIcono.calendario, faltas, 'Faltas', _coral),
              (KipuIcono.horario, tard, 'Tardanzas', t.a400),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _linea, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      KipuIcon(x.$1, size: 18, color: x.$4),
                      const SizedBox(height: 2),
                      Text(
                        '${x.$2}',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        x.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: KipuColores.gris,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _linea, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Seccion(
                t: t,
                icono: KipuIcono.sonrisa,
                titulo: esAnio ? 'Conducta del año' : 'Conducta del periodo',
                abajo: 0,
                accion: f.widget.onAnotar == null
                    ? null
                    : TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: t.a,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => f.widget.onAnotar!(f.e!),
                        icon: KipuIcon(KipuIcono.agregar, size: 16, color: t.a),
                        label: const Text('Anotar'),
                      ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  height: 10,
                  child: r.conductas.isEmpty
                      ? Container(color: t.a100)
                      : Row(
                          children: [
                            if (positivas > 0)
                              Expanded(
                                flex: positivas,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: t.a,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                              ),
                            if (positivas > 0 && porMejorar > 0)
                              const SizedBox(width: 3),
                            if (porMejorar > 0)
                              Expanded(
                                flex: porMejorar,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _coral,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$positivas',
                          style: TextStyle(
                            color: t.a,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' positivas'),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13.5),
                  ),
                  const Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$porMejorar',
                          style: const TextStyle(
                            color: _coral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' por mejorar'),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ],
              ),
              if (r.conductas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in r.conductas.take(4))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.positiva ? t.a100 : const Color(0xFFFCEEF0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${c.motivo} · ${_cuando(c.fecha)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.positiva
                                ? t.a700
                                : const Color(0xFFB33A4C),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  ({String? max, String? min, String? media, bool minBaja}) _estadisticas(
    List<(RegistroColumna, String)> notas,
  ) {
    final numeros = <double>[];
    final letras = <String>[];
    double aprueba = 10.5;
    for (final (c, v) in notas) {
      final n = double.tryParse(v.replaceAll(',', '.'));
      if (n != null) {
        numeros.add(n);
        final e = f.widget.escalaDe?.call(c);
        if (e?.aprueba != null) aprueba = e!.aprueba!;
      } else {
        letras.add(v);
      }
    }
    String fmt(double n) => n == n.roundToDouble()
        ? '${n.round()}'
        : n.toStringAsFixed(1).replaceAll('.', ',');
    if (numeros.isNotEmpty) {
      final mn = numeros.reduce(min);
      return (
        max: fmt(numeros.reduce(max)),
        min: fmt(mn),
        media: (numeros.reduce((a, b) => a + b) / numeros.length)
            .toStringAsFixed(1)
            .replaceAll('.', ','),
        minBaja: mn < aprueba,
      );
    }
    if (letras.isEmpty) {
      return (max: null, min: null, media: null, minBaja: false);
    }
    const orden = ['AD', 'A', 'B', 'C', 'Logrado', 'En proceso', 'No logrado'];
    int pos(String v) => orden.contains(v) ? orden.indexOf(v) : orden.length;
    final ord = [...letras]..sort((a, b) => pos(a).compareTo(pos(b)));
    final cuenta = <String, int>{};
    for (final v in letras) {
      cuenta[v] = (cuenta[v] ?? 0) + 1;
    }
    final moda =
        (cuenta.keys.toList()..sort((a, b) {
              final d = cuenta[b]!.compareTo(cuenta[a]!);
              return d != 0 ? d : pos(a).compareTo(pos(b));
            }))
            .first;
    return (
      max: ord.first,
      min: ord.last,
      media: moda,
      minBaja: ord.last == 'C' || ord.last == 'No logrado',
    );
  }
}

String _cuando(String fecha) {
  final hoy = claveFecha(DateTime.now());
  if (fecha == hoy) return 'hoy';
  return DateFormat(
    'd MMM',
    'es_PE',
  ).format(DateTime.parse(fecha)).replaceAll('.', '');
}

class _Dona extends StatelessWidget {
  final _Tonos t;
  final double tam;
  final List<(int, Color)> valores;
  final String centro;
  const _Dona({
    required this.t,
    required this.tam,
    required this.valores,
    required this.centro,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: tam,
    height: tam,
    child: CustomPaint(
      painter: _PintaDona(valores, t.a100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              centro,
              style: TextStyle(
                fontSize: tam / 4.6,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const Text(
              'asistencia',
              style: TextStyle(fontSize: 11, color: KipuColores.gris),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PintaDona extends CustomPainter {
  final List<(int, Color)> valores;
  final Color fondo;
  _PintaDona(this.valores, this.fondo);

  @override
  void paint(Canvas canvas, Size size) {
    const grosor = 13.0;
    final rect = Offset.zero & size;
    final arco = rect.deflate(grosor / 2);
    final lapiz = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arco, 0, 2 * pi, false, lapiz..color = fondo);
    final total = valores.fold(0, (a, v) => a + v.$1);
    if (total == 0) return;
    final hueco = valores.where((v) => v.$1 > 0).length > 1 ? .09 : 0.0;
    var inicio = -pi / 2;
    for (final (n, color) in valores) {
      if (n == 0) continue;
      final barrido = 2 * pi * n / total;
      canvas.drawArc(
        arco,
        inicio + hueco / 2,
        max(barrido - hueco, .001),
        false,
        lapiz..color = color,
      );
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_PintaDona old) => true;
}

// Piezas

class _Seccion extends StatelessWidget {
  final _Tonos t;
  final KipuIcono icono;
  final String titulo;
  final Widget? accion;
  final double abajo;
  const _Seccion({
    required this.t,
    required this.icono,
    required this.titulo,
    this.accion,
    this.abajo = 10,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 8, bottom: abajo),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: t.a100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: KipuIcon(icono, size: 17, color: t.a)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
              color: KipuColores.tinta,
            ),
          ),
        ),
        ?accion,
      ],
    ),
  );
}

/// Campo relleno con la etiqueta pequeña arriba. Al escribir se ilumina con
/// el color del curso.
class _Campo extends StatefulWidget {
  final _Tonos t;
  final String etiqueta;
  final TextEditingController controlador;
  final String? pista;
  final KipuIcono? icono;
  final Widget? derecha;
  final bool enTarjeta;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formato;
  final TextCapitalization mayusculas;
  final int lineas;
  final bool autofoco;
  final String? error;
  final ValueChanged<String>? onCambio;

  const _Campo({
    required this.t,
    required this.etiqueta,
    required this.controlador,
    this.pista,
    this.icono,
    this.derecha,
    this.enTarjeta = false,
    this.teclado,
    this.formato,
    this.mayusculas = TextCapitalization.none,
    this.lineas = 1,
    this.autofoco = false,
    this.error,
    this.onCambio,
  });

  @override
  State<_Campo> createState() => _CampoState();
}

class _CampoState extends State<_Campo> {
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final t = w.t;
    final activo = _foco.hasFocus;
    final error = w.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _foco.requestFocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 56),
            padding: EdgeInsets.fromLTRB(
              w.icono == null ? 14 : 10,
              8,
              w.derecha == null ? 14 : 4,
              8,
            ),
            decoration: BoxDecoration(
              color: activo || w.enTarjeta ? Colors.white : _campo,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: error
                    ? _coral
                    : activo
                    ? t.a
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: activo
                  ? [BoxShadow(color: t.a100, spreadRadius: 4)]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: w.lineas > 1
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (w.icono != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: t.a100,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: KipuIcon(w.icono!, size: 18, color: t.a),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.etiqueta,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: error
                              ? _coral
                              : activo
                              ? t.a
                              : KipuColores.gris,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: w.controlador,
                        focusNode: _foco,
                        autofocus: w.autofoco,
                        keyboardType: w.lineas > 1
                            ? TextInputType.multiline
                            : w.teclado,
                        inputFormatters: w.formato,
                        textCapitalization: w.mayusculas,
                        minLines: w.lineas,
                        maxLines: w.lineas > 1 ? 6 : 1,
                        onChanged: w.onCambio,
                        cursorColor: t.a,
                        style: const TextStyle(
                          fontSize: 15.5,
                          color: KipuColores.tinta,
                        ),
                        decoration: _sinBorde(
                          hintText: w.pista,
                          hintStyle: const TextStyle(
                            fontSize: 15.5,
                            color: _gris2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ?w.derecha,
              ],
            ),
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 4),
            child: Text(
              w.error!,
              style: const TextStyle(fontSize: 12, color: _coral),
            ),
          ),
      ],
    );
  }
}

class _ClaveCampo extends StatelessWidget {
  final _Tonos t;
  final String etiqueta;
  final KipuIcono icono;
  final TextEditingController controlador;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formato;
  final bool oculto;
  final String? error;
  final List<(KipuIcono, String, VoidCallback)> acciones;

  const _ClaveCampo({
    required this.t,
    required this.etiqueta,
    required this.icono,
    required this.controlador,
    this.teclado,
    this.formato,
    this.oculto = false,
    this.error,
    this.acciones = const [],
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 5),
        child: Text(
          etiqueta,
          style: const TextStyle(fontSize: 12, color: KipuColores.gris),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: error == null ? null : Border.all(color: _coral, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1F1B2E),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            KipuIcon(icono, size: 20, color: t.a),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controlador,
                obscureText: oculto,
                keyboardType: teclado,
                inputFormatters: formato,
                cursorColor: t.a,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: t.a700,
                ),
                decoration: _sinBorde(hintText: ''),
              ),
            ),
            for (final (ic, ayuda, accion) in acciones)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Tooltip(
                  message: ayuda,
                  child: Material(
                    color: t.a50,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: accion,
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: Center(
                          child: KipuIcon(ic, size: 17, color: t.a),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Text(
            error!,
            style: const TextStyle(fontSize: 12, color: _coral),
          ),
        ),
    ],
  );
}

/// Tarjetita del apoderado o del tutor, con llamada y WhatsApp a la mano.
class _Tarjeta extends StatelessWidget {
  final _Tonos t;
  final String titulo;
  final String telefono;
  final String? mensaje;
  final bool insignia;
  final VoidCallback? onQuitar;
  final List<Widget> children;

  const _Tarjeta({
    required this.t,
    required this.titulo,
    required this.telefono,
    required this.children,
    this.mensaje,
    this.insignia = false,
    this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final listo = telefono.length >= 9;
    Widget boton(
      KipuIcono ic,
      Color fondo,
      Color tinta,
      String ayuda,
      VoidCallback f,
    ) => Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: ayuda,
        child: Material(
          color: fondo,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: f,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(child: KipuIcon(ic, size: 20, color: tinta)),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.a50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.a100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                if (insignia)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: t.a100,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: t.a700,
                      ),
                    ),
                  )
                else
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Spacer(),
                if (listo) ...[
                  boton(
                    KipuIcono.whatsapp,
                    const Color(0xFFE3F6EC),
                    const Color(0xFF1A9E5C),
                    'Escribir por WhatsApp',
                    () => _whatsapp(telefono, mensaje ?? ''),
                  ),
                  boton(
                    KipuIcono.llamar,
                    Colors.white,
                    t.a,
                    'Llamar',
                    () => _llamar(telefono),
                  ),
                ],
                if (onQuitar != null)
                  boton(
                    KipuIcono.cerrar,
                    Colors.white,
                    KipuColores.gris,
                    'Quitar',
                    onQuitar!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  final _Tonos t;
  final String? valor;
  final ValueChanged<String?> onCambio;
  const _Chips({required this.t, required this.valor, required this.onCambio});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: [
      for (final p in _parentescos)
        Material(
          color: p == valor ? t.a : Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onCambio(p == valor ? null : p),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: p == valor ? FontWeight.w600 : FontWeight.w400,
                  color: p == valor ? Colors.white : KipuColores.gris,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class _BotonPunteado extends StatelessWidget {
  final _Tonos t;
  final String texto;
  final VoidCallback onTap;
  const _BotonPunteado({
    required this.t,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: CustomPaint(
      painter: _Punteado(const Color(0xFFD5D6E4)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KipuIcon(KipuIcono.agregar, size: 18, color: t.a),
            const SizedBox(width: 8),
            Text(
              texto,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: t.a,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Punteado extends CustomPainter {
  final Color color;
  _Punteado(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final borde = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(.75),
          const Radius.circular(18),
        ),
      );
    final lapiz = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in borde.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), lapiz);
      }
    }
  }

  @override
  bool shouldRepaint(_Punteado old) => old.color != color;
}

class _BotonAcceso extends StatelessWidget {
  final KipuIcono icono;
  final String texto;
  final Color fondo;
  final Color tinta;
  final VoidCallback? onTap;
  const _BotonAcceso({
    required this.icono,
    required this.texto,
    required this.fondo,
    required this.tinta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? .45 : 1,
    child: Material(
      color: fondo,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KipuIcon(icono, size: 17, color: tinta),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: tinta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Pestanas extends StatelessWidget {
  final List<String> opciones;
  final int valor;
  final Set<int> alertas;
  final ValueChanged<int> onCambio;
  const _Pestanas({
    required this.opciones,
    required this.valor,
    required this.alertas,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: _campo,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        for (var i = 0; i < opciones.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onCambio(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: i == valor ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: i == valor
                      ? const [
                          BoxShadow(
                            color: Color(0x141F1B2E),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      opciones[i],
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: i == valor
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: i == valor
                            ? KipuColores.tinta
                            : KipuColores.gris,
                      ),
                    ),
                    if (alertas.contains(i)) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _coral,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// Fechas y contacto

/// Escribe las barras de dd/mm/aaaa solas mientras se tipea.
class _FormatoFecha extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue viejo,
    TextEditingValue nuevo,
  ) {
    final d = nuevo.text.replaceAll(RegExp(r'\D'), '');
    final b = StringBuffer();
    for (var i = 0; i < d.length && i < 8; i++) {
      if (i == 2 || i == 4) b.write('/');
      b.write(d[i]);
    }
    final t = b.toString();
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

/// 'dd/mm/aaaa' → 'yyyy-MM-dd', o null si no es una fecha válida.
String? _aClave(String texto) {
  final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(texto);
  if (m == null) return null;
  final d = int.parse(m[1]!), mes = int.parse(m[2]!), a = int.parse(m[3]!);
  final f = DateTime(a, mes, d);
  if (f.day != d || f.month != mes || a < 1900 || f.isAfter(DateTime.now())) {
    return null;
  }
  return claveFecha(f);
}

String _aTexto(String clave) =>
    DateFormat('dd/MM/yyyy').format(DateTime.parse(clave));

int? _edad(String? clave) {
  if (clave == null) return null;
  final n = DateTime.parse(clave);
  final hoy = DateTime.now();
  var e = hoy.year - n.year;
  if (hoy.month < n.month || hoy.month == n.month && hoy.day < n.day) e--;
  return e;
}

String _titulo(String t) => t
    .toLowerCase()
    .split(' ')
    .map(
      (p) =>
          p.isEmpty || const {'de', 'del', 'la', 'las', 'los', 'y'}.contains(p)
          ? p
          : p[0].toUpperCase() + p.substring(1),
    )
    .join(' ');

/// Celular peruano de 9 dígitos con el código del país.
String _internacional(String celular) {
  final d = celular.replaceAll(RegExp(r'\D'), '');
  return d.length == 9 ? '51$d' : d;
}

Future<void> _whatsapp(String celular, String texto) => launchUrl(
  Uri.https('wa.me', '/${_internacional(celular)}', {
    if (texto.isNotEmpty) 'text': texto,
  }),
  mode: LaunchMode.externalApplication,
);

Future<void> _llamar(String celular) =>
    launchUrl(Uri(scheme: 'tel', path: celular.replaceAll(RegExp(r'\D'), '')));

/// Sin bordes del tema: el campo ya dibuja su propio fondo.
InputDecoration _sinBorde({String? hintText, TextStyle? hintStyle}) =>
    InputDecoration(
      isCollapsed: true,
      filled: false,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      hintText: hintText,
      hintStyle: hintStyle,
    );
