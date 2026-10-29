import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/registro.dart';
import 'package:kipu/screens/estudiantes.dart';

void main() {
  test('separa "APELLIDOS, Nombres"', () {
    expect(separarNombre('QUISPE MAMANI, Luz'), ('QUISPE MAMANI', 'Luz'));
    expect(separarNombre('RIVERA DÍAZ\tLuna'), ('RIVERA DÍAZ', 'Luna'));
    expect(separarNombre('   '), isNull);
  });

  test('apellido corto para el celular', () {
    expect(apellidoCorto('DE LA CRUZ MAMANI'), 'de la Cruz M.');
    expect(apellidoCorto('CASTILLO DE LA CRUZ'), 'Castillo C.');
    expect(apellidoCorto('QUISPE'), 'Quispe');
  });
}
