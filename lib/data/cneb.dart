import 'instrumentos.dart';

/// Competencias del Currículo Nacional de la Educación Básica (Minedu) y la
/// colección de instrumentos para colegios de gestión pública: dos por
/// competencia y nivel (una rúbrica y una lista de cotejo o escala; en
/// Inicial, ficha de observación y escala).
///
/// Los instrumentos no dependen de la escala: la columna del registro decide
/// si la nota sale en letras (AD/A/B/C) o en números, por si cambian las
/// normas.

class Competencia {
  final String id;
  final String nombre;

  /// Nombre corto para tarjetas y PDF.
  final String corto;

  /// Área según el nivel: {'Primaria': 'Personal Social', …}.
  final Map<String, String> areas;
  final bool transversal;

  const Competencia(
    this.id,
    this.nombre,
    this.corto,
    this.areas, {
    this.transversal = false,
  });

  List<String> get niveles => [
    for (final n in nivelesEducativos)
      if (areas.containsKey(n)) n,
  ];
}

const _ps = 'Personal Social', _ef = 'Educación Física', _com = 'Comunicación';
const _ac = 'Arte y Cultura', _ing = 'Inglés como lengua extranjera';
const _mat = 'Matemática', _cyt = 'Ciencia y Tecnología';
const _rel = 'Educación Religiosa', _cs2 = 'Castellano como segunda lengua';
const _dpcc = 'Desarrollo Personal, Ciudadanía y Cívica';
const _ccss = 'Ciencias Sociales', _ept = 'Educación para el Trabajo';
const _tr = 'Competencias transversales';

const competenciasCneb = [
  Competencia('identidad', 'Construye su identidad', 'Construye su identidad', {
    'Inicial': _ps,
    'Primaria': _ps,
    'Secundaria': _dpcc,
  }),
  Competencia(
    'motricidad',
    'Se desenvuelve de manera autónoma a través de su motricidad',
    'Se desenvuelve con su motricidad',
    {'Inicial': 'Psicomotriz', 'Primaria': _ef, 'Secundaria': _ef},
  ),
  Competencia('saludable', 'Asume una vida saludable', 'Asume una vida saludable', {
    'Primaria': _ef,
    'Secundaria': _ef,
  }),
  Competencia(
    'sociomotriz',
    'Interactúa a través de sus habilidades sociomotrices',
    'Habilidades sociomotrices',
    {'Primaria': _ef, 'Secundaria': _ef},
  ),
  Competencia(
    'aprecia',
    'Aprecia de manera crítica manifestaciones artístico-culturales',
    'Aprecia manifestaciones artísticas',
    {'Primaria': _ac, 'Secundaria': _ac},
  ),
  Competencia(
    'crea',
    'Crea proyectos desde los lenguajes artísticos',
    'Crea proyectos artísticos',
    {'Inicial': _com, 'Primaria': _ac, 'Secundaria': _ac},
  ),
  Competencia(
    'oral',
    'Se comunica oralmente en su lengua materna',
    'Se comunica oralmente',
    {'Inicial': _com, 'Primaria': _com, 'Secundaria': _com},
  ),
  Competencia(
    'lee',
    'Lee diversos tipos de textos escritos en su lengua materna',
    'Lee diversos tipos de textos',
    {'Inicial': _com, 'Primaria': _com, 'Secundaria': _com},
  ),
  Competencia(
    'escribe',
    'Escribe diversos tipos de textos en su lengua materna',
    'Escribe diversos tipos de textos',
    {'Inicial': _com, 'Primaria': _com, 'Secundaria': _com},
  ),
  Competencia(
    'oral-l2',
    'Se comunica oralmente en castellano como segunda lengua',
    'Se comunica oralmente en castellano (L2)',
    {'Inicial': _cs2, 'Primaria': _cs2, 'Secundaria': _cs2},
  ),
  Competencia(
    'oral-ing',
    'Se comunica oralmente en inglés como lengua extranjera',
    'Se comunica oralmente en inglés',
    {'Primaria': _ing, 'Secundaria': _ing},
  ),
  Competencia(
    'lee-ing',
    'Lee diversos tipos de textos escritos en inglés como lengua extranjera',
    'Lee textos en inglés',
    {'Primaria': _ing, 'Secundaria': _ing},
  ),
  Competencia(
    'escribe-ing',
    'Escribe diversos tipos de textos en inglés como lengua extranjera',
    'Escribe textos en inglés',
    {'Primaria': _ing, 'Secundaria': _ing},
  ),
  Competencia(
    'convive',
    'Convive y participa democráticamente en la búsqueda del bien común',
    'Convive y participa democráticamente',
    {'Inicial': _ps, 'Primaria': _ps, 'Secundaria': _dpcc},
  ),
  Competencia(
    'historia',
    'Construye interpretaciones históricas',
    'Construye interpretaciones históricas',
    {'Primaria': _ps, 'Secundaria': _ccss},
  ),
  Competencia(
    'ambiente',
    'Gestiona responsablemente el espacio y el ambiente',
    'Gestiona el espacio y el ambiente',
    {'Primaria': _ps, 'Secundaria': _ccss},
  ),
  Competencia(
    'economia',
    'Gestiona responsablemente los recursos económicos',
    'Gestiona los recursos económicos',
    {'Primaria': _ps, 'Secundaria': _ccss},
  ),
  Competencia(
    'indaga',
    'Indaga mediante métodos científicos para construir sus conocimientos',
    'Indaga mediante métodos científicos',
    {'Inicial': _cyt, 'Primaria': _cyt, 'Secundaria': _cyt},
  ),
  Competencia(
    'explica',
    'Explica el mundo físico basándose en conocimientos sobre los seres vivos, '
        'materia y energía, biodiversidad, Tierra y universo',
    'Explica el mundo físico',
    {'Primaria': _cyt, 'Secundaria': _cyt},
  ),
  Competencia(
    'disena',
    'Diseña y construye soluciones tecnológicas para resolver problemas de su '
        'entorno',
    'Diseña soluciones tecnológicas',
    {'Primaria': _cyt, 'Secundaria': _cyt},
  ),
  Competencia(
    'cantidad',
    'Resuelve problemas de cantidad',
    'Resuelve problemas de cantidad',
    {'Inicial': _mat, 'Primaria': _mat, 'Secundaria': _mat},
  ),
  Competencia(
    'regularidad',
    'Resuelve problemas de regularidad, equivalencia y cambio',
    'Regularidad, equivalencia y cambio',
    {'Primaria': _mat, 'Secundaria': _mat},
  ),
  Competencia(
    'forma',
    'Resuelve problemas de forma, movimiento y localización',
    'Forma, movimiento y localización',
    {'Inicial': _mat, 'Primaria': _mat, 'Secundaria': _mat},
  ),
  Competencia(
    'datos',
    'Resuelve problemas de gestión de datos e incertidumbre',
    'Gestión de datos e incertidumbre',
    {'Primaria': _mat, 'Secundaria': _mat},
  ),
  Competencia(
    'emprende',
    'Gestiona proyectos de emprendimiento económico o social',
    'Gestiona proyectos de emprendimiento',
    {'Secundaria': _ept},
  ),
  Competencia(
    'fe-identidad',
    'Construye su identidad como persona humana, amada por Dios, digna, libre '
        'y trascendente',
    'Identidad como persona amada por Dios',
    {'Inicial': _ps, 'Primaria': _rel, 'Secundaria': _rel},
  ),
  Competencia(
    'fe-encuentro',
    'Asume la experiencia del encuentro personal y comunitario con Dios en su '
        'proyecto de vida',
    'Encuentro personal y comunitario con Dios',
    {'Primaria': _rel, 'Secundaria': _rel},
  ),
  Competencia(
    'tic',
    'Se desenvuelve en entornos virtuales generados por las TIC',
    'Entornos virtuales (TIC)',
    {'Primaria': _tr, 'Secundaria': _tr},
    transversal: true,
  ),
  Competencia(
    'autonomo',
    'Gestiona su aprendizaje de manera autónoma',
    'Gestiona su aprendizaje',
    {'Primaria': _tr, 'Secundaria': _tr},
    transversal: true,
  ),
];

