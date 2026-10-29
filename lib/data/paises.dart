/// Lo que cambia de un país a otro al crear colegios y cursos. Por ahora solo
/// Perú; para sumar un país basta con agregar su ficha a [paises].
class Pais {
  final String codigo;
  final String nombre;
  final String bandera;
  final String curriculo;

  /// Grados de cada nivel, en orden.
  final Map<String, List<String>> grados;

  /// Áreas curriculares de cada nivel. "Otro" se agrega al final al mostrarlas.
  final Map<String, List<String>> areas;

  /// Cómo se divide el año escolar: bimestre, trimestre o semestre.
  final String periodo;

  /// Escalas de calificación que vienen listas; la primera es la de por defecto.
  final List<Escala> escalas;

  /// Feriados nacionales de fecha fija: (mes, día, nombre).
  final List<(int, int, String)> feriados;

  /// Si Jueves y Viernes Santo son feriado.
  final bool semanaSanta;

  const Pais({
    required this.codigo,
    required this.nombre,
    required this.bandera,
    required this.curriculo,
    required this.grados,
    required this.areas,
    required this.periodo,
    required this.escalas,
    this.feriados = const [],
    this.semanaSanta = false,
  });

  /// Feriados de [anio] como 'yyyy-MM-dd' → nombre.
  Map<String, String> feriadosDe(int anio) {
    String clave(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    final r = {
      for (final (m, d, n) in feriados) clave(DateTime(anio, m, d)): n,
    };
    if (semanaSanta) {
      final pascua = _pascua(anio);
      r[clave(pascua.subtract(const Duration(days: 3)))] = 'Jueves Santo';
      r[clave(pascua.subtract(const Duration(days: 2)))] = 'Viernes Santo';
    }
    return r;
  }
}

/// Domingo de Pascua (algoritmo de Meeus/Butcher).
DateTime _pascua(int y) {
  final a = y % 19, b = y ~/ 100, c = y % 100, d = b ~/ 4, e = b % 4;
  final f = (b + 8) ~/ 25, g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4, k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final mes = (h + l - 7 * m + 114) ~/ 31;
  final dia = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(y, mes, dia);
}

/// Un valor de una escala (AD, Logrado...) con su color. En escalas numéricas,
/// [desde] marca la nota mínima de ese tramo (18 a 20 = desde 18).
class ValorEscala {
  final String codigo;
  final String descripcion;
  final int color;
  final double? desde;

  const ValorEscala(this.codigo, this.descripcion, this.color, {this.desde});

  Map<String, dynamic> aJson() => {
    'codigo': codigo,
    'descripcion': descripcion,
    'color': color,
    if (desde != null) 'desde': desde,
  };

  factory ValorEscala.deJson(Map<String, dynamic> j) => ValorEscala(
    j['codigo'] as String,
    j['descripcion'] as String? ?? '',
    j['color'] as int,
    desde: (j['desde'] as num?)?.toDouble(),
  );
}

/// Escala de calificación: letras (AD/A/B/C, Logrado/No logrado) o numérica.
class Escala {
  final String id;
  final String nombre;
  final bool numerica;
  final double? minimo;
  final double? maximo;
  final double? aprueba;
  final List<ValorEscala> valores;

  const Escala({
    required this.id,
    required this.nombre,
    this.numerica = false,
    this.minimo,
    this.maximo,
    this.aprueba,
    required this.valores,
  });

  Map<String, dynamic> aJson() => {
    'id': id,
    'nombre': nombre,
    'numerica': numerica,
    'minimo': minimo,
    'maximo': maximo,
    'aprueba': aprueba,
    'valores': [for (final v in valores) v.aJson()],
  };

