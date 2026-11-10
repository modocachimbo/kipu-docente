import 'dart:convert';
import 'dart:math' as math;

import 'paises.dart';

/// Instrumentos de evaluación: rúbrica, lista de cotejo y escala de
/// valoración. Todo es Dart puro (sin Flutter) para poder probarlo.
///
/// Cómo se guardan (en la tabla Ajustes, como JSON):
/// - `instrumentos`: la biblioteca del docente.
/// - `instrumento_col_<columnaId>`: COPIA del instrumento que usa una columna
///   del registro. Es una copia para que editar la biblioteca no cambie
///   evaluaciones ya hechas.
/// - `instrumento_marcas_<columnaId>`: lo marcado a cada estudiante.
/// - `tramos_<escalaId>`: % mínimo de cada valor de una escala de letras.
enum TipoInstrumento { rubrica, cotejo, escala }

extension TipoInstrumentoTexto on TipoInstrumento {
  String get nombre => switch (this) {
    TipoInstrumento.rubrica => 'Rúbrica',
    TipoInstrumento.cotejo => 'Lista de cotejo',
    TipoInstrumento.escala => 'Escala de valoración',
  };

  String get plural => switch (this) {
    TipoInstrumento.rubrica => 'Rúbricas',
    TipoInstrumento.cotejo => 'Listas de cotejo',
    TipoInstrumento.escala => 'Escalas de valoración',
  };

  /// Qué es y cuándo conviene, para ayudar al docente a elegir.
  String get ayuda => switch (this) {
    TipoInstrumento.rubrica =>
      'Criterios por niveles de logro con un descriptor en cada cruce. '
          'Para productos y desempeños complejos: exposiciones, informes, '
          'proyectos, ensayos.',
    TipoInstrumento.cotejo =>
      'Ítems que se marcan como logrados o no. Rápida y objetiva: pasos de '
          'un procedimiento, partes de un producto, normas.',
    TipoInstrumento.escala =>
      'Cada ítem se valora en grados (siempre, a veces, nunca…). Para '
          'hábitos, actitudes, participación, auto y coevaluación.',
  };
}

/// Niveles educativos a los que apunta un instrumento.
const nivelesEducativos = ['Inicial', 'Primaria', 'Secundaria'];

/// Un nivel de logro (columna de rúbrica, grado de una escala o etiqueta de
/// una lista de cotejo) con sus puntos.
class NivelInstrumento {
  final String nombre;
  final double puntos;
  const NivelInstrumento(this.nombre, this.puntos);

  Map<String, dynamic> aJson() => {'nombre': nombre, 'puntos': puntos};
  factory NivelInstrumento.deJson(Map<String, dynamic> j) => NivelInstrumento(
    j['nombre'] as String? ?? '',
    (j['puntos'] as num?)?.toDouble() ?? 0,
  );
}

/// Un criterio (rúbrica) o ítem (lista de cotejo, escala).
class ItemInstrumento {
  final String id;
  final String texto;

  /// Peso: % en la rúbrica, puntos en la lista ponderada. 1 si no se usa.
  final double peso;

  /// Solo rúbrica: un descriptor por nivel, en el orden de los niveles.
  final List<String> descriptores;

  const ItemInstrumento({
    required this.id,
    required this.texto,
    this.peso = 1,
    this.descriptores = const [],
  });

  ItemInstrumento copiar({
    String? texto,
    double? peso,
    List<String>? descriptores,
  }) => ItemInstrumento(
    id: id,
    texto: texto ?? this.texto,
    peso: peso ?? this.peso,
    descriptores: descriptores ?? this.descriptores,
  );

  Map<String, dynamic> aJson() => {
    'id': id,
    'texto': texto,
    'peso': peso,
    if (descriptores.isNotEmpty) 'descriptores': descriptores,
  };

  factory ItemInstrumento.deJson(Map<String, dynamic> j) => ItemInstrumento(
    id: j['id'] as String,
    texto: j['texto'] as String? ?? '',
    peso: (j['peso'] as num?)?.toDouble() ?? 1,
    descriptores: [
      for (final d in (j['descriptores'] as List?) ?? const []) '$d',
    ],
  );
}

class Instrumento {
  final String id;
  final TipoInstrumento tipo;
  final String nombre;
  final String descripcion;

  /// Inicial, Primaria, Secundaria. Vacío = cualquiera.
  final List<String> niveles;
  final String area;

