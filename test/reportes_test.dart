import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/colores_notas.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/data/reportes.dart';

void main() {
  test('promedios, aprobados y números', () {
    expect(promedioDe([10, 15, 20]), 15);
    expect(promedioDe(const []), isNull);
    expect(porcentajeAprobados([10, 11, 15, 8]), 50);
    expect(numeroCorto(15.25), '15,3');
    expect(numeroCorto(15.0), '15');
    expect(numeroCorto(150, 0), '150');
  });

  test('distribución por niveles (0–10, 11–13, 14–17, 18–20)', () {
    final d = distribucion([5, 10, 10.5, 13, 14, 17, 18, 20], ColoresNotas.tramosPorDefecto);
    expect(d, [2, 2, 2, 2]);
    expect(nombresTramos(ColoresNotas.tramosPorDefecto).last, 'Destacado');
  });

  test('asistencia: la justificada no cuenta', () {
    Asistencia a(String e) => Asistencia(estudianteId: 1, fecha: '2026-11-10', estado: e);
    final c = conteoAsistencia([a('P'), a('P'), a('T'), a('F'), a('J')]);
    expect(c, {'P': 2, 'T': 1, 'F': 1, 'J': 1});
    expect(porcentajeAsistencia(c), 75);
    expect(lunesDe('2026-11-12'), '2026-11-09');
    expect(lunesDe('2026-11-09'), '2026-11-09');
  });
}
