import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/screens/asistencia_exportar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el reporte de asistencia sale en PDF y en Excel', () async {
    await initializeDateFormatting('es_PE');
    final ahora = DateTime(2026, 8, 1);
    final estudiantes = [
      for (var i = 0; i < 12; i++)
        Estudiante(
          id: i + 1,
          cursoId: 1,
          apellidos: ['QUISPE MAMANI', 'CÓRDOVA DÍAZ', 'HUAMÁN ROJAS'][i % 3],
          nombres: ['Lucía', 'Joaquín', 'Ximena', 'Mateo'][i % 4],
          desde: 1,
          creado: ahora,
        ),
    ];
    final fechas = [
      for (var d = 4; d <= 28; d += 3)
        '2026-08-${d.toString().padLeft(2, '0')}',
    ];
    final marcas = <(int, String), Asistencia>{
      for (final e in estudiantes)
        for (final (j, f) in fechas.indexed)
          (e.id, f): Asistencia(
            estudianteId: e.id,
            fecha: f,
            estado: (e.id + j) % 11 == 0
                ? 'F'
                : (e.id * j) % 13 == 1
                ? 'T'
                : (e.id + j) % 17 == 0
                ? 'J'
                : 'P',
            motivo: (e.id + j) % 11 == 0 ? 'Salud' : null,
            nota: (e.id + j) % 11 == 0 ? 'Avisó la mamá' : null,
          ),
    };
    final r = ReporteAsistencia(
      colegio: 'Elite School',
      curso: Curso(
        id: 1,
        colegioId: 1,
        nivel: 'Secundaria',
        grado: '3.° año',
        seccion: 'B',
        nombre: 'Química',
        creado: ahora,
      ),
      periodo: '3.° bimestre',
      desde: '2026-08-03',
      hasta: '2026-10-09',
      docente: 'Javier Ríos',
      color: const Color(0xFFE0661A),
      estudiantes: estudiantes,
      fechas: fechas,
      marcas: marcas,
    );
    final pdf = await pdfAsistencia(r);
    final xls = excelAsistencia(r);
    expect(pdf.length, greaterThan(1000));
    expect(xls.length, greaterThan(1000));
    final dir = Platform.environment['KIPU_SALIDA'];
    if (dir != null) {
      File('$dir/asistencia.pdf').writeAsBytesSync(pdf);
      File('$dir/asistencia.xlsx').writeAsBytesSync(xls);
    }
  });
}