  factory Escala.deJson(Map<String, dynamic> j) => Escala(
    id: j['id'] as String,
    nombre: j['nombre'] as String,
    numerica: j['numerica'] as bool? ?? false,
    minimo: (j['minimo'] as num?)?.toDouble(),
    maximo: (j['maximo'] as num?)?.toDouble(),
    aprueba: (j['aprueba'] as num?)?.toDouble(),
    valores: [
      for (final v in j['valores'] as List)
        ValorEscala.deJson(v as Map<String, dynamic>),
    ],
  );
}

// Colores de logro: destacado, esperado, en proceso, en inicio.
const _destacado = 0xFF5B4BD6;
const _esperado = 0xFF2557C7;
const _proceso = 0xFFB86E00;
const _inicio = 0xFFC2334A;
const _logrado = 0xFF0E7A5F;

/// "Otro" deja escribir lo que no está en la lista (área o sección).
const opcionOtro = 'Otro';

/// "Otro" deja escribir la sección (hay colegios con muchas secciones).
const secciones = ['Única', 'A', 'B', 'C', 'D', 'E', 'F', 'G', opcionOtro];

const peru = Pais(
  codigo: 'PE',
  nombre: 'Perú',
  bandera: '🇵🇪',
  curriculo: 'Currículo Nacional de Perú',
  grados: {
    'Inicial': ['3 años', '4 años', '5 años'],
    'Primaria': [
      '1.° grado',
      '2.° grado',
      '3.° grado',
      '4.° grado',
      '5.° grado',
      '6.° grado',
    ],
    'Secundaria': ['1.° año', '2.° año', '3.° año', '4.° año', '5.° año'],
  },
  // Currículo Nacional de la Educación Básica (CNEB, Minedu).
  areas: {
    'Inicial': [
      'Personal Social',
      'Psicomotriz',
      'Comunicación',
      'Castellano como segunda lengua',
      'Matemática',
      'Ciencia y Tecnología',
      'Tutoría',
    ],
    'Primaria': [
      'Personal Social',
      'Educación Física',
      'Comunicación',
      'Arte y Cultura',
      'Castellano como segunda lengua',
      'Inglés como lengua extranjera',
      'Matemática',
      'Ciencia y Tecnología',
      'Educación Religiosa',
      'Tutoría',
    ],
    'Secundaria': [
      'Desarrollo Personal, Ciudadanía y Cívica',
      'Ciencias Sociales',
      'Educación Física',
      'Comunicación',
      'Arte y Cultura',
      'Castellano como segunda lengua',
      'Inglés como lengua extranjera',
      'Matemática',
      'Ciencia y Tecnología',
      'Educación para el Trabajo',
      'Educación Religiosa',
      'Tutoría',
    ],
  },
  periodo: 'bimestre',
  semanaSanta: true,
  feriados: [
    (1, 1, 'Año Nuevo'),
    (5, 1, 'Día del Trabajo'),
    (6, 7, 'Batalla de Arica'),
    (6, 29, 'San Pedro y San Pablo'),
    (7, 23, 'Día de la Fuerza Aérea'),
    (7, 28, 'Fiestas Patrias'),
    (7, 29, 'Fiestas Patrias'),
    (8, 6, 'Batalla de Junín'),
    (8, 30, 'Santa Rosa de Lima'),
    (10, 8, 'Combate de Angamos'),
    (11, 1, 'Todos los Santos'),
    (12, 8, 'Inmaculada Concepción'),
    (12, 9, 'Batalla de Ayacucho'),
    (12, 25, 'Navidad'),
  ],
  escalas: [
    Escala(
      id: 'cneb',
      nombre: 'Letras CNEB',
      valores: [
        ValorEscala('AD', 'Logro destacado', _destacado),
        ValorEscala('A', 'Logro esperado', _esperado),
        ValorEscala('B', 'En proceso', _proceso),
        ValorEscala('C', 'En inicio', _inicio),
      ],
    ),
    Escala(
      id: 'vigesimal',
      nombre: 'Numérica 0 a 20',
      numerica: true,
      minimo: 0,
      maximo: 20,
      aprueba: 11,
      valores: [
        ValorEscala('18–20', 'Logro destacado', _destacado, desde: 18),
        ValorEscala('14–17', 'Logro esperado', _esperado, desde: 14),
        ValorEscala('11–13', 'En proceso', _proceso, desde: 11),
        ValorEscala('0–10', 'En inicio', _inicio, desde: 0),
      ],
    ),
    Escala(
      id: 'logrado',
      nombre: 'Logrado / No logrado',
      valores: [
        ValorEscala('Logrado', '', _logrado),
        ValorEscala('No logrado', '', _inicio),
      ],
    ),
  ],
);

const paises = [peru];

Pais paisPorCodigo(String? codigo) =>
    paises.firstWhere((p) => p.codigo == codigo, orElse: () => peru);
