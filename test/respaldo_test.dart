import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/database.dart';
import 'package:kipu/data/demo.dart';
import 'package:kipu/data/copias.dart';
import 'package:kipu/data/respaldo.dart';
import 'dart:typed_data';

void main() {
  test('ajustes que no viajan en la copia', () {
    expect(ajusteLocal('sesion'), isTrue);
    expect(ajusteLocal('cuenta'), isTrue);
    expect(ajusteLocal('plan'), isTrue);
    expect(ajusteLocal('respaldo_estado'), isTrue);
    expect(ajusteLocal('nombre'), isFalse);
    expect(ajusteLocal('colores_notas'), isFalse);
  });

  test('ajustes de copias se guardan', () {
    const a = AjustesCopias(frecuencia: Frecuencia.semanal, conservar: 20, todasEnDrive: true);
    final b = AjustesCopias.deTexto(a.aTexto());
    expect(b.frecuencia, Frecuencia.semanal);
    expect(b.conservar, 20);
    expect(b.todasEnDrive, isTrue);
    expect(AjustesCopias.deTexto('x').frecuencia, Frecuencia.cambios);
    expect(const AjustesCopias(frecuencia: Frecuencia.diaria).intervalo, const Duration(days: 1));
  });

  test('copia y restauración de ida y vuelta', () async {
    final a = KipuDb(NativeDatabase.memory());
    addTearDown(a.close);
    await cargarDatosDeEjemplo(a);
    await a.guardarAjuste('sesion', 'equipo-a');
    final c = await a.crearCopia(dispositivo: 'Prueba');
    expect(c.info.estudiantes, greaterThan(0));
    expect(c.nombreArchivo, endsWith('.kipu'));

    final b = KipuDb(NativeDatabase.memory());
    addTearDown(b.close);
    await b.guardarAjuste('sesion', 'equipo-b');
    await b.guardarAjuste('nombre', 'Otro');
    final info = await b.restaurarCopia(c.bytes);
    expect(info.dispositivo, 'Prueba');

    Future<int> cuenta(KipuDb db, String t) async =>
        (await db.customSelect('SELECT COUNT(*) AS n FROM "$t"').getSingle()).read<int>('n');
    for (final t in a.allTables) {
      if (t.actualTableName == 'ajustes') continue;
      expect(await cuenta(b, t.actualTableName), await cuenta(a, t.actualTableName),
          reason: t.actualTableName);
    }
    // La sesión es de cada equipo; el perfil viaja en la copia.
    expect(await b.leerAjuste('sesion'), 'equipo-b');
    expect(await b.leerAjuste('nombre'), await a.leerAjuste('nombre'));
    // La misma información da la misma huella.
    expect((await b.crearCopia(dispositivo: 'Prueba')).huella, c.huella);
  });

  test('copia anónima y archivos que no son copias', () async {
    final a = KipuDb(NativeDatabase.memory());
    addTearDown(a.close);
    await cargarDatosDeEjemplo(a);
    final c = await a.crearCopia(dispositivo: 'Prueba', anonima: true);
    final b = KipuDb(NativeDatabase.memory());
    addTearDown(b.close);
    await b.restaurarCopia(c.bytes);
    final e = await b.customSelect('SELECT nombres, dni, foto FROM estudiantes').get();
    expect(e.every((f) => f.read<String>('nombres') == 'Estudiante'), isTrue);
    expect(e.every((f) => f.data['dni'] == null && f.data['foto'] == null), isTrue);
    expect(() => b.leerInfo(Uint8List.fromList([1, 2, 3])), throwsA(isA<CopiaInvalida>()));
  });
}
