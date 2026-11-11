import 'package:drift/drift.dart';

import 'academico.dart';
import 'database.dart';
import 'planificacion.dart';

/// Unidades de ejemplo de cada curso (dos por bimestre) con sus sesiones.
const _temas = <String, List<(String, List<String>)>>{
  'Química': [
    (
      'El carbono, base de la vida',
      [
        'El átomo de carbono',
        'Hibridación',
        'Cadenas carbonadas',
        'Fórmulas químicas',
        'Modelos moleculares',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Hidrocarburos: el gas de Camisea',
      [
        'Alcanos',
        'Alquenos y alquinos',
        'Nomenclatura',
        'Del pozo a la cocina',
        'Combustión',
        'Debate: el gas en el Perú',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Funciones oxigenadas en casa',
      [
        'Alcoholes',
        'Aldehídos y cetonas',
        'Ácidos carboxílicos',
        'Ésteres y aromas',
        'Laboratorio: jabón casero',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Química de los alimentos',
      [
        'Carbohidratos',
        'Lípidos',
        'Proteínas',
        'Leemos etiquetas',
        'Loncheras saludables',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Biomoléculas y salud',
      [
        'Vitaminas',
        'Enzimas',
        'Anemia en el Perú',
        'Experimento con enzimas',
        'Campaña de salud',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Combustibles y energía limpia',
      [
        'Petróleo y derivados',
        'Biocombustibles',
        'Huella de carbono',
        'Prototipo de biodigestor',
        'Presentamos el prototipo',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      '¿Plásticos o biodegradables? Cuidamos el río Huaura',
      [
        '¿Qué es un polímero?',
        'Polímeros naturales',
        'Montamos el experimento',
        'Registramos datos del experimento',
        'Analizamos resultados',
        'Biodegradables vs. plásticos',
        'Diseño de la campaña',
        'Presentamos y evaluamos',
      ],
    ),
    (
      'Feria de ciencias: soluciones para Huacho',
      [
        'Elegimos el problema',
        'Armamos el proyecto',
        'Ensayo de la feria',
        'Feria de ciencias',
      ],
    ),
  ],
  'Física': [
    (
      'Magnitudes y medición',
      [
        'Sistema Internacional',
        'Notación científica',
        'Errores de medición',
        'Laboratorio de medidas',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Movimiento en una dimensión',
      [
        'MRU',
        'MRUV',
        'Caída libre',
        'Gráficas del movimiento',
        'Laboratorio con carritos',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Fuerzas y leyes de Newton',
      [
        'Primera ley',
        'Segunda ley',
        'Tercera ley',
        'Rozamiento',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Estática y máquinas simples',
      [
        'Equilibrio',
        'Palancas',
        'Poleas',
        'Construimos una grúa',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Energía y su conservación',
      [
        'Trabajo y potencia',
        'Energía cinética',
        'Energía potencial',
        'Energía mecánica',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Calor y temperatura',
      [
        'Escalas de temperatura',
        'Dilatación',
        'Transmisión del calor',
        'Termo casero',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Electricidad en casa',
      [
        'Carga eléctrica',
        'Corriente y voltaje',
        'Ley de Ohm',
        'Circuitos',
        'Trabajo y potencia',
        'Energía mecánica',
        'Conservación de la energía',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Ondas y sonido',
      [
        'Ondas mecánicas',
        'El sonido',
        'Instrumento casero',
        'Evaluamos lo aprendido',
      ],
    ),
  ],
  'Biología': [
    (
      'La célula',
      [
        'Teoría celular',
        'Célula animal y vegetal',
        'Microscopio',
        'Membrana celular',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Metabolismo',
      [
        'Fotosíntesis',
        'Respiración celular',
        'Laboratorio de fermentación',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Genética',
      [
        'El ADN',
        'Leyes de Mendel',
        'Herencia humana',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Evolución',
      [
        'Teorías evolutivas',
        'Selección natural',
        'Biodiversidad del Perú',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Sistemas del cuerpo',
      [
        'Sistema digestivo',
        'Sistema circulatorio',
        'Sistema nervioso',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Salud y enfermedad',
      [
        'Microorganismos',
        'Vacunas',
        'Prevención del dengue',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Reproducción y desarrollo',
      [
        'La célula y sus organelos',
        'Mitosis',
        'Meiosis',
        'Reproducción humana',
        'Salud sexual',
        'Evaluamos lo aprendido',
      ],
    ),
    (
      'Ecosistemas de Lima provincias',
      [
        'Cadenas tróficas',
        'Lomas costeras',
        'Salida de campo',
        'Evaluamos lo aprendido',
      ],
    ),
  ],
  'Ciencia y Tecnología': [
    (
      'Los seres vivos',
      ['¿Qué tienen los seres vivos?', 'Plantas', 'Animales', 'Evaluamos'],
    ),
    (
      'Nuestro cuerpo',
      ['Los huesos', 'Los músculos', 'Cuidamos el cuerpo', 'Evaluamos'],
    ),
    (
      'La materia',
      ['Estados de la materia', 'Mezclas', 'Experimentos', 'Evaluamos'],
    ),
    ('La energía', ['Fuentes de energía', 'La luz', 'El sonido', 'Evaluamos']),
    ('El suelo', ['Tipos de suelo', 'El biohuerto', 'Evaluamos']),
    (
      'El agua',
      ['El ciclo del agua', 'Agua y salud', 'Filtro casero', 'Evaluamos'],
    ),
    (
      'El clima',
      ['El tiempo y el clima', 'Fenómeno El Niño', 'Agua y salud', 'Evaluamos'],
    ),
    (
      'Inventos para mi comunidad',
      ['Elegimos el problema', 'Diseñamos', 'Construimos', 'Presentamos'],
    ),
  ],
};

Future<void> planificacionDeEjemplo(
  KipuDb db, {
  required List<int> idCursos,
  required List<Periodo> periodos,
  required int anio,
  required DateTime hoy,
}) async {
  final h = claveFecha(hoy);
  final horario = await db.verHorario().first;
  final cursos = await db.verCursos().first;
  for (final id in idCursos) {
    final curso = cursos.firstWhere((c) => c.curso.id == id).curso;
    final temas = _temas[curso.nombre] ?? _temas['Ciencia y Tecnología']!;
    final bloques = [
      for (final x in horario)
        if (x.$2.curso.id == id) x.$1,
    ];
    final comps = [
      for (final k in competenciasDelCurso(curso))
        if (!k.transversal) k.id,
    ];
    final ocupadas = <String>{};
    for (var p = 1; p <= periodos.length; p++) {
      final ini = DateTime.parse(periodos[p - 1].inicio!);
      final fin = DateTime.parse(periodos[p - 1].fin!);
      final mitad = DateTime(
        ini.year,
        ini.month,
        ini.day + fin.difference(ini).inDays ~/ 2,
      );
      for (var k = 0; k < 2; k++) {
        final i = (p - 1) * 2 + k;
        if (i >= temas.length) break;
        final (titulo, base) = temas[i];
        final desde = k == 0 ? ini : mitad.add(const Duration(days: 1));
        final hasta = k == 0 ? mitad : fin;
        final detalle = curso.nombre == 'Química' && i == 6;
        // Unas competencias por unidad, rotando, para que la matriz varíe.
        final usa = [
          for (var j = 0; j < comps.length; j++)
            if (comps.length <= 2 || (i + j) % 3 != 2) comps[j],
        ];
        final unidad = await db.crearUnidad(
          UnidadesCompanion.insert(
            cursoId: id,
            anio: anio,
            periodo: p,
            orden: 0,
            titulo: titulo,
            desde: Value(claveFecha(desde)),
            hasta: Value(claveFecha(hasta)),
            competencias: Value(usa.join(',')),
            producto: Value(
              detalle ? 'Campaña para cuidar el río Huaura' : null,
            ),
            temas: Value(base.take(3).join(', ')),
            situacion: Value(
              detalle
                  ? 'En la ribera del río Huaura se acumulan botellas y bolsas '
                        'plásticas. ¿De qué están hechos estos materiales y por qué '
                        'tardan tanto en degradarse? ¿Qué alternativas podemos '
                        'proponer a nuestra comunidad?'
                  : null,
            ),
            enfoques: Value(
              detalle
                  ? 'Ambiental|Búsqueda de la excelencia'
                  : (i.isEven ? 'Ambiental' : 'Orientación al bien común'),
            ),
            propositos: Value(
              Proposito.aTexto([
                for (final c in usa)
                  Proposito(
                    c,
                    capacidades: (capacidadesCneb[c] ?? const [])
                        .take(2)
                        .toList(),
                    criterios: detalle && c == 'indaga'
                        ? 'Plantea una hipótesis sobre el tiempo de degradación de distintos materiales.\n'
                              'Registra y organiza datos del experimento en tablas.'
                        : detalle && c == 'explica'
                        ? 'Explica la estructura de los polímeros y su relación con la degradación.\n'
                              'Argumenta el impacto del plástico en el ecosistema del río.'
                        : '',
                    evidencia: detalle && c == 'indaga'
                        ? 'Informe del experimento de degradación'
                        : detalle && c == 'explica'
                        ? 'Organizador visual sobre polímeros'
                        : '',
                    instrumento: detalle && c == 'indaga'
                        ? 'Rúbrica'
                        : detalle && c == 'explica'
                        ? 'Lista de cotejo'
                        : '',
                  ),
              ]),
            ),
          ),
        );
        // Las fechas salen del horario; las tres últimas de la unidad en
        // curso quedan sin fecha para repartirlas.
        // Las sesiones se reparten parejas entre las clases de la unidad.
        final todas = proximasClases(
          bloques,
          desde,
          cantidad: 200,
          ocupadas: ocupadas,
          hasta: claveFecha(hasta),
        );
        // Una sesión por clase: los temas largos se dan en dos partes.
        final sesiones = [...base];
        for (
          var k = 0;
          sesiones.length < todas.length && k < base.length;
          k++
        ) {
          final t = base[k];
          if (t.startsWith('Evaluamos')) continue;
          sesiones.insert(sesiones.indexOf(t) + 1, '$t (parte 2)');
        }
        final clases = [
          for (var j = 0; j < sesiones.length && j < todas.length; j++)
            todas[j],
        ];
        final enCurso =
            claveFecha(desde).compareTo(h) <= 0 &&
            claveFecha(hasta).compareTo(h) >= 0;
        for (var j = 0; j < sesiones.length; j++) {
          var c = j < clases.length ? clases[j] : null;
          if (enCurso && j >= sesiones.length - 2 && c != null) {
            if (c.fecha.compareTo(h) > 0) c = null;
          }
          if (c != null) ocupadas.add('${c.fecha} ${c.hora}');
          final hecha = c != null && c.fecha.compareTo(h) < 0;
          await db.crearSesion(
            SesionesCompanion.insert(
              unidadId: unidad,
              orden: 0,
              titulo: sesiones[j],
              fecha: Value(c?.fecha),
              hora: Value(c?.hora),
              hecha: Value(hecha),
              competencia: Value(usa.isEmpty ? null : usa[j % usa.length]),
              proposito: Value(
                detalle && sesiones[j] == 'Registramos datos del experimento'
                    ? 'Hoy registraremos y organizaremos en tablas los cambios '
                          'que observamos en las muestras.'
                    : null,
              ),
              inicio: Value(
                detalle && sesiones[j] == 'Registramos datos del experimento'
                    ? 'Observamos las muestras de la semana pasada. Saberes '
                          'previos: ¿qué cambió?'
                    : null,
              ),
              desarrollo: Value(
                detalle && sesiones[j] == 'Registramos datos del experimento'
                    ? 'En equipos miden la masa y el aspecto de cada muestra y '
                          'completan la tabla. Comparamos con la hipótesis.'
                    : null,
              ),
              cierre: Value(
                detalle && sesiones[j] == 'Registramos datos del experimento'
                    ? 'Metacognición: ¿qué dificultades tuvimos al medir?'
                    : null,
              ),
              minInicio: const Value(15),
              minDesarrollo: const Value(60),
              minCierre: const Value(15),
              materiales: Value(
                detalle && sesiones[j] == 'Registramos datos del experimento'
                    ? 'Balanza, ficha de registro'
                    : null,
              ),
              tarea: Value(
                detalle && sesiones[j] == 'Registramos datos del experimento'
                    ? 'Traer un envase etiquetado'
                    : null,
              ),
            ),
          );
        }
      }
    }
  }
}
