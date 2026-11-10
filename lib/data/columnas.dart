import 'dart:convert';
import 'dart:math' as math;

import 'calculo.dart';
import 'instrumentos.dart';
import 'paises.dart';

/// Opciones de una columna del registro que no están en la tabla
/// RegistroColumnas. Se guardan en Ajustes como `columna_cfg_<id>` para no
/// cambiar el esquema de la base de datos.
///
/// Tipos de columna (RegistroColumnas.tipo):
/// - 'nota': a mano o con instrumento de evaluación.
/// - 'asistencia': % de asistencia del periodo convertido a la escala.
/// - 'participacion': participaciones (+) y (−) del periodo.
/// - 'calculada': promedios (se configurará después).
const tiposAutomaticos = {'asistencia', 'participacion'};

bool esAutomatica(String tipo) => tiposAutomaticos.contains(tipo);

/// La columna tiene escala propia. Desde que la calculada da notas, todas
/// la tienen.
bool tieneEscala(String tipo) => true;

enum Redondeo { normal, arriba, cortar }

extension RedondeoTexto on Redondeo {
  String get nombre => switch (this) {
    Redondeo.normal => 'Normal',
    Redondeo.arriba => 'Hacia arriba',
    Redondeo.cortar => 'Cortar',
  };
}

class ConfigColumna {
  /// Decimales de la nota numérica (0, 1 o 2).
  final int decimales;
  final Redondeo redondeo;

  /// En escalas numéricas, mostrar también la letra: «16 · A».
  final bool mostrarLetra;

  /// Columna que esta recupera, y si cuenta la nota más alta (si no, la de
  /// recuperación reemplaza a la original).
  final int? recupera;
  final bool recuperaMasAlta;

  /// No se puede poner ni cambiar notas hasta desbloquearla.
  final bool bloqueada;

  /// No sale en la descarga (PDF y Excel).
  final bool ocultaEnDescarga;

  /// Competencia del CNEB que evalúa (id), para el registro por
  /// competencias.
  final String competencia;

  /// Participación: cuántas (+) netas en el periodo dan la nota máxima.
  final int meta;

  /// Columna calculada: qué calcula y con qué columnas.
  final Calculo? calculo;

  const ConfigColumna({
    this.decimales = 0,
    this.redondeo = Redondeo.normal,
    this.mostrarLetra = false,
    this.recupera,
    this.recuperaMasAlta = true,
    this.bloqueada = false,
    this.ocultaEnDescarga = false,
    this.competencia = '',
    this.meta = 10,
    this.calculo,
  });

  ConfigColumna copiar({
    int? decimales,
    Redondeo? redondeo,
    bool? mostrarLetra,
    int? recupera,
    bool sinRecupera = false,
    bool? recuperaMasAlta,
    bool? bloqueada,
    bool? ocultaEnDescarga,
    String? competencia,
    int? meta,
    Calculo? calculo,
  }) => ConfigColumna(
    decimales: decimales ?? this.decimales,
    redondeo: redondeo ?? this.redondeo,
    mostrarLetra: mostrarLetra ?? this.mostrarLetra,
    recupera: sinRecupera ? null : (recupera ?? this.recupera),
    recuperaMasAlta: recuperaMasAlta ?? this.recuperaMasAlta,
    bloqueada: bloqueada ?? this.bloqueada,
    ocultaEnDescarga: ocultaEnDescarga ?? this.ocultaEnDescarga,
    competencia: competencia ?? this.competencia,
    meta: meta ?? this.meta,
    calculo: calculo ?? this.calculo,
  );

  Map<String, dynamic> aJson() => {
    if (decimales != 0) 'decimales': decimales,
    if (redondeo != Redondeo.normal) 'redondeo': redondeo.name,
    if (mostrarLetra) 'mostrarLetra': true,
    'recupera': ?recupera,
    if (!recuperaMasAlta) 'recuperaMasAlta': false,
    if (bloqueada) 'bloqueada': true,
    if (ocultaEnDescarga) 'ocultaEnDescarga': true,
    if (competencia.isNotEmpty) 'competencia': competencia,
    if (meta != 10) 'meta': meta,
    if (calculo != null) 'calculo': calculo!.aJson(),
  };

  factory ConfigColumna.deJson(Map<String, dynamic> j) => ConfigColumna(
    decimales: ((j['decimales'] as num?)?.toInt() ?? 0).clamp(0, 2).toInt(),
    redondeo: Redondeo.values.firstWhere(
      (r) => r.name == j['redondeo'],
      orElse: () => Redondeo.normal,
    ),
    mostrarLetra: j['mostrarLetra'] as bool? ?? false,
    recupera: (j['recupera'] as num?)?.toInt(),
    recuperaMasAlta: j['recuperaMasAlta'] as bool? ?? true,
    bloqueada: j['bloqueada'] as bool? ?? false,
    ocultaEnDescarga: j['ocultaEnDescarga'] as bool? ?? false,
    competencia: j['competencia'] as String? ?? '',
    meta: math.max(1, (j['meta'] as num?)?.toInt() ?? 10),
    calculo: j['calculo'] is Map<String, dynamic>
        ? Calculo.deJson(j['calculo'] as Map<String, dynamic>)
        : null,
  );

  static ConfigColumna deTexto(String? v) {
    if (v == null || v.isEmpty) return const ConfigColumna();
    try {
      return ConfigColumna.deJson(jsonDecode(v) as Map<String, dynamic>);
    } catch (_) {
      return const ConfigColumna();
    }
  }

  String aTexto() => jsonEncode(aJson());
}