  /// Rúbrica: columnas de menor a mayor logro (como se ven en la tabla).
  /// Escala: de mejor a peor (el mejor arriba). Lista de cotejo: [positiva,
  /// negativa].
  final List<NivelInstrumento> escala;
  final List<ItemInstrumento> items;

  /// Añade «No observado»: esos ítems no cuentan en la nota.
  final bool noObservado;

  /// Cada ítem tiene su peso. En la rúbrica, false = pesos iguales
  /// («Porcentajes automáticos»).
  final bool ponderada;

  /// Viene de los ejemplos de Kipu (se muestra la marca «Ejemplo»).
  final bool ejemplo;

  const Instrumento({
    required this.id,
    required this.tipo,
    required this.nombre,
    this.descripcion = '',
    this.niveles = const [],
    this.area = '',
    required this.escala,
    required this.items,
    this.noObservado = false,
    this.ponderada = false,
    this.ejemplo = false,
  });

  Instrumento copiar({
    String? id,
    String? nombre,
    String? descripcion,
    List<String>? niveles,
    String? area,
    List<NivelInstrumento>? escala,
    List<ItemInstrumento>? items,
    bool? noObservado,
    bool? ponderada,
    bool? ejemplo,
  }) => Instrumento(
    id: id ?? this.id,
    tipo: tipo,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    niveles: niveles ?? this.niveles,
    area: area ?? this.area,
    escala: escala ?? this.escala,
    items: items ?? this.items,
    noObservado: noObservado ?? this.noObservado,
    ponderada: ponderada ?? this.ponderada,
    ejemplo: ejemplo ?? this.ejemplo,
  );

  /// Puntos del mejor y del peor nivel.
  double get puntosMax => escala.isEmpty ? 1 : escala.map((n) => n.puntos).reduce(math.max);
  double get puntosMin => escala.isEmpty ? 0 : escala.map((n) => n.puntos).reduce(math.min);

  /// Peso efectivo de un ítem.
  double pesoDe(ItemInstrumento i) => ponderada ? math.max(0, i.peso) : 1;

  /// Resumen corto: «6 criterios · 4 niveles».
  String get resumen {
    final n = items.length;
    return switch (tipo) {
      TipoInstrumento.rubrica =>
        '$n ${n == 1 ? 'criterio' : 'criterios'} · ${escala.length} niveles',
      TipoInstrumento.cotejo =>
        '$n ${n == 1 ? 'ítem' : 'ítems'} · ${escala.map((e) => e.nombre).join(' / ')}',
      TipoInstrumento.escala =>
        '$n ${n == 1 ? 'ítem' : 'ítems'} · ${escala.length} niveles',
    };
  }

  /// Problemas que impiden usarlo; vacío = listo.
  List<String> validar() {
    final r = <String>[];
    if (nombre.trim().isEmpty) r.add('Escribe un nombre');
    if (items.isEmpty) {
      r.add(
        tipo == TipoInstrumento.rubrica
            ? 'Agrega al menos un criterio'
            : 'Agrega al menos un ítem',
      );
    }
    if (items.any((i) => i.texto.trim().isEmpty)) {
      r.add(
        tipo == TipoInstrumento.rubrica
            ? 'Hay un criterio sin nombre'
            : 'Hay un ítem sin texto',
      );
    }
    if (escala.length < 2) r.add('Hacen falta al menos 2 niveles');
    if (escala.any((n) => n.nombre.trim().isEmpty)) {
      r.add('Hay un nivel sin nombre');
    }
    if (escala.isNotEmpty && puntosMax <= puntosMin) {
      r.add('El mejor nivel debe tener más puntos que el más bajo');
    }
    if (ponderada && items.every((i) => i.peso <= 0)) {
      r.add('Al menos un ítem debe tener peso mayor que 0');
    }
    return r;
  }

  Map<String, dynamic> aJson() => {
    'id': id,
    'tipo': tipo.name,
    'nombre': nombre,
    if (descripcion.isNotEmpty) 'descripcion': descripcion,
    if (niveles.isNotEmpty) 'niveles': niveles,
    if (area.isNotEmpty) 'area': area,
    'escala': [for (final n in escala) n.aJson()],
    'items': [for (final i in items) i.aJson()],
    'noObservado': noObservado,
    'ponderada': ponderada,
    if (ejemplo) 'ejemplo': true,
  };

