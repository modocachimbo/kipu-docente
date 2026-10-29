import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/registro.dart';
import 'package:kipu/data/paises.dart';
import 'package:kipu/screens/estudiantes.dart';
import 'package:kipu/screens/registro.dart';

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

  test('la plantilla de Excel se vuelve a leer', () {
    final filas = leerExcel(plantillaExcel());
    expect(filas, hasLength(1));
    expect(filas.first.apellidos, 'QUISPE MAMANI');
    expect(filas.first.nombres, 'Luz Angélica');
    expect(filas.first.telefono, '987654321');
  });

  test('media de la columna según la escala', () {
    final e = {for (final x in peru.escalas) x.id: x};
    expect(mediaColumna(['15', '14', '16'], e['vigesimal']), '15,0');
    expect(mediaColumna(['A', 'B', 'A', 'AD'], e['cneb']), 'A');
    expect(
      mediaColumna(['Logrado', 'No logrado', 'Logrado'], e['logrado']),
      '2 de 3',
    );
    expect(mediaColumna([], e['vigesimal']), isNull);
  });
}
