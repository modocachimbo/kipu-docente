import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/cuenta.dart';

void main() {
  test('la prueba dura 7 días y luego vence', () {
    final p = Plan('prueba', DateTime(2026, 11, 11, 17, 30));
    expect(p.diasRestantes(DateTime(2026, 11, 11)), 7);
    expect(p.diasRestantes(DateTime(2026, 11, 16)), 2);
    expect(p.vencido(DateTime(2026, 11, 17)), false);
    expect(p.vencido(DateTime(2026, 11, 18)), true);
  });

  test('el plan se guarda y se lee', () {
    final p = Plan('anual', DateTime(2026, 3, 1));
    final q = Plan.deTexto(p.aTexto())!;
    expect(q.tipo, 'anual');
    expect(q.diasTotales, 365);
    expect(Plan.deTexto('basura'), isNull);
  });

  test('correo válido', () {
    expect(correoValido('lucia@gmail.com'), true);
    expect(correoValido('lucia@'), false);
    expect(normalizarCorreo(' Lucia@Gmail.COM '), 'lucia@gmail.com');
  });
}
