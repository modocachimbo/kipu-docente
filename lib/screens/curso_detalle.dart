import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../main.dart';
import '../theme.dart';
import 'asistencia.dart';
import 'cursos.dart' show confirmar;

class CursoDetalle extends StatelessWidget {
  final CursoConColegio datos;
  const CursoDetalle({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final cur = datos.curso;
    return Scaffold(
      appBar: AppBar(
        title: Text(cur.nombre),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'pegar') _pegarLista(context);
              if (v == 'borrar' &&
                  await confirmar(context, '¿Eliminar este curso?',
                      'Se borrarán también sus estudiantes.')) {
                await db.borrarCurso(cur.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pegar', child: Text('Pegar lista de estudiantes')),
              PopupMenuItem(value: 'borrar', child: Text('Eliminar curso')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editarEstudiante(context, cur.id),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Estudiante'),
      ),
      body: StreamBuilder<List<Estudiante>>(
        stream: db.verEstudiantes(cur.id),
        builder: (context, snap) {
          final lista = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: KipuColores.morado,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cur.nivel} · ${datos.colegio.nombre}'.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${cur.grado} "${cur.seccion}"',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    if ((cur.area ?? '').isNotEmpty)
                      Text(cur.area!,
                          style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text('${lista.length} estudiantes',
                              style: const TextStyle(color: Colors.white70)),
                        ),
                        if (lista.isNotEmpty)
                          FilledButton.tonalIcon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: AppBar(
                                      title: Text('Asistencia · ${cur.nombre}')),
                                  body: PasarLista(datos: datos),
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.fact_check),
                            label: const Text('Pasar lista'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (lista.isEmpty)
                _SinEstudiantes(
                  onAgregar: () => _editarEstudiante(context, cur.id),
                  onPegar: () => _pegarLista(context),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < lista.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: 64),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: KipuColores.moradoClaro,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: KipuColores.moradoOscuro,
                                    fontWeight: FontWeight.w600)),
                          ),
                          title: Text(
                              '${lista[i].apellidos}, ${lista[i].nombres}'),
                          subtitle: lista[i].dni == null
                              ? null
                              : Text('DNI ${lista[i].dni}'),
                          onTap: () =>
                              _editarEstudiante(context, cur.id, lista[i]),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pegarLista(BuildContext context) async {
    final texto = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pegar lista'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Un estudiante por línea, como "APELLIDOS, Nombres". '
                'Puedes copiarla desde Excel o SIAGIE.',
                style: TextStyle(fontSize: 13, color: KipuColores.gris),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: texto,
                autofocus: true,
                maxLines: 10,
                minLines: 6,
                decoration: const InputDecoration(
                    hintText: 'QUISPE MAMANI, Luz Angélica\n'
                        'RIVERA DÍAZ, Luna'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Agregar')),
        ],
      ),
    );
    if (ok != true) return;
    var n = 0;
    for (final linea in texto.text.split('\n')) {
      final e = separarNombre(linea);
      if (e == null) continue;
      await db.guardarEstudiante(EstudiantesCompanion.insert(
          cursoId: datos.curso.id, apellidos: e.$1, nombres: e.$2));
      n++;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se agregaron $n estudiantes')));
    }
  }
}

/// Convierte "APELLIDOS, Nombres" (o separado por tabulación) en sus partes.
(String, String)? separarNombre(String linea) {
  final limpio = linea.trim();
  if (limpio.isEmpty) return null;
  for (final sep in [',', '\t']) {
    final i = limpio.indexOf(sep);
    if (i > 0) {
      return (limpio.substring(0, i).trim(), limpio.substring(i + 1).trim());
    }
  }
  return (limpio, '');
}

class _SinEstudiantes extends StatelessWidget {
  final VoidCallback onAgregar;
  final VoidCallback onPegar;
  const _SinEstudiantes({required this.onAgregar, required this.onPegar});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.groups_outlined, size: 44, color: KipuColores.morado),
            const SizedBox(height: 10),
            const Text('Agrega a tus estudiantes',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Uno por uno, o pega la lista completa desde Excel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KipuColores.gris),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                    onPressed: onAgregar,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Agregar')),
                OutlinedButton.icon(
                    onPressed: onPegar,
                    icon: const Icon(Icons.content_paste),
                    label: const Text('Pegar lista')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editarEstudiante(BuildContext context, int cursoId,
    [Estudiante? e]) {
  final form = GlobalKey<FormState>();
  final apellidos = TextEditingController(text: e?.apellidos);
  final nombres = TextEditingController(text: e?.nombres);
  final dni = TextEditingController(text: e?.dni);
  final apoderado = TextEditingController(text: e?.apoderado);
  final telefono = TextEditingController(text: e?.telefono);
  String? opcional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

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
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(e == null ? 'Nuevo estudiante' : 'Editar estudiante',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              TextFormField(
                controller: apellidos,
                autofocus: e == null,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Escribe los apellidos' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nombres,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Escribe los nombres' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dni,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                    labelText: 'DNI (opcional)', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: apoderado,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(labelText: 'Apoderado (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: telefono,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Celular del apoderado (opcional)'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (e != null) ...[
                    IconButton.outlined(
                      tooltip: 'Eliminar',
                      onPressed: () async {
                        if (await confirmar(ctx, '¿Eliminar estudiante?',
                            '${e.apellidos}, ${e.nombres}')) {
                          await db.borrarEstudiante(e.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (!form.currentState!.validate()) return;
                        await db.guardarEstudiante(EstudiantesCompanion(
                          id: e == null ? const Value.absent() : Value(e.id),
                          cursoId: Value(cursoId),
                          apellidos: Value(apellidos.text.trim().toUpperCase()),
                          nombres: Value(nombres.text.trim()),
                          dni: Value(opcional(dni)),
                          apoderado: Value(opcional(apoderado)),
                          telefono: Value(opcional(telefono)),
                        ));
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