  factory Instrumento.deJson(Map<String, dynamic> j) => Instrumento(
    id: j['id'] as String,
    tipo: TipoInstrumento.values.firstWhere(
      (t) => t.name == j['tipo'],
      orElse: () => TipoInstrumento.cotejo,
    ),
    nombre: j['nombre'] as String? ?? '',
    descripcion: j['descripcion'] as String? ?? '',
    niveles: [for (final n in (j['niveles'] as List?) ?? const []) '$n'],
    area: j['area'] as String? ?? '',
    escala: [
      for (final n in (j['escala'] as List?) ?? const [])
        NivelInstrumento.deJson(n as Map<String, dynamic>),
    ],
    items: [
      for (final i in (j['items'] as List?) ?? const [])
        ItemInstrumento.deJson(i as Map<String, dynamic>),
    ],
    noObservado: j['noObservado'] as bool? ?? false,
    ponderada: j['ponderada'] as bool? ?? false,
    ejemplo: j['ejemplo'] as bool? ?? false,
  );

  static List<Instrumento> listaDeJson(String? v) {
    if (v == null || v.isEmpty) return [];
    try {
      return [
        for (final x in jsonDecode(v) as List)
          Instrumento.deJson(x as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  static String listaAJson(List<Instrumento> l) =>
      jsonEncode([for (final i in l) i.aJson()]);

  /// Instrumento nuevo y vacío, listo para editar.
  factory Instrumento.nuevo(TipoInstrumento tipo) {
    final id = nuevoId();
    return switch (tipo) {
      TipoInstrumento.rubrica => Instrumento(
        id: id,
        tipo: tipo,
        nombre: '',
        escala: plantillaNivelesRubrica,
        items: [
          ItemInstrumento(
            id: nuevoId(),
            texto: '',
            peso: 100,
            descriptores: List.filled(plantillaNivelesRubrica.length, ''),
          ),
        ],
      ),
      TipoInstrumento.cotejo => Instrumento(
        id: id,
        tipo: tipo,
        nombre: '',
        escala: etiquetasCotejo.first.niveles,
        items: [ItemInstrumento(id: nuevoId(), texto: '')],
      ),
      TipoInstrumento.escala => Instrumento(
        id: id,
        tipo: tipo,
        nombre: '',
        escala: nivelesEscala.first.niveles,
        items: [ItemInstrumento(id: nuevoId(), texto: '')],
      ),
    };
  }
}

var _contador = 0;

/// Id único y corto (no necesita ser secreto).
String nuevoId() {
  _contador++;
  final t = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final r = math.Random().nextInt(1 << 20).toRadixString(36);
  return '$t$r$_contador';
}

/// Copia con ids nuevos (duplicar o tomar un ejemplo).
Instrumento duplicar(Instrumento i, {String? nombre, bool ejemplo = false}) =>
    i.copiar(
      id: nuevoId(),
      nombre: nombre ?? i.nombre,
      ejemplo: ejemplo,
      items: [
        for (final x in i.items)
          ItemInstrumento(
            id: nuevoId(),
            texto: x.texto,
            peso: x.peso,
            descriptores: [...x.descriptores],
          ),
      ],
    );

// ───────────────────────── Plantillas de niveles ─────────────────────────

class PresetNiveles {
  final String nombre;
  final List<NivelInstrumento> niveles;
  const PresetNiveles(this.nombre, this.niveles);
}

/// Rúbrica: de menor a mayor logro.
const plantillaNivelesRubrica = [
  NivelInstrumento('En inicio', 1),
  NivelInstrumento('En proceso', 2),
  NivelInstrumento('Logro esperado', 3),
  NivelInstrumento('Logro destacado', 4),
];

const nivelesRubrica = [
  PresetNiveles('Niveles CNEB', plantillaNivelesRubrica),
  PresetNiveles('Insuficiente…Sobresaliente', [
    NivelInstrumento('Insuficiente', 1),
    NivelInstrumento('Aprobado', 2),
    NivelInstrumento('Notable', 3),
    NivelInstrumento('Sobresaliente', 4),
  ]),
  PresetNiveles('3 niveles', [
    NivelInstrumento('Por mejorar', 1),
    NivelInstrumento('Bien', 2),
    NivelInstrumento('Muy bien', 3),
  ]),
];

/// Escala de valoración: del mejor al más bajo.
const nivelesEscala = [
  PresetNiveles('Frecuencia', [
    NivelInstrumento('Siempre', 3),
    NivelInstrumento('Casi siempre', 2),
    NivelInstrumento('A veces', 1),
    NivelInstrumento('Nunca', 0),
  ]),
  PresetNiveles('Calidad', [
    NivelInstrumento('Excelente', 3),
    NivelInstrumento('Bueno', 2),
    NivelInstrumento('Regular', 1),
    NivelInstrumento('Deficiente', 0),
  ]),
  PresetNiveles('4-3-2-1', [
    NivelInstrumento('4', 4),
    NivelInstrumento('3', 3),
    NivelInstrumento('2', 2),
    NivelInstrumento('1', 1),
  ]),
  PresetNiveles('Caritas', [
    NivelInstrumento('😀 Muy bien', 2),
    NivelInstrumento('🙂 Bien', 1),
    NivelInstrumento('😐 Puedo mejorar', 0),
  ]),
  PresetNiveles('Siempre / A veces / Nunca', [
    NivelInstrumento('Siempre', 2),
    NivelInstrumento('A veces', 1),
    NivelInstrumento('Nunca', 0),
  ]),
];

/// Lista de cotejo: [positiva, negativa].
const etiquetasCotejo = [
  PresetNiveles('Sí / No', [NivelInstrumento('Sí', 1), NivelInstrumento('No', 0)]),
  PresetNiveles('Logrado / No logrado', [
    NivelInstrumento('Logrado', 1),
    NivelInstrumento('No logrado', 0),
  ]),
  PresetNiveles('Cumple / No cumple', [
    NivelInstrumento('Cumple', 1),
    NivelInstrumento('No cumple', 0),
  ]),
  PresetNiveles('Lo hace / Aún no', [
    NivelInstrumento('Lo hace', 1),
    NivelInstrumento('Aún no', 0),
  ]),
];

// ───────────────────────────── Evaluar ─────────────────────────────

/// Marca de «No observado» en un ítem.
const marcaNoObservado = -1;

/// Lo marcado a un estudiante: {itemId: índice del nivel o -1}, más un
/// comentario opcional.
class Marcas {
  final Map<String, int> porItem;
  final String comentario;
  const Marcas([this.porItem = const {}, this.comentario = '']);

  bool get vacia => porItem.isEmpty && comentario.trim().isEmpty;

  Map<String, dynamic> aJson() => {
    'm': porItem,
    if (comentario.trim().isNotEmpty) 'c': comentario.trim(),
  };

  factory Marcas.deJson(Map<String, dynamic> j) => Marcas(
    {
      for (final e in ((j['m'] as Map?) ?? const {}).entries)
        '${e.key}': (e.value as num).toInt(),
    },
    j['c'] as String? ?? '',
  );

  static Map<int, Marcas> mapaDeJson(String? v) {
    if (v == null || v.isEmpty) return {};
    try {
      final j = jsonDecode(v) as Map<String, dynamic>;
      return {
        for (final e in j.entries)
          int.parse(e.key): Marcas.deJson(e.value as Map<String, dynamic>),
      };
    } catch (_) {
      return {};
    }
  }

  static String mapaAJson(Map<int, Marcas> m) => jsonEncode({
    for (final e in m.entries)
      if (!e.value.vacia) '${e.key}': e.value.aJson(),
  });
}

/// Resultado de aplicar un instrumento a un estudiante.
class Resultado {
  /// Ítems marcados que cuentan (sin «No observado»).
  final int aplicables;
  final int total;

  /// Ítems con el nivel más alto (en la lista de cotejo: los logrados).
  final int logrados;

  /// Puntos obtenidos sobre puntos posibles, de 0 a 1.
  final double proporcion;

  /// Nivel promedio de 0 (el más bajo) a 1 (el más alto).
  final double nivelMedio;

  const Resultado({
    required this.aplicables,
    required this.total,
    required this.logrados,
    required this.proporcion,
    required this.nivelMedio,
  });

  double get porcentaje => proporcion * 100;
}

/// Calcula el resultado. Devuelve null si no hay nada marcado que cuente.
/// Los ítems sin marcar no cuentan (así se puede evaluar por partes).
Resultado? calcular(Instrumento ins, Marcas m) {
  final max = ins.puntosMax, min = ins.puntosMin;
  var obtenidos = 0.0, posibles = 0.0, sumaNivel = 0.0, sumaPeso = 0.0;
  var aplicables = 0, logrados = 0;
  for (final it in ins.items) {
    final k = m.porItem[it.id];
    if (k == null || k == marcaNoObservado) continue;
    if (k < 0 || k >= ins.escala.length) continue;
    final w = ins.pesoDe(it);
    final p = ins.escala[k].puntos;
    aplicables++;
    if (p >= max) logrados++;
    obtenidos += w * p;
    posibles += w * max;
    sumaNivel += w * (max == min ? 1 : (p - min) / (max - min));
    sumaPeso += w;
  }
  if (aplicables == 0) return null;
  return Resultado(
    aplicables: aplicables,
    total: ins.items.length,
    logrados: logrados,
    proporcion: posibles <= 0 ? 0 : obtenidos / posibles,
    nivelMedio: sumaPeso <= 0 ? 0 : sumaNivel / sumaPeso,
  );
}

/// % mínimo de cada valor de una escala de letras, del mejor al penúltimo
/// (el último va desde 0). Para AD/A/B/C: 90, 70, 55.
List<double> tramosPorDefecto(Escala e) {
  final k = e.valores.length;
  if (k == 4) return const [90, 70, 55];
  if (k == 2) return const [55];
  if (k == 3) return const [80, 55];
  // Reparto parejo para otras escalas.
  return [for (var i = 1; i < k; i++) (100 * (k - i) / k).roundToDouble()];
}

/// Pasa el resultado a un valor de la escala de la columna.
///
/// - Escala numérica: puntos obtenidos ÷ posibles × rango, redondeado a
///   entero (como en SIAGIE).
/// - Rúbrica o escala de valoración con tantos niveles como la escala de
///   letras (4 niveles y AD/A/B/C): el nivel promedio redondeado, así
///   «Logro esperado» sigue siendo A.
/// - En otro caso: el % con los tramos.
String valorEnEscala(
  Instrumento ins,
  Resultado r,
  Escala e, {
  List<double>? tramos,
}) {
  if (e.numerica) {
    final lo = e.minimo ?? 0, hi = e.maximo ?? 20;
    final n = lo + r.proporcion * (hi - lo);
    final redondo = (n + 1e-9).roundToDouble();
    return redondo.toInt().toString();
  }
  final k = e.valores.length;
  if (k == 0) return '';
  if (ins.tipo != TipoInstrumento.cotejo && ins.escala.length == k) {
    // 0 = el mejor valor de la escala de letras.
    final i = ((1 - r.nivelMedio) * (k - 1) + 1e-9).round().clamp(0, k - 1).toInt();
    return e.valores[i].codigo;
  }
  final t = tramos ?? tramosPorDefecto(e);
  final pct = r.porcentaje + 1e-9;
  for (var i = 0; i < t.length && i < k - 1; i++) {
    if (pct >= t[i]) return e.valores[i].codigo;
  }
  return e.valores.last.codigo;
}

/// «4 de 5 logrados · 80 %» o «Nivel medio 3,2 de 4 · 73 %».
String describirResultado(Instrumento ins, Resultado r) {
  final pct = '${r.porcentaje.round()} %';
  final noObs = r.total - r.aplicables;
  final extra = noObs > 0 ? ' · $noObs sin marcar' : '';
  if (ins.tipo == TipoInstrumento.cotejo) {
    return '${r.logrados} de ${r.aplicables} logrados · $pct$extra';
  }
  final niveles = ins.escala.length;
  final medio = 1 + r.nivelMedio * (niveles - 1);
  final txt = medio.toStringAsFixed(1).replaceAll('.', ',');
  return 'Nivel medio $txt de $niveles · $pct$extra';
}

/// Texto de los tramos para mostrar: «AD ≥ 90 % · A ≥ 70 % · …».
String describirTramos(Escala e, List<double> t) {
  final p = <String>[];
  for (var i = 0; i < e.valores.length; i++) {
    final c = e.valores[i].codigo;
    p.add(
      i < t.length ? '$c ≥ ${t[i].round()} %' : '$c < ${t.isEmpty ? 100 : t.last.round()} %',
    );
  }
  return p.join(' · ');
}

/// Revisa que los tramos bajen de mayor a menor y estén entre 1 y 100.
String? validarTramos(List<double> t) {
  for (var i = 0; i < t.length; i++) {
    if (t[i] <= 0 || t[i] > 100) return 'Usa porcentajes entre 1 y 100';
    if (i > 0 && t[i] >= t[i - 1]) {
      return 'Cada tramo debe ser menor que el anterior';
    }
  }
  return null;
}
