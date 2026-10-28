import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../main.dart';
import '../theme.dart';
import 'curso_detalle.dart';

const grados = {
  'Inicial': ['3 años', '4 años', '5 años'],
  'Primaria': [
    '1.° grado',
    '2.° grado',
    '3.° grado',
    '4.° grado',
    '5.° grado',
    '6.° grado'
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

class MisCursos extends StatelessWidget {
  const MisCursos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis cursos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _menuCrear(context),
        icon: const Icon(Icons.add),
        label: const Text('Crear'),
      ),
      body: StreamBuilder<List<Colegio>>(
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              children: [
                for (final col in colegios) ...[
                  _BannerColegio(colegio: col),
                  const SizedBox(height: 12),
                  _GrillaCursos(
                    cursos:
                        cursos.where((c) => c.colegio.id == col.id).toList(),
                    onAgregar: () => crearCurso(context, colegioId: col.id),
                  ),
                  const SizedBox(height: 26),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _menuCrear(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance,
                  color: KipuColores.morado),
              title: const Text('Crear colegio'),
              onTap: () {
                Navigator.pop(ctx);
                crearColegio(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: KipuColores.morado),
              title: const Text('Crear curso / asignatura'),
              onTap: () {
                Navigator.pop(ctx);
                crearCurso(context);
              },
            ),
          ],
        ),
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
              decoration: const BoxDecoration(
                  color: KipuColores.moradoClaro, shape: BoxShape.circle),
              child: const Icon(Icons.account_balance,
                  size: 40, color: KipuColores.morado),
            ),
            const SizedBox(height: 18),
            const Text('Aún no tienes colegios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
  const _BannerColegio({required this.colegio});

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
              [colegio.nombre, if ((colegio.lugar ?? '').isNotEmpty) colegio.lugar]
                  .join(' - ')
                  .toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (v) async {
              if (v == 'borrar' &&
                  await confirmar(context,
                      '¿Eliminar ${colegio.nombre}?',
                      'Se borrarán también sus cursos y estudiantes.')) {
                await db.borrarColegio(colegio.id);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'borrar', child: Text('Eliminar colegio')),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrillaCursos extends StatelessWidget {
  final List<CursoConColegio> cursos;
  final VoidCallback onAgregar;

  const _GrillaCursos({required this.cursos, required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final columnas = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
      final ancho = (c.maxWidth - 12 * (columnas - 1)) / columnas;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final cc in cursos)
            SizedBox(width: ancho, child: TarjetaCurso(datos: cc)),
          SizedBox(
            width: ancho,
            height: 104,
            child: OutlinedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar curso'),
            ),
          ),
        ],
      );
    });
  }
}

class TarjetaCurso extends StatelessWidget {
  final CursoConColegio datos;
  const TarjetaCurso({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final cur = datos.curso;
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CursoDetalle(datos: datos)),
        ),
        child: Container(
          height: 104,
          decoration: const BoxDecoration(
            border: Border(
                left: BorderSide(color: KipuColores.morado, width: 5)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cur.nivel.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            color: KipuColores.morado,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(cur.grado.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 17,
                                color: KipuColores.morado,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: KipuColores.morado,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('SECCIÓN ${cur.seccion.toUpperCase()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: cur.nombre.toUpperCase()),
                        if ((cur.area ?? '').isNotEmpty &&
                            cur.area != cur.nombre)
                          TextSpan(
                              text: ' (${cur.area!.toUpperCase()})',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
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
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text('${datos.totalEstudiantes} est.',
                      style: const TextStyle(
                          fontSize: 11, color: KipuColores.gris)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmar(BuildContext context, String titulo, String texto) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar')),
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
          20, 0, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const Text('Por favor, completa el formulario',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: KipuColores.gris)),
            const SizedBox(height: 18),
            contenido,
          ],
        ),
      ),
    ),
  );
}

Future<void> crearColegio(BuildContext context) {
  final form = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final lugar = TextEditingController();
  return _hoja(
    context,
    'Crear colegio',
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
                  labelText: 'Nombre del colegio', hintText: 'Ej. Elite School'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Escribe el nombre' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lugar,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Distrito o ciudad (opcional)',
                  hintText: 'Ej. Huacho'),
            ),
            const SizedBox(height: 20),
            _Botones(onGuardar: () async {
              if (!form.currentState!.validate()) return;
              await db.crearColegio(nombre.text.trim(),
                  lugar.text.trim().isEmpty ? null : lugar.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            }),
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea un colegio')));
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
    await db.crearCurso(CursosCompanion.insert(
      colegioId: _colegio,
      nivel: _nivel!,
      grado: _grado!,
      seccion: _seccion!,
      nombre: nombre,
      area: Value(_area),
    ));
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
          child: FilledButton(onPressed: onGuardar, child: const Text('Guardar')),
        ),
      ],
    );
  }
}
