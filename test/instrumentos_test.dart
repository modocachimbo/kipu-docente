import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/instrumentos.dart';
import 'package:kipu/data/instrumentos_ejemplos.dart';
import 'package:kipu/data/instrumentos_excel.dart';
import 'package:kipu/data/paises.dart';

void main() {
  final cneb = peru.escalas.firstWhere((e) => e.id == 'cneb');
  final vigesimal = peru.escalas.firstWhere((e) => e.id == 'vigesimal');
  final logrado = peru.escalas.firstWhere((e) => e.id == 'logrado');

  Instrumento cotejo({bool noObs = false, bool ponderada = false}) =>
      Instrumento(
        id: 'c',
        tipo: TipoInstrumento.cotejo,
        nombre: 'Exposición',
        escala: etiquetasCotejo.first.niveles,
        noObservado: noObs,
        ponderada: ponderada,
        items: [
          for (var i = 0; i < 5; i++)
            ItemInstrumento(id: '$i', texto: 'Ítem $i', peso: i + 1.0),
        ],
      );

  group('lista de cotejo', () {
    test('simple: 4 de 5 = 80 % → A y 16', () {
      final ins = cotejo();
      final m = Marcas({'0': 0, '1': 0, '2': 0, '3': 0, '4': 1});
      final r = calcular(ins, m)!;
      expect(r.logrados, 4);
      expect(r.porcentaje, closeTo(80, .001));
      expect(valorEnEscala(ins, r, cneb), 'A');
      expect(valorEnEscala(ins, r, vigesimal), '16');
      expect(valorEnEscala(ins, r, logrado), 'Logrado');
      expect(describirResultado(ins, r), '4 de 5 logrados · 80 %');
    });

    test('«No observado» no cuenta en la nota', () {
      final ins = cotejo(noObs: true);
      final m = Marcas({
        '0': 0,
        '1': 0,
        '2': marcaNoObservado,
        '3': marcaNoObservado,
        '4': 0,
      });
      final r = calcular(ins, m)!;
      expect(r.aplicables, 3);
      expect(r.porcentaje, 100);
      expect(valorEnEscala(ins, r, cneb), 'AD');
    });

    test('ponderada: puntos logrados ÷ total', () {
      final ins = cotejo(ponderada: true); // pesos 1..5, total 15
      final m = Marcas({'0': 1, '1': 1, '2': 0, '3': 0, '4': 0}); // 3+4+5
      final r = calcular(ins, m)!;
      expect(r.porcentaje, closeTo(80, .001));
    });

    test('sin marcas no hay nota', () {
      expect(calcular(cotejo(), const Marcas()), isNull);
    });

    test('tramos propios', () {
      final ins = cotejo();
      final r = calcular(ins, Marcas({'0': 0, '1': 0, '2': 0, '3': 1, '4': 1}))!;
      expect(valorEnEscala(ins, r, cneb), 'B'); // 60 %
      expect(valorEnEscala(ins, r, cneb, tramos: [95, 80, 65]), 'C');
    });
  });

  group('rúbrica', () {
    final rub = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-texto-narrativo');
    Marcas todos(int k) => Marcas({for (final i in rub.items) i.id: k});

    test('cada nivel de la rúbrica cae en su letra', () {
      expect(valorEnEscala(rub, calcular(rub, todos(3))!, cneb), 'AD');
      expect(valorEnEscala(rub, calcular(rub, todos(2))!, cneb), 'A');
      expect(valorEnEscala(rub, calcular(rub, todos(1))!, cneb), 'B');
      expect(valorEnEscala(rub, calcular(rub, todos(0))!, cneb), 'C');
    });

    test('en vigesimal: puntos ÷ máximo × 20', () {
      expect(valorEnEscala(rub, calcular(rub, todos(3))!, vigesimal), '20');
      expect(valorEnEscala(rub, calcular(rub, todos(2))!, vigesimal), '15');
      expect(valorEnEscala(rub, calcular(rub, todos(0))!, vigesimal), '5');
    });

    test('el resumen muestra los puntos', () {
      expect(
        describirResultado(rub, calcular(rub, todos(2))!),
        'Nivel medio 3,0 de 4 · 12 de 16 pts · 75 %',
      );
    });

    test('nivel medio mezclado se redondea', () {
      final ind = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-indagacion');
      // 3 criterios en «Logro esperado» y 2 en «Logro destacado».
      final m = Marcas({'a': 2, 'b': 2, 'c': 2, 'd': 3, 'e': 3});
      final r = calcular(ind, m)!;
      expect(valorEnEscala(ind, r, cneb), 'A');
      expect(describirResultado(ind, r), startsWith('Nivel medio 3,4 de 4'));
    });
  });

  test('todos los ejemplos son válidos y tienen nivel educativo', () {
    for (final e in ejemplosInstrumentos) {
      expect(e.validar(), isEmpty, reason: e.nombre);
      expect(e.niveles, isNotEmpty, reason: e.nombre);
      if (e.tipo == TipoInstrumento.rubrica) {
        for (final i in e.items) {
          expect(i.descriptores.length, e.escala.length, reason: '${e.nombre} · ${i.texto}');
        }
      }
    }
    final ids = ejemplosInstrumentos.map((e) => e.id).toSet();
    expect(ids.length, ejemplosInstrumentos.length);
    for (final n in nivelesEducativos) {
      expect(ejemplosInstrumentos.where((e) => e.niveles.contains(n)), isNotEmpty);
    }
  });

  test('JSON de ida y vuelta', () {
    final rub = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-ensayo');
    final otra = Instrumento.listaDeJson(Instrumento.listaAJson([rub])).single;
    expect(otra.aJson(), rub.aJson());
    final m = {7: Marcas({'a': 1}, 'Mejoró'), 8: const Marcas()};
    final m2 = Marcas.mapaDeJson(Marcas.mapaAJson(m));
    expect(m2.keys, [7]);
    expect(m2[7]!.comentario, 'Mejoró');
    expect(Instrumento.listaDeJson('basura'), isEmpty);
  });

  group('Excel y CSV', () {
    test('descargar y volver a subir da el mismo instrumento', () {
      for (final e in ejemplosInstrumentos) {
        final l = leerArchivo(excelDeInstrumento(e));
        expect(l.errores, isEmpty, reason: e.nombre);
        final x = l.instrumento!;
        expect(x.tipo, e.tipo, reason: e.nombre);
        expect(x.nombre, e.nombre);
        expect(x.niveles, e.niveles);
        expect([for (final n in x.escala) (n.nombre, n.puntos)],
            [for (final n in e.escala) (n.nombre, n.puntos)], reason: e.nombre);
        expect([for (final i in x.items) i.texto], [for (final i in e.items) i.texto]);
        expect(x.noObservado, e.noObservado, reason: e.nombre);
        if (e.tipo == TipoInstrumento.rubrica) {
          expect(x.items.first.descriptores, e.items.first.descriptores);
        }
      }
    });

    test('las plantillas en blanco se pueden subir tal cual', () {
      for (final t in TipoInstrumento.values) {
        final l = leerArchivo(excelDeInstrumento(plantillaDe(t)));
        expect(l.ok, isTrue, reason: '${t.nombre}: ${l.errores}');
      }
    });

    test('CSV con punto y coma y comillas', () {
      final ins = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-cuaderno');
      final l = leerArchivo(utf8.encode(csvDeInstrumento(ins)), esCsv: true);
      expect(l.errores, isEmpty);
      expect(l.instrumento!.ponderada, isTrue);
      expect(l.instrumento!.items.first.peso, 4);
    });

    test('CSV escrito a mano, sin TIPO ni PUNTOS', () {
      const csv = 'NOMBRE,Lectura en voz alta\n'
          'NIVELES,,Sí,No\n'
          'ÍTEM,PESO\n'
          'Lee con fluidez,\n'
          '"Respeta comas, puntos",\n';
      final l = leerArchivo(utf8.encode(csv), esCsv: true);
      expect(l.errores, isEmpty);
      expect(l.instrumento!.tipo, TipoInstrumento.cotejo);
      expect(l.instrumento!.items[1].texto, 'Respeta comas, puntos');
      expect(l.avisos.join(), contains('TIPO'));
    });

    test('errores claros con número de fila', () {
      const csv = 'TIPO;Rúbrica\n'
          'NIVELES;;Bajo;Alto\n'
          'PUNTOS;;uno;2\n'
          'CRITERIO;PESO\n'
          ';;algo;\n'
          'Claridad;-3;a;b\n';
      final l = leerArchivo(utf8.encode(csv), esCsv: true);
      expect(l.ok, isFalse);
      final todo = l.errores.join('\n');
      expect(todo, contains('NOMBRE'));
      expect(todo, contains('Fila 5'));
      expect(todo, contains('Fila 6'));
      expect(todo, contains('«uno»'));
    });

    test('nombre de archivo sin tildes ni espacios', () {
      final e = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-exposicion');
      expect(nombreArchivo(e), 'rubrica-exposicion-oral.xlsx');
    });
  });

  test('tramos por defecto y validación', () {
    expect(tramosPorDefecto(cneb), [90, 70, 55]);
    expect(describirTramos(cneb, [90, 70, 55]),
        'AD ≥ 90 % · A ≥ 70 % · B ≥ 55 % · C < 55 %');
    expect(validarTramos([90, 70, 55]), isNull);
    expect(validarTramos([70, 90, 55]), isNotNull);
    expect(validarTramos([120, 70, 55]), isNotNull);
  });
}