Competencia? competenciaPorId(String id) {
  for (final c in competenciasCneb) {
    if (c.id == id) return c;
  }
  return null;
}

/// Orden de las áreas para agrupar en pantalla.
const ordenAreas = [
  _ps,
  'Psicomotriz',
  _dpcc,
  _ccss,
  _ef,
  _com,
  _cs2,
  _ac,
  _ing,
  _mat,
  _cyt,
  _ept,
  _rel,
  _tr,
];

// ───────────────────────── Contenido ─────────────────────────

/// Una capacidad (o aspecto) que se evalúa: el criterio, lo que hace el
/// estudiante cuando lo logra y lo que suma en el logro destacado.
class _Cap {
  final String criterio;
  final String hace;
  final String mas;
  const _Cap(this.criterio, this.hace, this.mas);
}

enum _Segundo { cotejo, escala }

class _Def {
  final String comp;
  final String nivel;

  /// Situación o producto donde se recoge la evidencia.
  final String evidencia;
  final List<_Cap> caps;
  final _Segundo segundo;

  /// Ítems que se suman en la lista de cotejo o escala.
  final List<String> extra;
  const _Def(
    this.comp,
    this.nivel,
    this.evidencia,
    this.caps, {
    this.segundo = _Segundo.cotejo,
    this.extra = const [],
  });
}

const _i = 'Inicial', _p = 'Primaria', _s = 'Secundaria';

