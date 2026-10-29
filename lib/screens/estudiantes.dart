import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
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
Future<void> pegarLista(
  BuildContext context,
  int cursoId, {
  int periodo = 1,
}) async {
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
        desde: Value(periodo),
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
  int periodo = 1,
  String Function(int periodo) nombrePeriodo = _periodoSimple,
]) {
  var desde = e?.desde ?? periodo;
  var hasta = e?.hasta;
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
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: KipuColores.fondo,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      KipuIcon(
                        KipuIcono.calendario,
                        size: 22,
                        color: hasta == null
                            ? KipuColores.morado
                            : const Color(0xFFC2334A),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasta == null
                              ? 'En el curso desde el ${nombrePeriodo(desde)}'
                              : 'Retirado desde el ${nombrePeriodo(hasta!)}',
                          style: const TextStyle(fontSize: 13.5),
                        ),
                      ),
                      if (e != null)
                        TextButton(
                          onPressed: () => setState(
                            () => hasta = hasta == null
                                ? (periodo > desde ? periodo : desde + 1)
                                : null,
                          ),
                          child: Text(hasta == null ? 'Se retiró' : 'Deshacer'),
                        ),
                    ],
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
                              desde: Value(desde),
                              hasta: Value(hasta),
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

String _periodoSimple(int p) => '$p.° periodo';

/// Opciones para traer la lista completa del curso.
Future<void> importarEstudiantes(
  BuildContext context,
  int cursoId, {
  required int periodo,
  required Color color,
}) async {
  final v = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 480),
    builder: (ctx) {
      Widget opcion(String id, KipuIcono i, String t, String d) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: KipuIcon(i, size: 28, color: color),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(d),
        onTap: () => Navigator.pop(ctx, id),
      );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Importar estudiantes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            opcion(
              'pegar',
              KipuIcono.pegar,
              'Pegar lista',
              'Copia apellidos y nombres del Excel o SIAGIE',
            ),
            opcion(
              'subir',
              KipuIcono.columna,
              'Subir Excel',
              'Con la plantilla llena: apellidos, nombres, DNI…',
            ),
            opcion(
              'plantilla',
              KipuIcono.abajo,
              'Descargar plantilla de Excel',
              'Llénala y luego súbela',
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
  if (!context.mounted) return;
  switch (v) {
    case 'pegar':
      await pegarLista(context, cursoId, periodo: periodo);
    case 'plantilla':
      await FilePicker.saveFile(
        fileName: 'plantilla-estudiantes.xlsx',
        bytes: plantillaExcel(),
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    case 'subir':
      final f = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (f == null) return;
      final filas = leerExcel(await f.xFile.readAsBytes());
      for (final x in filas) {
        await db.guardarEstudiante(
          EstudiantesCompanion.insert(
            cursoId: cursoId,
            apellidos: x.apellidos.toUpperCase(),
            nombres: x.nombres,
            dni: Value(x.dni),
            apoderado: Value(x.apoderado),
            telefono: Value(x.telefono),
            desde: Value(periodo),
          ),
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se agregaron ${filas.length} estudiantes')),
        );
      }
  }
}

const _columnasExcel = ['APELLIDOS', 'NOMBRES', 'DNI', 'APODERADO', 'CELULAR'];

Uint8List plantillaExcel() {
  final x = Excel.createExcel();
  final hoja = x[x.getDefaultSheet()!];
  hoja.appendRow([for (final c in _columnasExcel) TextCellValue(c)]);
  hoja.appendRow([
    TextCellValue('QUISPE MAMANI'),
    TextCellValue('Luz Angélica'),
    TextCellValue('74512345'),
    TextCellValue('Rosa Mamani'),
    TextCellValue('987654321'),
  ]);
  for (var i = 0; i < _columnasExcel.length; i++) {
    hoja.setColumnWidth(i, i < 2 ? 28 : 16);
  }
  return Uint8List.fromList(x.encode()!);
}

typedef FilaExcel = ({
  String apellidos,
  String nombres,
  String? dni,
  String? apoderado,
  String? telefono,
});

/// Lee la plantilla: salta la fila de títulos y las filas sin apellidos.
List<FilaExcel> leerExcel(List<int> bytes) {
  final x = Excel.decodeBytes(bytes);
  final hoja = x.tables.values.firstOrNull;
  if (hoja == null) return [];
  String? celda(List<Data?> fila, int i) {
    if (i >= fila.length) return null;
    final t = fila[i]?.value?.toString().trim() ?? '';
    return t.isEmpty ? null : t;
  }

  final r = <FilaExcel>[];
  for (final fila in hoja.rows) {
    final ap = celda(fila, 0);
    if (ap == null || ap.toUpperCase().startsWith('APELLIDO')) continue;
    var nombres = celda(fila, 1);
    var apellidos = ap;
    // Si vino todo en una columna, "APELLIDOS, Nombres".
    if (nombres == null) {
      final partes = separarNombre(ap);
      if (partes == null) continue;
      (apellidos, nombres) = partes;
    }
    r.add((
      apellidos: apellidos,
      nombres: nombres,
      dni: celda(fila, 2),
      apoderado: celda(fila, 3),
      telefono: celda(fila, 4),
    ));
  }
  return r;
}
