import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Íconos propios de Kipu, en estilo bicolor: trazo en el color principal y
/// relleno suave en el mismo color con transparencia.
enum KipuIcono {
  inicio,
  cursos,
  horario,
  asistencia,
  notas,
  reportes,
  diario,
  planificacion,
  copia,
  colegio,
  secciones,
  estudiantes,
  campana,
  buscar,
  calendario,
  mas,
  ubicacion,
  editar,
  estrella,
  cumple,
  ayuda,
  salir,
  ajustes,
  cerrar,
  check,
  abajo,
  flecha,
  agregar,
  borrar,
  ordenar,
  aviso,
  paleta,
}

// R = relleno suave, T = trazo. Ambos se reemplazan por el color al dibujar.
const _svg = <KipuIcono, String>{
  KipuIcono.inicio: '''
<rect x="3" y="3" width="8" height="10" rx="2.5" fill="R"/>
<rect x="13" y="11" width="8" height="10" rx="2.5" fill="R"/>
<rect x="3" y="3" width="8" height="10" rx="2.5" stroke="T"/>
<rect x="13" y="3" width="8" height="6" rx="2.5" stroke="T"/>
<rect x="3" y="15" width="8" height="6" rx="2.5" stroke="T"/>
<rect x="13" y="11" width="8" height="10" rx="2.5" stroke="T"/>''',
  KipuIcono.cursos: '''
<path d="M3 5.5C3 4.7 3.7 4 4.5 4H9c1.7 0 3 1.3 3 3v13c0-1.1-.9-2-2-2H4.5c-.8 0-1.5-.7-1.5-1.5v-11Z" fill="R"/>
<path d="M3 5.5C3 4.7 3.7 4 4.5 4H9c1.7 0 3 1.3 3 3v13c0-1.1-.9-2-2-2H4.5c-.8 0-1.5-.7-1.5-1.5v-11Z" stroke="T"/>
<path d="M21 5.5c0-.8-.7-1.5-1.5-1.5H15c-1.7 0-3 1.3-3 3v13c0-1.1.9-2 2-2h5.5c.8 0 1.5-.7 1.5-1.5v-11Z" stroke="T"/>
<path d="M15 8h3M15 11h3" stroke="T"/>''',
  KipuIcono.horario: '''
<circle cx="12" cy="12" r="9" fill="R"/>
<circle cx="12" cy="12" r="9" stroke="T"/>
<path d="M12 7v5l3.5 2" stroke="T"/>''',
  KipuIcono.asistencia: '''
<rect x="4" y="3" width="16" height="18" rx="3" fill="R"/>
<rect x="4" y="3" width="16" height="18" rx="3" stroke="T"/>
<path d="m8 8.5 1.5 1.5L12 7.5M8 15l1.5 1.5L12 14M14.5 9h2M14.5 15.5h2" stroke="T"/>''',
  KipuIcono.notas: '''
<path d="M5 3h10l4 4v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" fill="R"/>
<path d="M5 3h10l4 4v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" stroke="T"/>
<path d="M7 9h4M7 13h7M7 17h3" stroke="T"/>
<path d="m14 17 1.5 1.5 3-3" stroke="T"/>''',
  KipuIcono.reportes: '''
<path d="M12 3a9 9 0 1 0 9 9h-9V3Z" fill="R"/>
<path d="M12 3a9 9 0 1 0 9 9h-9V3Z" stroke="T"/>
<path d="M15 2.5A7 7 0 0 1 21.5 9H15V2.5Z" stroke="T"/>''',
  KipuIcono.diario: '''
<rect x="5" y="3" width="14" height="18" rx="2.5" fill="R"/>
<rect x="5" y="3" width="14" height="18" rx="2.5" stroke="T"/>
<circle cx="12" cy="10" r="2.5" stroke="T"/>
<path d="M8.5 16.5c.6-1.8 2-2.7 3.5-2.7s2.9.9 3.5 2.7M3 7h2M3 12h2M3 17h2" stroke="T"/>''',
  KipuIcono.planificacion: '''
<rect x="4" y="4" width="16" height="17" rx="3" fill="R"/>
<rect x="4" y="4" width="16" height="17" rx="3" stroke="T"/>
<rect x="8.5" y="2.5" width="7" height="3.5" rx="1.5" stroke="T"/>
<path d="m8 13 2.5 2.5L16 10" stroke="T"/>''',
  KipuIcono.copia: '''
<path d="M7 18h10.5a4 4 0 0 0 .6-8A6 6 0 0 0 6.5 9.3 4.4 4.4 0 0 0 7 18Z" fill="R"/>
<path d="M7 18h10.5a4 4 0 0 0 .6-8A6 6 0 0 0 6.5 9.3 4.4 4.4 0 0 0 7 18Z" stroke="T"/>
<path d="M12 15.5v-5m0 0-2 2m2-2 2 2" stroke="T"/>''',
  KipuIcono.colegio: '''
<path d="M4 10h16v10H4z" fill="R"/>
<path d="M2.5 10 12 4l9.5 6M4 10v10h16V10M2 20h20" stroke="T"/>
<path d="M10 20v-4h4v4M7 13h2M15 13h2M12 4V1.8h3" stroke="T"/>''',
  KipuIcono.secciones: '''
<circle cx="12" cy="8" r="3.5" fill="R"/>
<circle cx="12" cy="8" r="3.5" stroke="T"/>
<path d="M5.5 20c.7-3.4 3.3-5.5 6.5-5.5s5.8 2.1 6.5 5.5" stroke="T"/>
<path d="M4.5 13.5A3 3 0 0 1 6 8M19.5 13.5A3 3 0 0 0 18 8M2 18c.3-1.4 1-2.5 2-3.2M22 18c-.3-1.4-1-2.5-2-3.2" stroke="T"/>''',
  KipuIcono.estudiantes: '''
<path d="M12 4 2 9l10 5 10-5-10-5Z" fill="R"/>
<path d="M12 4 2 9l10 5 10-5-10-5Z" stroke="T"/>
<path d="M6 11v5c0 1.7 2.7 3 6 3s6-1.3 6-3v-5M21 9.5V15" stroke="T"/>''',
  KipuIcono.campana: '''
<path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2h-15L6 16Z" fill="R"/>
<path d="M6 16V11a6 6 0 1 1 12 0v5l1.5 2h-15L6 16Z" stroke="T"/>
<path d="M10 21h4" stroke="T"/>''',
  KipuIcono.buscar: '''
<circle cx="11" cy="11" r="7" fill="R"/>
<circle cx="11" cy="11" r="7" stroke="T"/>
<path d="m16.5 16.5 4 4" stroke="T"/>''',
  KipuIcono.calendario: '''
<rect x="3" y="5" width="18" height="16" rx="3" fill="R"/>
<rect x="3" y="5" width="18" height="16" rx="3" stroke="T"/>
<path d="M3 10h18M8 3v4M16 3v4" stroke="T"/>
<rect x="7" y="13" width="3" height="3" rx=".8" stroke="T"/>''',
  KipuIcono.mas: '''
<circle cx="12" cy="12" r="9" fill="R"/>
<circle cx="7.5" cy="12" r="1" stroke="T"/>
<circle cx="12" cy="12" r="1" stroke="T"/>
<circle cx="16.5" cy="12" r="1" stroke="T"/>''',
  KipuIcono.ubicacion: '''
<path d="M12 21s7-6 7-11.5a7 7 0 1 0-14 0C5 15 12 21 12 21Z" fill="R"/>
<path d="M12 21s7-6 7-11.5a7 7 0 1 0-14 0C5 15 12 21 12 21Z" stroke="T"/>
<circle cx="12" cy="9.5" r="2.5" stroke="T"/>''',
  KipuIcono.editar: '''
<path d="m4 20 1-4L16 5l3 3L8 19l-4 1Z" fill="R"/>
<path d="m4 20 1-4L16 5l3 3L8 19l-4 1ZM14 7l3 3" stroke="T"/>''',
  KipuIcono.estrella: '''
<path d="m12 3 2.7 5.6 6.1.8-4.5 4.2 1.1 6.1L12 16.8l-5.4 2.9 1.1-6.1-4.5-4.2 6.1-.8L12 3Z" fill="R"/>
<path d="m12 3 2.7 5.6 6.1.8-4.5 4.2 1.1 6.1L12 16.8l-5.4 2.9 1.1-6.1-4.5-4.2 6.1-.8L12 3Z" stroke="T"/>''',
  KipuIcono.cumple: '''
<rect x="4" y="11" width="16" height="9" rx="2" fill="R"/>
<rect x="4" y="11" width="16" height="9" rx="2" stroke="T"/>
<path d="M4 15c2 1.3 4 1.3 5.3 0 1.4 1.3 4 1.3 5.4 0 1.3 1.3 3.3 1.3 5.3 0M8 11V8M12 11V8M16 11V8" stroke="T"/>
<path d="M8 5.5v-.1M12 5.5v-.1M16 5.5v-.1" stroke="T" stroke-width="2.6"/>''',
  KipuIcono.ayuda: '''
<circle cx="12" cy="12" r="9" fill="R"/>
<circle cx="12" cy="12" r="9" stroke="T"/>
<path d="M9.5 9.5a2.5 2.5 0 1 1 3.6 2.2c-.7.4-1.1 1-1.1 1.8M12 16.5v.1" stroke="T"/>''',
  KipuIcono.salir: '''
<path d="M4 5a2 2 0 0 1 2-2h7v18H6a2 2 0 0 1-2-2V5Z" fill="R"/>
<path d="M13 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h7M16 8l4 4-4 4M20 12H10" stroke="T"/>''',
  KipuIcono.ajustes: '''
<rect x="3" y="4" width="18" height="16" rx="4" fill="R"/>
<path d="M4 8h9M17 8h3M4 16h3M11 16h9" stroke="T"/>
<circle cx="15" cy="8" r="2" stroke="T"/>
<circle cx="9" cy="16" r="2" stroke="T"/>''',
  // Íconos de línea para controles (cerrar, elegir, desplegar, ir).
  KipuIcono.cerrar: '''
<path d="M6.5 6.5l11 11M17.5 6.5l-11 11" stroke="T"/>''',
  KipuIcono.check: '''
<path d="m5 12.5 4.5 4.5L19 7.5" stroke="T"/>''',
  KipuIcono.abajo: '''
<path d="m7 10 5 5 5-5" stroke="T"/>''',
  KipuIcono.flecha: '''
<path d="M5 12h14M13 6l6 6-6 6" stroke="T"/>''',
  KipuIcono.agregar: '''
<path d="M12 5v14M5 12h14" stroke="T"/>''',
  KipuIcono.borrar: '''
<path d="M6 7h12l-1 12.5a2 2 0 0 1-2 1.5H9a2 2 0 0 1-2-1.5L6 7Z" fill="R"/>
<path d="M4 7h16M9.5 7V4.5h5V7M6 7l1 12.5a2 2 0 0 0 2 1.5h6a2 2 0 0 0 2-1.5L18 7M10 11v6M14 11v6" stroke="T"/>''',
  KipuIcono.ordenar: '''
<path d="M8 19V5M4.5 8.5 8 5l3.5 3.5M16 5v14M12.5 15.5 16 19l3.5-3.5" stroke="T"/>''',
  KipuIcono.aviso: '''
<path d="M10.3 4.2a2 2 0 0 1 3.4 0l7.5 13a2 2 0 0 1-1.7 3H4.5a2 2 0 0 1-1.7-3l7.5-13Z" fill="R"/>
<path d="M10.3 4.2a2 2 0 0 1 3.4 0l7.5 13a2 2 0 0 1-1.7 3H4.5a2 2 0 0 1-1.7-3l7.5-13ZM12 9.5v4M12 16.8v.1" stroke="T"/>''',
  KipuIcono.paleta: '''
<path d="M12 3a9 9 0 0 0 0 18c1.2 0 1.8-.8 1.8-1.7 0-1.2-1-1.6-1-2.6 0-1 .8-1.7 1.8-1.7h2.1A4.3 4.3 0 0 0 21 10.7C21 6.4 17 3 12 3Z" fill="R"/>
<path d="M12 3a9 9 0 0 0 0 18c1.2 0 1.8-.8 1.8-1.7 0-1.2-1-1.6-1-2.6 0-1 .8-1.7 1.8-1.7h2.1A4.3 4.3 0 0 0 21 10.7C21 6.4 17 3 12 3Z" stroke="T"/>
<circle cx="7.5" cy="11" r="1" stroke="T"/><circle cx="10" cy="7" r="1" stroke="T"/><circle cx="15" cy="7.5" r="1" stroke="T"/>''',
};

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

class KipuIcon extends StatelessWidget {
  final KipuIcono icono;
  final double size;
  final Color? color;

  const KipuIcon(this.icono, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    final hex = _hex(c);
    final cuerpo = _svg[icono]!
        .replaceAll('fill="R"', 'fill="$hex" fill-opacity="0.22" stroke="none"')
        .replaceAll('stroke="T"', 'stroke="$hex" fill="none"');
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
      'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'
      '$cuerpo</svg>',
      width: size,
      height: size,
    );
  }
}
