import 'package:flutter/material.dart' show Color, Colors;

import '../data/database.dart';

/// Una fila del horario de un colegio: hora de clase o recreo.
class FilaHorario {
  final String inicio;
  final String fin;
  final bool recreo;
  const FilaHorario(this.inicio, this.fin, {this.recreo = false});
}

/// Horas que se usan cuando el colegio aún no tiene horario.
const filasPorDefecto = [
  FilaHorario('07:50', '09:20'),
  FilaHorario('09:20', '09:35', recreo: true),
  FilaHorario('09:35', '11:05'),
  FilaHorario('11:05', '11:20', recreo: true),
  FilaHorario('11:20', '12:50'),
  FilaHorario('12:50', '13:00', recreo: true),
  FilaHorario('13:00', '14:30'),
];

const diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const diasLargos = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

int minutos(String hhmm) =>
    int.parse(hhmm.substring(0, 2)) * 60 + int.parse(hhmm.substring(3, 5));

String hhmm(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

String duracion(int m) {
  final h = m ~/ 60, r = m % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h $r min';
}

/// «1.° A», «5.° C»: grado corto y sección, para las etiquetas.
String aula(Curso c) {
  final g = RegExp(r'^\S+').firstMatch(c.grado)?.group(0) ?? c.grado;
  return '$g ${c.seccion}';
}

Color claroDe(Color c) => Color.lerp(c, Colors.white, .82)!;
Color oscuroDe(Color c) => Color.lerp(c, Colors.black, .28)!;

/// Filas del horario de un colegio. Usa las horas guardadas; si no hay, las
/// deduce de sus clases (los huecos cortos entre clases son recreos); y si
/// tampoco hay clases, propone un horario base.
List<FilaHorario> filasDeColegio(
  int colegioId,
  List<Franja> franjas,
  List<(Horario, CursoConColegio)> clases,
) {
  final propias = [
    for (final f in franjas)
      if (f.colegioId == colegioId)
        FilaHorario(f.inicio, f.fin, recreo: f.recreo),
  ];
  final delColegio = [
    for (final (h, c) in clases)
      if (c.colegio.id == colegioId) h,
  ];
  if (propias.isEmpty && delColegio.isEmpty) return filasPorDefecto;

  final filas = <FilaHorario>[...propias];
  if (propias.isEmpty) {
    final rangos = {for (final h in delColegio) '${h.inicio}-${h.fin}'}.toList()
      ..sort();
    String? finAnterior;
    for (final r in rangos) {
      final [ini, fin] = r.split('-');
      if (finAnterior != null) {
        final hueco = minutos(ini) - minutos(finAnterior);
        if (hueco > 0 && hueco <= 30) {
          filas.add(FilaHorario(finAnterior, ini, recreo: true));
        }
      }
      filas.add(FilaHorario(ini, fin));
      finAnterior = fin;
    }
  } else {
    // Clases puestas a una hora que ya no está en el horario del colegio.
    for (final h in delColegio) {
      if (!filas.any((f) => !f.recreo && f.inicio == h.inicio)) {
        filas.add(FilaHorario(h.inicio, h.fin));
      }
    }
  }
  filas.sort((a, b) => a.inicio.compareTo(b.inicio));
  return filas;
}

/// Días que se muestran: de lunes a viernes, y sábado o domingo si hay clases.
List<int> diasVisibles(List<(Horario, CursoConColegio)> clases) => [
  1,
  2,
  3,
  4,
  5,
  if (clases.any((x) => x.$1.dia == 6) || clases.any((x) => x.$1.dia == 7)) 6,
  if (clases.any((x) => x.$1.dia == 7)) 7,
];

/// Qué hay entre dos clases seguidas del mismo día.
String? entreClases(
  (Horario, CursoConColegio) a,
  (Horario, CursoConColegio) b,
  List<Franja> franjas,
) {
  final hueco = minutos(b.$1.inicio) - minutos(a.$1.fin);
  if (hueco < 0) return 'Se cruzan las horas';
  if (a.$2.colegio.id != b.$2.colegio.id) {
    return hueco == 0
        ? 'Cambio de colegio · sin tiempo'
        : 'Cambio de colegio · ${duracion(hueco)}';
  }
  if (hueco <= 0) return null;
  final filas = filasDeColegio(a.$2.colegio.id, franjas, [a, b]);
  final esRecreo = filas.any(
    (f) => f.recreo && f.inicio == a.$1.fin && f.fin == b.$1.inicio,
  );
  return '${esRecreo ? 'Recreo' : 'Libre'} · ${duracion(hueco)}';
}

/// «Semana del 2 al 6 de noviembre».
String textoSemana(DateTime hoy) {
  const meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  final lunes = DateTime(hoy.year, hoy.month, hoy.day - (hoy.weekday - 1));
  final viernes = lunes.add(const Duration(days: 4));
  if (lunes.month == viernes.month) {
    return 'Semana del ${lunes.day} al ${viernes.day} de ${meses[viernes.month - 1]}';
  }
  return 'Semana del ${lunes.day} de ${meses[lunes.month - 1]} al '
      '${viernes.day} de ${meses[viernes.month - 1]}';
}

/// Día del mes de [dia] (1 = lunes) en la semana de [hoy].
int diaDelMes(DateTime hoy, int dia) =>
    DateTime(hoy.year, hoy.month, hoy.day - (hoy.weekday - dia)).day;

/// Clase de otro colegio que se cruza con [inicio]–[fin] el mismo día.
(Horario, CursoConColegio)? cruceCon(
  List<(Horario, CursoConColegio)> clases,
  int colegioId,
  int dia,
  String inicio,
  String fin, {
  int? sinContar,
}) {
  for (final x in clases) {
    final h = x.$1;
    if (h.dia != dia || x.$2.colegio.id == colegioId || h.id == sinContar) {
      continue;
    }
    if (h.inicio.compareTo(fin) < 0 && inicio.compareTo(h.fin) < 0) return x;
  }
  return null;
}
