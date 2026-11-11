import 'academico.dart';
import 'database.dart';
import 'diario_db.dart';

/// Un recordatorio que debe sonar en [cuando].
class Aviso {
  /// Identifica el aviso para no repetirlo (evento + fecha, clase + fecha…).
  final String clave;
  final DateTime cuando;
  final String titulo;
  final String cuerpo;
  const Aviso(this.clave, this.cuando, this.titulo, this.cuerpo);

  @override
  String toString() => '$clave@$cuando';
}

/// Todo lo que hace falta para calcular los avisos.
class DatosAvisos {
  final List<Evento> eventos;
  final List<(Horario, CursoConColegio)> clases;
  final List<(Estudiante, Curso)> cumples;
  final List<Periodo> periodos;
  final List<Pendiente> pendientes;
  final AjustesAvisos ajustes;

  const DatosAvisos({
    this.eventos = const [],
    this.clases = const [],
    this.cumples = const [],
    this.periodos = const [],
    this.pendientes = const [],
    this.ajustes = const AjustesAvisos(),
  });
}

String _dosDigitos(int n) => n.toString().padLeft(2, '0');

String claveFecha(DateTime d) =>
    '${d.year}-${_dosDigitos(d.month)}-${_dosDigitos(d.day)}';

/// 15:30 → «3:30 p. m.».
String horaBonita(String hhmm) {
  final p = hhmm.split(':');
  final h = int.tryParse(p.first) ?? 0;
  final m = p.length > 1 ? p[1] : '00';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$m ${h < 12 ? 'a. m.' : 'p. m.'}';
}

DateTime _conHora(DateTime dia, String? hhmm, {int defecto = 7}) {
  if (hhmm == null) return DateTime(dia.year, dia.month, dia.day, defecto);
  final p = hhmm.split(':');
  return DateTime(
    dia.year,
    dia.month,
    dia.day,
    int.tryParse(p.first) ?? defecto,
    p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0,
  );
}

const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// «hoy», «mañana» o «el jue 12», visto desde [desde].
String _cuandoEs(DateTime dia, DateTime desde) {
  final a = DateTime(desde.year, desde.month, desde.day);
  final b = DateTime(dia.year, dia.month, dia.day);
  final n = DateTime.utc(b.year, b.month, b.day)
      .difference(DateTime.utc(a.year, a.month, a.day))
      .inDays;
  if (n == 0) return 'hoy';
  if (n == 1) return 'mañana';
  return 'el ${_dias[b.weekday - 1]} ${b.day}';
}

/// Avisos que caen entre [desde] (incluido) y [hasta] (excluido), en orden.
List<Aviso> calcularAvisos(DatosAvisos d, DateTime desde, DateTime hasta) {
  final r = <Aviso>[];
  void agregar(Aviso a) {
    if (!a.cuando.isBefore(desde) && a.cuando.isBefore(hasta)) r.add(a);
  }

  final inicio = DateTime(desde.year, desde.month, desde.day);
  // Los avisos "1 semana antes" miran hasta 8 días más allá.
  final dias = <DateTime>[
    for (
      var x = inicio;
      x.isBefore(hasta.add(const Duration(days: 8)));
      x = DateTime(x.year, x.month, x.day + 1)
    )
      x,
  ];

  final feriados = <String>{
    for (final dia in dias)
      for (final e in d.eventos)
        if (e.tipo == 'feriado' && ocurreEl(e.fecha, e.repetir, claveFecha(dia)))
          claveFecha(dia),
  };

  for (final dia in dias) {
    final k = claveFecha(dia);

    // Eventos de la agenda con aviso.
    for (final e in d.eventos) {
      final antes = e.recordar;
      if (antes == null || !ocurreEl(e.fecha, e.repetir, k)) continue;
      final base = _conHora(dia, e.hora);
      final cuando = base.subtract(Duration(minutes: antes));
      final cuerpo = [
        nombreTipoEvento(e.tipo),
        e.hora == null
            ? '${_mayus(_cuandoEs(dia, cuando))}, todo el día'
            : '${_mayus(_cuandoEs(dia, cuando))} a las ${horaBonita(e.hora!)}',
      ].join(' · ');
      agregar(Aviso('e:${e.id}:$k', cuando, e.titulo, cuerpo));
    }

    // Clases del horario.
    if (d.ajustes.clases && !feriados.contains(k)) {
      for (final (h, c) in d.clases) {
        if (h.dia != dia.weekday) continue;
        final m = d.ajustes.minutosClase;
        agregar(
          Aviso(
            'c:${h.id}:$k',
            _conHora(dia, h.inicio).subtract(Duration(minutes: m)),
            m == 0 ? 'Empieza tu clase' : 'En $m min tienes clase',
            '${c.curso.nombre} · ${c.curso.grado} ${c.curso.seccion} · '
                '${horaBonita(h.inicio)}',
          ),
        );
      }
    }

    // Cumpleaños.
    if (d.ajustes.cumples) {
      for (final (e, c) in d.cumples) {
        final n = e.nacimiento;
        if (n == null || n.length < 10 || n.substring(5) != k.substring(5)) {
          continue;
        }
        agregar(
          Aviso(
            'b:${e.id}:$k',
            _conHora(dia, null),
            'Hoy cumple años ${_primero(e.nombres)} ${_primero(e.apellidos)}',
            '${c.grado} ${c.seccion} · ${c.nombre}',
          ),
        );
      }
    }

    // Cierre del periodo: 3 días antes y el mismo día.
    if (d.ajustes.cierre) {
      for (final p in d.periodos) {
        final fin = p.fin;
        if (fin == null) continue;
        final f = DateTime.parse(fin);
        final faltan = DateTime.utc(f.year, f.month, f.day)
            .difference(DateTime.utc(dia.year, dia.month, dia.day))
            .inDays;
        if (faltan != 3 && faltan != 0) continue;
        agregar(
          Aviso(
            'p:${p.nombre}:$k',
            _conHora(dia, null, defecto: 8),
            faltan == 0
                ? 'Hoy cierra el ${p.nombre}'
                : 'Faltan 3 días para cerrar el ${p.nombre}',
            'Revisa que estén todas las notas en tus registros.',
          ),
        );
      }
    }

    // Pendientes que vencen ese día.
    if (d.ajustes.pendientes) {
      for (final p in d.pendientes) {
        if (p.hecho || p.vence != k) continue;
        agregar(
          Aviso(
            't:${p.id}:$k',
            _conHora(dia, null, defecto: 8),
            'Pendiente para hoy',
            p.texto,
          ),
        );
      }
    }
  }

  r.sort((a, b) => a.cuando.compareTo(b.cuando));
  return r;
}

String _mayus(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _primero(String s) {
  final p = s.trim().split(RegExp(r'\s+')).first.toLowerCase();
  return p.isEmpty ? p : p[0].toUpperCase() + p.substring(1);
}
