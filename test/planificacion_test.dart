import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:excel/excel.dart' as xl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/academico.dart';
import 'package:kipu/data/cneb.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/data/demo.dart';
import 'package:kipu/data/planificacion.dart';
import 'package:kipu/data/planificacion_excel.dart';
import 'package:kipu/screens/planificacion_exportar.dart';

Horario _bloque(int dia, String inicio, String fin) =>
    Horario(id: dia, cursoId: 1, dia: dia, inicio: inicio, fin: fin);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('proximasClases', () {
    final horario = [
      _bloque(1, '07:50', '09:20'),
      _bloque(3, '09:35', '11:05'),
    ];

    test('sigue el horario y salta las ocupadas', () {
      // Miércoles 11 de noviembre de 2026.
      final r = proximasClases(
        horario,
        DateTime(2026, 11, 11),
        cantidad: 3,
        ocupadas: {'2026-11-16 07:50'},
      );
      expect(r.map((c) => '${c.fecha} ${c.hora}'), [
        '2026-11-11 09:35',
        '2026-11-18 09:35',
        '2026-11-23 07:50',
      ]);
    });

    test('hoy no cuenta la clase que ya terminó', () {
      final r = proximasClases(
        horario,
        DateTime(2026, 11, 11),
        cantidad: 1,
        horaActual: '12:00',
      );
      expect(r.single.fecha, '2026-11-16');
    });

    test('se detiene en la fecha límite', () {
      final r = proximasClases(
        horario,
        DateTime(2026, 11, 11),
        cantidad: 10,
        hasta: '2026-11-18',
      );
      expect(r.length, 3);
    });
  });

  test('competencias del curso según el área y el nivel', () {
    final c = Curso(
      id: 1,
      colegioId: 1,
      nivel: 'Secundaria',
      grado: '5.° año',
      seccion: 'B',
      nombre: 'Química',
      area: 'Ciencia y Tecnología',
      creado: DateTime(2026),
    );
    final ids = competenciasDelCurso(c).map((k) => k.id).toList();
    expect(ids, containsAll(['indaga', 'explica', 'disena']));
    expect(ids, isNot(contains('cantidad')));
    // Todas las competencias tienen sus capacidades.
    for (final k in competenciasCneb) {
      expect(capacidadesCneb[k.id], isNotEmpty, reason: k.id);
    }
  });

  test('propósitos ida y vuelta en JSON', () {
    final l = [
      const Proposito(
        'indaga',
        capacidades: ['Analiza datos e información'],
        criterios: 'Registra datos',
        evidencia: 'Informe',
        instrumento: 'Rúbrica',
      ),
      const Proposito('explica'),
    ];
    final r = Proposito.lista(Proposito.aTexto(l));
    expect(r.length, 2);
    expect(r.first.capacidades, ['Analiza datos e información']);
    expect(r.first.instrumento, 'Rúbrica');
    expect(r.last.criterios, '');
    expect(Proposito.lista('no es json'), isEmpty);
  });

  group('formato del colegio', () {
    test('reconoce los títulos de las columnas', () {
      expect(campoDeTitulo('Fecha'), 'fecha');
      expect(campoDeTitulo('N°'), 'numero');
      expect(campoDeTitulo('Título de la sesión'), 'tema');
      expect(campoDeTitulo('Actividades / estrategias'), 'actividades');
      expect(campoDeTitulo('Recursos y materiales'), 'materiales');
      expect(campoDeTitulo('Competencia'), 'competencia');
      expect(campoDeTitulo('Observaciones'), isNull);
    });

    test('llena debajo de la fila de títulos', () {
      final x = xl.Excel.createExcel();
      final h = x[x.getDefaultSheet()!];
      void poner(int f, int c, String v) => h.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: f),
        xl.TextCellValue(v),
      );
      poner(0, 0, 'PLANIFICACIÓN SEMANAL');
      poner(1, 0, 'Docente:');
      poner(3, 0, 'N°');
      poner(3, 1, 'Fecha');
      poner(3, 2, 'Tema');
      poner(3, 3, 'Observaciones');
      final r = llenarFormato(x.encode()!, const [
        FilaSesion(
          numero: 1,
          unidad: 'U1',
          fecha: '02/11/2026',
          hora: '07:50',
          tema: '¿Qué es un polímero?',
          competencia: 'Explica el mundo físico',
          proposito: '',
          actividades: '',
          materiales: '',
          tarea: '',
        ),
      ]);
      expect(r.bytes, isNotNull);
      expect(r.columnas, ['N°', 'Fecha', 'Tema']);
      final y = xl.Excel.decodeBytes(r.bytes!);
      final fila = y.tables.values.first.rows[4];
      expect(fila[0]?.value.toString(), '1');
      expect(fila[1]?.value.toString(), '02/11/2026');
      expect(fila[2]?.value.toString(), '¿Qué es un polímero?');
    });

    test('avisa si no hay títulos', () {
      final x = xl.Excel.createExcel();
      final r = llenarFormato(x.encode()!, const []);
      expect(r.bytes, isNull);
      expect(r.error, isNotNull);
    });
  });

  test('unidades, sesiones, reparto, columna y copia', () async {
    final db = KipuDb(NativeDatabase.memory());
    addTearDown(db.close);
    final col = await db.crearColegio('Elite School', null);
    final a = await db.crearCurso(
      CursosCompanion.insert(
        colegioId: col,
        nivel: 'Secundaria',
        grado: '5.° año',
        seccion: 'B',
        nombre: 'Química',
      ),
    );
    final b = await db.crearCurso(
      CursosCompanion.insert(
        colegioId: col,
        nivel: 'Secundaria',
        grado: '5.° año',
        seccion: 'A',
        nombre: 'Química',
      ),
    );
    final u = await db.crearUnidad(
      UnidadesCompanion.insert(
        cursoId: a,
        anio: 2026,
        periodo: 4,
        orden: 0,
        titulo: 'Polímeros',
        competencias: const Value('indaga,explica'),
      ),
    );
    for (final t in ['S1', 'S2', 'S3']) {
      await db.crearSesion(
        SesionesCompanion.insert(unidadId: u, orden: 0, titulo: t),
      );
    }
    var ses = await db.verSesiones(u).first;
    expect(ses.map((s) => s.orden), [1, 2, 3]);

    final unidad = (await db.verUnidades(a, 2026).first).single;
    expect(unidad.listaCompetencias, ['indaga', 'explica']);
    final n = await db.repartirSesiones(unidad, [
      Horario(id: 1, cursoId: a, dia: 1, inicio: '11:20', fin: '12:50'),
      Horario(id: 2, cursoId: a, dia: 5, inicio: '09:35', fin: '11:05'),
    ], DateTime(2026, 11, 11));
    expect(n, 3);
    ses = await db.verSesiones(u).first;
    expect(ses.map((s) => s.fecha), ['2026-11-13', '2026-11-16', '2026-11-20']);
    final semana = await db.verSesionesEntre('2026-11-09', '2026-11-15').first;
    expect(semana.single.sesion.titulo, 'S1');

    await db.columnaDeSesion(ses.first, unidad, escala: 'literal');
    final cols = await db.verColumnas(a, 4).first;
    expect(cols.single.tema, 'S1');
    expect(cols.single.fecha, '2026-11-13');
    expect((await db.verSesiones(u).first).first.columnaId, cols.single.id);

    await db.marcarSesion(ses.first.id, true);
    expect(await db.copiarPlanificacion(a, b, 2026), 1);
    final copia = (await db.verUnidades(b, 2026).first).single;
    final sesCopia = await db.verSesiones(copia.id).first;
    expect(sesCopia.length, 3);
    expect(sesCopia.every((s) => s.fecha == null && !s.hecha), isTrue);

    // Borrar la unidad borra sus sesiones.
    await db.borrarUnidad(u);
    expect(await db.verSesiones(u).first, isEmpty);
  });

  test('los datos de ejemplo traen planificación', () async {
    final db = KipuDb(NativeDatabase.memory());
    addTearDown(db.close);
    await cargarDatosDeEjemplo(db);
    final anio = await db.verAnioActivo().first;
    final cursos = await db.verCursos().first;
    for (final c in cursos) {
      final us = await db.verUnidades(c.curso.id, anio).first;
      expect(us.length, 8, reason: c.curso.nombre);
      final ses = await db.verSesionesCurso(c.curso.id, anio).first;
      expect(ses.values.expand((l) => l), isNotEmpty);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('descargas: Excel de Kipu y PDF Minedu', () async {
    await initializeDateFormatting('es_PE');
    final db = KipuDb(NativeDatabase.memory());
    addTearDown(db.close);
    await cargarDatosDeEjemplo(db);
    final anio = await db.verAnioActivo().first;
    final cfg = await db.verConfigAcademica(anio).first;
    final curso = (await db.verCursos().first).firstWhere(
      (c) => c.colegio.nombre != 'Elite School',
    );
    final us = await db.verUnidades(curso.curso.id, anio).first;
    final ses = await db.verSesionesCurso(curso.curso.id, anio).first;
    final bloques = [
      for (var i = 0; i < us.length; i++)
        BloqueUnidad(i + 1, us[i], ses[us[i].id] ?? const []),
    ];
    final x = excelPlanificacion(titulo: 'Prueba', bloques: bloques);
    final hoja = xl.Excel.decodeBytes(x).tables.values.first;
    expect(hoja.rows[2][0]?.value.toString(), startsWith('Unidad 1:'));
    expect(hoja.rows[3][3]?.value.toString(), 'Tema / sesión');
    for (final simple in [false, true]) {
      final pdf = await pdfPlanificacion(
        curso: curso,
        bloques: bloques.take(2).toList(),
        periodos: cfg.periodos,
        docente: 'Prof. Javier',
        simple: simple,
      );
      expect(String.fromCharCodes(pdf.take(4)), '%PDF');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