const _defs = <_Def>[
  // ═══════════════════════════ INICIAL ═══════════════════════════
  _Def('identidad', _i, 'Juego libre y rutinas del aula', [
    _Cap('Se valora a sí mismo', 'Reconoce sus características, gustos y lo que puede hacer', 'lo comparte con seguridad ante el grupo'),
    _Cap('Autorregula sus emociones', 'Expresa lo que siente y busca ayuda cuando lo necesita', 'propone formas de calmarse'),
    _Cap('Toma decisiones', 'Elige actividades y materiales por iniciativa propia', 'explica por qué los eligió'),
  ], segundo: _Segundo.escala),
  _Def('convive', _i, 'Juego en sectores y asamblea', [
    _Cap('Interactúa con los demás', 'Juega y comparte con sus compañeros', 'invita a otros a jugar'),
    _Cap('Construye normas', 'Respeta los acuerdos del aula', 'recuerda los acuerdos a sus compañeros'),
    _Cap('Participa en el grupo', 'Participa en las actividades del grupo y propone ideas', 'ayuda a organizar la actividad'),
    _Cap('Resuelve conflictos', 'Busca resolver los conflictos dialogando', 'propone soluciones que todos aceptan'),
  ]),
  _Def('fe-identidad', _i, 'Momentos de oración y celebración', [
    _Cap('Reconoce el amor de Dios', 'Expresa con gestos o palabras que es amado por Dios', 'lo relaciona con su familia y amigos'),
    _Cap('Agradece', 'Agradece por la vida, la naturaleza y su familia', 'invita a otros a agradecer'),
    _Cap('Muestra amor al prójimo', 'Muestra gestos de cariño y respeto hacia los demás', 'lo hace sin que se lo pidan'),
  ], segundo: _Segundo.escala),
  _Def('motricidad', _i, 'Sesión de psicomotricidad', [
    _Cap('Coordinación', 'Corre, salta y trepa con coordinación', 'combina movimientos en un circuito'),
    _Cap('Equilibrio', 'Mantiene el equilibrio en diferentes posturas', 'lo mantiene en superficies angostas'),
    _Cap('Conciencia corporal', 'Reconoce y nombra las partes de su cuerpo', 'explica para qué sirve cada una'),
    _Cap('Coordinación fina', 'Manipula objetos pequeños con precisión', 'usa tijeras o pinzas con seguridad'),
  ]),
  _Def('oral', _i, 'Asamblea y conversaciones del aula', [
    _Cap('Expresa sus ideas', 'Expresa sus ideas y necesidades con claridad', 'usa palabras nuevas que aprendió'),
    _Cap('Comprende lo que escucha', 'Responde preguntas sobre lo que escucha', 'hace preguntas sobre lo escuchado'),
    _Cap('Narra en orden', 'Narra experiencias siguiendo un orden', 'agrega detalles que hacen interesante su relato'),
    _Cap('Escucha a los demás', 'Escucha y espera su turno para hablar', 'responde a lo que dijo un compañero'),
  ], segundo: _Segundo.escala),
  _Def('lee', _i, 'Lectura de cuentos e imágenes', [
    _Cap('Obtiene información', 'Describe las imágenes y personajes del texto', 'señala detalles que otros no vieron'),
    _Cap('Infiere', 'Anticipa de qué tratará el texto por el título y las imágenes', 'explica en qué se basó'),
    _Cap('Opina', 'Dice lo que le gustó o no del texto', 'explica por qué'),
  ]),
  _Def('escribe', _i, 'Escritura espontánea (lista, mensaje, nombre)', [
    _Cap('Escribe a su manera', 'Escribe usando grafismos o letras', 'escribe su nombre de forma reconocible'),
    _Cap('Escribe con propósito', 'Escribe con un propósito: una lista, un mensaje, un cartel', 'elige a quién va dirigido'),
    _Cap('Explica lo que escribió', 'Explica lo que quiso escribir', 'señala con el dedo mientras lee'),
  ]),
  _Def('crea', _i, 'Taller de arte, música o danza', [
    _Cap('Explora', 'Explora materiales, colores y sonidos', 'combina materiales de forma original'),
    _Cap('Crea', 'Crea dibujos, modelados o movimientos con libertad', 'crea a partir de una historia o experiencia'),
    _Cap('Comunica', 'Cuenta lo que creó y cómo lo hizo', 'muestra su trabajo con orgullo a otros'),
  ], segundo: _Segundo.escala),
  _Def('oral-l2', _i, 'Juegos y canciones en castellano', [
    _Cap('Comprende', 'Comprende indicaciones sencillas en castellano', 'responde con acciones sin ayuda'),
    _Cap('Se expresa', 'Usa palabras y frases cortas en castellano', 'las usa en el juego con sus compañeros'),
    _Cap('Interactúa', 'Participa en canciones y juegos en castellano', 'propone una canción o juego'),
  ], segundo: _Segundo.escala),
  _Def('cantidad', _i, 'Juego con material concreto', [
    _Cap('Agrupa', 'Agrupa objetos según una característica', 'explica el criterio que usó'),
    _Cap('Compara', 'Compara cantidades usando "muchos", "pocos", "más que"', 'ordena tres grupos de menor a mayor'),
    _Cap('Cuenta', 'Cuenta objetos hasta 10', 'cuenta más allá de 10'),
    _Cap('Explica', 'Dice cómo lo hizo', 'enseña a un compañero'),
  ]),
  _Def('forma', _i, 'Juegos de recorridos y construcción', [
    _Cap('Se ubica en el espacio', 'Ubica objetos usando arriba, abajo, delante, detrás', 'da indicaciones a otros'),
    _Cap('Reconoce formas', 'Reconoce formas en objetos de su entorno', 'construye con ellas'),
    _Cap('Sigue recorridos', 'Sigue y describe recorridos sencillos', 'representa el recorrido con un dibujo'),
  ]),
  _Def('indaga', _i, 'Exploración de la naturaleza', [
    _Cap('Pregunta', 'Hace preguntas sobre lo que observa', 'propone cómo averiguarlo'),
    _Cap('Predice', 'Dice qué cree que pasará', 'explica por qué lo cree'),
    _Cap('Explora y registra', 'Explora y registra lo que descubre con dibujos', 'compara lo que pensó con lo que pasó'),
    _Cap('Comunica', 'Cuenta lo que descubrió', 'usa su registro al explicarlo'),
  ], segundo: _Segundo.escala),

  // ═══════════════════════════ PRIMARIA ═══════════════════════════
  _Def('identidad', _p, 'Dinámicas, diálogos y situaciones del aula', [
    _Cap('Se valora a sí mismo', 'Describe sus características, logros y lo que le gustaría mejorar', 'se propone metas concretas'),
    _Cap('Autorregula sus emociones', 'Reconoce sus emociones y las expresa de forma adecuada', 'usa estrategias para calmarse'),
    _Cap('Reflexiona y argumenta éticamente', 'Explica por qué una acción es correcta o incorrecta', 'considera cómo afecta a los demás'),
    _Cap('Vive su sexualidad de manera responsable', 'Reconoce situaciones de riesgo y pide ayuda a un adulto de confianza', 'explica cómo protegerse'),
  ], segundo: _Segundo.escala),
  _Def('convive', _p, 'Asamblea de aula y trabajo en equipo', [
    _Cap('Interactúa con todos', 'Trata con respeto a todos sus compañeros', 'incluye a quienes están solos'),
    _Cap('Construye normas', 'Propone y cumple acuerdos de convivencia', 'evalúa si los acuerdos funcionan'),
    _Cap('Maneja conflictos', 'Resuelve conflictos mediante el diálogo', 'ayuda a otros a resolverlos'),
    _Cap('Delibera', 'Da su opinión sobre asuntos públicos con argumentos', 'escucha y considera otras opiniones'),
    _Cap('Participa por el bien común', 'Participa en acciones que benefician a todos', 'propone una acción para el aula o la escuela'),
  ]),
  _Def('historia', _p, 'Línea de tiempo o análisis de fuentes', [
    _Cap('Interpreta fuentes', 'Obtiene información de fuentes como fotos, objetos y relatos', 'distingue entre fuentes diferentes'),
    _Cap('Comprende el tiempo histórico', 'Ordena hechos en una línea de tiempo', 'usa décadas y siglos'),
    _Cap('Explica procesos históricos', 'Explica causas y consecuencias de un hecho histórico', 'lo relaciona con el presente'),
  ]),
  _Def('ambiente', _p, 'Croquis, salida de campo o proyecto ambiental', [
    _Cap('Comprende el espacio', 'Describe los elementos naturales y sociales de su localidad', 'explica cómo se relacionan'),
    _Cap('Maneja fuentes', 'Usa planos, croquis y mapas para ubicarse', 'elabora su propio croquis'),
    _Cap('Genera acciones', 'Propone acciones para cuidar el ambiente y prevenir riesgos', 'las practica en casa y en la escuela'),
  ]),
  _Def('economia', _p, 'Proyecto de ahorro o consumo responsable', [
    _Cap('Comprende el sistema económico', 'Explica de dónde vienen los productos que consume', 'reconoce el trabajo que hay detrás'),
    _Cap('Toma decisiones económicas', 'Distingue entre lo que necesita y lo que desea', 'elabora un presupuesto sencillo'),
  ]),
  _Def('motricidad', _p, 'Circuito motor o juego dirigido', [
    _Cap('Comprende su cuerpo', 'Reconoce las partes de su cuerpo y su lateralidad en el movimiento', 'ajusta sus movimientos con precisión'),
    _Cap('Coordinación', 'Coordina movimientos al correr, saltar y lanzar', 'los combina con fluidez'),
    _Cap('Se expresa corporalmente', 'Expresa ideas y emociones con su cuerpo', 'crea secuencias de movimiento'),
  ]),
  _Def('saludable', _p, 'Rutina de actividad física e higiene', [
    _Cap('Comprende la salud', 'Explica la importancia de la alimentación y la actividad física', 'da ejemplos de su vida diaria'),
    _Cap('Practica hábitos saludables', 'Realiza calentamiento, hidratación e higiene', 'motiva a otros a practicarlos'),
  ], segundo: _Segundo.escala, extra: ['Trae su útil de aseo', 'Elige alimentos saludables en el recreo']),
  _Def('sociomotriz', _p, 'Juegos cooperativos y de oposición', [
    _Cap('Se relaciona', 'Juega respetando las reglas y a sus compañeros', 'acepta la derrota con calma'),
    _Cap('Crea estrategias', 'Propone estrategias sencillas en el juego', 'adapta la estrategia según el juego'),
  ], segundo: _Segundo.escala),
  _Def('oral', _p, 'Exposición, diálogo o debate', [
    _Cap('Obtiene información', 'Recupera información explícita de lo que escucha', 'distingue lo importante de lo secundario'),
    _Cap('Infiere e interpreta', 'Deduce el propósito y las intenciones de quien habla', 'explica el sentido de expresiones figuradas'),
    _Cap('Adecúa y organiza sus ideas', 'Expresa sus ideas de forma ordenada y adecuada al público', 'usa conectores variados'),
    _Cap('Usa recursos no verbales', 'Acompaña lo que dice con gestos, volumen y mirada', 'usa el tono para enfatizar'),
    _Cap('Interactúa', 'Participa respetando turnos y opiniones', 'retoma lo que dijeron otros'),
  ], segundo: _Segundo.escala),
  _Def('lee', _p, 'Lectura de un cuento, noticia o texto informativo', [
    _Cap('Obtiene información', 'Identifica información explícita del texto', 'la ubica en textos largos'),
    _Cap('Infiere', 'Deduce el tema, la idea principal y el significado de palabras por el contexto', 'explica las relaciones de causa y efecto'),
    _Cap('Reflexiona y evalúa', 'Opina sobre el contenido del texto con argumentos', 'compara el texto con otros que leyó'),
  ]),
  _Def('escribe', _p, 'Producción de un texto (cuento, carta, afiche)', [
    _Cap('Adecúa el texto', 'Escribe de acuerdo al propósito, destinatario y tipo de texto', 'elige un registro adecuado'),
    _Cap('Organiza las ideas', 'Organiza sus ideas en párrafos con coherencia', 'mantiene el tema de principio a fin'),
    _Cap('Usa las convenciones', 'Usa conectores, ortografía y puntuación adecuados', 'casi no comete errores'),
    _Cap('Revisa su texto', 'Revisa y corrige su texto', 'mejora su texto a partir de comentarios'),
  ]),
  _Def('aprecia', _p, 'Observación de una obra o manifestación cultural', [
    _Cap('Percibe', 'Describe lo que ve, escucha y siente ante una obra', 'nota detalles de forma y color'),
    _Cap('Contextualiza', 'Relaciona la obra con su cultura y su comunidad', 'investiga su origen'),
    _Cap('Reflexiona', 'Opina sobre la obra con argumentos', 'compara obras de distintas culturas'),
  ], segundo: _Segundo.escala),
  _Def('crea', _p, 'Proyecto artístico (dibujo, música, teatro, danza)', [
    _Cap('Explora y experimenta', 'Explora materiales y técnicas artísticas', 'combina técnicas de forma original'),
    _Cap('Aplica procesos creativos', 'Planifica y crea su trabajo artístico', 'mejora su obra a partir de pruebas'),
    _Cap('Evalúa y comunica', 'Presenta su trabajo y explica sus decisiones', 'recibe y da comentarios con respeto'),
  ]),
  _Def('oral-l2', _p, 'Diálogos y juegos de roles en castellano', [
    _Cap('Comprende', 'Comprende textos orales sencillos en castellano', 'responde a preguntas sobre ellos'),
    _Cap('Se expresa', 'Expresa ideas con frases completas en castellano', 'usa vocabulario variado'),
    _Cap('Interactúa', 'Conversa con otros en castellano sobre temas cotidianos', 'mantiene la conversación'),
  ], segundo: _Segundo.escala),
  _Def('oral-ing', _p, 'Juego de roles o diálogo breve', [
    _Cap('Comprende', 'Comprende instrucciones y frases sencillas en inglés', 'responde sin necesidad de gestos'),
    _Cap('Se expresa', 'Se presenta y responde preguntas en inglés', 'usa frases completas'),
    _Cap('Pronunciación', 'Pronuncia de forma comprensible', 'cuida la entonación'),
  ], segundo: _Segundo.escala),
  _Def('lee-ing', _p, 'Lectura de un texto breve en inglés', [
    _Cap('Obtiene información', 'Identifica palabras y datos en un texto breve en inglés', 'ubica información en textos más largos'),
    _Cap('Infiere', 'Deduce el tema con ayuda de imágenes', 'deduce el significado de palabras nuevas'),
  ]),
  _Def('escribe-ing', _p, 'Producción de un texto corto en inglés', [
    _Cap('Adecúa el texto', 'Escribe oraciones sencillas en inglés sobre sí mismo', 'escribe un párrafo corto'),
    _Cap('Usa las convenciones', 'Usa mayúsculas, punto y vocabulario conocido', 'casi no comete errores'),
  ]),
  _Def('cantidad', _p, 'Resolución de problemas aritméticos', [
    _Cap('Traduce cantidades', 'Representa el problema con material, dibujos u operaciones', 'propone más de una forma'),
    _Cap('Comunica su comprensión', 'Expresa con lenguaje matemático lo que entiende de números y operaciones', 'usa ejemplos propios'),
    _Cap('Usa estrategias', 'Emplea estrategias de cálculo y estimación', 'elige la estrategia más eficaz'),
    _Cap('Argumenta', 'Justifica su procedimiento y su respuesta', 'detecta y corrige errores'),
  ]),
  _Def('regularidad', _p, 'Problemas con patrones e igualdades', [
    _Cap('Traduce datos', 'Representa patrones y equivalencias con material o símbolos', 'crea sus propios patrones'),
    _Cap('Comunica su comprensión', 'Describe la regla de un patrón', 'predice términos lejanos'),
    _Cap('Usa estrategias', 'Usa estrategias para encontrar valores desconocidos', 'comprueba su resultado'),
    _Cap('Argumenta', 'Explica por qué una igualdad se mantiene', 'da contraejemplos'),
  ]),
  _Def('forma', _p, 'Problemas de geometría y ubicación', [
    _Cap('Modela objetos', 'Relaciona objetos del entorno con formas geométricas', 'construye modelos'),
    _Cap('Comunica su comprensión', 'Describe propiedades de figuras y cuerpos', 'usa el vocabulario geométrico adecuado'),
    _Cap('Usa estrategias', 'Mide y estima longitudes, superficies o recorridos', 'elige la unidad adecuada'),
    _Cap('Argumenta', 'Explica sus afirmaciones sobre formas y medidas', 'las prueba con ejemplos'),
  ]),
  _Def('datos', _p, 'Encuesta, tabla o gráfico', [
    _Cap('Representa datos', 'Organiza datos en tablas y gráficos de barras', 'elige el gráfico más adecuado'),
    _Cap('Comunica su comprensión', 'Lee e interpreta la información de tablas y gráficos', 'saca conclusiones'),
    _Cap('Usa estrategias', 'Recoge datos con encuestas o registros', 'formula sus propias preguntas'),
    _Cap('Sustenta conclusiones', 'Explica sus conclusiones con los datos', 'predice lo que podría pasar'),
  ]),
  _Def('indaga', _p, 'Experimento o indagación guiada', [
    _Cap('Problematiza', 'Formula preguntas e hipótesis sobre un fenómeno', 'identifica qué va a medir'),
    _Cap('Diseña estrategias', 'Propone pasos y materiales para comprobar su hipótesis', 'considera medidas de seguridad'),
    _Cap('Genera y registra datos', 'Registra datos en tablas o dibujos', 'repite mediciones'),
    _Cap('Analiza datos', 'Compara los datos con su hipótesis y concluye', 'explica con conocimientos científicos'),
    _Cap('Evalúa y comunica', 'Comunica el proceso y sus conclusiones', 'propone mejoras'),
  ]),
  _Def('explica', _p, 'Explicación oral o escrita de un fenómeno', [
    _Cap('Comprende y usa conocimientos', 'Explica fenómenos usando conocimientos científicos', 'da ejemplos de su entorno'),
    _Cap('Evalúa implicancias', 'Opina sobre el impacto de la ciencia en la vida diaria', 'argumenta con evidencias'),
  ]),
  _Def('disena', _p, 'Prototipo o maqueta', [
    _Cap('Determina la alternativa de solución', 'Describe el problema y propone una solución', 'considera varias opciones'),
    _Cap('Diseña', 'Dibuja su diseño con materiales y pasos', 'incluye medidas'),
    _Cap('Implementa y valida', 'Construye su prototipo y prueba si funciona', 'lo mejora tras las pruebas'),
    _Cap('Evalúa y comunica', 'Explica cómo funciona y sus limitaciones', 'propone mejoras'),
  ]),
  _Def('fe-identidad', _p, 'Reflexión sobre textos bíblicos y vivencias', [
    _Cap('Conoce a Dios', 'Reconoce el amor de Dios en la creación y en su vida', 'lo relaciona con su familia y comunidad'),
    _Cap('Cultiva su fe', 'Participa en celebraciones y oraciones', 'expresa su fe con sus palabras'),
    _Cap('Convive con respeto', 'Respeta las creencias de los demás', 'promueve el diálogo'),
  ], segundo: _Segundo.escala),
  _Def('fe-encuentro', _p, 'Compromiso personal o comunitario', [
    _Cap('Transforma su entorno', 'Realiza acciones de servicio y solidaridad', 'invita a otros a participar'),
    _Cap('Actúa coherentemente', 'Actúa según los valores cristianos en el aula', 'reconoce cuándo debe mejorar'),
  ], segundo: _Segundo.escala),
  _Def('tic', _p, 'Trabajo con herramientas digitales', [
    _Cap('Personaliza entornos virtuales', 'Usa la computadora o tableta con autonomía', 'organiza sus archivos'),
    _Cap('Gestiona información', 'Busca y selecciona información en internet', 'verifica que la fuente sea confiable'),
    _Cap('Interactúa en entornos virtuales', 'Se comunica de forma respetuosa y segura en línea', 'protege sus datos personales'),
    _Cap('Crea objetos virtuales', 'Crea presentaciones, dibujos o textos digitales', 'combina distintos formatos'),
  ]),
  _Def('autonomo', _p, 'Al cerrar la unidad o un proyecto', [
    _Cap('Define metas', 'Se propone metas de aprendizaje', 'las escribe y las revisa'),
    _Cap('Organiza acciones', 'Organiza su tiempo y sus materiales para cumplir sus tareas', 'prioriza lo más importante'),
    _Cap('Monitorea y ajusta', 'Revisa su avance y pide ayuda cuando la necesita', 'cambia de estrategia si no funciona'),
  ], segundo: _Segundo.escala),

  // ══════════════════════════ SECUNDARIA ══════════════════════════
  _Def('identidad', _s, 'Proyecto de vida o caso para analizar', [
    _Cap('Se valora a sí mismo', 'Explica sus características, intereses y potencialidades', 'las vincula con su proyecto de vida'),
    _Cap('Autorregula sus emociones', 'Reconoce sus emociones y las maneja en situaciones difíciles', 'ayuda a otros a manejarlas'),
    _Cap('Reflexiona y argumenta éticamente', 'Argumenta su posición ante dilemas morales', 'considera principios éticos universales'),
    _Cap('Vive su sexualidad de manera integral y responsable', 'Explica la importancia de relaciones de respeto e igualdad', 'propone acciones para prevenir la violencia'),
  ]),
  _Def('convive', _s, 'Debate, asamblea o proyecto participativo', [
    _Cap('Interactúa con todas las personas', 'Se relaciona con respeto y rechaza la discriminación', 'defiende a quien es discriminado'),
    _Cap('Construye normas y asume acuerdos', 'Evalúa las normas de convivencia según los derechos', 'propone mejoras justificadas'),
    _Cap('Maneja conflictos', 'Usa el diálogo y la negociación para resolver conflictos', 'actúa como mediador'),
    _Cap('Delibera sobre asuntos públicos', 'Argumenta su posición sobre asuntos públicos con fuentes', 'evalúa las posturas contrarias'),
    _Cap('Participa por el bien común', 'Propone y ejecuta acciones colectivas por el bien común', 'evalúa su impacto'),
  ], segundo: _Segundo.escala),
  _Def('historia', _s, 'Ensayo o análisis de fuentes históricas', [
    _Cap('Interpreta críticamente fuentes', 'Contrasta fuentes diversas sobre un mismo hecho', 'evalúa su confiabilidad e intención'),
    _Cap('Comprende el tiempo histórico', 'Ubica procesos en el tiempo y reconoce cambios y permanencias', 'compara ritmos de cambio'),
    _Cap('Elabora explicaciones', 'Explica procesos históricos con causas y consecuencias múltiples', 'los relaciona con problemas actuales'),
  ]),
  _Def('ambiente', _s, 'Estudio de caso o proyecto ambiental', [
    _Cap('Comprende las relaciones', 'Explica cómo interactúan los elementos naturales y sociales', 'considera distintas escalas'),
    _Cap('Maneja fuentes', 'Usa mapas, gráficos y datos para analizar el espacio', 'elabora sus propios mapas'),
    _Cap('Genera acciones', 'Propone acciones para la gestión de riesgos y el desarrollo sostenible', 'las difunde en su comunidad'),
  ]),
  _Def('economia', _s, 'Análisis de caso o presupuesto', [
    _Cap('Comprende el sistema económico y financiero', 'Explica el rol del Estado, las empresas y las familias', 'analiza el efecto de las políticas económicas'),
    _Cap('Toma decisiones económicas', 'Elabora un presupuesto y toma decisiones de consumo responsable', 'considera derechos del consumidor y tributos'),
  ]),
  _Def('motricidad', _s, 'Secuencia o rutina de movimiento', [
    _Cap('Comprende su cuerpo', 'Ajusta sus movimientos con control y precisión', 'analiza su ejecución para mejorarla'),
    _Cap('Se expresa corporalmente', 'Crea secuencias de movimiento con ritmo y expresión', 'las presenta con creatividad'),
  ], extra: ['Calienta antes de la actividad', 'Respeta su ritmo y el de los demás']),
  _Def('saludable', _s, 'Plan personal de actividad física y alimentación', [
    _Cap('Comprende la salud', 'Explica la relación entre actividad física, alimentación y salud', 'usa datos de su propio cuerpo'),
    _Cap('Incorpora prácticas saludables', 'Elabora y sigue un plan de actividad física', 'evalúa su avance y lo ajusta'),
  ], segundo: _Segundo.escala, extra: ['Se hidrata durante la actividad', 'Respeta las normas de seguridad']),
  _Def('sociomotriz', _s, 'Deporte colectivo', [
    _Cap('Se relaciona con juego limpio', 'Practica el deporte respetando reglas y rivales', 'promueve el juego limpio'),
    _Cap('Crea y aplica estrategias', 'Aplica estrategias de ataque y defensa', 'las ajusta durante el juego'),
  ], segundo: _Segundo.escala),
  _Def('oral', _s, 'Exposición, debate o panel', [
    _Cap('Obtiene información', 'Recupera información relevante de textos orales', 'la organiza para usarla'),
    _Cap('Infiere e interpreta', 'Interpreta intenciones, ironías y puntos de vista', 'explica cómo se construyen'),
    _Cap('Adecúa, organiza y desarrolla', 'Desarrolla sus ideas con coherencia y adecuación', 'usa un vocabulario preciso y variado'),
    _Cap('Usa recursos no verbales y paraverbales', 'Usa la voz, los gestos y la mirada para reforzar su mensaje', 'los ajusta al público'),
    _Cap('Interactúa estratégicamente', 'Argumenta y contraargumenta respetando a los demás', 'integra las ideas de otros'),
    _Cap('Reflexiona y evalúa', 'Evalúa la validez de lo que escucha', 'detecta falacias'),
  ]),
  _Def('lee', _s, 'Lectura de un texto literario, argumentativo o expositivo', [
    _Cap('Obtiene información', 'Identifica información explícita relevante en textos complejos', 'integra datos de varias partes del texto'),
    _Cap('Infiere e interpreta', 'Deduce el tema, la tesis y el propósito del autor', 'interpreta el lenguaje figurado'),
    _Cap('Reflexiona y evalúa', 'Evalúa la forma, el contenido y el contexto del texto', 'contrasta con otras fuentes'),
  ]),
  _Def('escribe', _s, 'Producción de un ensayo, artículo o informe', [
    _Cap('Adecúa el texto', 'Adecúa el texto al propósito, destinatario y registro', 'elige el formato más eficaz'),
    _Cap('Organiza y desarrolla las ideas', 'Organiza las ideas con coherencia, cohesión y fuentes', 'desarrolla argumentos sólidos'),
    _Cap('Usa las convenciones', 'Usa recursos gramaticales y ortográficos con corrección', 'usa recursos estilísticos'),
    _Cap('Reflexiona y evalúa', 'Revisa y mejora su texto', 'explica sus decisiones de escritura'),
  ]),
  _Def('aprecia', _s, 'Crítica o análisis de una obra', [
    _Cap('Percibe', 'Analiza los elementos y principios de una obra', 'usa vocabulario técnico'),
    _Cap('Contextualiza', 'Relaciona la obra con su contexto histórico y cultural', 'compara épocas y culturas'),
    _Cap('Reflexiona críticamente', 'Emite un juicio fundamentado sobre la obra', 'considera otras interpretaciones'),
  ]),
  _Def('crea', _s, 'Proyecto artístico', [
    _Cap('Explora y experimenta', 'Experimenta con técnicas y lenguajes artísticos', 'los combina con intención'),
    _Cap('Aplica procesos creativos', 'Planifica, desarrolla y mejora su proyecto', 'usa bocetos y referentes'),
    _Cap('Evalúa y comunica', 'Presenta su proyecto y explica su intención', 'reflexiona sobre su proceso'),
  ], segundo: _Segundo.escala),
  _Def('oral-l2', _s, 'Diálogo o exposición en castellano', [
    _Cap('Comprende', 'Comprende textos orales en castellano', 'deduce información implícita'),
    _Cap('Se expresa', 'Expresa ideas organizadas en castellano', 'usa vocabulario variado y conectores'),
    _Cap('Interactúa', 'Participa en conversaciones y debates en castellano', 'argumenta su posición'),
  ], segundo: _Segundo.escala),
  _Def('oral-ing', _s, 'Exposición oral o entrevista', [
    _Cap('Obtiene información', 'Comprende información de textos orales en inglés', 'deduce información implícita'),
    _Cap('Se expresa', 'Expresa ideas con coherencia en inglés', 'usa vocabulario y tiempos verbales variados'),
    _Cap('Interactúa', 'Mantiene una conversación en inglés', 'reformula cuando no le entienden'),
    _Cap('Pronunciación y fluidez', 'Habla con pronunciación comprensible y fluidez', 'cuida la entonación y el ritmo'),
  ], segundo: _Segundo.escala),
  _Def('lee-ing', _s, 'Comprensión de lectura', [
    _Cap('Obtiene información', 'Identifica información relevante en textos en inglés', 'integra información de varias partes'),
    _Cap('Infiere e interpreta', 'Deduce el tema, el propósito y el significado de palabras', 'interpreta expresiones'),
    _Cap('Reflexiona', 'Opina sobre el texto en inglés', 'argumenta su opinión'),
  ]),
  _Def('escribe-ing', _s, 'Producción escrita', [
    _Cap('Adecúa el texto', 'Escribe textos en inglés según el propósito', 'adapta el registro'),
    _Cap('Organiza las ideas', 'Organiza las ideas en párrafos con conectores', 'usa conectores variados'),
    _Cap('Usa las convenciones', 'Usa gramática y ortografía adecuadas', 'casi no comete errores'),
  ]),
  _Def('cantidad', _s, 'Problemas con números racionales, porcentajes o potencias', [
    _Cap('Traduce cantidades', 'Representa la situación con expresiones numéricas', 'evalúa si la expresión es la adecuada'),
    _Cap('Comunica su comprensión', 'Explica propiedades de los números y operaciones', 'usa notación matemática precisa'),
    _Cap('Usa estrategias', 'Emplea estrategias de cálculo, estimación y redondeo', 'elige la más eficiente'),
    _Cap('Argumenta afirmaciones', 'Justifica sus procedimientos y resultados', 'demuestra con ejemplos y contraejemplos'),
  ]),
  _Def('regularidad', _s, 'Problemas con ecuaciones y funciones', [
    _Cap('Traduce datos y condiciones', 'Plantea ecuaciones, inecuaciones o funciones a partir de la situación', 'evalúa si el modelo es adecuado'),
    _Cap('Comunica su comprensión', 'Describe el comportamiento de una función con gráficos y tablas', 'relaciona sus representaciones'),
    _Cap('Usa estrategias', 'Resuelve ecuaciones y sistemas con procedimientos adecuados', 'verifica la solución'),
    _Cap('Argumenta afirmaciones', 'Justifica relaciones de cambio y equivalencia', 'generaliza a partir de casos'),
  ]),
  _Def('forma', _s, 'Problemas de geometría, trigonometría o mapas', [
    _Cap('Modela objetos', 'Representa objetos con formas geométricas y sus medidas', 'considera escalas'),
    _Cap('Comunica su comprensión', 'Explica propiedades y relaciones geométricas', 'usa lenguaje geométrico preciso'),
    _Cap('Usa estrategias', 'Calcula perímetros, áreas, volúmenes o distancias', 'elige el procedimiento más eficiente'),
    _Cap('Argumenta afirmaciones', 'Justifica relaciones geométricas', 'demuestra propiedades'),
  ]),
  _Def('datos', _s, 'Estudio estadístico o problema de probabilidad', [
    _Cap('Representa datos', 'Organiza datos en tablas y gráficos estadísticos', 'elige el gráfico más adecuado'),
    _Cap('Comunica su comprensión', 'Interpreta medidas de tendencia central y dispersión', 'explica qué significan en el contexto'),
    _Cap('Usa estrategias', 'Recoge datos con muestras y calcula probabilidades', 'justifica cómo eligió la muestra'),
    _Cap('Sustenta conclusiones', 'Plantea conclusiones basadas en los datos', 'reconoce sus límites'),
  ]),
  _Def('indaga', _s, 'Informe de indagación o laboratorio', [
    _Cap('Problematiza situaciones', 'Formula una pregunta investigable y una hipótesis con variables', 'justifica su hipótesis'),
    _Cap('Diseña estrategias', 'Diseña un procedimiento controlando variables', 'justifica la confiabilidad de su diseño'),
    _Cap('Genera y registra datos', 'Obtiene y organiza datos con precisión', 'calcula promedios y errores'),
    _Cap('Analiza datos', 'Interpreta los datos y los contrasta con su hipótesis', 'los relaciona con teorías científicas'),
    _Cap('Evalúa y comunica', 'Comunica conclusiones y limitaciones de su indagación', 'propone nuevas preguntas'),
  ]),
  _Def('explica', _s, 'Explicación científica o estudio de caso', [
    _Cap('Comprende y usa conocimientos', 'Explica fenómenos con modelos y teorías científicas', 'usa evidencias cuantitativas'),
    _Cap('Evalúa las implicancias', 'Argumenta sobre el impacto de la ciencia y la tecnología en la sociedad', 'considera aspectos éticos'),
  ]),
  _Def('disena', _s, 'Prototipo tecnológico', [
    _Cap('Determina una alternativa de solución', 'Describe el problema y propone una solución con fundamentos científicos', 'compara alternativas'),
    _Cap('Diseña la alternativa', 'Representa su diseño con especificaciones y medidas', 'calcula costos y tiempos'),
    _Cap('Implementa y valida', 'Construye el prototipo y lo prueba', 'lo optimiza según los resultados'),
    _Cap('Evalúa y comunica', 'Explica el funcionamiento y el impacto de su solución', 'propone mejoras'),
  ]),
  _Def('emprende', _s, 'Proyecto de emprendimiento económico o social', [
    _Cap('Crea propuestas de valor', 'Identifica una necesidad y propone una solución innovadora', 'la valida con usuarios'),
    _Cap('Aplica habilidades técnicas', 'Usa técnicas y herramientas para producir el bien o servicio', 'cuida la calidad y la seguridad'),
    _Cap('Trabaja cooperativamente', 'Cumple su rol y colabora con el equipo', 'ayuda a resolver problemas del equipo'),
    _Cap('Evalúa los resultados', 'Evalúa los resultados e impactos del proyecto', 'propone mejoras sostenibles'),
  ]),
  _Def('fe-identidad', _s, 'Reflexión o ensayo sobre la fe y la dignidad humana', [
    _Cap('Conoce a Dios', 'Explica la acción de Dios en la historia y en su vida', 'lo relaciona con su proyecto de vida'),
    _Cap('Cultiva y valora su fe', 'Expresa su fe con respeto en celebraciones y reflexiones', 'la vive con coherencia'),
    _Cap('Dialoga con respeto', 'Dialoga con quienes tienen otras creencias', 'busca puntos de encuentro'),
  ]),
  _Def('fe-encuentro', _s, 'Proyecto de servicio o compromiso', [
    _Cap('Transforma su entorno', 'Participa en acciones de servicio y bien común', 'las organiza con otros'),
    _Cap('Actúa con coherencia', 'Toma decisiones según valores cristianos', 'reflexiona sobre sus actos'),
  ], segundo: _Segundo.escala),
  _Def('tic', _s, 'Producto digital', [
    _Cap('Personaliza entornos virtuales', 'Configura y organiza sus herramientas digitales', 'las adapta a sus necesidades'),
    _Cap('Gestiona información', 'Busca, contrasta y organiza información de fuentes confiables', 'cita las fuentes'),
    _Cap('Interactúa en entornos virtuales', 'Colabora en línea de forma ética y segura', 'cuida su huella digital'),
    _Cap('Crea objetos virtuales', 'Crea productos digitales con un propósito', 'combina formatos de forma creativa'),
  ]),
  _Def('autonomo', _s, 'Al cerrar la unidad o el periodo', [
    _Cap('Define metas', 'Define metas de aprendizaje realistas', 'las relaciona con su proyecto de vida'),
    _Cap('Organiza acciones', 'Planifica sus tareas y su tiempo', 'prevé dificultades'),
    _Cap('Monitorea y ajusta', 'Evalúa su avance y ajusta sus estrategias', 'busca recursos por su cuenta'),
  ], segundo: _Segundo.escala),
];

