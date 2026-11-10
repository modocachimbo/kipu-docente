import 'instrumentos.dart';

/// Ejemplos listos para usar, pensados para Inicial, Primaria y Secundaria
/// según el Currículo Nacional. El docente los agrega a su biblioteca y los
/// adapta; el original no cambia.
///
/// Los ids son fijos («ej-…») para reconocer qué ejemplos ya se agregaron.

ItemInstrumento _i(String id, String texto, {double peso = 1}) =>
    ItemInstrumento(id: id, texto: texto, peso: peso);

ItemInstrumento _c(String id, String texto, List<String> d, {double peso = 25}) =>
    ItemInstrumento(id: id, texto: texto, peso: peso, descriptores: d);

const _i0 = 'Inicial', _p = 'Primaria', _s = 'Secundaria';

final List<Instrumento> ejemplosInstrumentos = [
  // ─────────────────────────── INICIAL ───────────────────────────
  Instrumento(
    id: 'ej-sectores',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Juego libre en sectores',
    descripcion:
        'Ficha de observación para la hora del juego libre. Marca «No '
        'observado» si ese día no lo pudiste ver.',
    niveles: const [_i0],
    area: 'Personal Social',
    escala: etiquetasCotejo[3].niveles,
    noObservado: true,
    items: [
      _i('a', 'Elige el sector y el material con el que quiere jugar'),
      _i('b', 'Comparte los materiales con sus compañeros'),
      _i('c', 'Propone ideas o reglas para el juego'),
      _i('d', 'Expresa con palabras lo que siente cuando hay un conflicto'),
      _i('e', 'Ordena los materiales al terminar'),
      _i('f', 'Cuenta a qué jugó y con quién'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-psicomotriz',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Psicomotricidad: se desenvuelve con autonomía',
    descripcion: 'Para la sesión de psicomotricidad o el patio.',
    niveles: const [_i0],
    area: 'Psicomotriz',
    escala: etiquetasCotejo[3].niveles,
    noObservado: true,
    items: [
      _i('a', 'Corre esquivando obstáculos'),
      _i('b', 'Salta con los dos pies juntos'),
      _i('c', 'Mantiene el equilibrio en un pie por unos segundos'),
      _i('d', 'Lanza y atrapa una pelota'),
      _i('e', 'Sube y baja escaleras alternando los pies'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-caritas',
    tipo: TipoInstrumento.escala,
    nombre: 'Autoevaluación con caritas',
    descripcion:
        'El niño o la niña señala la carita. En los primeros grados de '
        'Primaria también funciona.',
    niveles: const [_i0, _p],
    escala: nivelesEscala[3].niveles,
    items: [
      _i('a', 'Guardé mis materiales'),
      _i('b', 'Escuché a mis amigos'),
      _i('c', 'Terminé mi trabajo'),
      _i('d', 'Pedí ayuda cuando la necesité'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-oral-inicial',
    tipo: TipoInstrumento.escala,
    nombre: 'Se comunica oralmente (5 años)',
    descripcion: 'Para la asamblea, el cuento o las conversaciones del aula.',
    niveles: const [_i0],
    area: 'Comunicación',
    escala: nivelesEscala[4].niveles,
    noObservado: true,
    items: [
      _i('a', 'Expresa sus ideas y necesidades con claridad'),
      _i('b', 'Responde preguntas sobre un cuento escuchado'),
      _i('c', 'Narra hechos en orden: inicio, desarrollo y final'),
      _i('d', 'Espera su turno para hablar'),
    ],
    ejemplo: true,
  ),

  // ─────────────────────────── PRIMARIA ───────────────────────────
  Instrumento(
    id: 'ej-texto-narrativo',
    tipo: TipoInstrumento.rubrica,
    nombre: 'Escribe un texto narrativo',
    descripcion:
        'Cuento o anécdota. Compártela con los estudiantes antes de que '
        'empiecen a escribir.',
    niveles: const [_p],
    area: 'Comunicación',
    escala: plantillaNivelesRubrica,
    items: [
      _c('a', 'Adecuación al propósito', [
        'El texto no cuenta una historia o no responde a lo pedido.',
        'Cuenta una historia, pero se aleja a ratos de lo pedido.',
        'Cuenta una historia que responde al propósito y al destinatario.',
        'Además, elige detalles que hacen la historia atractiva para el lector.',
      ]),
      _c('b', 'Secuencia y coherencia', [
        'Las ideas están sueltas; no se entiende el orden de los hechos.',
        'Tiene inicio y desarrollo, pero falta el final o hay saltos.',
        'Tiene inicio, nudo y desenlace en orden lógico.',
        'Mantiene la secuencia y crea suspenso o sorpresa.',
      ]),
      _c('c', 'Uso de conectores', [
        'No usa conectores o repite siempre «y».',
        'Usa pocos conectores y a veces mal.',
        'Usa conectores de tiempo y causa de forma adecuada.',
        'Usa conectores variados que dan fluidez al texto.',
      ]),
      _c('d', 'Ortografía y puntuación', [
        'Muchos errores que dificultan entender el texto.',
        'Varios errores, pero el texto se entiende.',
        'Pocos errores; usa punto, coma y mayúsculas.',
        'Casi sin errores; usa también signos de diálogo.',
      ]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-problemas',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Resuelve problemas de cantidad',
    descripcion: 'Para revisar la solución de un problema paso a paso.',
    niveles: const [_p, _s],
    area: 'Matemática',
    escala: etiquetasCotejo[0].niveles,
    items: [
      _i('a', 'Identifica los datos y la pregunta del problema'),
      _i('b', 'Elige una estrategia (dibujo, tabla, operación)'),
      _i('c', 'Realiza las operaciones correctamente'),
      _i('d', 'Comprueba que la respuesta tenga sentido'),
      _i('e', 'Explica cómo llegó a la respuesta'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-participacion',
    tipo: TipoInstrumento.escala,
    nombre: 'Participación en clase',
    niveles: const [_p, _s],
    escala: nivelesEscala[0].niveles,
    items: [
      _i('a', 'Participa en las actividades'),
      _i('b', 'Respeta el turno de palabra'),
      _i('c', 'Trae el material'),
      _i('d', 'Colabora con los compañeros'),
      _i('e', 'Muestra interés'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-cuaderno',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Revisión del cuaderno',
    descripcion:
        'Lista ponderada: cada ítem vale distinto. Nota = puntos logrados ÷ '
        'total.',
    niveles: const [_p, _s],
    escala: etiquetasCotejo[2].niveles,
    ponderada: true,
    items: [
      _i('a', 'Tiene completas las actividades', peso: 4),
      _i('b', 'Corrigió lo que se revisó en clase', peso: 3),
      _i('c', 'Está ordenado y con letra legible', peso: 2),
      _i('d', 'Pone fecha y título', peso: 1),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-indagacion',
    tipo: TipoInstrumento.rubrica,
    nombre: 'Indaga mediante métodos científicos',
    descripcion: 'Para un experimento o una indagación completa.',
    niveles: const [_p, _s],
    area: 'Ciencia y Tecnología',
    escala: plantillaNivelesRubrica,
    items: [
      _c('a', 'Problematiza situaciones', peso: 20, [
        'No formula preguntas sobre el fenómeno.',
        'Formula una pregunta, pero no es investigable.',
        'Formula una pregunta investigable y una hipótesis.',
        'Además, identifica las variables de su hipótesis.',
      ]),
      _c('b', 'Diseña estrategias', peso: 20, [
        'No propone cómo comprobar su hipótesis.',
        'Propone pasos incompletos o sin materiales.',
        'Propone pasos, materiales y medidas de seguridad.',
        'Además, explica por qué su diseño es confiable.',
      ]),
      _c('c', 'Genera y registra datos', peso: 20, [
        'No registra datos o están incompletos.',
        'Registra algunos datos sin orden.',
        'Registra datos en tablas con unidades.',
        'Además, repite mediciones para mayor precisión.',
      ]),
      _c('d', 'Analiza datos', peso: 20, [
        'No relaciona los datos con su hipótesis.',
        'Describe los datos sin sacar conclusiones.',
        'Compara los datos con su hipótesis y concluye.',
        'Además, explica sus resultados con conocimientos científicos.',
      ]),
      _c('e', 'Evalúa y comunica', peso: 20, [
        'No comunica lo que hizo.',
        'Comunica sus resultados de forma incompleta.',
        'Comunica el proceso y sus conclusiones con claridad.',
        'Además, propone mejoras a su indagación.',
      ]),
    ],
    ponderada: true,
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-coevaluacion',
    tipo: TipoInstrumento.escala,
    nombre: 'Coevaluación del trabajo en equipo',
    descripcion:
        'Cada estudiante valora a sus compañeros de equipo. Úsala con la '
        'columna «En equipo» del registro.',
    niveles: const [_p, _s],
    escala: nivelesEscala[4].niveles,
    items: [
      _i('a', 'Aporta ideas al equipo'),
      _i('b', 'Escucha y respeta las opiniones'),
      _i('c', 'Cumple con su parte a tiempo'),
      _i('d', 'Ayuda a resolver los desacuerdos'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-convivencia',
    tipo: TipoInstrumento.escala,
    nombre: 'Convivencia en el aula (Tutoría)',
    niveles: const [_p, _s],
    area: 'Tutoría',
    escala: nivelesEscala[0].niveles,
    noObservado: true,
    items: [
      _i('a', 'Cumple los acuerdos de convivencia'),
      _i('b', 'Trata con respeto a compañeros y docentes'),
      _i('c', 'Resuelve los conflictos dialogando'),
      _i('d', 'Cuida los materiales y el aula'),
    ],
    ejemplo: true,
  ),

  // ────────────────────────── SECUNDARIA ──────────────────────────
  Instrumento(
    id: 'ej-exposicion',
    tipo: TipoInstrumento.rubrica,
    nombre: 'Exposición oral',
    descripcion: 'Para exposiciones individuales o en equipo.',
    niveles: const [_p, _s],
    area: 'Comunicación',
    escala: nivelesRubrica[1].niveles,
    items: [
      _c('a', 'Habla', [
        'Habla muy rápido o se detiene mucho; cuesta entenderle.',
        'A ratos habla con claridad, pero se acelera.',
        'Casi siempre habla despacio y con claridad.',
        'Habla despacio, con claridad y buena pronunciación.',
      ]),
      _c('b', 'Volumen', [
        'Muy bajo: solo lo escuchan los de adelante.',
        'Se escucha, pero baja la voz a menudo.',
        'Se escucha bien en casi todo el aula.',
        'Se escucha en todo el aula y varía el tono para enfatizar.',
      ]),
      _c('c', 'Dominio del tema', [
        'No parece entender el tema; lee todo.',
        'Entiende partes del tema; lee bastante.',
        'Entiende el tema y lee poco.',
        'Domina el tema y lo explica con sus palabras.',
      ]),
      _c('d', 'Postura y contacto visual', [
        'No mira al público y su postura distrae.',
        'Mira al público a veces.',
        'Mira al público casi siempre y tiene buena postura.',
        'Mira a todos con naturalidad y usa gestos que apoyan.',
      ]),
      _c('e', 'Responde preguntas', [
        'No puede contestar las preguntas.',
        'Contesta algunas preguntas con dificultad.',
        'Contesta con precisión la mayoría de preguntas.',
        'Contesta todas y amplía con ejemplos.',
      ]),
      _c('f', 'Material de apoyo', [
        'No usa material o tiene muchos errores.',
        'Usa material con mucho texto o poco claro.',
        'Usa material claro y ordenado.',
        'Su material es claro, visual y lo aprovecha al explicar.',
      ]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-exposicion-cotejo',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Exposición oral (lista rápida)',
    descripcion: 'Versión corta para evaluar a toda la clase en una sesión.',
    niveles: const [_p, _s],
    area: 'Comunicación',
    escala: etiquetasCotejo[0].niveles,
    items: [
      _i('a', 'Habla con volumen adecuado'),
      _i('b', 'Mantiene contacto visual'),
      _i('c', 'Usa material de apoyo'),
      _i('d', 'Respeta el tiempo'),
      _i('e', 'Responde a las preguntas'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-informe-lab',
    tipo: TipoInstrumento.rubrica,
    nombre: 'Informe de laboratorio',
    niveles: const [_s],
    area: 'Ciencia y Tecnología',
    escala: plantillaNivelesRubrica,
    items: [
      _c('a', 'Objetivo e hipótesis', [
        'Falta el objetivo o la hipótesis.',
        'Están, pero no se relacionan entre sí.',
        'Son claros y se relacionan.',
        'Son claros y la hipótesis se puede medir.',
      ]),
      _c('b', 'Procedimiento', [
        'No describe lo que hizo.',
        'Describe pasos incompletos.',
        'Describe los pasos en orden.',
        'Otro grupo podría repetirlo solo leyendo su informe.',
      ]),
      _c('c', 'Resultados', [
        'Sin datos o sin unidades.',
        'Datos desordenados.',
        'Datos en tablas o gráficos con unidades.',
        'Tablas y gráficos bien rotulados y comentados.',
      ]),
      _c('d', 'Conclusiones', [
        'No hay conclusiones.',
        'Repite los resultados sin concluir.',
        'Concluye a partir de sus datos.',
        'Concluye, explica errores posibles y propone mejoras.',
      ]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-ensayo',
    tipo: TipoInstrumento.rubrica,
    nombre: 'Ensayo argumentativo',
    niveles: const [_s],
    area: 'Comunicación',
    escala: plantillaNivelesRubrica,
    ponderada: true,
    items: [
      _c('a', 'Tesis', peso: 20, [
        'No hay una postura clara.',
        'La postura aparece, pero es confusa.',
        'Plantea una tesis clara al inicio.',
        'Tesis clara, original y bien delimitada.',
      ]),
      _c('b', 'Argumentos', peso: 30, [
        'Opiniones sin razones.',
        'Uno o dos argumentos débiles.',
        'Al menos dos argumentos sólidos.',
        'Argumentos sólidos y bien encadenados.',
      ]),
      _c('c', 'Evidencias y fuentes', peso: 20, [
        'No usa evidencias.',
        'Usa evidencias sin citar la fuente.',
        'Usa evidencias pertinentes y cita fuentes.',
        'Evidencias variadas y confiables, bien citadas.',
      ]),
      _c('d', 'Contraargumento', peso: 10, [
        'No considera otras posturas.',
        'Menciona otra postura sin responderla.',
        'Presenta y responde una postura contraria.',
        'Refuta con evidencias la postura contraria.',
      ]),
      _c('e', 'Redacción', peso: 20, [
        'Muchos errores que dificultan la lectura.',
        'Errores frecuentes, pero se entiende.',
        'Redacción clara con pocos errores.',
        'Redacción fluida, precisa y sin errores.',
      ]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-debate',
    tipo: TipoInstrumento.escala,
    nombre: 'Participación en un debate',
    niveles: const [_p, _s],
    area: 'Comunicación',
    escala: nivelesEscala[1].niveles,
    items: [
      _i('a', 'Defiende su postura con argumentos'),
      _i('b', 'Usa datos o ejemplos para sustentar'),
      _i('c', 'Refuta con respeto a la otra postura'),
      _i('d', 'Respeta los turnos y el tiempo'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-holistica',
    tipo: TipoInstrumento.rubrica,
    nombre: 'Situación significativa (rúbrica holística)',
    descripcion:
        'Una sola fila que valora el desempeño completo. Útil al cerrar una '
        'unidad.',
    niveles: const [_p, _s],
    escala: plantillaNivelesRubrica,
    items: [
      _c('a', 'Desempeño global', peso: 100, [
        'Resuelve la situación de forma incompleta y necesita mucha ayuda.',
        'Resuelve parte de la situación con ayuda.',
        'Resuelve la situación usando lo aprendido de forma autónoma.',
        'Resuelve la situación, la relaciona con otros contextos y propone mejoras.',
      ]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-mapa',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Organizador gráfico o mapa conceptual',
    niveles: const [_p, _s],
    escala: etiquetasCotejo[1].niveles,
    items: [
      _i('a', 'Ubica el concepto principal en el lugar central'),
      _i('b', 'Organiza las ideas de lo general a lo específico'),
      _i('c', 'Usa palabras de enlace que tienen sentido'),
      _i('d', 'Incluye ejemplos'),
      _i('e', 'No tiene errores de ortografía'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-proyecto',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Producto de proyecto (afiche, maqueta)',
    niveles: const [_p, _s],
    escala: etiquetasCotejo[2].niveles,
    noObservado: true,
    items: [
      _i('a', 'El título o mensaje es claro'),
      _i('b', 'Responde al problema planteado en el proyecto'),
      _i('c', 'Las imágenes o materiales son pertinentes'),
      _i('d', 'Cita las fuentes de información'),
      _i('e', 'Se entregó en la fecha acordada'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-seguridad-lab',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Normas de seguridad en el laboratorio',
    niveles: const [_s],
    area: 'Ciencia y Tecnología',
    escala: etiquetasCotejo[2].niveles,
    noObservado: true,
    items: [
      _i('a', 'Usa mandil y lentes de protección'),
      _i('b', 'Sigue las indicaciones del docente'),
      _i('c', 'Manipula los materiales con cuidado'),
      _i('d', 'Deja limpio su lugar de trabajo'),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-metacognicion',
    tipo: TipoInstrumento.escala,
    nombre: 'Autoevaluación y metacognición',
    descripcion: 'Al cerrar la unidad: el estudiante reflexiona sobre cómo aprendió.',
    niveles: const [_p, _s],
    escala: const [
      NivelInstrumento('Totalmente', 2),
      NivelInstrumento('En parte', 1),
      NivelInstrumento('Aún no', 0),
    ],
    items: [
      _i('a', 'Comprendí el propósito de la unidad'),
      _i('b', 'Organicé mi tiempo para terminar las tareas'),
      _i('c', 'Pedí ayuda cuando no entendí'),
      _i('d', 'Puedo explicar lo aprendido a un compañero'),
    ],
    ejemplo: true,
  ),

  // ──────────────────── EXÁMENES Y TRABAJO DIARIO ────────────────────
  Instrumento(
    id: 'ej-practica',
    tipo: TipoInstrumento.prueba,
    nombre: 'Práctica calificada (10 preguntas)',
    descripcion:
        'Opción múltiple A–D, 2 puntos cada una. Cambia la clave según tu '
        'práctica. Puedes dictar las respuestas de corrido: «BADC…».',
    niveles: const [_p, _s],
    ponderada: true,
    items: [
      for (var k = 0; k < 10; k++)
        ItemInstrumento(id: 'p$k', texto: '', peso: 2, opciones: 4, clave: const [1, 0, 3, 2, 1, 2, 0, 3, 1, 0][k]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-bimestral',
    tipo: TipoInstrumento.prueba,
    nombre: 'Examen bimestral mixto',
    descripcion:
        '8 de opción múltiple (1,5 pts), 4 de verdadero o falso (0,5 pts) y 2 '
        'problemas de desarrollo (3 pts). Total: 20.',
    niveles: const [_s],
    ponderada: true,
    items: [
      for (var k = 0; k < 8; k++)
        ItemInstrumento(id: 'm$k', texto: '', peso: 1.5, opciones: 4, clave: const [0, 2, 1, 3, 0, 1, 2, 3][k]),
      for (var k = 0; k < 4; k++)
        ItemInstrumento(id: 'v$k', texto: '', peso: .5, opciones: 2, clave: k.isEven ? 0 : 1),
      const ItemInstrumento(id: 'd0', texto: 'Problema 1', peso: 3),
      const ItemInstrumento(id: 'd1', texto: 'Problema 2', peso: 3),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-control-lectura',
    tipo: TipoInstrumento.prueba,
    nombre: 'Control de lectura',
    descripcion:
        '5 preguntas literales e inferenciales (A–C) y 2 preguntas de opinión '
        'que se corrigen a mano.',
    niveles: const [_p, _s],
    area: 'Comunicación',
    ponderada: true,
    items: [
      const ItemInstrumento(id: 'a', texto: '¿Quién es el personaje principal?', peso: 2, opciones: 3, clave: 0),
      const ItemInstrumento(id: 'b', texto: '¿Dónde ocurre la historia?', peso: 2, opciones: 3, clave: 1),
      const ItemInstrumento(id: 'c', texto: '¿Qué problema enfrenta el personaje?', peso: 2, opciones: 3, clave: 2),
      const ItemInstrumento(id: 'd', texto: '¿Por qué el personaje toma esa decisión?', peso: 2, opciones: 3, clave: 0),
      const ItemInstrumento(id: 'e', texto: '¿Cuál es el tema del texto?', peso: 2, opciones: 3, clave: 1),
      const ItemInstrumento(id: 'f', texto: '¿Estás de acuerdo con el final? Explica.', peso: 5),
      const ItemInstrumento(id: 'g', texto: '¿Qué le aconsejarías al personaje?', peso: 5),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-quiz-vf',
    tipo: TipoInstrumento.prueba,
    nombre: 'Quiz de verdadero o falso',
    descripcion: '10 afirmaciones de 2 puntos. Ideal para iniciar o cerrar la clase.',
    niveles: const [_p, _s],
    ponderada: true,
    items: [
      for (var k = 0; k < 10; k++)
        ItemInstrumento(id: 'q$k', texto: '', peso: 2, opciones: 2, clave: const [0, 1, 1, 0, 0, 1, 0, 1, 0, 0][k]),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-tareas',
    tipo: TipoInstrumento.cotejo,
    nombre: 'Revisión de tareas',
    descripcion: 'Lista ponderada para la tarea del día o de la semana.',
    niveles: const [_p, _s],
    escala: etiquetasCotejo[2].niveles,
    ponderada: true,
    items: [
      _i('a', 'La entregó a tiempo', peso: 2),
      _i('b', 'Está completa', peso: 4),
      _i('c', 'Las respuestas son correctas', peso: 10),
      _i('d', 'Está ordenada y limpia', peso: 2),
      _i('e', 'Corrigió lo observado', peso: 2),
    ],
    ejemplo: true,
  ),
  Instrumento(
    id: 'ej-actitudinal',
    tipo: TipoInstrumento.escala,
    nombre: 'Actitud en clase',
    descripcion: 'Escala actitudinal del periodo. Con caritas se entiende rápido.',
    niveles: const [_p, _s],
    escala: nivelesEscala[3].niveles,
    items: [
      _i('a', 'Llega puntual'),
      _i('b', 'Respeta a sus compañeros y docentes'),
      _i('c', 'Cumple con sus responsabilidades'),
      _i('d', 'Mantiene el orden y la limpieza'),
      _i('e', 'Participa con entusiasmo'),
    ],
    ejemplo: true,
  ),
];

/// Lo que se agrega a la biblioteca la primera vez, para no empezar vacío.
const ejemplosIniciales = [
  'ej-exposicion',
  'ej-exposicion-cotejo',
  'ej-participacion',
  'ej-sectores',
];
