import 'dart:convert';
import 'dart:math' as math;

import 'columnas.dart';
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
enum TipoInstrumento { rubrica, cotejo, escala, prueba }

extension TipoInstrumentoTexto on TipoInstrumento {
  String get nombre => switch (this) {
    TipoInstrumento.rubrica => 'Rúbrica',
    TipoInstrumento.cotejo => 'Lista de cotejo',
    TipoInstrumento.escala => 'Escala de valoración',
    TipoInstrumento.prueba => 'Examen con clave',
  };

  String get plural => switch (this) {
    TipoInstrumento.rubrica => 'Rúbricas',
    TipoInstrumento.cotejo => 'Listas de cotejo',
    TipoInstrumento.escala => 'Escalas de valoración',
    TipoInstrumento.prueba => 'Exámenes',
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
    TipoInstrumento.prueba =>
      'Preguntas con puntaje: opción múltiple, verdadero o falso y de '
          'desarrollo. Marcas lo que respondió y Kipu corrige con la clave.',
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

  /// Solo examen: 0 = desarrollo (puntaje a mano), 2 = verdadero o falso,
  /// 3 a 6 = opción múltiple A–C … A–F.
  final int opciones;

  /// Solo examen: índice de la respuesta correcta (0 = A o V).
  final int? clave;

  const ItemInstrumento({
    required this.id,
    required this.texto,
    this.peso = 1,
    this.descriptores = const [],
    this.opciones = 0,
    this.clave,
  });

  bool get desarrollo => opciones == 0;

  /// Letras de las opciones: [V, F] o [A, B, C, D].
  List<String> get letras => opciones == 2
      ? const ['V', 'F']
      : [for (var k = 0; k < opciones; k++) String.fromCharCode(65 + k)];

  ItemInstrumento copiar({
    String? texto,
    double? peso,
    List<String>? descriptores,
    int? opciones,
    int? clave,
    bool sinClave = false,
  }) => ItemInstrumento(
    id: id,
    texto: texto ?? this.texto,
    peso: peso ?? this.peso,
    descriptores: descriptores ?? this.descriptores,
    opciones: opciones ?? this.opciones,
    clave: sinClave ? null : (clave ?? this.clave),
  );

  Map<String, dynamic> aJson() => {
    'id': id,
    'texto': texto,
    'peso': peso,
    if (descriptores.isNotEmpty) 'descriptores': descriptores,
    if (opciones != 0) 'opciones': opciones,
    if (clave != null) 'clave': clave,
  };

  factory ItemInstrumento.deJson(Map<String, dynamic> j) => ItemInstrumento(
    id: j['id'] as String,
    texto: j['texto'] as String? ?? '',
    peso: (j['peso'] as num?)?.toDouble() ?? 1,
    descriptores: [
      for (final d in (j['descriptores'] as List?) ?? const []) '$d',
    ],
    opciones: (j['opciones'] as num?)?.toInt() ?? 0,
    clave: (j['clave'] as num?)?.toInt(),
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

  /// Ids de las competencias del CNEB que evalúa (ver cneb.dart). Sirven para
  /// filtrar y para el registro por competencias.
  final List<String> competencias;

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

  /// Id del ejemplo del que se copió, para saber cuáles ya se agregaron.
  final String origen;

  /// Carpeta de la biblioteca ('' = sin carpeta).
  final String carpeta;

  const Instrumento({
    required this.id,
    required this.tipo,
    required this.nombre,
    this.descripcion = '',
    this.niveles = const [],
    this.area = '',
    this.competencias = const [],
    this.escala = const [],
    required this.items,
    this.noObservado = false,
    this.ponderada = false,
    this.ejemplo = false,
    this.origen = '',
    this.carpeta = '',
  });

  Instrumento copiar({
    String? id,
    String? nombre,
    String? descripcion,
    List<String>? niveles,
    String? area,
    List<String>? competencias,
    List<NivelInstrumento>? escala,
    List<ItemInstrumento>? items,
    bool? noObservado,
    bool? ponderada,
    bool? ejemplo,
    String? origen,
    String? carpeta,
  }) => Instrumento(
    id: id ?? this.id,
    tipo: tipo,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    niveles: niveles ?? this.niveles,
    area: area ?? this.area,
    competencias: competencias ?? this.competencias,
    escala: escala ?? this.escala,
    items: items ?? this.items,
    noObservado: noObservado ?? this.noObservado,
    ponderada: ponderada ?? this.ponderada,
    ejemplo: ejemplo ?? this.ejemplo,
    origen: origen ?? this.origen,
    carpeta: carpeta ?? this.carpeta,
  );

  /// Puntos del mejor y del peor nivel.
  double get puntosMax => escala.isEmpty ? 1 : escala.map((n) => n.puntos).reduce(math.max);
  double get puntosMin => escala.isEmpty ? 0 : escala.map((n) => n.puntos).reduce(math.min);

  /// Peso efectivo de un ítem.
  double pesoDe(ItemInstrumento i) =>
      ponderada || tipo == TipoInstrumento.prueba ? math.max(0, i.peso) : 1;

  /// Puntaje total del examen.
  double get puntajeTotal => items.fold(0, (s, i) => s + math.max(0, i.peso));

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
      TipoInstrumento.prueba =>
        '$n ${n == 1 ? 'pregunta' : 'preguntas'} · ${_numTxt(puntajeTotal)} puntos',
    };
  }

