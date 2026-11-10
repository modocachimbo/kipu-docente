import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/calculo.dart';
import 'package:kipu/data/columnas.dart';
import 'package:kipu/data/paises.dart';

void main() {
  final cneb = peru.escalas.firstWhere((e) => e.id == 'cneb');
  final vig = peru.escalas.firstWhere((e) => e.id == 'vigesimal');
  const cfg = ConfigColumna();

  ColumnaDato col(int id, String codigo, Escala e, {int periodo = 1, String tipo = 'nota', String comp = ''}) =>
      ColumnaDato(
        id: id,
        codigo: codigo,
        periodo: periodo,
        orden: id,
        tipo: tipo,
        escala: e,
        competencia: comp,
      );

  final cols = [
    col(1, 'EX1', vig),
    col(2, 'EX2', vig),
    col(3, 'T1', vig),
    col(4, 'T2', vig),
    col(5, 'R1', cneb, comp: 'cantidad'),
  ];
  final notas = {1: '16', 2: '12', 3: '20', 4: null, 5: 'A'};
  String? valor(ColumnaDato c) => notas[c.id];
  final propia = col(99, 'Prom', vig, tipo: 'calculada');

  group('columnas que entran', () {
    final todas = [
      ...cols,
      col(6, 'EX1', vig, periodo: 2),
      col(7, 'Prom', vig, tipo: 'calculada'),
      col(8, 'REC', vig),
    ];
    test('todas las del periodo, sin calculadas ni recuperaciones', () {
      final r = columnasDelCalculo(
        const Calculo(seleccion: Seleccion.todas),
        propia,
        todas,
        recuperaciones: {8},
      );
      expect(r.map((c) => c.id), [1, 2, 3, 4, 5]);
    });
    test('por defecto, solo las que están antes (a la izquierda)', () {
      final enMedio = col(3, 'Prom', vig, tipo: 'calculada');
      expect(columnasDelCalculo(const Calculo(), enMedio, todas).map((c) => c.id), [1, 2]);
      final fija = ColumnaDato(
        id: 50,
        codigo: 'Prom',
        periodo: 1,
        orden: 0,
        tipo: 'calculada',
        escala: vig,
        fijada: true,
      );
      expect(columnasDelCalculo(const Calculo(), fija, todas).map((c) => c.id), [1, 2, 3, 4, 5, 8]);
      // Por defecto las vacías cuentan como cero.
      expect(const Calculo().sinNota, SinNota.cero);
    });
    test('por tipo y por competencia', () {
      expect(
        columnasDelCalculo(const Calculo(seleccion: Seleccion.porTipo, filtro: 'ex'), propia, todas)
            .map((c) => c.id),
        [1, 2],
      );
      expect(
        columnasDelCalculo(
          const Calculo(seleccion: Seleccion.porCompetencia, filtro: 'cantidad'),
          propia,
          todas,
        ).map((c) => c.id),
        [5],
      );
    });
    test('a mano, con otros periodos', () {
      final r = columnasDelCalculo(
        const Calculo(seleccion: Seleccion.manual, columnas: [1, 6, 99]),
        propia,
        todas,
      );
      expect(r.map((c) => c.id), [1, 6]);
    });
  });

  test('prefijos y grupos sugeridos', () {
    expect(prefijoDe('EX1'), 'EX');
    expect(prefijoDe('Asist'), 'ASIST');
    expect(prefijoDe('F12'), 'F');
    final g = gruposSugeridos(cols);
    expect([for (final x in g) x.prefijo], ['EX', 'T', 'R']);
    expect(totalPesos(g), 100);
    expect(g.first.nombre, 'Exámenes');
  });

  group('promedio', () {
    test('simple: la vacía no cuenta y la letra usa su equivalencia', () {
      // 16, 12, 20 y A (=15) → 63 / 4 = 15,75 → 16
      final d = calcularCelda(
        c: const Calculo(sinNota: SinNota.noCuenta),
        salida: vig,
        cfg: cfg,
        cols: cols,
        valor: valor,
      );
      expect(d.valor, '16');
    });
    test('vacía como cero', () {
      // (16 + 12 + 20 + 0 + 15) / 5 = 12,6 → 13
      final d = calcularCelda(
        c: const Calculo(sinNota: SinNota.cero),
        salida: vig,
        cfg: cfg,
        cols: cols,
        valor: valor,
      );
      expect(d.valor, '13');
    });
    test('esperar a que estén todas', () {
      final d = calcularCelda(
        c: const Calculo(sinNota: SinNota.esperar),
        salida: vig,
        cfg: cfg,
        cols: cols,
        valor: valor,
      );
      expect(d.valor, isNull);
      expect(d.resumen, contains('Faltan 1'));
    });
    test('por grupos con pesos', () {
      // Exámenes (16+12)/2 = 14 × 40 ; Tareas 20 × 60 → 5,6 + 12 = 17,6 → 18
      const c = Calculo(
        sinNota: SinNota.noCuenta,
        porGrupos: true,
        grupos: [GrupoPeso('Exámenes', 'EX', 40), GrupoPeso('Tareas', 'T', 60)],
      );
      final d = calcularCelda(c: c, salida: vig, cfg: cfg, cols: cols, valor: valor);
      expect(d.valor, '18');
      expect(d.resumen, startsWith('Exámenes 14 × 40 % + Tareas 20 × 60 %'));
    });
    test('pesos que no suman 100 se usan en proporción', () {
      const c = Calculo(
        sinNota: SinNota.noCuenta,
        porGrupos: true,
        grupos: [GrupoPeso('Exámenes', 'EX', 1), GrupoPeso('Tareas', 'T', 1)],
      );
      // (14 + 20) / 2 = 17
      expect(calcularCelda(c: c, salida: vig, cfg: cfg, cols: cols, valor: valor).valor, '17');
    });
    test('con un decimal', () {
      final d = calcularCelda(
        c: const Calculo(sinNota: SinNota.noCuenta),
        salida: vig,
        cfg: const ConfigColumna(decimales: 1),
        cols: cols,
        valor: valor,
      );
      expect(d.valor, '15.8');
    });
  });

  group('nivel de la competencia', () {
    final letras = [col(1, 'R1', cneb), col(2, 'R2', cneb), col(3, 'R3', cneb), col(4, 'N1', vig)];
    final n = {1: 'A', 2: 'B', 3: 'A', 4: '19'};
    String? v(ColumnaDato c) => n[c.id];
    test('la más frecuente (el número pasa a letra)', () {
      final d = calcularCelda(
        c: const Calculo(tipo: TipoCalculo.nivel),
        salida: cneb,
        cfg: cfg,
        cols: letras,
        valor: v,
      );
      expect(d.valor, 'A');
      expect(d.resumen, contains('2 A'));
    });
    test('la última', () {
      final d = calcularCelda(
        c: const Calculo(tipo: TipoCalculo.nivel, nivel: ModoNivel.ultima),
        salida: cneb,
        cfg: cfg,
        cols: letras,
        valor: v,
      );
      expect(d.valor, 'AD'); // 19 sobre 20 = 95 %
    });
    test('empate: gana la mejor', () {
      final d = calcularCelda(
        c: const Calculo(tipo: TipoCalculo.nivel),
        salida: cneb,
        cfg: cfg,
        cols: letras.take(2).toList(),
        valor: v,
      );
      expect(d.valor, 'A');
    });
  });

  test('suma, más alta y más baja', () {
    expect(
      calcularCelda(c: const Calculo(tipo: TipoCalculo.suma), salida: vig, cfg: cfg, cols: cols.take(3).toList(), valor: valor).valor,
      '48',
    );
    expect(
      calcularCelda(c: const Calculo(tipo: TipoCalculo.maxima), salida: vig, cfg: cfg, cols: cols, valor: valor).valor,
      '20',
    );
    expect(
      calcularCelda(
        c: const Calculo(tipo: TipoCalculo.minima, sinNota: SinNota.noCuenta),
        salida: vig,
        cfg: cfg,
        cols: cols,
        valor: valor,
      ).valor,
      '12',
    );
  });

  group('fórmula', () {
    test('respeta paréntesis y prioridad', () {
      // (EX1 + EX2) / 2 * 0.4 + T1 * 0.6 = 14*0.4 + 12 = 17,6 → 18
      const f = ['(', 'c:1', '+', 'c:2', ')', '/', '2', '*', '0.4', '+', 'c:3', '*', '0.6'];
      final d = calcularCelda(
        c: const Calculo(tipo: TipoCalculo.formula, formula: f),
        salida: vig,
        cfg: cfg,
        cols: cols,
        valor: valor,
      );
      expect(d.valor, '18');
      expect(formulaTexto(f, {1: 'EX1', 2: 'EX2', 3: 'T1'}), '(EX1 + EX2) ÷ 2 × 0,4 + T1 × 0,6');
    });
    test('valida errores comunes', () {
      expect(validarFormula(const []), isNotNull);
      expect(validarFormula(const ['2', '+', '3']), contains('columna'));
      expect(validarFormula(const ['(', 'c:1', '+', '2']), contains('paréntesis'));
      expect(validarFormula(const ['c:1', '+']), isNotNull);
      expect(validarFormula(const ['c:1', '/', '0']), isNotNull);
      expect(validarFormula(const ['c:1', '*', '2']), isNull);
    });
    test('resultado a letras', () {
      final d = calcularCelda(
        c: const Calculo(tipo: TipoCalculo.formula, formula: ['c:1']),
        salida: cneb,
        cfg: cfg,
        cols: cols,
        valor: valor,
      );
      expect(d.valor, 'A'); // 16/20 = 80 %
    });
  });

  test('equivalencias de letras', () {
    expect(equivalenciasPorDefecto(cneb), [19, 15, 12, 8]);
    expect(enVeinte('B', cneb, const []), 12);
    expect(enVeinte('B', cneb, const [20, 16, 13, 9]), 13);
    expect(enVeinte('10', vig, const []), 10);
  });

  test('el cálculo se guarda en las opciones de la columna', () {
    const c = Calculo(
      tipo: TipoCalculo.formula,
      seleccion: Seleccion.manual,
      columnas: [3, 4],
      porGrupos: true,
      grupos: [GrupoPeso('Exámenes', 'EX', 40)],
      sinNota: SinNota.cero,
      nivel: ModoNivel.sugerida,
      formula: ['c:3', '+', '1'],
    );
    final x = ConfigColumna.deTexto(const ConfigColumna(calculo: c).aTexto()).calculo!;
    expect(x.aJson(), c.aJson());
    expect(calculoEnPalabras(const Calculo(porGrupos: true, grupos: [GrupoPeso('Exámenes', 'EX', 40), GrupoPeso('Tareas', 'T', 60)]), cols),
        'Promedio = 40 % Exámenes + 60 % Tareas');
  });
}
