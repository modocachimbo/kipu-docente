import 'dart:math' as math;

import 'columnas.dart';
import 'paises.dart';

/// Columna calculada del registro: qué calcula, con qué columnas y cómo.
/// Todo es Dart puro para poder probarlo.

enum TipoCalculo { promedio, nivel, suma, maxima, minima, formula }

extension TipoCalculoTexto on TipoCalculo {
  String get nombre => switch (this) {
    TipoCalculo.promedio => 'Promedio',
    TipoCalculo.nivel => 'Nivel de la competencia',
    TipoCalculo.suma => 'Suma',
    TipoCalculo.maxima => 'Nota más alta',
    TipoCalculo.minima => 'Nota más baja',
    TipoCalculo.formula => 'Fórmula',
  };

  String get ayuda => switch (this) {
    TipoCalculo.promedio => 'Todas valen igual o con pesos por grupo',
    TipoCalculo.nivel => 'AD, A, B, C sin promediar letras',
    TipoCalculo.suma => 'Puntos acumulados: tareas, méritos',
    TipoCalculo.maxima => 'La mejor nota de las columnas',
    TipoCalculo.minima => 'La nota más baja de las columnas',
    TipoCalculo.formula => 'Arma tu propia fórmula con las columnas',
  };
}

/// Qué columnas entran en el cálculo.
enum Seleccion { todas, porTipo, porCompetencia, manual }

/// Qué hacer con las notas vacías.
enum SinNota { noCuenta, cero, esperar }

extension SinNotaTexto on SinNota {
  String get nombre => switch (this) {
    SinNota.noCuenta => 'No cuenta',
    SinNota.cero => 'Cuenta como 0',
    SinNota.esperar => 'Esperar a que estén todas',
  };
}

/// Nivel de la competencia en letras.
enum ModoNivel { frecuente, ultima, sugerida }

extension ModoNivelTexto on ModoNivel {
  String get nombre => switch (this) {
    ModoNivel.frecuente => 'La más frecuente',
    ModoNivel.ultima => 'La última',
    ModoNivel.sugerida => 'Kipu sugiere y tú confirmas',
  };
}

/// Grupo de columnas con su peso: «Exámenes 40 %» = códigos que empiezan
/// con EX.
class GrupoPeso {
  final String nombre;
  final String prefijo;
  final double peso;
  const GrupoPeso(this.nombre, this.prefijo, this.peso);

  GrupoPeso copiar({String? nombre, String? prefijo, double? peso}) =>
      GrupoPeso(nombre ?? this.nombre, prefijo ?? this.prefijo, peso ?? this.peso);

  Map<String, dynamic> aJson() => {'n': nombre, 'p': prefijo, 'w': peso};
  factory GrupoPeso.deJson(Map<String, dynamic> j) => GrupoPeso(
    j['n'] as String? ?? '',
    j['p'] as String? ?? '',
    (j['w'] as num?)?.toDouble() ?? 0,
  );
}

class Calculo {
  final TipoCalculo tipo;
  final Seleccion seleccion;

  /// Prefijo del código (porTipo) o id de competencia (porCompetencia).
  final String filtro;

  /// Ids de columnas elegidas a mano (pueden ser de otros periodos).
  final List<int> columnas;
  final bool porGrupos;
  final List<GrupoPeso> grupos;
  final SinNota sinNota;
  final ModoNivel nivel;

  /// Fórmula: números, «+ - * / ( )» y columnas como `c:<id>`.
  final List<String> formula;

  const Calculo({
    this.tipo = TipoCalculo.promedio,
    this.seleccion = Seleccion.todas,
    this.filtro = '',
    this.columnas = const [],
    this.porGrupos = false,
    this.grupos = const [],
    this.sinNota = SinNota.noCuenta,
    this.nivel = ModoNivel.frecuente,
    this.formula = const [],
  });

  Calculo copiar({
    TipoCalculo? tipo,
    Seleccion? seleccion,
    String? filtro,
    List<int>? columnas,
    bool? porGrupos,
    List<GrupoPeso>? grupos,
    SinNota? sinNota,
    ModoNivel? nivel,
    List<String>? formula,
  }) => Calculo(
    tipo: tipo ?? this.tipo,
    seleccion: seleccion ?? this.seleccion,
    filtro: filtro ?? this.filtro,
    columnas: columnas ?? this.columnas,
    porGrupos: porGrupos ?? this.porGrupos,
    grupos: grupos ?? this.grupos,
    sinNota: sinNota ?? this.sinNota,
    nivel: nivel ?? this.nivel,
    formula: formula ?? this.formula,
  );