String _primeraMayuscula(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Descriptores por nivel a partir de lo que hace el estudiante.
List<String> _descriptores(_Cap c) => [
  '${c.hace} solo con apoyo constante o de forma muy incompleta.',
  '${c.hace} de forma parcial o con ayuda del docente.',
  '${c.hace} de forma autónoma y adecuada.',
  '${c.hace} con precisión y, además, ${c.mas}.',
];

String _clave(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-');

Instrumento _rubrica(_Def d, Competencia c) => Instrumento(
  id: 'cneb-${c.id}-${_clave(d.nivel)}-r',
  tipo: TipoInstrumento.rubrica,
  nombre: c.corto,
  descripcion: 'Evidencia sugerida: ${d.evidencia}. Competencia: ${c.nombre}.',
  niveles: [d.nivel],
  area: c.areas[d.nivel]!,
  competencias: [c.id],
  escala: plantillaNivelesRubrica,
  items: [
    for (final (k, cap) in d.caps.indexed)
      ItemInstrumento(
        id: String.fromCharCode(97 + k),
        texto: cap.criterio,
        peso: 1,
        descriptores: _descriptores(cap),
      ),
  ],
  ejemplo: true,
);

Instrumento _segundo(_Def d, Competencia c) {
  final inicial = d.nivel == _i;
  final escala = d.segundo == _Segundo.escala;
  final textos = [for (final cap in d.caps) cap.hace, ...d.extra];
  return Instrumento(
    id: 'cneb-${c.id}-${_clave(d.nivel)}-${escala ? 'e' : 'l'}',
    tipo: escala ? TipoInstrumento.escala : TipoInstrumento.cotejo,
    nombre: c.corto,
    descripcion: inicial
        ? 'Ficha de observación. Evidencia: ${d.evidencia}. Marca «No '
              'observado» si ese día no lo pudiste ver.'
        : 'Evidencia sugerida: ${d.evidencia}. Competencia: ${c.nombre}.',
    niveles: [d.nivel],
    area: c.areas[d.nivel]!,
    competencias: [c.id],
    escala: escala
        ? (inicial ? nivelesEscala[4].niveles : nivelesEscala[0].niveles)
        : (inicial ? etiquetasCotejo[3].niveles : etiquetasCotejo[1].niveles),
    noObservado: inicial,
    items: [
      for (final (k, t) in textos.indexed)
        ItemInstrumento(id: String.fromCharCode(97 + k), texto: _primeraMayuscula(t)),
    ],
    ejemplo: true,
  );
}

/// Inicial lleva ficha de observación (lista con «No observado») y escala,
/// sin rúbrica: a esa edad se evalúa observando.
Instrumento _inicialEscala(_Def d, Competencia c) => Instrumento(
  id: 'cneb-${c.id}-inicial-e',
  tipo: TipoInstrumento.escala,
  nombre: c.corto,
  descripcion:
      'Escala para observar a lo largo del periodo. Evidencia: ${d.evidencia}.',
  niveles: const [_i],
  area: c.areas[_i]!,
  competencias: [c.id],
  escala: nivelesEscala[4].niveles,
  noObservado: true,
  items: [
    for (final (k, cap) in d.caps.indexed)
      ItemInstrumento(id: String.fromCharCode(97 + k), texto: cap.hace),
  ],
  ejemplo: true,
);

Instrumento _inicialFicha(_Def d, Competencia c) => Instrumento(
  id: 'cneb-${c.id}-inicial-l',
  tipo: TipoInstrumento.cotejo,
  nombre: c.corto,
  descripcion:
      'Ficha de observación. Evidencia: ${d.evidencia}. Marca «No observado» '
      'si ese día no lo pudiste ver.',
  niveles: const [_i],
  area: c.areas[_i]!,
  competencias: [c.id],
  escala: etiquetasCotejo[3].niveles,
  noObservado: true,
  items: [
    for (final (k, cap) in d.caps.indexed)
      ItemInstrumento(id: String.fromCharCode(97 + k), texto: cap.hace),
  ],
  ejemplo: true,
);

/// La colección completa, en el orden de las áreas.
final List<Instrumento> coleccionCneb = () {
  final r = <Instrumento>[];
  for (final d in _defs) {
    final c = competenciaPorId(d.comp)!;
    if (d.nivel == _i) {
      r
        ..add(_inicialFicha(d, c))
        ..add(_inicialEscala(d, c));
    } else {
      r
        ..add(_rubrica(d, c))
        ..add(_segundo(d, c));
    }
  }
  return r;
}();

/// Para pruebas: qué competencias tienen contenido en cada nivel.
Set<(String, String)> get competenciasConInstrumentos => {
  for (final d in _defs) (d.comp, d.nivel),
};