  /// Problemas que impiden usarlo; vacío = listo.
  List<String> validar() {
    final r = <String>[];
    if (nombre.trim().isEmpty) r.add('Escribe un nombre');
    if (tipo == TipoInstrumento.prueba) {
      if (items.isEmpty) r.add('Agrega al menos una pregunta');
      for (final (k, i) in items.indexed) {
        if (i.peso <= 0) r.add('La pregunta ${k + 1} debe valer más de 0 puntos');
        if (!i.desarrollo && (i.clave == null || i.clave! >= i.opciones)) {
          r.add('Marca la respuesta correcta de la pregunta ${k + 1}');
        }
      }
      return r;
    }
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
    if (competencias.isNotEmpty) 'competencias': competencias,
    'escala': [for (final n in escala) n.aJson()],
    'items': [for (final i in items) i.aJson()],
    'noObservado': noObservado,
    'ponderada': ponderada,
    if (ejemplo) 'ejemplo': true,
    if (origen.isNotEmpty) 'origen': origen,
    if (carpeta.isNotEmpty) 'carpeta': carpeta,
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
    competencias: [
      for (final c in (j['competencias'] as List?) ?? const []) '$c',
    ],
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
    origen: j['origen'] as String? ?? '',
    carpeta: j['carpeta'] as String? ?? '',
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
      TipoInstrumento.prueba => Instrumento(
        id: id,
        tipo: tipo,
        nombre: '',
        ponderada: true,
        items: [
          for (var k = 0; k < 5; k++)
            ItemInstrumento(id: nuevoId(), texto: '', peso: 4, opciones: 4),
        ],
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
      origen: ejemplo ? i.id : '',
      items: [
        for (final x in i.items)
          ItemInstrumento(
            id: nuevoId(),
            texto: x.texto,
            peso: x.peso,
            descriptores: [...x.descriptores],
            opciones: x.opciones,
            clave: x.clave,
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

  /// Puntos obtenidos y posibles (en el examen, el puntaje).
  final double puntos;
  final double posibles;

  const Resultado({
    required this.aplicables,
    required this.total,
    required this.logrados,
    required this.proporcion,
    required this.nivelMedio,
    this.puntos = 0,
    this.posibles = 0,
  });

  double get porcentaje => proporcion * 100;
}

/// Calcula el resultado. Devuelve null si no hay nada marcado que cuente.
/// Los ítems sin marcar no cuentan (así se puede evaluar por partes).
Resultado? calcular(Instrumento ins, Marcas m) {
  if (ins.tipo == TipoInstrumento.prueba) return _calcularPrueba(ins, m);
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
    puntos: obtenidos,
    posibles: posibles,
  );
}

/// En el examen la marca es la opción que eligió el estudiante (o -1 si no
/// respondió) y, en desarrollo, los medios puntos obtenidos (3 = 1,5 pts).
/// Las preguntas sin marcar cuentan como no respondidas: el total es siempre
/// el puntaje del examen.
Resultado? _calcularPrueba(Instrumento ins, Marcas m) {
  if (m.porItem.isEmpty) return null;
  var obtenidos = 0.0, aplicables = 0, correctas = 0;
  final total = ins.puntajeTotal;
  for (final it in ins.items) {
    final k = m.porItem[it.id];
    final w = math.max(0.0, it.peso);
    if (k != null) aplicables++;
    if (k == null || k < 0) continue;
    if (it.desarrollo) {
      final p = math.min(w, k / 2);
      obtenidos += p;
      if (p >= w) correctas++;
    } else if (k == it.clave) {
      obtenidos += w;
      correctas++;
    }
  }
  final prop = total <= 0 ? 0.0 : obtenidos / total;
  return Resultado(
    aplicables: aplicables,
    total: ins.items.length,
    logrados: correctas,
    proporcion: prop,
    nivelMedio: prop,
    puntos: obtenidos,
    posibles: total,
  );
}

/// Convierte respuestas escritas de corrido («ABDC VF-B») en marcas: una
/// letra por pregunta objetiva, en orden; «-» o «.» = no respondió. Las
/// preguntas de desarrollo se saltan y conservan su marca.
Map<String, int> respuestasRapidas(
  Instrumento ins,
  String texto,
  Map<String, int> actuales,
) {
  final letras = texto
      .toUpperCase()
      .replaceAll(RegExp(r'[\s,;]'), '')
      .split('');
  final r = {...actuales};
  var j = 0;
  for (final it in ins.items) {
    if (it.desarrollo) continue;
    if (j >= letras.length) break;
    final l = letras[j++];
    if (l == '-' || l == '.' || l == '_') {
      r[it.id] = marcaNoObservado;
      continue;
    }
    final k = it.letras.indexOf(l);
    if (k >= 0) r[it.id] = k;
  }
  return r;
}

String _numTxt(double n) => n == n.roundToDouble()
    ? n.round().toString()
    : n.toStringAsFixed(1).replaceAll('.', ',');

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
  int decimales = 0,
  Redondeo redondeo = Redondeo.normal,
}) {
  if (e.numerica) {
    final lo = e.minimo ?? 0, hi = e.maximo ?? 20;
    final n = lo + r.proporcion * (hi - lo);
    return numeroGuardado(redondear(n, decimales, redondeo), decimales);
  }
  final k = e.valores.length;
  if (k == 0) return '';
  if ((ins.tipo == TipoInstrumento.rubrica ||
          ins.tipo == TipoInstrumento.escala) &&
      ins.escala.length == k) {
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
  if (ins.tipo == TipoInstrumento.prueba) {
    final sin = r.total - r.aplicables;
    return '${_numTxt(r.puntos)} de ${_numTxt(r.posibles)} puntos · '
        '${r.logrados} correctas · $pct'
        '${sin > 0 ? ' · $sin sin marcar' : ''}';
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


// ───────────────────────────── Carpetas ─────────────────────────────

/// Carpeta de la biblioteca del docente («Cuadernos», «Exposiciones»…).
class Carpeta {
  final String id;
  final String nombre;
  final int color;
  const Carpeta(this.id, this.nombre, this.color);

  Carpeta copiar({String? nombre, int? color}) =>
      Carpeta(id, nombre ?? this.nombre, color ?? this.color);

  Map<String, dynamic> aJson() => {'id': id, 'nombre': nombre, 'color': color};

  factory Carpeta.deJson(Map<String, dynamic> j) => Carpeta(
    j['id'] as String,
    j['nombre'] as String? ?? '',
    (j['color'] as num?)?.toInt() ?? coloresCarpeta.first,
  );

  static List<Carpeta> listaDeJson(String? v) {
    if (v == null || v.isEmpty) return [];
    try {
      return [
        for (final x in jsonDecode(v) as List)
          Carpeta.deJson(x as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  static String listaAJson(List<Carpeta> l) =>
      jsonEncode([for (final c in l) c.aJson()]);
}

const coloresCarpeta = [
  0xFF4F5BD5,
  0xFF16A37F,
  0xFFF07A2D,
  0xFFE5508E,
  0xFF3D7BF0,
  0xFF8B5CF6,
  0xFFB86E00,
  0xFF6E6A80,
];

/// Las carpetas con las que empieza la biblioteca, con las palabras que
/// sirven para acomodar cada instrumento en su lugar.
const carpetasIniciales = [
  (Carpeta('cuadernos', 'Cuadernos y tareas', 0xFF3D7BF0), ['cuaderno', 'tarea', 'revision']),
  (Carpeta('exposiciones', 'Exposiciones', 0xFFF07A2D), ['exposicion', 'oral', 'debate', 'presentacion', 'comunica oralmente']),
  (Carpeta('trabajos', 'Trabajos y proyectos', 0xFF16A37F), ['proyecto', 'trabajo', 'informe', 'ensayo', 'laboratorio', 'indagacion', 'producto', 'mapa', 'organizador', 'texto', 'prototipo', 'situacion']),
  (Carpeta('examenes', 'Exámenes', 0xFF8B5CF6), ['examen', 'practica', 'control', 'quiz', 'prueba']),
  (Carpeta('actitudes', 'Actitudes', 0xFFE5508E), ['actitud', 'participacion', 'convivencia', 'coevaluacion', 'autoevaluacion', 'metacognicion', 'caritas', 'seguridad']),
];

String _sinTildes(String s) {
  const de = 'áéíóúüñÁÉÍÓÚÜÑ', a = 'aeiouunAEIOUUN';
  var r = s;
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i], a[i]);
  }
  return r.toLowerCase();
}

/// Carpeta donde conviene guardar un instrumento según su nombre y tipo, o
/// '' si no encaja en ninguna. Solo propone carpetas que existen.
String carpetaSugerida(Instrumento i, List<Carpeta> carpetas) {
  final ids = {for (final c in carpetas) c.id};
  if (i.tipo == TipoInstrumento.prueba && ids.contains('examenes')) {
    return 'examenes';
  }
  final texto = _sinTildes('${i.nombre} ${i.descripcion}');
  for (final (c, palabras) in carpetasIniciales) {
    if (!ids.contains(c.id)) continue;
    if (palabras.any(texto.contains)) return c.id;
  }
  // También por el nombre de una carpeta creada por el docente.
  for (final c in carpetas) {
    final n = _sinTildes(c.nombre);
    if (n.length >= 4 && texto.contains(n)) return c.id;
  }
  return '';
}