  Map<String, dynamic> aJson() => {
    'tipo': tipo.name,
    'sel': seleccion.name,
    if (filtro.isNotEmpty) 'filtro': filtro,
    if (columnas.isNotEmpty) 'cols': columnas,
    if (porGrupos) 'porGrupos': true,
    if (grupos.isNotEmpty) 'grupos': [for (final g in grupos) g.aJson()],
    if (sinNota != SinNota.noCuenta) 'sinNota': sinNota.name,
    if (nivel != ModoNivel.frecuente) 'nivel': nivel.name,
    if (formula.isNotEmpty) 'formula': formula,
  };

  factory Calculo.deJson(Map<String, dynamic> j) {
    T de<T extends Enum>(List<T> v, Object? n, T d) =>
        v.firstWhere((x) => x.name == n, orElse: () => d);
    return Calculo(
      tipo: de(TipoCalculo.values, j['tipo'], TipoCalculo.promedio),
      seleccion: de(Seleccion.values, j['sel'], Seleccion.todas),
      filtro: j['filtro'] as String? ?? '',
      columnas: [for (final c in (j['cols'] as List?) ?? const []) (c as num).toInt()],
      porGrupos: j['porGrupos'] as bool? ?? false,
      grupos: [
        for (final g in (j['grupos'] as List?) ?? const [])
          GrupoPeso.deJson(g as Map<String, dynamic>),
      ],
      sinNota: de(SinNota.values, j['sinNota'], SinNota.noCuenta),
      nivel: de(ModoNivel.values, j['nivel'], ModoNivel.frecuente),
      formula: [for (final t in (j['formula'] as List?) ?? const []) '$t'],
    );
  }
}

/// Una columna tal como la necesita el cálculo.
class ColumnaDato {
  final int id;
  final String codigo;
  final String tema;
  final int periodo;
  final int orden;
  final String tipo;
  final Escala escala;
  final String competencia;
  const ColumnaDato({
    required this.id,
    required this.codigo,
    this.tema = '',
    required this.periodo,
    required this.orden,
    required this.tipo,
    required this.escala,
    this.competencia = '',
  });
}

/// Letras iniciales del código, en mayúsculas: EX1 → EX, F2 → F.
String prefijoDe(String codigo) =>
    RegExp(r'^[A-Za-zÁÉÍÓÚÑáéíóúñ]+').firstMatch(codigo.trim())?.group(0)?.toUpperCase() ??
    codigo.trim().toUpperCase();

/// Nombre que se propone para un grupo según el prefijo.
String nombreGrupo(String prefijo) => switch (prefijo.toUpperCase()) {
  'EX' || 'EXAM' => 'Exámenes',
  'E' => 'Escalas',
  'F' => 'Fichas',
  'T' => 'Tareas',
  'P' || 'PC' || 'PR' => 'Prácticas',
  'R' => 'Rúbricas',
  'L' => 'Listas de cotejo',
  'N' => 'Notas',
  'ASIST' => 'Asistencia',
  'PART' => 'Participación',
  'EXP' => 'Exposiciones',
  'FB' => 'Feedback',
  _ => prefijo,
};

/// Grupos sugeridos con las columnas que hay: uno por prefijo, con pesos
/// iguales que suman 100.
List<GrupoPeso> gruposSugeridos(Iterable<ColumnaDato> cols) {
  final prefijos = <String>[];
  for (final c in cols) {
    final p = prefijoDe(c.codigo);
    if (!prefijos.contains(p)) prefijos.add(p);
  }
  if (prefijos.isEmpty) return const [];
  final base = (100 / prefijos.length).floorToDouble();
  return [
    for (final (i, p) in prefijos.indexed)
      GrupoPeso(
        nombreGrupo(p),
        p,
        i == 0 ? 100 - base * (prefijos.length - 1) : base,
      ),
  ];
}

