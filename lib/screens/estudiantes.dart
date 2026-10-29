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
import '../widgets/ventana.dart';

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

/// Opciones para traer la lista completa del curso.
Future<void> importarEstudiantes(
  BuildContext context,
  int cursoId, {
  required int periodo,
  required Color color,
}) async {
  final v = await ventanaCentrada<String>(
    context: context,
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
