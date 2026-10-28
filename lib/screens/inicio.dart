import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/demo.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'asistencia.dart' show fechaClave;
import 'configuracion.dart' show editarPerfil;

String _mayuscula(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

const _coloresNivel = {
  'AD': [Color(0xFF7C6CF2), Color(0xFF9D90F7)],
  'A': [Color(0xFF4F7CF5), Color(0xFF7FA3FA)],
  'B': [Color(0xFF3FB8E8), Color(0xFF8AD8F5)],
  'C': [Color(0xFF2FCB9C), Color(0xFF6FE3BE)],
};
const _nombresNivel = {
  'AD': 'Logro destacado (AD)',
  'A': 'Logro esperado (A)',
  'B': 'En proceso (B)',
  'C': 'En inicio (C)',
};

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final ancho = c.maxWidth;
          final conColumna = ancho >= 1080;
          final principal = <Widget>[
            _Encabezado(compacto: ancho < 640),
            const SizedBox(height: 20),
            const _Saludo(),
            const SizedBox(height: 18),
            const _Contadores(),
            const SizedBox(height: 18),
            _Estadisticas(enFila: ancho >= 760),
            const SizedBox(height: 18),
            const _Destacado(),
          ];
          final lateral = <Widget>[
            const _MiPerfil(),
            const SizedBox(height: 16),
            const _MiCalendario(),
          ];
          final relleno = EdgeInsets.fromLTRB(
              ancho < 640 ? 16 : 24, 20, ancho < 640 ? 16 : 24, 28);
          if (!conColumna) {
            return ListView(
              padding: relleno,
              children: [...principal, const SizedBox(height: 18), ...lateral],
            );
          }
          return SingleChildScrollView(
            padding: relleno,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: principal)),
                const SizedBox(width: 22),
                SizedBox(width: 330, child: Column(children: lateral)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------- Encabezado

class _Encabezado extends StatelessWidget {
  final bool compacto;
  const _Encabezado({required this.compacto});

  @override
  Widget build(BuildContext context) {
    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard',
            style: TextStyle(
                fontSize: compacto ? 24 : 28, fontWeight: FontWeight.w700)),
        const Text('Tu enseñanza, bien organizada',
            style: TextStyle(
                color: KipuColores.morado,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
    final acciones = Row(
      children: [
        const Expanded(child: _Buscador()),
        const SizedBox(width: 12),
        const _Campana(),
      ],
    );
    if (compacto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [titulo, const SizedBox(height: 14), acciones],
      );
    }
    return Row(
      children: [
        titulo,
        const SizedBox(width: 28),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: acciones),
          ),
        ),
      ],
    );
  }
}

class _Buscador extends StatelessWidget {
  const _Buscador();

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      viewHintText: 'Buscar alumno por nombre o apellido',
      builder: (context, controller) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: controller.openView,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: const Row(
              children: [
                KipuIcon(KipuIcono.buscar, size: 22, color: KipuColores.morado),
                SizedBox(width: 10),
                Text('Buscar alumno',
                    style: TextStyle(color: KipuColores.morado, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
      suggestionsBuilder: (context, controller) async {
        if (controller.text.trim().length < 2) {
          return const [
            ListTile(
              title: Text('Escribe al menos 2 letras',
                  style: TextStyle(color: KipuColores.gris)),
            )
          ];
        }
        final r = await db.buscarEstudiantes(controller.text);
        if (r.isEmpty) {
          return const [ListTile(title: Text('Sin resultados'))];
        }
        return [
          for (final (e, c) in r)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: KipuColores.moradoClaro,
                child: KipuIcon(KipuIcono.estudiantes,
                    size: 20, color: KipuColores.morado),
              ),
              title: Text('${e.apellidos}, ${e.nombres}'),
              subtitle: c == null
                  ? null
                  : Text(
                      '${c.curso.grado} ${c.curso.seccion} · ${c.curso.nombre} · ${c.colegio.nombre}'),
              onTap: () => controller.closeView(null),
            ),
        ];
      },
    );
  }
}