/// Columnas que entran en el cálculo. Nunca la propia columna ni otras
/// calculadas del mismo periodo (para no dar vueltas), ni las columnas de
/// recuperación: su nota ya cuenta dentro de la columna original.
List<ColumnaDato> columnasDelCalculo(
  Calculo c,
  ColumnaDato propia,
  List<ColumnaDato> todas, {
  Set<int> recuperaciones = const {},
}) {
  bool valida(ColumnaDato x) =>
      x.id != propia.id &&
      !recuperaciones.contains(x.id) &&
      !(x.tipo == 'calculada' && x.periodo == propia.periodo);
  final delPeriodo = [
    for (final x in todas)
      if (x.periodo == propia.periodo && x.tipo != 'calculada' && valida(x)) x,
  ];
  final r = switch (c.seleccion) {
    Seleccion.todas => delPeriodo,
    Seleccion.porTipo => [
      for (final x in delPeriodo)
        if (prefijoDe(x.codigo) == c.filtro.toUpperCase()) x,
    ],
    Seleccion.porCompetencia => [
      for (final x in delPeriodo)
        if (x.competencia == c.filtro) x,
    ],
    Seleccion.manual => [
      for (final x in todas)
        if (c.columnas.contains(x.id) && valida(x)) x,
    ],
  };
  return r..sort((a, b) {
    final d = a.periodo.compareTo(b.periodo);
    return d != 0 ? d : a.orden.compareTo(b.orden);
  });
}

// ─────────────────────── Letras y números ───────────────────────

/// Cuánto vale cada letra cuando se mezcla con números (en la escala de 0 a
/// 20). AD = 19, A = 15, B = 12, C = 8 por defecto; el docente lo cambia.
List<double> equivalenciasPorDefecto(Escala e) {
  final k = e.valores.length;
  if (e.numerica || k == 0) return const [];
  if (k == 4) return const [19, 15, 12, 8];
  if (k == 2) return const [16, 8];
  if (k == 3) return const [18, 13, 8];
  return [
    for (var i = 0; i < k; i++) (19 - (11 * i / (k - 1))).roundToDouble(),
  ];
}

/// Valor en la escala de 0 a 20 (los números de otra escala se llevan a 20).
double? enVeinte(String? v, Escala e, List<double> equivalencias) {
  if (v == null || v.isEmpty) return null;
  if (e.numerica) {
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null) return null;
    final lo = e.minimo ?? 0, hi = e.maximo ?? 20;
    return hi <= lo ? n : (n - lo) / (hi - lo) * 20;
  }
  final i = e.valores.indexWhere((x) => x.codigo == v);
  if (i < 0) return null;
  final eq = equivalencias.length == e.valores.length
      ? equivalencias
      : equivalenciasPorDefecto(e);
  return i < eq.length ? eq[i] : null;
}

/// Lleva un número de 0 a 20 a la escala de salida.
String aSalida(
  double veinte,
  Escala salida,
  ConfigColumna cfg, {
  List<double>? tramos,
}) {
  if (salida.numerica) {
    final lo = salida.minimo ?? 0, hi = salida.maximo ?? 20;
    final n = lo + veinte.clamp(0, 20) / 20 * (hi - lo);
    return numeroGuardado(redondear(n, cfg.decimales, cfg.redondeo), cfg.decimales);
  }
  return valorDePorcentaje(veinte / 20 * 100, salida, tramos: tramos);
}

// ───────────────────────────── Fórmula ─────────────────────────────

const operadores = {'+', '-', '*', '/', '(', ')'};

bool esColumna(String t) => t.startsWith('c:');
int? idDeToken(String t) => esColumna(t) ? int.tryParse(t.substring(2)) : null;

/// Fórmula para leer: «(F1 + F2) ÷ 2 × 0,4».
String formulaTexto(List<String> tokens, Map<int, String> codigos) => tokens
    .map((t) {
      if (esColumna(t)) return codigos[idDeToken(t)] ?? '?';
      return switch (t) {
        '*' => '×',
        '/' => '÷',
        '-' => '−',
        _ => t.replaceAll('.', ','),
      };
    })
    .join(' ')
    .replaceAll('( ', '(')
    .replaceAll(' )', ')');

/// Evalúa la fórmula con los valores de cada columna (en 0 a 20). Devuelve
/// null si está mal escrita o divide entre cero.
double? evaluarFormula(List<String> tokens, double? Function(int) valor) {
  if (tokens.isEmpty) return null;
  final p = _Lector(tokens, valor);
  final r = p.expresion();
  return p.i == tokens.length ? r : null;
}

/// Lee la fórmula respetando paréntesis y prioridad de × y ÷.
class _Lector {
  final List<String> t;
  final double? Function(int) valor;
  int i = 0;
  _Lector(this.t, this.valor);

  double? expresion() {
    var v = termino();
    while (v != null && i < t.length && (t[i] == '+' || t[i] == '-')) {
      final op = t[i++];
      final d = termino();
      if (d == null) return null;
      v = op == '+' ? v + d : v - d;
    }
    return v;
  }

  double? termino() {
    var v = factor();
    while (v != null && i < t.length && (t[i] == '*' || t[i] == '/')) {
      final op = t[i++];
      final d = factor();
      if (d == null) return null;
      if (op == '/' && d == 0) return null;
      v = op == '*' ? v * d : v / d;
    }
    return v;
  }

