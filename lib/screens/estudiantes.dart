import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/database.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'cursos.dart' show confirmar;

/// Foto del estudiante o, si no tiene, las iniciales de su primer apellido y
/// su primer nombre.
class AvatarEstudiante extends StatelessWidget {
  final Estudiante estudiante;
  final double tam;
  const AvatarEstudiante(this.estudiante, {super.key, this.tam = 36});

  static const _tonos = [
    (Color(0xFFE6E8FB), Color(0xFF3A44B0)),
    (Color(0xFFE2ECFD), Color(0xFF2557C7)),
    (Color(0xFFD9F4EC), Color(0xFF0E7A5F)),
    (Color(0xFFFCE3EE), Color(0xFFB8336C)),
    (Color(0xFFFDE9DB), Color(0xFFC25A16)),
    (Color(0xFFE9E6FD), Color(0xFF5B4BD6)),
  ];

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(tam * .34);
    final foto = estudiante.foto;
    if (foto != null) {
      return ClipRRect(
        borderRadius: radio,
        child: Image.memory(foto, width: tam, height: tam, fit: BoxFit.cover),
      );
    }
    final (fondo, texto) = _tonos[estudiante.id % _tonos.length];
    return Container(
      width: tam,
      height: tam,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fondo, borderRadius: radio),
      child: Text(
        iniciales(estudiante),
        style: TextStyle(
          color: texto,
          fontSize: tam * .36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Pide una foto de la galería, ya reducida para no llenar la base de datos.
Future<Uint8List?> elegirFoto() async {
  final img = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 320,
    maxHeight: 320,
    imageQuality: 82,
  );
  return img?.readAsBytes();
}

/// Ventana para pegar la lista completa de estudiantes del curso.
Future<void> pegarLista(BuildContext context, int cursoId) async {
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
                hintText:
                    'QUISPE MAMANI, Luz Angélica\n'
                    'RIVERA DÍAZ, Luna',
              ),
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
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  var n = 0;
  for (final linea in texto.text.split('\n')) {
    final e = separarNombre(linea);
    if (e == null) continue;
    await db.guardarEstudiante(
      EstudiantesCompanion.insert(
        cursoId: cursoId,
        apellidos: e.$1.toUpperCase(),
        nombres: e.$2,
      ),
    );
    n++;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Se agregaron $n estudiantes')));
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

/// Ficha para crear o editar un estudiante, con su foto.
Future<void> editarEstudiante(
  BuildContext context,
  int cursoId, [
  Estudiante? e,
]) {
  final form = GlobalKey<FormState>();
  final apellidos = TextEditingController(text: e?.apellidos);
  final nombres = TextEditingController(text: e?.nombres);
  final dni = TextEditingController(text: e?.dni);
  final apoderado = TextEditingController(text: e?.apoderado);
  final telefono = TextEditingController(text: e?.telefono);
  var foto = e?.foto;
  String? opcional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          0,
          22,
          MediaQuery.viewInsetsOf(ctx).bottom + 22,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final f = await elegirFoto();
                        if (f != null) setState(() => foto = f);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          foto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    foto!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: KipuColores.fondo,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: KipuIcon(
                                      KipuIcono.camara,
                                      size: 28,
                                      color: KipuColores.morado,
                                    ),
                                  ),
                                ),
                          if (foto != null)
                            Positioned(
                              right: -6,
                              bottom: -6,
                              child: GestureDetector(
                                onTap: () => setState(() => foto = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const KipuIcon(
                                    KipuIcono.cerrar,
                                    size: 16,
                                    color: KipuColores.gris,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e == null
                                ? 'Nuevo estudiante'
                                : 'Editar estudiante',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            foto == null
                                ? 'Toca el recuadro para poner su foto'
                                : 'Toca la foto para cambiarla',
                            style: const TextStyle(
                              fontSize: 13,
                              color: KipuColores.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                    labelText: 'DNI (opcional)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apoderado,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apoderado (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefono,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular del apoderado (opcional)',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (e != null) ...[
                      IconButton.outlined(
                        tooltip: 'Eliminar',
                        onPressed: () async {
                          if (await confirmar(
                            ctx,
                            '¿Eliminar estudiante?',
                            '${e.apellidos}, ${e.nombres}',
                          )) {
                            await db.borrarEstudiante(e.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                          }
                        },
                        icon: const KipuIcon(
                          KipuIcono.borrar,
                          size: 22,
                          color: Color(0xFFC2334A),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (!form.currentState!.validate()) return;
                          await db.guardarEstudiante(
                            EstudiantesCompanion(
                              id: e == null
                                  ? const Value.absent()
                                  : Value(e.id),
                              cursoId: Value(cursoId),
                              apellidos: Value(
                                apellidos.text.trim().toUpperCase(),
                              ),
                              nombres: Value(nombres.text.trim()),
                              dni: Value(opcional(dni)),
                              apoderado: Value(opcional(apoderado)),
                              telefono: Value(opcional(telefono)),
                              foto: Value(foto),
                            ),
                          );
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
    ),
  );
}