class _Campana extends StatelessWidget {
  const _Campana();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Evento>>(
      stream: db.verEventos(fechaClave(DateTime.now())),
      builder: (context, snap) {
        final eventos = snap.data ?? [];
        return Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              backgroundColor: Colors.white,
              builder: (_) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Para hoy',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (eventos.isEmpty)
                        const Text('No tienes pendientes hoy.',
                            style: TextStyle(color: KipuColores.gris)),
                      for (final e in eventos) _FilaEvento(evento: e),
                    ],
                  ),
                ),
              ),
            ),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const KipuIcon(KipuIcono.campana,
                      size: 24, color: KipuColores.morado),
                  if (eventos.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 17,
                        height: 17,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Color(0xFFE5394B), shape: BoxShape.circle),
                        child: Text('${eventos.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Saludo

class _Saludo extends StatefulWidget {
  const _Saludo();

  @override
  State<_Saludo> createState() => _SaludoState();
}

class _SaludoState extends State<_Saludo> {
  late final Timer _reloj;
  DateTime _ahora = DateTime.now();

  @override
  void initState() {
    super.initState();
    _reloj = Timer.periodic(const Duration(seconds: 20),
        (_) => setState(() => _ahora = DateTime.now()));
  }

  @override
  void dispose() {
    _reloj.cancel();
    super.dispose();
  }

  String get _frase => switch (_ahora.weekday) {
        DateTime.monday => '¡Que tengas un gran inicio de semana!',
        DateTime.friday => '¡Último empujón de la semana!',
        DateTime.saturday || DateTime.sunday => '¡Disfruta tu descanso, te lo ganaste!',
        _ => '¡Que tengas un gran día de clases!',
      };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: db.verAjuste('genero'),
      builder: (context, genero) => StreamBuilder<String?>(
        stream: db.verAjuste('nombre'),
        builder: (context, nombre) {
          final esProfesora = genero.data == 'profesora';
          final primerNombre = (nombre.data ?? '').split(' ').first;
          return LayoutBuilder(builder: (context, c) {
            final chico = c.maxWidth < 560;
            final alto = chico ? 160.0 : 170.0;
            // El personaje se ve de la cintura para arriba, con la cabeza
            // sobresaliendo de la tarjeta.
            final margen = chico ? 44.0 : 60.0;
            final alturaFigura = (alto + margen) * 1.9;
            final figura = alturaFigura * (esProfesora ? 0.37 : 0.33);
            return SizedBox(
              height: alto + margen,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    top: margen,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7D6CF0), Color(0xFF6D5BE6)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: margen + 16,
                    right: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B3CB5).withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const KipuIcon(KipuIcono.calendario,
                              size: 15, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            _mayuscula(DateFormat(
                                    chico ? "d MMM" : "MMMM d, y", 'es_PE')
                                .format(_ahora)),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('h:mm a', 'en_US')
                                .format(_ahora)
                                .toLowerCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: chico ? 0 : 22,
                    top: 0,
                    bottom: 0,
                    width: figura,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        maxHeight: alturaFigura,
                        child: Image.asset(
                          esProfesora
                              ? 'assets/img/profesora.png'
                              : 'assets/img/profesor.png',
                          height: alturaFigura,
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (chico ? 0 : 22) + figura + (chico ? 2 : 10),
                    right: 18,
                    bottom: chico ? 22 : 34,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text:
                                    '${esProfesora ? 'Bienvenida' : 'Bienvenido'}, '),
                            TextSpan(
                                text: 'Prof. $primerNombre',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ]),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: chico ? 20 : 28,
                            fontWeight: FontWeight.w500,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_frase,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: chico ? 13 : 15)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Contadores

class _Contadores extends StatelessWidget {
  const _Contadores();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: db.verResumen(),
      builder: (context, snap) {
        final r = snap.data;
        final items = [
          (KipuIcono.colegio, r?.colegios ?? 0, 'Colegios'),
          (KipuIcono.cursos, r?.cursos ?? 0, 'Cursos / asignaturas'),
          (KipuIcono.reportes, r?.secciones ?? 0, 'Secciones'),
          (KipuIcono.estudiantes, r?.estudiantes ?? 0, 'Estudiantes'),
        ];
        return LayoutBuilder(builder: (context, c) {
          final columnas = c.maxWidth >= 600 ? 4 : 2;
          final ancho = (c.maxWidth - 14 * (columnas - 1)) / columnas;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (var i = 0; i < items.length; i++)
                Container(
                  width: ancho,
                  height: 92,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: KipuColores.tarjetas[i]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: KipuIcon(items[i].$1,
                            size: 22, color: KipuColores.tarjetas[i][0]),
                      ),
                      const Spacer(),
                      Text('${items[i].$2}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.1,
                              fontWeight: FontWeight.w700)),
                      Text(items[i].$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11.5)),
                    ],
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}

// ---------------------------------------------------------------- Estadísticas

class _Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Tarjeta(
      {required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: child,
      );
}

class _Filtro<T> extends StatelessWidget {
  final T valor;
  final Map<T, String> opciones;
  final ValueChanged<T> onCambio;
  const _Filtro(
      {required this.valor, required this.opciones, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: valor,
      onSelected: onCambio,
      itemBuilder: (_) => [
        for (final o in opciones.entries)
          PopupMenuItem(value: o.key, child: Text(o.value)),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: KipuColores.morado,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(maxWidth: 150),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(opciones[valor] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _Estadisticas extends StatelessWidget {
  final bool enFila;
  const _Estadisticas({required this.enFila});

  @override
  Widget build(BuildContext context) {
    if (enFila) {
      return const IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _EstadisticaDona()),
            SizedBox(width: 18),
            Expanded(child: _EstadisticaBarras()),
          ],
        ),
      );
    }
    return const Column(
      children: [
        _EstadisticaDona(),
        SizedBox(height: 18),
        _EstadisticaBarras(),
      ],
    );
  }
}

class _SinNotas extends StatelessWidget {
  const _SinNotas();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          const Text('Aún no hay notas registradas.',
              style: TextStyle(color: KipuColores.gris)),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => cargarDatosDeEjemplo(db),
            child: const Text('Ver con datos de ejemplo'),
          ),
        ],
      ),
    );
  }
}