/// Redondea con los decimales y el modo de la columna.
double redondear(double n, int decimales, Redondeo modo) {
  final f = math.pow(10, decimales).toDouble();
  final x = n * f;
  final r = switch (modo) {
    Redondeo.normal => (x + 1e-9).roundToDouble(),
    Redondeo.arriba => (x - 1e-9).ceilToDouble(),
    Redondeo.cortar => (x + 1e-9).floorToDouble(),
  };
  return r / f;
}

/// Número como se guarda en el registro: «15», «14.5».
String numeroGuardado(double n, int decimales) {
  final t = n.toStringAsFixed(decimales);
  return t.contains('.')
      ? t.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
      : t;
}

/// Ejemplo para mostrar el redondeo elegido: «14,45 → 14,5».
String ejemploRedondeo(int decimales, Redondeo modo) {
  final muestra = decimales == 0 ? 14.5 : (decimales == 1 ? 14.45 : 14.455);
  String coma(String s) => s.replaceAll('.', ',');
  return '${coma(muestra.toString())} → '
      '${coma(numeroGuardado(redondear(muestra, decimales, modo), decimales))}';
}

/// Pasa un porcentaje (0 a 100) a la escala de la columna.
String valorDePorcentaje(
  double pct,
  Escala e, {
  List<double>? tramos,
  int decimales = 0,
  Redondeo redondeo = Redondeo.normal,
}) {
  final p = pct.clamp(0, 100).toDouble();
  if (e.numerica) {
    final lo = e.minimo ?? 0, hi = e.maximo ?? 20;
    return numeroGuardado(
      redondear(lo + p / 100 * (hi - lo), decimales, redondeo),
      decimales,
    );
  }
  final k = e.valores.length;
  if (k == 0) return '';
  final t = tramos ?? tramosPorDefecto(e);
  for (var i = 0; i < t.length && i < k - 1; i++) {
    if (p + 1e-9 >= t[i]) return e.valores[i].codigo;
  }
  return e.valores.last.codigo;
}

/// % de asistencia: presente (P) y tarde (T) cuentan como asistió; la
/// falta (F) baja el %; la justificada (J) no cuenta en el total.
double? porcentajeAsistencia(Iterable<String> estados) {
  var asistio = 0, total = 0;
  for (final e in estados) {
    if (e == 'J') continue;
    total++;
    if (e == 'P' || e == 'T') asistio++;
  }
  return total == 0 ? null : asistio / total * 100;
}

/// % de participación: (+) menos (−), sobre la meta del periodo.
double? porcentajeParticipacion(int positivas, int negativas, int meta) {
  if (positivas == 0 && negativas == 0) return null;
  return ((positivas - negativas) / math.max(1, meta) * 100)
      .clamp(0, 100)
      .toDouble();
}

/// Letra que corresponde a una nota numérica, por los tramos de la escala
/// numérica (18–20, 14–17…) y la escala de letras con la misma cantidad de
/// valores (AD, A, B, C).
String? letraDeNumero(String valor, Escala numerica, Escala letras) {
  final n = double.tryParse(valor.replaceAll(',', '.'));
  if (n == null || !numerica.numerica) return null;
  final tramos = numerica.valores.where((v) => v.desde != null).toList();
  if (tramos.isEmpty || tramos.length != letras.valores.length) return null;
  for (var i = 0; i < tramos.length; i++) {
    if (n + 1e-9 >= tramos[i].desde!) return letras.valores[i].codigo;
  }
  return letras.valores.last.codigo;
}

/// Nota que cuenta cuando hay recuperación: la más alta de las dos o, si
/// el docente lo prefiere, siempre la de recuperación.
String? notaConRecuperacion(
  String? original,
  String? recuperacion,
  Escala e, {
  bool masAlta = true,
}) {
  if (recuperacion == null || recuperacion.isEmpty) return original;
  if (original == null || original.isEmpty || !masAlta) return recuperacion;
  if (e.numerica) {
    final a = double.tryParse(original.replaceAll(',', '.'));
    final b = double.tryParse(recuperacion.replaceAll(',', '.'));
    if (a == null) return recuperacion;
    if (b == null) return original;
    return b > a ? recuperacion : original;
  }
  // En letras, el valor que va primero en la escala es el mejor.
  final orden = [for (final v in e.valores) v.codigo];
  final ia = orden.indexOf(original), ib = orden.indexOf(recuperacion);
  if (ia < 0) return recuperacion;
  if (ib < 0) return original;
  return ib < ia ? recuperacion : original;
}

/// Prefijo del código sugerido según cómo se evalúa.
String prefijoCodigo(String modo, {TipoInstrumento? instrumento}) =>
    switch (modo) {
      'asistencia' => 'Asist',
      'participacion' => 'Part',
      'calculada' => 'Prom',
      'instrumento' => switch (instrumento) {
        TipoInstrumento.rubrica => 'R',
        TipoInstrumento.cotejo => 'L',
        TipoInstrumento.escala => 'E',
        TipoInstrumento.prueba => 'EX',
        null => 'I',
      },
      _ => 'N',
    };

/// Primer código libre con ese prefijo: N1, N2… (Asist, Asist2…).
String codigoLibre(String prefijo, Iterable<String> usados) {
  final u = usados.map((c) => c.toUpperCase()).toSet();
  final sinNumero = prefijo.length > 2;
  if (sinNumero && !u.contains(prefijo.toUpperCase())) return prefijo;
  for (var i = sinNumero ? 2 : 1; ; i++) {
    final c = '$prefijo$i';
    if (!u.contains(c.toUpperCase())) return c;
  }
}
