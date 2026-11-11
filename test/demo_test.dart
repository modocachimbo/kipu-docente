import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/academico.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/data/demo.dart';
import 'package:kipu/data/reportes.dart';

void main() {
  test('los datos de ejemplo llenan todos los reportes', () async {
    final db = KipuDb(NativeDatabase.memory());
    addTearDown(db.close);
    await cargarDatosDeEjemplo(db);

    final anio = await db.verAnioActivo().first;
    final cfg = await db.verConfigAcademica(anio).first;
    expect(cfg.configurado, isTrue);
    expect(cfg.fechasFaltantes, 0);
    final hoy = claveFecha(DateTime.now());
    final empezados = [
      for (var p = 1; p <= cfg.periodos.length; p++)
        if (cfg.periodos[p - 1].inicio!.compareTo(hoy) <= 0) p,
    ];

    final cursos = await db.verCursos().first;
    expect(cursos.length, 6);
    var riesgos = 0, anecdotas = 0, letras = 0;
    for (final c in cursos) {
      final d = await db.datosCurso(c, cfg);
      for (final p in empezados) {
        // Cada bimestre empezado tiene evaluaciones y nota de casi todos.
        expect(d.evaluaciones[p], isNotEmpty, reason: '${d.nombre} p$p');
        expect(
          d.notaPeriodo[p]!.length,
          greaterThan(d.estudiantes.length * .8),
          reason: '${d.nombre} p$p',
        );
        expect(d.asistenciaEn(p, anio), isNotEmpty);
      }
      if (d.letras) letras++;
      riesgos += enRiesgo(d, empezados.last, anio).length;
      anecdotas += d.anecdotas.length;
      // ignore: avoid_print
      print(
        '${d.nombre}: ${d.estudiantes.length} est., '
        'prom. ${[for (final p in empezados) numeroCorto(promedioDe(d.notas(p).values) ?? 0)]}, '
        'asist. ${numeroCorto(porcentajeAsistencia(conteoAsistencia(d.asistenciaEn(null, anio))) ?? 0)} %, '
        'apoyo ${enRiesgo(d, empezados.last, anio).length}, '
        'anéc. ${d.anecdotas.length}, letras ${d.letras}',
      );
    }
    expect(letras, 1, reason: 'el curso de primaria va en letras');
    expect(riesgos, greaterThan(6));
    expect(anecdotas, greaterThan(20));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
