import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/colores_notas.dart';
import 'package:kipu/data/paises.dart';

void main() {
  final vig = peru.escalas.firstWhere((e) => e.id == 'vigesimal');
  const c = ColoresNotas();

  test('rangos por defecto en 0–20', () {
    expect(c.colorDe(0, vig), ColoresNotas.rojo);
    expect(c.colorDe(10, vig), ColoresNotas.rojo);
    expect(c.colorDe(10.5, vig), ColoresNotas.rojo);
    expect(c.colorDe(11, vig), ColoresNotas.naranja);
    expect(c.colorDe(13, vig), ColoresNotas.naranja);
    expect(c.colorDe(14, vig), ColoresNotas.celeste);
    expect(c.colorDe(17, vig), ColoresNotas.celeste);
    expect(c.colorDe(18, vig), ColoresNotas.azul);
    expect(c.colorDe(20, vig), ColoresNotas.azul);
  });

  test('otras escalas en proporción y desactivado', () {
    const cien = Escala(id: 'x', nombre: '0–100', numerica: true, minimo: 0, maximo: 100, valores: []);
    expect(c.colorDe(90, cien), ColoresNotas.azul);
    expect(c.colorDe(54, cien), ColoresNotas.rojo);
    expect(const ColoresNotas(activo: false).colorDe(5, vig), isNull);
  });

  test('se guarda y se lee', () {
    const x = ColoresNotas(activo: false, tramos: [TramoColor(0, 1), TramoColor(12, 2)]);
    final y = ColoresNotas.deTexto(x.aTexto());
    expect(y.activo, false);
    expect([for (final t in y.tramos) t.desde], [0, 12]);
    expect(ColoresNotas.deTexto('basura').tramos.length, 4);
  });
}
