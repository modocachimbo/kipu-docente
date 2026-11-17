import 'dart:typed_data';

import 'archivo_local.dart';

export 'archivo_local.dart';

/// En la web no hay carpeta propia.
bool get hayCarpetaLocal => false;

Future<String?> carpetaLocal() async => null;

Future<void> guardarLocal(String nombre, Uint8List bytes) async {}

Future<List<ArchivoLocal>> listarLocal() async => const [];

Future<Uint8List> leerLocal(String ruta) async => Uint8List(0);

Future<void> borrarLocal(String ruta) async {}