  double? factor() {
    if (i >= t.length) return null;
    final x = t[i++];
    if (x == '(') {
      final v = expresion();
      if (i >= t.length || t[i] != ')') return null;
      i++;
      return v;
    }
    if (x == '-') {
      final v = factor();
      return v == null ? null : -v;
    }
    if (esColumna(x)) {
      final id = idDeToken(x);
      return id == null ? null : valor(id);
    }
    return double.tryParse(x.replaceAll(',', '.'));
  }
}

/// Revisa que la fórmula se pueda calcular (con todas las columnas en 10).
String? validarFormula(List<String> tokens) {
  if (tokens.isEmpty) return 'La fórmula está vacía';
  if (!tokens.any(esColumna)) return 'Agrega al menos una columna';
  var abiertos = 0;
  for (final t in tokens) {
    if (t == '(') abiertos++;
    if (t == ')') abiertos--;
    if (abiertos < 0) return 'Hay un «)» de más';
  }
  if (abiertos > 0) return 'Falta cerrar un paréntesis';
  if (evaluarFormula(tokens, (_) => 10) == null) {
    return 'La fórmula está incompleta o divide entre cero';
  }
  return null;
}

// ───────────────────────────── Calcular ─────────────────────────────

/// Resultado de una celda calculada con su explicación.
class Desglose {
  final String? valor;
  final List<(String, String)> lineas;
  final String resumen;
  const Desglose(this.valor, this.lineas, this.resumen);
}

String _n(double x) => x == x.roundToDouble()
    ? x.round().toString()
    : x.toStringAsFixed(1).replaceAll('.', ',');

