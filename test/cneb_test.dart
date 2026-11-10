import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/cneb.dart';
import 'package:kipu/data/instrumentos.dart';
import 'package:kipu/data/instrumentos_ejemplos.dart';
import 'package:kipu/data/instrumentos_excel.dart';
import 'package:kipu/data/paises.dart';

void main() {
  final cneb = peru.escalas.firstWhere((e) => e.id == 'cneb');
  final vigesimal = peru.escalas.firstWhere((e) => e.id == 'vigesimal');

  group('colección CNEB', () {
    test('cada competencia tiene dos instrumentos en cada nivel donde se evalúa', () {
      for (final c in competenciasCneb) {
        for (final n in c.niveles) {
          final de = coleccionCneb
              .where((i) => i.competencias.contains(c.id) && i.niveles.contains(n))
              .toList();
          expect(de.length, 2, reason: '${c.nombre} · $n');
          expect(de.map((i) => i.tipo).toSet().length, 2, reason: '${c.nombre} · $n');
          expect(de.every((i) => i.area == c.areas[n]), isTrue);
        }
      }
    });

    test('todos son válidos, con ids únicos y sin rúbricas en Inicial', () {
      expect(coleccionCneb.length, greaterThan(130));
      expect(coleccionCneb.map((i) => i.id).toSet().length, coleccionCneb.length);
      for (final i in coleccionCneb) {
        expect(i.validar(), isEmpty, reason: i.id);
        if (i.niveles.contains('Inicial')) {
          expect(i.tipo, isNot(TipoInstrumento.rubrica), reason: i.id);
          expect(i.noObservado, isTrue, reason: i.id);
        }
        if (i.tipo == TipoInstrumento.rubrica) {
          for (final it in i.items) {
            expect(it.descriptores.length, 4);
            expect(it.descriptores.every((d) => d.endsWith('.')), isTrue);
          }
        }
      }
      // Todas las áreas que aparecen tienen un lugar en el orden.
      for (final i in coleccionCneb) {
        expect(ordenAreas, contains(i.area), reason: i.id);
      }
    });

    test('sirven con letras y con números', () {
      final r = coleccionCneb.firstWhere((i) => i.id == 'cneb-cantidad-primaria-r');
      final m = Marcas({for (final it in r.items) it.id: 2});
      final res = calcular(r, m)!;
      expect(valorEnEscala(r, res, cneb), 'A');
      expect(valorEnEscala(r, res, vigesimal), '15');
    });
  });

  group('examen con clave', () {
    final ex = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-bimestral');

    test('suma 20 y corrige con la clave', () {
      expect(ex.puntajeTotal, 20);
      expect(ex.validar(), isEmpty);
      // Todas las de opción múltiple bien (12), V/F mal (0), desarrollo 1,5 + 3.
      final m = <String, int>{
        for (final it in ex.items)
          if (it.opciones == 4) it.id: it.clave!,
        for (final it in ex.items)
          if (it.opciones == 2) it.id: 1 - it.clave!,
        'd0': 3,
        'd1': 6,
      };
      final r = calcular(ex, Marcas(m))!;
      expect(r.puntos, closeTo(16.5, .001));
      expect(valorEnEscala(ex, r, vigesimal), '17');
      expect(valorEnEscala(ex, r, cneb), 'A'); // 82,5 %
      expect(describirResultado(ex, r), startsWith('16,5 de 20 puntos'));
    });

    test('desarrollo no pasa del puntaje de la pregunta', () {
      final r = calcular(ex, const Marcas({'d0': 40}))!;
      expect(r.puntos, 3);
    });

    test('respuestas de corrido', () {
      final p = ejemplosInstrumentos.firstWhere((e) => e.id == 'ej-practica');
      final todas = String.fromCharCodes([
        for (final it in p.items) 65 + it.clave!,
      ]);
      final m = respuestasRapidas(p, todas, const {});
      expect(calcular(p, Marcas(m))!.puntos, 20);
      final conBlanco = respuestasRapidas(p, 'b a-d', const {});
      expect(conBlanco[p.items[2].id], marcaNoObservado);
      expect(conBlanco[p.items[0].id], 1);
      expect(conBlanco.length, 4);
    });

    test('valida la clave y los puntos', () {
      final malo = Instrumento(
        id: 'x',
        tipo: TipoInstrumento.prueba,
        nombre: 'Malo',
        items: const [
          ItemInstrumento(id: 'a', texto: '', peso: 2, opciones: 4),
          ItemInstrumento(id: 'b', texto: '', peso: 0, opciones: 0),
        ],
      );
      final e = malo.validar().join('\n');
      expect(e, contains('pregunta 1'));
      expect(e, contains('pregunta 2'));
    });
  });

  group('Excel', () {
    test('toda la colección CNEB va y vuelve con sus competencias', () {
      for (final i in coleccionCneb) {
        final l = leerArchivo(excelDeInstrumento(i));
        expect(l.errores, isEmpty, reason: i.id);
        expect(l.instrumento!.competencias, i.competencias, reason: i.id);
        expect(l.instrumento!.area, i.area);
      }
    });

    test('examen ida y vuelta, con clave y desarrollo', () {
      for (final e in ejemplosInstrumentos.where(
        (e) => e.tipo == TipoInstrumento.prueba,
      )) {
        final l = leerArchivo(excelDeInstrumento(e));
        expect(l.errores, isEmpty, reason: e.nombre);
        final x = l.instrumento!;
        expect(x.tipo, TipoInstrumento.prueba);
        expect([for (final i in x.items) (i.opciones, i.clave, i.peso)],
            [for (final i in e.items) (i.opciones, i.clave, i.peso)], reason: e.nombre);
      }
    });

    test('examen en CSV escrito a mano', () {
      const csv = 'NOMBRE;Práctica 1\n'
          'TIPO;Examen\n'
          'COMPETENCIAS;Resuelve problemas de cantidad\n'
          'PREGUNTA;PUNTOS;TIPO DE PREGUNTA;CLAVE\n'
          ';5;A-D;c\n'
          ';5;V/F;F\n'
          'Explica tu respuesta;10;Desarrollo;\n';
      final l = leerArchivo(utf8.encode(csv), esCsv: true);
      expect(l.errores, isEmpty);
      final x = l.instrumento!;
      expect(x.competencias, ['cantidad']);
      expect(x.items[0].clave, 2);
      expect(x.items[1].opciones, 2);
      expect(x.items[1].clave, 1);
      expect(x.items[2].desarrollo, isTrue);
    });

    test('examen sin clave da error con la fila', () {
      const csv = 'NOMBRE;P\nTIPO;Examen\nPREGUNTA;PUNTOS;TIPO DE PREGUNTA;CLAVE\n;4;A-D;\n';
      final l = leerArchivo(utf8.encode(csv), esCsv: true);
      expect(l.ok, isFalse);
      expect(l.errores.join(), contains('Fila 4'));
    });

    test('la plantilla de examen se sube tal cual', () {
      final l = leerArchivo(excelDeInstrumento(plantillaDe(TipoInstrumento.prueba)));
      expect(l.ok, isTrue, reason: l.errores.join());
    });
  });

  test('copiar un ejemplo recuerda su origen', () {
    final e = coleccionCneb.first;
    final c = duplicar(e, ejemplo: true);
    expect(c.origen, e.id);
    expect(c.id, isNot(e.id));
    expect(Instrumento.deJson(c.aJson()).origen, e.id);
  });
}
