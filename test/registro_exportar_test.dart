import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/data/paises.dart';
import 'package:kipu/screens/registro_exportar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el registro de notas sale en PDF y en Excel', () async {
    await initializeDateFormatting('es_PE');
    final ahora = DateTime(2026, 4, 1);
    final escalas = {for (final e in peru.escalas) e.id: e};
    final estudiantes = [
      for (var i = 0; i < 14; i++)
        Estudiante(
          id: i + 1,
          cursoId: 1,
          apellidos: ['QUISPE MAMANI', 'CÓRDOVA DÍAZ', 'HUAMÁN ROJAS'][i % 3],
          nombres: ['Lucía', 'Joaquín', 'Ximena', 'Mateo'][i % 4],
          desde: i == 13 ? 2 : 1,
          creado: ahora,
        ),
    ];
    RegistroColumna col(int id, int p, String cod, String tema, String esc) =>
        RegistroColumna(
          id: id,
          cursoId: 1,
          periodo: p,
          orden: id,
          codigo: cod,
          tema: tema,
          fecha: '2026-0${3 + p}-${10 + id % 18}',
          tipo: 'nota',
          escala: esc,
          enEquipo: false,
          fijada: false,
        );
    final c1 = [
      col(1, 1, 'F1', 'Materia y energía', 'vigesimal'),
      col(2, 1, 'T1', 'Informe de laboratorio', 'cneb'),
      col(3, 1, 'FB', 'Feedback de la práctica', 'logrado'),
      col(4, 1, 'F2', 'Tabla periódica', 'vigesimal'),
    ];
    final c2 = [
      for (
        var i = 0;
        i < int.parse(Platform.environment['KIPU_COLS'] ?? '1');
        i++
      )
        col(5 + i, 2, 'F${3 + i}', 'Enlaces químicos y más', 'vigesimal'),
    ];
    final notas = <int, Map<int, String>>{
      1: {for (final e in estudiantes) e.id: '${8 + e.id % 12}'},
      2: {
        for (final e in estudiantes) e.id: ['AD', 'A', 'B', 'C'][e.id % 4],
      },
      3: {
        for (final e in estudiantes)
          if (e.id % 5 != 0) e.id: e.id % 7 == 0 ? 'No logrado' : 'Logrado',
      },
      4: {
        for (final e in estudiantes)
          if (e.id % 3 != 0) e.id: '1${e.id % 10}.5',
      },
      for (var i = 0; i < 40; i++)
        5 + i: {for (final e in estudiantes) e.id: '${10 + (e.id + i) % 9}'},
    };
    HojaRegistro hoja(int p, String n, List<RegistroColumna> c) => HojaRegistro(
      periodo: n,
      estudiantes: estudiantes.where((e) => e.desde <= p).toList(),
      columnas: c,
      notas: notas,
    );
    final r = ReporteRegistro(
      colegio: 'Elite School',
      curso: Curso(
        id: 1,
        colegioId: 1,
        nivel: 'Secundaria',
        grado: '1.° año',
        seccion: 'A',
        nombre: 'Química',
        creado: ahora,
      ),
      docente: 'Javier Ríos',
      color: const Color(0xFFE0661A),
      alcance: 'Año completo',
      hojas: [
        hoja(1, '1.° bimestre', c1),
        hoja(2, '2.° bimestre', c2),
        hoja(3, '3.° bimestre', const []),
      ],
      escalaDe: (c) => escalas[c.escala],
    );
    final pdf = await pdfRegistro(r);
    final xls = excelRegistro(r);
    expect(pdf.length, greaterThan(1000));
    expect(xls.length, greaterThan(1000));
    final dir = Platform.environment['KIPU_SALIDA'];
    if (dir != null) {
      File('$dir/registro.pdf').writeAsBytesSync(pdf);
      File('$dir/registro.xlsx').writeAsBytesSync(xls);
    }
  });
}
