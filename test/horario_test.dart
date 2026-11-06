import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/screens/horario_datos.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late KipuDb db;
  late int elite, tesla, quimica, fisica, biologia;

  setUp(() async {
    db = KipuDb(NativeDatabase.memory());
    elite = await db.crearColegio('Elite School', 'Huacho');
    tesla = await db.crearColegio('I.E. Nikola Tesla', 'Huaura');
    Future<int> curso(int colegio, String nombre, String seccion) => db
        .into(db.cursos)
        .insert(
          CursosCompanion.insert(
            colegioId: colegio,
            nivel: 'Secundaria',
            grado: '5.° año',
            seccion: seccion,
            nombre: nombre,
          ),
        );
    quimica = await curso(elite, 'Química', 'A');
    fisica = await curso(elite, 'Física', 'B');
    biologia = await curso(tesla, 'Biología', 'A');
  });

  tearDown(() => db.close());

  test('poner una clase reemplaza la del mismo colegio a esa hora', () async {
    await db.ponerClase(quimica, 1, '07:50', '09:20');
    await db.ponerClase(biologia, 1, '07:50', '09:20');
    await db.ponerClase(fisica, 1, '07:50', '09:20');
    final clases = await db.verHorario().first;
    expect([for (final (_, c) in clases) c.curso.nombre]..sort(), [
      'Biología',
      'Física',
    ]);
  });

  test('cambiar las horas de un colegio mueve o quita sus clases', () async {
    await db.ponerClase(quimica, 1, '07:50', '09:20');
    await db.ponerClase(fisica, 2, '09:35', '11:05');
    await db.ponerClase(biologia, 1, '09:35', '11:05');
    await db.guardarFranjas(
      elite,
      [
        (inicio: '08:00', fin: '09:30', recreo: false),
        (inicio: '09:30', fin: '09:45', recreo: true),
      ],
      {'07:50': (inicio: '08:00', fin: '09:30'), '09:35': null},
    );
    final clases = await db.verHorario().first;
    expect(
      [for (final (h, c) in clases) '${c.curso.nombre} ${h.dia} ${h.inicio}'],
      ['Química 1 08:00', 'Biología 1 09:35'],
    );

    final franjas = await db.verFranjas().first;
    final filas = filasDeColegio(elite, franjas, clases);
    expect(
      [for (final f in filas) '${f.inicio}${f.recreo ? 'R' : ''}'],
      ['08:00', '09:30R'],
    );
  });

  test('sin horas guardadas se deducen de las clases y sus recreos', () async {
    await db.ponerClase(quimica, 1, '07:50', '09:20');
    await db.ponerClase(fisica, 1, '09:35', '11:05');
    await db.ponerClase(quimica, 2, '13:00', '14:30');
    final clases = await db.verHorario().first;
    final filas = filasDeColegio(elite, const [], clases);
    expect(
      [for (final f in filas) '${f.inicio}-${f.fin}${f.recreo ? 'R' : ''}'],
      ['07:50-09:20', '09:20-09:35R', '09:35-11:05', '13:00-14:30'],
    );
  });

  test('entre clases: recreo, cambio de colegio y cruce', () async {
    await db.guardarFranjas(elite, [
      (inicio: '07:50', fin: '09:20', recreo: false),
      (inicio: '09:20', fin: '09:35', recreo: true),
      (inicio: '09:35', fin: '11:05', recreo: false),
    ], {});
    await db.ponerClase(quimica, 1, '07:50', '09:20');
    await db.ponerClase(fisica, 1, '09:35', '11:05');
    await db.ponerClase(biologia, 1, '11:40', '13:10');
    await db.ponerClase(biologia, 2, '08:00', '09:30');
    await db.ponerClase(quimica, 2, '07:50', '09:20');
    final clases = await db.verHorario().first;
    final franjas = await db.verFranjas().first;
    List<(Horario, CursoConColegio)> dia(int d) => [
      for (final x in clases)
        if (x.$1.dia == d) x,
    ]..sort((a, b) => a.$1.inicio.compareTo(b.$1.inicio));
    final lunes = dia(1);
    expect(entreClases(lunes[0], lunes[1], franjas), 'Recreo · 15 min');
    expect(
      entreClases(lunes[1], lunes[2], franjas),
      'Cambio de colegio · 35 min',
    );
    final martes = dia(2);
    expect(entreClases(martes[0], martes[1], franjas), 'Se cruzan las horas');
    expect(
      cruceCon(clases, elite, 2, '07:50', '09:20')?.$2.curso.nombre,
      'Biología',
    );
  });
}
