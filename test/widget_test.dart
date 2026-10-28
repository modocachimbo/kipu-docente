import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/screens/curso_detalle.dart';

void main() {
  test('separa "APELLIDOS, Nombres"', () {
    expect(separarNombre('QUISPE MAMANI, Luz'), ('QUISPE MAMANI', 'Luz'));
    expect(separarNombre('RIVERA DÍAZ\tLuna'), ('RIVERA DÍAZ', 'Luna'));
    expect(separarNombre('   '), isNull);
  });
}
