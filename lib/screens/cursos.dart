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
      appBar: AppBar(title: const Text('Mis cursos')),
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
            builder: (context, snapCol) => StreamBuilder<List<CursoConColegio>>(
              stream: db.verCursos(),
              builder: (context, snapCur) {
                final colegios = snapCol.data ?? [];
                final cursos = snapCur.data ?? [];
                if (colegios.isEmpty) {
                  return _Vacio(onCrear: () => crearColegio(context));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: _editando
                          ? _AvisoEdicion(
                              onListo: () => setState(() => _editando = false),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    for (final col in colegios) ...[
                      _BannerColegio(
                        colegio: col,
                        cursos: cursos
                            .where((c) => c.colegio.id == col.id)
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      _GrillaCursos(
                        cursos: cursos
                            .where((c) => c.colegio.id == col.id)
                            .toList(),
                        editando: _editando,
                        onAgregar: () => crearCurso(context, colegioId: col.id),
                      ),
                      const SizedBox(height: 26),
                    ],
                  ],
                );
              },
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

class _BannerColegio extends StatelessWidget {
  final Colegio colegio;
  final List<CursoConColegio> cursos;
  const _BannerColegio({required this.colegio, required this.cursos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      decoration: BoxDecoration(
        color: KipuColores.morado,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              [
                colegio.nombre,
                if ((colegio.lugar ?? '').isNotEmpty) colegio.lugar,
              ].join(' - ').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
  final bool editando;
  final VoidCallback onAgregar;

  const _GrillaCursos({
    required this.cursos,
    required this.editando,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columnas = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
        final ancho = (c.maxWidth - 12 * (columnas - 1)) / columnas;
        if (cursos.isEmpty && !editando) {
          return _SinCursos(onAgregar: onAgregar);
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final cc in cursos)
              SizedBox(
                width: ancho,
                child: TarjetaCurso(datos: cc, editando: editando),
              ),
            if (editando)
              SizedBox(
                width: ancho,
                child: _AgregarCurso(onTap: onAgregar),
              ),
          ],
        );
      },
    );
  }
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
  final bool editando;
  const TarjetaCurso({super.key, required this.datos, this.editando = false});

  @override
  Widget build(BuildContext context) {
    final cur = datos.curso;
    final tarjeta = Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CursoDetalle(datos: datos)),
        ),
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: KipuColores.morado, width: 5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cur.nivel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: KipuColores.morado,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          cur.grado.toUpperCase(),
                          style: TextStyle(
                            fontSize: 17,
                            color: KipuColores.morado,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: KipuColores.morado,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'SECCIÓN ${cur.seccion.toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: cur.nombre.toUpperCase()),
                          if ((cur.area ?? '').isNotEmpty &&
                              cur.area != cur.nombre)
                            TextSpan(
                              text: ' (${cur.area!.toUpperCase()})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: KipuColores.morado,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${datos.totalEstudiantes} est.',
                    style: const TextStyle(
                      fontSize: 11,
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
