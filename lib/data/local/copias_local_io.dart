import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'archivo_local.dart';

export 'archivo_local.dart';

bool get hayCarpetaLocal => true;

Future<Directory> _carpeta() async {
  final base = await getApplicationDocumentsDirectory();
  final d = Directory('${base.path}${Platform.pathSeparator}copias');
  if (!await d.exists()) await d.create(recursive: true);
  return d;
}

Future<String?> carpetaLocal() async => (await _carpeta()).path;

Future<void> guardarLocal(String nombre, Uint8List bytes) async {
  final d = await _carpeta();
  // Se escribe aparte y luego se renombra: si se corta, no queda a medias.
  final tmp = File('${d.path}${Platform.pathSeparator}.$nombre.tmp');
  await tmp.writeAsBytes(bytes, flush: true);
  await tmp.rename('${d.path}${Platform.pathSeparator}$nombre');
}

Future<List<ArchivoLocal>> listarLocal() async {
  final d = await _carpeta();
  final r = <ArchivoLocal>[];
  await for (final f in d.list()) {
    if (f is File && f.path.endsWith('.kipu')) {
      final s = await f.stat();
      r.add(ArchivoLocal(
        f.path,
        f.uri.pathSegments.last,
        s.size,
        s.modified,
      ));
    }
  }
  r.sort((a, b) => b.fecha.compareTo(a.fecha));
  return r;
}

Future<Uint8List> leerLocal(String ruta) => File(ruta).readAsBytes();

Future<void> borrarLocal(String ruta) async {
  final f = File(ruta);
  if (await f.exists()) await f.delete();
}