class _EstadisticaDona extends StatefulWidget {
  const _EstadisticaDona();

  @override
  State<_EstadisticaDona> createState() => _EstadisticaDonaState();
}

class _EstadisticaDonaState extends State<_EstadisticaDona> {
  int _curso = 0; // 0 = todos

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CursoConColegio>>(
      stream: db.verCursos(),
      builder: (context, snapCursos) {
        final opciones = <int, String>{
          0: 'Total',
          for (final c in snapCursos.data ?? <CursoConColegio>[])
            c.curso.id: '${c.curso.nombre} ${c.curso.grado} ${c.curso.seccion}',
        };
        if (!opciones.containsKey(_curso)) _curso = 0;
        return _Tarjeta(
          child: StreamBuilder<Map<String, int>>(
            stream: db.verNiveles(cursoId: _curso == 0 ? null : _curso),
            builder: (context, snap) {
              final n = snap.data ?? {};
              final total = n.values.fold(0, (a, b) => a + b);
              final aprobados = total - (n['C'] ?? 0);
              final pct = total == 0 ? 0 : (aprobados * 100 / total).round();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('ESTADÍSTICA ACADÉMICA',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      _Filtro<int>(
                        valor: _curso,
                        opciones: opciones,
                        onCambio: (v) => setState(() => _curso = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (total == 0)
                    const _SinNotas()
                  else
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            painter: _Dona(aprobados / total),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: '$pct',
                                        style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w500)),
                                    const TextSpan(
                                        text: '%',
                                        style: TextStyle(fontSize: 14)),
                                  ])),
                                  const Text('APROBADOS',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final k in ['AD', 'A', 'B', 'C'])
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${n[k] ?? 0}',
                                          style: const TextStyle(
                                              fontSize: 22,
                                              height: 1.1,
                                              fontWeight: FontWeight.w700)),
                                      Text(_nombresNivel[k]!,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: KipuColores.morado)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _Dona extends CustomPainter {
  final double valor;
  _Dona(this.valor);

  @override
  void paint(Canvas canvas, Size size) {
    const grosor = 11.0;
    final rect = Offset.zero & size;
    final arco = rect.deflate(grosor / 2);
    canvas.drawArc(
        arco,
        0,
        2 * pi,
        false,
        Paint()
          ..color = KipuColores.moradoClaro
          ..style = PaintingStyle.stroke
          ..strokeWidth = grosor);
    canvas.drawArc(
        arco,
        -pi / 2,
        2 * pi * valor,
        false,
        Paint()
          ..shader = const SweepGradient(
            colors: [Color(0xFF6D5BE6), Color(0xFF8F7CF5), Color(0xFF6D5BE6)],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = grosor);
  }

  @override
  bool shouldRepaint(_Dona old) => old.valor != valor;
}

class _EstadisticaBarras extends StatefulWidget {
  const _EstadisticaBarras();

  @override
  State<_EstadisticaBarras> createState() => _EstadisticaBarrasState();
}

class _EstadisticaBarrasState extends State<_EstadisticaBarras> {
  int _periodo = 0; // 0 = todos

  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      child: StreamBuilder<Map<String, int>>(
        stream: db.verNiveles(periodo: _periodo == 0 ? null : _periodo),
        builder: (context, snap) {
          final n = snap.data ?? {};
          final total = n.values.fold(0, (a, b) => a + b);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('NIVELES DE LOGRO',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  _Filtro<int>(
                    valor: _periodo,
                    opciones: const {
                      0: 'Total',
                      1: 'I bimestre',
                      2: 'II bimestre',
                      3: 'III bimestre',
                      4: 'IV bimestre',
                    },
                    onCambio: (v) => setState(() => _periodo = v),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (total == 0)
                const _SinNotas()
              else
                for (final k in ['AD', 'A', 'B', 'C'])
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _Barra(
                      etiqueta: _nombresNivel[k]!,
                      valor: (n[k] ?? 0) / total,
                      colores: _coloresNivel[k]!,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  final String etiqueta;
  final double valor;
  final List<Color> colores;
  const _Barra(
      {required this.etiqueta, required this.valor, required this.colores});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(etiqueta,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            Text('${(valor * 100).round()}%',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(height: 1.4, color: KipuColores.tinta, margin: const EdgeInsets.only(top: 6)),
            FractionallySizedBox(
              widthFactor: valor.clamp(0.02, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: colores),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Destacado

class _Destacado extends StatelessWidget {
  const _Destacado();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<(Estudiante, CursoConColegio?)?>(
      stream: db.verDestacado(),
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) return const SizedBox.shrink();
        final (e, c) = d;
        final chip = c == null
            ? null
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: KipuColores.morado,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    '${c.curso.grado} ${c.curso.seccion} - ${c.colegio.nombre}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              );
        return _Tarjeta(
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          child: LayoutBuilder(builder: (context, cons) {
            final chico = cons.maxWidth < 560;
            final nombre = Text('${e.apellidos} ${e.nombres}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16));
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: KipuColores.morado,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const KipuIcon(KipuIcono.estrella,
                      size: 22, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text('PUESTO GLOBAL',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Container(
                    width: 1.5,
                    height: 26,
                    color: KipuColores.tinta,
                    margin: const EdgeInsets.symmetric(horizontal: 10)),
                Expanded(
                  child: chico
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            nombre,
                            if (c != null)
                              Text(
                                  '${c.curso.grado} ${c.curso.seccion} · ${c.colegio.nombre}',
                                  style: const TextStyle(
                                      fontSize: 12, color: KipuColores.morado)),
                          ],
                        )
                      : nombre,
                ),
                if (!chico && chip != null) chip,
              ],
            );
          }),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Columna derecha

class _Cabecera extends StatelessWidget {
  final String titulo;
  final Widget? accion;
  const _Cabecera({required this.titulo, this.accion});

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        padding: const EdgeInsets.fromLTRB(18, 0, 12, 0),
        decoration: const BoxDecoration(
          color: KipuColores.morado,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(titulo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            ?accion,
          ],
        ),
      );
}

class _MiPerfil extends StatelessWidget {
  const _MiPerfil();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: db.verAjuste('genero'),
      builder: (context, genero) => StreamBuilder<String?>(
        stream: db.verAjuste('nombre'),
        builder: (context, nombre) => StreamBuilder<String?>(
          stream: db.verAjuste('lugar'),
          builder: (context, lugar) {
            final esProfesora = genero.data == 'profesora';
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _Cabecera(
                    titulo: 'Mi perfil',
                    accion: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => editarPerfil(context),
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: KipuIcon(KipuIcono.editar,
                              size: 18, color: KipuColores.morado),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: KipuColores.moradoClaro,
                            border: Border.all(
                                color: KipuColores.morado, width: 1.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Transform.scale(
                            scale: 2.6,
                            alignment: const Alignment(0, -0.82),
                            child: Image.asset(
                              esProfesora
                                  ? 'assets/img/profesora.png'
                                  : 'assets/img/profesor.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(nombre.data ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified,
                                      size: 15, color: KipuColores.morado),
                                ],
                              ),
                              Text(esProfesora ? 'PROFESORA' : 'PROFESOR',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: KipuColores.gris,
                                      letterSpacing: .5)),
                              if ((lugar.data ?? '').isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const KipuIcon(KipuIcono.ubicacion,
                                        size: 16, color: KipuColores.morado),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(lugar.data!,
                                          style:
                                              const TextStyle(fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiCalendario extends StatefulWidget {
  const _MiCalendario();

  @override
  State<_MiCalendario> createState() => _MiCalendarioState();
}

class _MiCalendarioState extends State<_MiCalendario> {
  DateTime _dia = DateUtils.dateOnly(DateTime.now());

  DateTime get _domingo =>
      _dia.subtract(Duration(days: _dia.weekday % 7));

  void _cambiarMes(int mes) {
    final ultimo = DateUtils.getDaysInMonth(_dia.year, mes);
    setState(() => _dia = DateTime(_dia.year, mes, min(_dia.day, ultimo)));
  }

  @override
  Widget build(BuildContext context) {
    final semana = [for (var i = 0; i < 7; i++) _domingo.add(Duration(days: i))];
    const letras = ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'];
    final hoy = DateUtils.dateOnly(DateTime.now());
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cabecera(
            titulo: 'Mi calendario',
            accion: _Filtro<int>(
              valor: _dia.month,
              opciones: {
                for (var m = 1; m <= 12; m++)
                  m: _mayuscula(DateFormat('MMMM', 'es_PE')
                      .format(DateTime(2000, m))),
              },
              onCambio: _cambiarMes,
            ),
          ),
          Container(
            color: const Color(0xFFE9E8F2),
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            child: StreamBuilder<Set<String>>(
              stream: db.verFechasConEventos(
                  fechaClave(semana.first), fechaClave(semana.last)),
              builder: (context, snap) {
                final conEventos = snap.data ?? {};
                return Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _dia = semana[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: semana[i] == _dia
                                  ? KipuColores.morado
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(letras[i],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: semana[i] == _dia
                                            ? Colors.white
                                            : KipuColores.tinta)),
                                const SizedBox(height: 6),
                                Text('${semana[i].day}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: semana[i] == _dia
                                            ? Colors.white
                                            : (semana[i] == hoy
                                                ? KipuColores.morado
                                                : KipuColores.tinta))),
                                const SizedBox(height: 4),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: conEventos
                                            .contains(fechaClave(semana[i]))
                                        ? (semana[i] == _dia
                                            ? Colors.white
                                            : KipuColores.morado)
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: StreamBuilder<List<Evento>>(
              stream: db.verEventos(fechaClave(_dia)),
              builder: (context, snap) {
                final eventos = snap.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        DateFormat("MMMM, d", 'es_PE')
                            .format(_dia)
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    if (eventos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Sin pendientes este día.',
                            style: TextStyle(color: KipuColores.gris)),
                      ),
                    for (final e in eventos) _FilaEvento(evento: e),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaEvento extends StatelessWidget {
  final Evento evento;
  const _FilaEvento({required this.evento});

  @override
  Widget build(BuildContext context) {
    final cumple = evento.tipo == 'cumple';
    final hora = evento.hora == null
        ? 'Todo el día'
        : DateFormat('h:mm a', 'en_US')
            .format(DateFormat('HH:mm').parse(evento.hora!))
            .toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3A3650), width: .8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(hora, style: const TextStyle(fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 6),
            child: cumple
                ? const KipuIcon(KipuIcono.cumple,
                    size: 15, color: KipuColores.morado)
                : Container(
                    margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: KipuColores.morado, shape: BoxShape.circle),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento.titulo,
                    style: const TextStyle(fontSize: 13, height: 1.2)),
                if (evento.etiqueta != null) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: KipuColores.morado,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(evento.etiqueta!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
