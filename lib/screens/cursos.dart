import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'curso_detalle.dart';

const grados = {
  'Inicial': ['3 años', '4 años', '5 años'],
  'Primaria': [
    '1.° grado',
    '2.° grado',
    '3.° grado',
    '4.° grado',
    '5.° grado',
    '6.° grado',
  ],
  'Secundaria': ['1.° año', '2.° año', '3.° año', '4.° año', '5.° año'],
};

const secciones = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'Única'];

const areas = [
  'Ciencia y Tecnología',
  'Matemática',
  'Comunicación',
  'Personal Social',
  'Ciencias Sociales',
  'Desarrollo Personal, Ciudadanía y Cívica',
  'Educación para el Trabajo',
  'Inglés',
  'Arte y Cultura',
  'Educación Física',
  'Educación Religiosa',
  'Tutoría',
];

class MisCursos extends StatefulWidget {
  const MisCursos({super.key});

  @override
  State<MisCursos> createState() => _MisCursosState();
}

class _MisCursosState extends State<MisCursos> {
  bool _editando = false;
  bool _menuAbierto = false;

  void _cerrarMenu() => setState(() => _menuAbierto = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis cursos'),
        actions: [
          if (MediaQuery.sizeOf(context).width < 700)
            StreamBuilder<String?>(
              stream: db.verAjuste('orden_cursos'),
              builder: (context, snap) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BotonOrdenar(orden: snap.data ?? 'grado'),
              ),
            ),
        ],
      ),
      floatingActionButton: StreamBuilder<List<Colegio>>(
        stream: db.verColegios(),
        builder: (context, snap) {
          if ((snap.data ?? []).isEmpty) return const SizedBox.shrink();
          return _BotonFlotante(
            editando: _editando,
            abierto: _menuAbierto,
            onPrincipal: () => setState(() {
              if (_editando) {
                _editando = false;
              } else {
                _menuAbierto = !_menuAbierto;
              }
            }),
            opciones: [
              _Opcion('Nuevo colegio', KipuIcono.colegio, () {
                _cerrarMenu();
                crearColegio(context);
              }),
              _Opcion('Editar mis cursos', KipuIcono.editar, () {
                setState(() {
                  _menuAbierto = false;
                  _editando = true;
                });
              }),
            ],
          );
        },
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Colegio>>(
            stream: db.verColegios(),
            builder: (context, snapCol) => StreamBuilder<String?>(
              stream: db.verAjuste('colegio_activo'),
              builder: (context, snapAct) => StreamBuilder<String?>(
                stream: db.verAjuste('orden_cursos'),
                builder: (context, snapOrd) =>
                    StreamBuilder<List<CursoConColegio>>(
                      stream: db.verCursos(),
                      builder: (context, snapCur) =>
                          StreamBuilder<Map<int, IndicadoresCurso>>(
                            stream: db.verIndicadoresCursos(),
                            builder: (context, snapInd) {
                              final colegios = snapCol.data ?? [];
                              if (colegios.isEmpty) {
                                return snapCol.hasData
                                    ? _Vacio(
                                        onCrear: () => crearColegio(context),
                                      )
                                    : const SizedBox.shrink();
                              }
                              final activo = colegioActivo(
                                colegios,
                                snapAct.data,
                              );
                              final cursos = (snapCur.data ?? [])
                                  .where((c) => c.colegio.id == activo.id)
                                  .toList();
                              final orden = snapOrd.data ?? 'grado';
                              final ancho =
                                  MediaQuery.sizeOf(context).width >= 700;
                              return ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  4,
                                  20,
                                  110,
                                ),
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _PestanasColegios(
                                          colegios: colegios,
                                          activo: activo,
                                        ),
                                      ),
                                      if (ancho) ...[
                                        const SizedBox(width: 12),
                                        _BotonOrdenar(orden: orden),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    child: _editando
                                        ? _AvisoEdicion(
                                            onListo: () => setState(
                                              () => _editando = false,
                                            ),
                                          )
                                        : const SizedBox(
                                            width: double.infinity,
                                          ),
                                  ),
                                  _BannerColegio(
                                    colegio: activo,
                                    color: colorColegio(colegios, activo.id),
                                    cursos: cursos,
                                    indicadores: snapInd.data ?? {},
                                  ),
                                  const SizedBox(height: 6),
                                  _GrillaCursos(
                                    cursos: cursos,
                                    indicadores: snapInd.data ?? {},
                                    orden: orden,
                                    color: colorColegio(colegios, activo.id),
                                    editando: _editando,
                                    onAgregar: () => crearCurso(
                                      context,
                                      colegioId: activo.id,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    ),
              ),
            ),
          ),
          // Velo oscuro detrás del menú flotante; al tocarlo se cierra.
          IgnorePointer(
            ignoring: !_menuAbierto,
            child: AnimatedOpacity(
              opacity: _menuAbierto ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                onTap: _cerrarMenu,
                child: Container(color: Colors.black.withValues(alpha: .28)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Opcion {
  final String texto;
  final KipuIcono icono;
  final VoidCallback onTap;
  const _Opcion(this.texto, this.icono, this.onTap);
}

/// Botón flotante que se despliega hacia arriba como globos.
class _BotonFlotante extends StatelessWidget {
  final bool editando;
  final bool abierto;
  final VoidCallback onPrincipal;
  final List<_Opcion> opciones;

  const _BotonFlotante({
    required this.editando,
    required this.abierto,
    required this.onPrincipal,
    required this.opciones,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < opciones.length; i++)
          _Globo(
            opcion: opciones[i],
            visible: abierto,
            retraso: (opciones.length - 1 - i) * 40,
          ),
        FloatingActionButton.extended(
          onPressed: onPrincipal,
          backgroundColor: editando ? const Color(0xFF16A37F) : null,
          icon: AnimatedRotation(
            turns: abierto ? .125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              editando
                  ? Icons.check
                  : (abierto ? Icons.add : Icons.edit_outlined),
            ),
          ),
          label: Text(editando ? 'Listo' : (abierto ? 'Cerrar' : 'Editar')),
        ),
      ],
    );
  }
}

class _Globo extends StatelessWidget {
  final _Opcion opcion;
  final bool visible;
  final int retraso;
  const _Globo({
    required this.opcion,
    required this.visible,
    required this.retraso,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      child: !visible
          ? const SizedBox(width: 0, height: 0)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 200 + retraso),
              curve: Curves.easeOutBack,
              builder: (context, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - t)),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: opcion.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          child: Text(
                            opcion.texto,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: KipuColores.morado,
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: opcion.onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: KipuIcon(
                            opcion.icono,
                            color: Colors.white,
                            size: 22,
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
}

class _AvisoEdicion extends StatelessWidget {
  final VoidCallback onListo;
  const _AvisoEdicion({required this.onListo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: KipuColores.moradoClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, color: KipuColores.moradoOscuro, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo edición: agrega o elimina cursos. Usa ⋮ para editar o eliminar un colegio.',
              style: TextStyle(color: KipuColores.moradoOscuro, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onListo, child: const Text('Listo')),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  final VoidCallback onCrear;
  const _Vacio({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: KipuColores.moradoClaro,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance,
                size: 40,
                color: KipuColores.morado,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aún no tienes colegios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Crea el colegio donde enseñas y luego agrega tus cursos y secciones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KipuColores.gris),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCrear,
              icon: const Icon(Icons.add),
              label: const Text('Crear colegio'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Colores para distinguir colegios; el primero sigue al color de la app.
List<Color> get coloresColegio => [
  KipuColores.morado,
  const Color(0xFF3D7BF0),
  const Color(0xFF16A37F),
  const Color(0xFFF07A2D),
  const Color(0xFFE5508E),
];

/// Color fijo de un colegio según el orden en que se creó.
Color colorColegio(List<Colegio> colegios, int id) {
  final ids = colegios.map((c) => c.id).toList()..sort();
  final i = ids.indexOf(id);
  return coloresColegio[(i < 0 ? 0 : i) % coloresColegio.length];
}

/// Colegio elegido en Mis cursos; si no hay uno guardado, el primero.
Colegio colegioActivo(List<Colegio> colegios, String? guardado) =>
    colegios.firstWhere(
      (c) => c.id.toString() == guardado,
      orElse: () => colegios.first,
    );

class _PestanasColegios extends StatelessWidget {
  final List<Colegio> colegios;
  final Colegio activo;
  const _PestanasColegios({required this.colegios, required this.activo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: StreamBuilder<List<CursoConColegio>>(
        stream: db.verCursos(),
        builder: (context, snap) {
          final cursos = snap.data ?? [];
          return ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (final c in colegios)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Pestana(
                    texto: c.nombre,
                    color: colorColegio(colegios, c.id),
                    cantidad: cursos.where((x) => x.colegio.id == c.id).length,
                    elegida: c.id == activo.id,
                    onTap: () =>
                        db.guardarAjuste('colegio_activo', c.id.toString()),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: BorderSide(
                      color: KipuColores.morado.withValues(alpha: .4),
                      width: 1.5,
                    ),
                  ),
                  onPressed: () => crearColegio(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Colegio'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  final String texto;
  final Color color;
  final int cantidad;
  final bool elegida;
  final VoidCallback onTap;
  const _Pestana({
    required this.texto,
    required this.color,
    required this.cantidad,
    required this.elegida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tinta = elegida ? Colors.white : KipuColores.tinta;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: elegida ? color : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: elegida
            ? [
                BoxShadow(
                  color: color.withValues(alpha: .35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: elegida ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                texto,
                style: TextStyle(
                  color: tinta,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: elegida
                      ? Colors.white.withValues(alpha: .25)
                      : KipuColores.moradoClaro,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$cantidad',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: elegida ? Colors.white : KipuColores.gris,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _ordenes = {
  'grado': 'Grado y sección',
  'nombre': 'Nombre del curso',
  'horario': 'Según mi horario',
};

class _BotonOrdenar extends StatelessWidget {
  final String orden;
  const _BotonOrdenar({required this.orden});

  @override
  Widget build(BuildContext context) {
    final corto = MediaQuery.sizeOf(context).width < 700;
    return PopupMenuButton<String>(
      tooltip: 'Ordenar cursos',
      color: Colors.white,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) => db.guardarAjuste('orden_cursos', v),
      itemBuilder: (_) => [
        const PopupMenuItem(
          enabled: false,
          height: 30,
          child: Text(
            'ORDENAR CURSOS POR',
            style: TextStyle(fontSize: 11, color: KipuColores.gris),
          ),
        ),
        for (final e in _ordenes.entries)
          PopupMenuItem(
            value: e.key,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontWeight: e.key == orden
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: e.key == orden ? KipuColores.moradoOscuro : null,
                    ),
                  ),
                ),
                if (e.key == orden)
                  Icon(Icons.check, size: 18, color: KipuColores.morado),
              ],
            ),
          ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: corto ? KipuColores.moradoClaro : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert, size: 18, color: KipuColores.moradoOscuro),
            const SizedBox(width: 4),
            Text(
              corto
                  ? 'Ordenar'
                  : 'Ordenar: ${_ordenes[orden]!.split(' ').first}',
              style: TextStyle(
                color: KipuColores.moradoOscuro,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerColegio extends StatelessWidget {
  final Colegio colegio;
  final Color color;
  final List<CursoConColegio> cursos;
  final Map<int, IndicadoresCurso> indicadores;
  const _BannerColegio({
    required this.colegio,
    required this.color,
    required this.cursos,
    required this.indicadores,
  });

  @override
  Widget build(BuildContext context) {
    final alumnos = cursos.fold(0, (a, c) => a + c.totalEstudiantes);
    var presentes = 0, registros = 0;
    for (final c in cursos) {
      presentes += indicadores[c.curso.id]?.presentes ?? 0;
      registros += indicadores[c.curso.id]?.registros ?? 0;
    }
    final niveles = cursos.map((c) => c.curso.nivel).toSet().join(' y ');
    final ancho = MediaQuery.sizeOf(context).width >= 700;
    final detalle = [
      if ((colegio.lugar ?? '').isNotEmpty) colegio.lugar!,
      if (ancho && niveles.isNotEmpty) niveles,
      if (!ancho) '${cursos.length} ${cursos.length == 1 ? 'curso' : 'cursos'}',
      if (!ancho) '$alumnos alumnos',
    ].join(' · ');
    return Container(
      padding: EdgeInsets.fromLTRB(22, ancho ? 18 : 14, 6, ancho ? 18 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, .18)!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colegio.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (detalle.isNotEmpty)
                  Text(
                    detalle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
          if (ancho) ...[
            _Dato('${cursos.length}', 'cursos'),
            _Dato('$alumnos', 'alumnos'),
            if (registros > 0)
              _Dato('${(presentes * 100 / registros).round()}%', 'asistencia'),
          ],
          PopupMenuButton<String>(
            iconColor: Colors.white,
            tooltip: 'Opciones del colegio',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.white,
            onSelected: (v) async {
              switch (v) {
                case 'editar':
                  await editarColegio(context, colegio);
                case 'curso':
                  await crearCurso(context, colegioId: colegio.id);
                case 'borrar':
                  if (await _confirmarBorrarColegio(context, colegio, cursos)) {
                    await db.borrarColegio(colegio.id);
                  }
              }
            },
            itemBuilder: (_) => [
              _item('editar', Icons.edit_outlined, 'Editar nombre'),
              _item('curso', Icons.add, 'Agregar curso'),
              const PopupMenuDivider(),
              _item(
                'borrar',
                Icons.delete_outline,
                'Eliminar colegio',
                color: const Color(0xFFE5566B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _item(
    String valor,
    IconData icono,
    String texto, {
    Color? color,
  }) => PopupMenuItem(
    value: valor,
    child: Row(
      children: [
        Icon(icono, size: 20, color: color ?? KipuColores.morado),
        const SizedBox(width: 12),
        Text(texto, style: TextStyle(color: color)),
      ],
    ),
  );
}

class _Dato extends StatelessWidget {
  final String valor;
  final String texto;
  const _Dato(this.valor, this.texto);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );
}

/// Para borrar un colegio hay que escribir BORRAR, porque se lleva todo lo de adentro.
Future<bool> _confirmarBorrarColegio(
  BuildContext context,
  Colegio colegio,
  List<CursoConColegio> cursos,
) async {
  final estudiantes = cursos.fold(0, (a, c) => a + c.totalEstudiantes);
  final texto = TextEditingController();
  const rojo = Color(0xFFE5566B);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final listo = texto.text.trim().toUpperCase() == 'BORRAR';
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: rojo, size: 40),
          title: Text('¿Eliminar ${colegio.nombre}?'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se borrará todo lo que está dentro de este colegio: '
                  '${cursos.length} ${cursos.length == 1 ? 'curso' : 'cursos'} y '
                  '$estudiantes ${estudiantes == 1 ? 'estudiante' : 'estudiantes'}, '
                  'con su asistencia y sus notas. No se puede deshacer.',
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Para confirmar, escribe '),
                      TextSpan(
                        text: 'BORRAR',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: rojo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: texto,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'BORRAR'),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: rojo),
              onPressed: listo ? () => Navigator.pop(ctx, true) : null,
              child: const Text('Eliminar todo'),
            ),
          ],
        );
      },
    ),
  );
  return r ?? false;
}

class _GrillaCursos extends StatelessWidget {
  final List<CursoConColegio> cursos;
  final Map<int, IndicadoresCurso> indicadores;
  final String orden;
  final Color color;
  final bool editando;
  final VoidCallback onAgregar;

  const _GrillaCursos({
    required this.cursos,
    required this.indicadores,
    required this.orden,
    required this.color,
    required this.editando,
    required this.onAgregar,
  });

  /// Posición del grado dentro de su nivel (Inicial, Primaria, Secundaria).
  static int _posGrado(Curso c) {
    final niveles = grados.keys.toList();
    final n = niveles.indexOf(c.nivel);
    final g = grados[c.nivel]?.indexOf(c.grado) ?? -1;
    return (n < 0 ? 9 : n) * 100 + (g < 0 ? 99 : g);
  }

  /// Agrupa y ordena los cursos según lo que eligió el docente.
  List<(String?, List<CursoConColegio>)> _grupos(DateTime ahora) {
    int porGrado(CursoConColegio a, CursoConColegio b) {
      final g = _posGrado(a.curso).compareTo(_posGrado(b.curso));
      return g != 0 ? g : a.curso.seccion.compareTo(b.curso.seccion);
    }

    final lista = [...cursos];
    switch (orden) {
      case 'nombre':
        lista.sort((a, b) {
          final n = a.curso.nombre.compareTo(b.curso.nombre);
          return n != 0 ? n : porGrado(a, b);
        });
        return _agrupar(lista, (c) => c.curso.nombre.toUpperCase());
      case 'horario':
        DateTime clave(CursoConColegio c) {
          final p = indicadores[c.curso.id]?.proximaClase(ahora);
          if (p == null) return DateTime(9999);
          final partes = p.bloque.inicio.split(':').map(int.parse).toList();
          return DateTime(
            p.dia.year,
            p.dia.month,
            p.dia.day,
            partes[0],
            partes[1],
          );
        }
        lista.sort((a, b) => clave(a).compareTo(clave(b)));
        return [(null, lista)];
      default:
        lista.sort(porGrado);
        final variosNiveles =
            cursos.map((c) => c.curso.nivel).toSet().length > 1;
        return _agrupar(
          lista,
          (c) =>
              (variosNiveles
                      ? '${c.curso.nivel} · ${c.curso.grado}'
                      : c.curso.grado)
                  .toUpperCase(),
        );
    }
  }

  static List<(String?, List<CursoConColegio>)> _agrupar(
    List<CursoConColegio> lista,
    String Function(CursoConColegio) titulo,
  ) {
    final grupos = <(String?, List<CursoConColegio>)>[];
    for (final c in lista) {
      final t = titulo(c);
      if (grupos.isNotEmpty && grupos.last.$1 == t) {
        grupos.last.$2.add(c);
      } else {
        grupos.add((t, [c]));
      }
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    if (cursos.isEmpty && !editando) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _SinCursos(onAgregar: onAgregar),
      );
    }
    final ahora = DateTime.now();
    final grupos = _grupos(ahora);
    return LayoutBuilder(
      builder: (context, c) {
        final columnas = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
        final ancho = (c.maxWidth - 12 * (columnas - 1)) / columnas;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var g = 0; g < grupos.length; g++) ...[
              if (grupos[g].$1 != null) _TituloGrupo(grupos[g].$1!),
              if (grupos[g].$1 == null) const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final cc in grupos[g].$2)
                    SizedBox(
                      width: ancho,
                      child: TarjetaCurso(
                        datos: cc,
                        color: color,
                        indicadores: indicadores[cc.curso.id],
                        mostrarGrado: orden != 'grado',
                        editando: editando,
                      ),
                    ),
                  if (editando && g == grupos.length - 1)
                    SizedBox(
                      width: ancho,
                      child: _AgregarCurso(onTap: onAgregar),
                    ),
                ],
              ),
            ],
            if (editando && grupos.isEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                children: [
                  SizedBox(
                    width: ancho,
                    child: _AgregarCurso(onTap: onAgregar),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TituloGrupo extends StatelessWidget {
  final String texto;
  const _TituloGrupo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Row(
      children: [
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .6,
            color: KipuColores.gris,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Color(0xFFDDD9EE), height: 1)),
      ],
    ),
  );
}

class _SinCursos extends StatelessWidget {
  final VoidCallback onAgregar;
  const _SinCursos({required this.onAgregar});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text(
        'Aún no tienes cursos aquí.',
        style: TextStyle(color: KipuColores.gris),
      ),
      TextButton.icon(
        onPressed: onAgregar,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Agregar curso'),
      ),
    ],
  );
}

class _AgregarCurso extends StatelessWidget {
  final VoidCallback onTap;
  const _AgregarCurso({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .9, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Material(
        color: KipuColores.moradoClaro.withValues(alpha: .5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: KipuColores.morado.withValues(alpha: .5),
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SizedBox(
            height: 104,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: KipuColores.morado,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agregar curso',
                  style: TextStyle(
                    color: KipuColores.moradoOscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TarjetaCurso extends StatelessWidget {
  final CursoConColegio datos;
  final Color? color;
  final IndicadoresCurso? indicadores;
  final bool mostrarGrado;
  final bool editando;
  const TarjetaCurso({
    super.key,
    required this.datos,
    this.color,
    this.indicadores,
    this.mostrarGrado = true,
    this.editando = false,
  });

  static const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final cur = datos.curso;
    final tono = color ?? KipuColores.morado;
    final ahora = DateTime.now();
    final proxima = indicadores?.proximaClase(ahora);
    final pct = indicadores?.pctAsistencia;
    final enC = indicadores?.enC ?? 0;
    final subtitulo = mostrarGrado
        ? '${cur.grado} · ${cur.nivel}'
        : (cur.area ?? cur.nivel);
    final tarjeta = Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CursoDetalle(datos: datos)),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: tono, width: 5)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tono,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SECCIÓN ${cur.seccion.toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cur.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: KipuColores.gris,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: tono,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (proxima != null)
                    _Ficha(
                      '${DateUtils.isSameDay(proxima.dia, ahora) ? 'Hoy' : _dias[proxima.dia.weekday - 1]} ${proxima.bloque.inicio}',
                      KipuColores.moradoClaro,
                      KipuColores.moradoOscuro,
                    ),
                  _Ficha(
                    '${datos.totalEstudiantes} alumnos',
                    const Color(0xFFF0EEF6),
                    KipuColores.gris,
                  ),
                  if (pct != null)
                    _Ficha(
                      '$pct% asist.',
                      const Color(0xFFDDF6EE),
                      const Color(0xFF12936F),
                    ),
                  if (enC > 0)
                    _Ficha(
                      '$enC en C',
                      const Color(0xFFFFEBDD),
                      const Color(0xFFD96D1F),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!editando) return tarjeta;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tarjeta,
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: const Color(0xFFE5566B),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                if (await confirmar(
                  context,
                  '¿Eliminar ${cur.nombre} ${cur.grado} ${cur.seccion}?',
                  'Se borrarán sus ${datos.totalEstudiantes} estudiantes, '
                      'su asistencia y sus notas.',
                )) {
                  await db.borrarCurso(cur.id);
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Ficha extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color tinta;
  const _Ficha(this.texto, this.fondo, this.tinta);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: tinta,
      ),
    ),
  );
}

Future<bool> confirmar(
  BuildContext context,
  String titulo,
  String texto, {
  String accion = 'Eliminar',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return r ?? false;
}

Future<void> _hoja(BuildContext context, String titulo, Widget contenido) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: KipuColores.fondo,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(ctx).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const Text(
              'Por favor, completa el formulario',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: KipuColores.gris),
            ),
            const SizedBox(height: 18),
            contenido,
          ],
        ),
      ),
    ),
  );
}

Future<void> crearColegio(BuildContext context) => _formColegio(context);

Future<void> editarColegio(BuildContext context, Colegio colegio) =>
    _formColegio(context, colegio: colegio);

Future<void> _formColegio(BuildContext context, {Colegio? colegio}) {
  final form = GlobalKey<FormState>();
  final nombre = TextEditingController(text: colegio?.nombre);
  final lugar = TextEditingController(text: colegio?.lugar);
  return _hoja(
    context,
    colegio == null ? 'Crear colegio' : 'Editar colegio',
    Builder(
      builder: (ctx) => Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nombre,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del colegio',
                hintText: 'Ej. Elite School',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Escribe el nombre' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lugar,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Distrito o ciudad (opcional)',
                hintText: 'Ej. Huacho',
              ),
            ),
            const SizedBox(height: 20),
            _Botones(
              onGuardar: () async {
                if (!form.currentState!.validate()) return;
                final ciudad = lugar.text.trim().isEmpty
                    ? null
                    : lugar.text.trim();
                if (colegio == null) {
                  await db.crearColegio(nombre.text.trim(), ciudad);
                } else {
                  await db.editarColegio(
                    colegio.id,
                    nombre.text.trim(),
                    ciudad,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> crearCurso(BuildContext context, {int? colegioId}) async {
  final colegios = await db.verColegios().first;
  if (!context.mounted) return;
  if (colegios.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Primero crea un colegio')));
    return crearColegio(context);
  }
  return _hoja(
    context,
    'Agregar un nuevo curso',
    _FormCurso(colegios: colegios, colegioId: colegioId ?? colegios.first.id),
  );
}

class _FormCurso extends StatefulWidget {
  final List<Colegio> colegios;
  final int colegioId;
  const _FormCurso({required this.colegios, required this.colegioId});

  @override
  State<_FormCurso> createState() => _FormCursoState();
}

class _FormCursoState extends State<_FormCurso> {
  final _form = GlobalKey<FormState>();
  late int _colegio = widget.colegioId;
  String? _nivel;
  String? _grado;
  String? _seccion;
  String? _area;
  final _nombre = TextEditingController();

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final nombre = _nombre.text.trim().isEmpty ? _area! : _nombre.text.trim();
    await db.crearCurso(
      CursosCompanion.insert(
        colegioId: _colegio,
        nivel: _nivel!,
        grado: _grado!,
        seccion: _seccion!,
        nombre: nombre,
        area: Value(_area),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String? requerido(String? v) => v == null ? 'Selecciona' : null;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.colegios.length > 1) ...[
            DropdownButtonFormField<int>(
              initialValue: _colegio,
              decoration: const InputDecoration(labelText: 'Colegio'),
              items: [
                for (final c in widget.colegios)
                  DropdownMenuItem(value: c.id, child: Text(c.nombre)),
              ],
              onChanged: (v) => setState(() => _colegio = v!),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _nivel,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: [
                    for (final n in grados.keys)
                      DropdownMenuItem(value: n, child: Text(n)),
                  ],
                  validator: requerido,
                  onChanged: (v) => setState(() {
                    _nivel = v;
                    _grado = null;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_nivel),
                  initialValue: _grado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Grado'),
                  items: [
                    for (final g in grados[_nivel] ?? const <String>[])
                      DropdownMenuItem(value: g, child: Text(g)),
                  ],
                  validator: requerido,
                  onChanged: (v) => setState(() => _grado = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _seccion,
            decoration: const InputDecoration(labelText: 'Sección'),
            items: [
              for (final s in secciones)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            validator: requerido,
            onChanged: (v) => setState(() => _seccion = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _area,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Área curricular'),
            items: [
              for (final a in areas) DropdownMenuItem(value: a, child: Text(a)),
            ],
            validator: requerido,
            onChanged: (v) => setState(() => _area = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nombre del curso (opcional)',
              hintText: 'Ej. Química, Física, Biología',
            ),
          ),
          const SizedBox(height: 20),
          _Botones(onGuardar: _guardar),
        ],
      ),
    );
  }
}

class _Botones extends StatelessWidget {
  final VoidCallback onGuardar;
  const _Botones({required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onPressed: onGuardar,
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