/// Calcula la nota de un estudiante.
///
/// [valor] da la nota que cuenta de cada columna (con la recuperación ya
/// aplicada). [equivalencias] va por id de escala.
Desglose calcularCelda({
  required Calculo c,
  required Escala salida,
  required ConfigColumna cfg,
  required List<ColumnaDato> cols,
  required String? Function(ColumnaDato) valor,
  Map<String, List<double>> equivalencias = const {},
  List<double>? tramos,
}) {
  double? veinte(ColumnaDato col) =>
      enVeinte(valor(col), col.escala, equivalencias[col.escala.id] ?? const []);

  final lineas = <(String, String)>[];
  String etiqueta(ColumnaDato col) =>
      col.tema.isEmpty ? col.codigo : '${col.codigo} · ${col.tema}';
  for (final col in cols) {
    lineas.add((etiqueta(col), valor(col) ?? 'sin nota'));
  }
  final faltan = cols.where((col) => veinte(col) == null).length;
  if (c.sinNota == SinNota.esperar && faltan > 0) {
    return Desglose(null, lineas, 'Faltan $faltan notas para calcular');
  }
  // Lo que vale cada columna (en 0 a 20) según la regla de notas vacías.
  double? usar(ColumnaDato col) =>
      veinte(col) ?? (c.sinNota == SinNota.cero ? 0 : null);

  switch (c.tipo) {
    case TipoCalculo.formula:
      final porId = {for (final col in cols) col.id: col};
      final r = evaluarFormula(c.formula, (id) {
        final col = porId[id];
        return col == null ? 0 : (usar(col) ?? 0);
      });
      if (r == null) return Desglose(null, lineas, 'Revisa la fórmula');
      return Desglose(
        aSalida(r, salida, cfg, tramos: tramos),
        lineas,
        'Resultado de la fórmula: ${_n(r)} (sobre 20)',
      );

    case TipoCalculo.suma:
      final vals = [for (final col in cols) ?usar(col)];
      if (vals.isEmpty) return Desglose(null, lineas, 'Aún no hay notas');
      // La suma no se lleva a 20: son puntos acumulados.
      final crudos = [
        for (final col in cols)
          if (usar(col) != null)
            col.escala.numerica
                ? (double.tryParse((valor(col) ?? '0').replaceAll(',', '.')) ?? 0)
                : usar(col)!,
      ];
      final s = crudos.fold<double>(0, (a, b) => a + b);
      return Desglose(
        numeroGuardado(redondear(s, cfg.decimales, cfg.redondeo), cfg.decimales),
        lineas,
        'Suma de ${crudos.length} notas: ${_n(s)}',
      );

    case TipoCalculo.maxima || TipoCalculo.minima:
      final vals = [for (final col in cols) ?usar(col)];
      if (vals.isEmpty) return Desglose(null, lineas, 'Aún no hay notas');
      final x = c.tipo == TipoCalculo.maxima
          ? vals.reduce(math.max)
          : vals.reduce(math.min);
      return Desglose(
        aSalida(x, salida, cfg, tramos: tramos),
        lineas,
        '${c.tipo.nombre}: ${_n(x)} (sobre 20)',
      );

    case TipoCalculo.nivel:
      // Con nota numérica, el nivel se calcula como promedio.
      if (salida.numerica) {
        return calcularCelda(
          c: c.copiar(tipo: TipoCalculo.promedio),
          salida: salida,
          cfg: cfg,
          cols: cols,
          valor: valor,
          equivalencias: equivalencias,
          tramos: tramos,
        );
      }
      final codigos = [
        for (final col in cols)
          if (valor(col) case final v?)
            col.escala.id == salida.id
                ? v
                : (veinte(col) == null
                      ? null
                      : valorDePorcentaje(veinte(col)! / 20 * 100, salida, tramos: tramos)),
      ].whereType<String>().toList();
      if (codigos.isEmpty) return Desglose(null, lineas, 'Aún no hay notas');
      if (c.nivel == ModoNivel.ultima) {
        return Desglose(codigos.last, lineas, 'Última evidencia: ${codigos.last}');
      }
      final cuenta = <String, int>{};
      for (final v in codigos) {
        cuenta[v] = (cuenta[v] ?? 0) + 1;
      }
      final orden = [for (final v in salida.valores) v.codigo];
      final mejor = (cuenta.keys.toList()
            ..sort((a, b) {
              final d = cuenta[b]!.compareTo(cuenta[a]!);
              return d != 0 ? d : orden.indexOf(a).compareTo(orden.indexOf(b));
            }))
          .first;
      final detalle = [
        for (final v in orden)
          if (cuenta[v] != null) '${cuenta[v]} $v',
      ].join(', ');
      return Desglose(mejor, lineas, 'Más frecuente: $mejor ($detalle)');

    case TipoCalculo.promedio:
      if (c.porGrupos && c.grupos.isNotEmpty) {
        var suma = 0.0, pesos = 0.0;
        final partes = <String>[];
        for (final g in c.grupos) {
          final del = [
            for (final col in cols)
              if (prefijoDe(col.codigo) == g.prefijo.toUpperCase()) col,
          ];
          final vals = [for (final col in del) ?usar(col)];
          if (vals.isEmpty || g.peso <= 0) continue;
          final m = vals.reduce((a, b) => a + b) / vals.length;
          suma += m * g.peso;
          pesos += g.peso;
          partes.add('${g.nombre} ${_n(m)} × ${_n(g.peso)} %');
        }
        if (pesos == 0) return Desglose(null, lineas, 'Aún no hay notas');
        final r = suma / pesos;
        return Desglose(
          aSalida(r, salida, cfg, tramos: tramos),
          lineas,
          '${partes.join(' + ')} = ${_n(r)} (sobre 20)',
        );
      }
      final vals = [for (final col in cols) ?usar(col)];
      if (vals.isEmpty) return Desglose(null, lineas, 'Aún no hay notas');
      final r = vals.reduce((a, b) => a + b) / vals.length;
      return Desglose(
        aSalida(r, salida, cfg, tramos: tramos),
        lineas,
        'Promedio de ${vals.length} notas: ${_n(r)} (sobre 20)',
      );
  }
}

/// La regla en palabras: «Promedio = 40 % Exámenes + 60 % Tareas».
String calculoEnPalabras(Calculo c, List<ColumnaDato> cols) {
  final codigos = {for (final col in cols) col.id: col.codigo};
  final cuales = switch (c.seleccion) {
    Seleccion.todas => 'todas las columnas del periodo',
    Seleccion.porTipo => 'las columnas ${c.filtro.toUpperCase()}',
    Seleccion.porCompetencia => 'las columnas de la competencia',
    Seleccion.manual => cols.map((x) => x.codigo).join(', '),
  };
  return switch (c.tipo) {
    TipoCalculo.formula => formulaTexto(c.formula, codigos),
    TipoCalculo.promedio when c.porGrupos && c.grupos.isNotEmpty =>
      'Promedio = ${[for (final g in c.grupos) '${_n(g.peso)} % ${g.nombre}'].join(' + ')}',
    TipoCalculo.nivel => '${c.nivel.nombre} de $cuales',
    _ => '${c.tipo.nombre} de $cuales',
  };
}

/// Total de los pesos de los grupos (para avisar si no suma 100).
double totalPesos(List<GrupoPeso> g) => g.fold(0, (s, x) => s + x.peso);
