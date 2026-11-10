import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/columnas.dart';
import 'package:kipu/data/instrumentos.dart';
import 'package:kipu/data/paises.dart';

void main() {
  final cneb = peru.escalas.firstWhere((e) => e.id == 'cneb');
  final vigesimal = peru.escalas.firstWhere((e) => e.id == 'vigesimal');

  group('redondeo', () {
    test('normal, hacia arriba y cortar', () {
      expect(redondear(14.5, 0, Redondeo.normal), 15);
      expect(redondear(14.4, 0, Redondeo.normal), 14);
      expect(redondear(14.1, 0, Redondeo.arriba), 15);
      expect(redondear(14.9, 0, Redondeo.cortar), 14);
      expect(redondear(14.45, 1, Redondeo.normal), 14.5);
      expect(redondear(14.0, 0, Redondeo.arriba), 14);
    });

    test('se guarda sin ceros de más', () {
      expect(numeroGuardado(15, 0), '15');
      expect(numeroGuardado(14.5, 1), '14.5');
      expect(numeroGuardado(14, 2), '14');
      expect(numeroGuardado(14.25, 2), '14.25');
      expect(ejemploRedondeo(0, Redondeo.normal), '14,5 → 15');
      expect(ejemploRedondeo(0, Redondeo.cortar), '14,5 → 14');
    });
  });

  group('asistencia y participación', () {
    test('presente y tarde cuentan; la justificada no', () {
      expect(porcentajeAsistencia(['P', 'P', 'T', 'F']), 75);
      expect(porcentajeAsistencia(['P', 'J', 'J', 'F']), 50);
      expect(porcentajeAsistencia(['J']), isNull);
      expect(porcentajeAsistencia(const []), isNull);
    });

    test('participaciones netas sobre la meta', () {
      expect(porcentajeParticipacion(5, 0, 10), 50);
      expect(porcentajeParticipacion(12, 0, 10), 100);
      expect(porcentajeParticipacion(1, 4, 10), 0);
      expect(porcentajeParticipacion(0, 0, 10), isNull);
    });

    test('el porcentaje pasa a la escala', () {
      expect(valorDePorcentaje(92, cneb), 'AD');
      expect(valorDePorcentaje(75, cneb), 'A');
      expect(valorDePorcentaje(60, cneb), 'B');
      expect(valorDePorcentaje(20, cneb), 'C');
      expect(valorDePorcentaje(75, vigesimal), '15');
      expect(valorDePorcentaje(77.5, vigesimal, decimales: 1), '15.5');
      expect(valorDePorcentaje(77.5, vigesimal, redondeo: Redondeo.cortar), '15');
    });
  });

  test('letra de una nota numérica', () {
    expect(letraDeNumero('19', vigesimal, cneb), 'AD');
    expect(letraDeNumero('15', vigesimal, cneb), 'A');
    expect(letraDeNumero('11', vigesimal, cneb), 'B');
    expect(letraDeNumero('7.5', vigesimal, cneb), 'C');
    expect(letraDeNumero('A', vigesimal, cneb), isNull);
  });

  group('recuperación', () {
    test('cuenta la más alta', () {
      expect(notaConRecuperacion('9', '13', vigesimal), '13');
      expect(notaConRecuperacion('14', '11', vigesimal), '14');
      expect(notaConRecuperacion('C', 'A', cneb), 'A');
      expect(notaConRecuperacion('A', 'B', cneb), 'A');
      expect(notaConRecuperacion(null, 'B', cneb), 'B');
      expect(notaConRecuperacion('B', null, cneb), 'B');
    });

    test('o la recuperación reemplaza a la original', () {
      expect(notaConRecuperacion('14', '11', vigesimal, masAlta: false), '11');
    });
  });

  test('códigos sugeridos libres', () {
    expect(codigoLibre('N', ['N1', 'N2', 'T1']), 'N3');
    expect(codigoLibre('R', const []), 'R1');
    expect(codigoLibre('Asist', const []), 'Asist');
    expect(codigoLibre('Asist', ['ASIST']), 'Asist2');
    expect(prefijoCodigo('instrumento', instrumento: TipoInstrumento.prueba), 'EX');
    expect(prefijoCodigo('participacion'), 'Part');
  });

  test('opciones de la columna en JSON', () {
    const c = ConfigColumna(
      decimales: 1,
      redondeo: Redondeo.arriba,
      mostrarLetra: true,
      recupera: 7,
      recuperaMasAlta: false,
      bloqueada: true,
      ocultaEnDescarga: true,
      competencia: 'cantidad',
      meta: 12,
    );
    final x = ConfigColumna.deTexto(c.aTexto());
    expect(x.aJson(), c.aJson());
    expect(ConfigColumna.deTexto(null).aJson(), isEmpty);
    expect(ConfigColumna.deTexto('roto').meta, 10);
    expect(const ConfigColumna(recupera: 3).copiar(sinRecupera: true).recupera, isNull);
  });
}
