import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';

/// Todo lo que va en el reporte de asistencia de un periodo.
class ReporteAsistencia {
  final String colegio;
  final Curso curso;
  final String periodo;
  final String? desde;
  final String? hasta;
  final String docente;
  final Color color;
  final List<Estudiante> estudiantes;
  final List<String> fechas;
  final Map<(int, String), Asistencia> marcas;

  const ReporteAsistencia({
    required this.colegio,
    required this.curso,
    required this.periodo,
    required this.desde,
    required this.hasta,
    required this.docente,
    required this.color,
    required this.estudiantes,
    required this.fechas,
    required this.marcas,
  });

  String get titulo =>
      'Asistencia ${curso.nombre} ${curso.grado} ${curso.seccion}';
  String get archivo =>
      'asistencia-${curso.nombre}-${curso.grado}${curso.seccion}-$periodo'
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9áéíóúñ]+'), '-');

  String get rango => desde == null || hasta == null
      ? ''
      : '${_dia(desde!)} al ${_dia(hasta!)} ${hasta!.substring(0, 4)}';

  ({int p, int t, int f, int j, int total, int? pct}) resumen(Estudiante e) {
    var p = 0, t = 0, f = 0, j = 0;
    for (final d in fechas) {
      switch (marcas[(e.id, d)]?.estado) {
        case 'P':
          p++;
        case 'T':
          t++;
        case 'F':
          f++;
        case 'J':
          j++;
      }
    }
    final total = p + t + f + j;
    return (
      p: p,
      t: t,
      f: f,
      j: j,
      total: total,
      pct: total == 0 ? null : ((p + t) * 100 / total).round(),
    );
  }

  List<Asistencia> get conNota => [
    for (final e in estudiantes)
      for (final d in fechas)
        if (marcas[(e.id, d)] case final a? when (a.nota ?? a.motivo) != null)
          a,
  ]..sort((a, b) => a.fecha.compareTo(b.fecha));
}

String _dia(String f) =>
    DateFormat('d MMM', 'es_PE').format(DateTime.parse(f)).replaceAll('.', '');

const _nombreEstado = {
  'P': 'Presente',
  'T': 'Tarde',
  'F': 'Falta',
  'J': 'Justificada',
};
const _tarde = Color(0xFFE9A23B);
const _falta = Color(0xFFE0697A);
const _justif = Color(0xFF6C7BD9);
const _tinta = Color(0xFF1F1B2E);
const _gris = Color(0xFF6E6A80);

Color colorEstado(String estado, Color base) => switch (estado) {
  'T' => _tarde,
  'F' => _falta,
  'J' => _justif,
  _ => base,
};

PdfColor _pdf(Color c) => PdfColor(c.r, c.g, c.b);
PdfColor _suave(Color c, double t) => _pdf(Color.lerp(c, Colors.white, t)!);

// PDF

const _verde = Color(0xFF2FA66A);
const _iniciales = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

PdfColor _osc(Color c, double t) => _pdf(Color.lerp(c, Colors.black, t)!);

Future<Uint8List> pdfAsistencia(ReporteAsistencia r) async {
  Future<pw.Font> fuente(String f) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-$f.ttf'));
  final normal = await fuente('Regular');
  final media = await fuente('Medium');
  final negrita = await fuente('SemiBold');
  final fuerte = await fuente('Bold');
  final base = r.color;
  final doc = pw.Document(
    title: r.titulo,
    author: r.docente,
    creator: 'Kipu Docente',
    theme: pw.ThemeData.withFont(base: normal, bold: negrita),
  );
  final hoy = DateFormat(
    "d 'de' MMMM 'de' yyyy",
    'es_PE',
  ).format(DateTime.now());
  final linea = _suave(_tinta, .9);
  final dias = [for (final f in r.fechas) DateTime.parse(f)];
  final tutor = r.curso.tutor?.trim() ?? '';

  pw.Widget texto(
    String s, {
    double size = 8,
    pw.Font? font,
    PdfColor? color,
    double ls = 0,
  }) => pw.Text(
    s,
    style: pw.TextStyle(
      font: font ?? normal,
      fontSize: size,
      color: color ?? _pdf(_tinta),
      letterSpacing: ls,
    ),
  );

  pw.Widget celda(String? e) {
    if (e == null) {
      return pw.Center(child: texto('·', size: 9, color: _suave(_gris, .5)));
    }
    if (e == 'P') {
      return pw.Center(
        child: pw.Container(
          width: 5.5,
          height: 5.5,
          decoration: pw.BoxDecoration(
            color: _pdf(base),
            shape: pw.BoxShape.circle,
          ),
        ),
      );
    }
    final c = colorEstado(e, base);
    return pw.Center(
      child: pw.Container(
        width: 13,
        height: 13,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          color: _suave(c, .8),
          borderRadius: pw.BorderRadius.circular(3.5),
        ),
        child: texto(e, size: 7.3, font: fuerte, color: _osc(c, .3)),
      ),
    );
  }

  Color colorPct(int? p) => p == null
      ? _gris
      : p < 80
      ? _falta
      : p >= 95
      ? _verde
      : base;

  pw.Widget pastilla(int? p) {
    final c = colorPct(p);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.6),
      decoration: pw.BoxDecoration(
        color: _suave(c, .84),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: texto(
        p == null ? '—' : '$p%',
        size: 7.3,
        font: fuerte,
        color: _osc(c, .3),
      ),
    );
  }

  // Indicadores del aula.
  var asist = 0, total = 0, faltas = 0, tardes = 0, justif = 0, riesgo = 0;
  for (final e in r.estudiantes) {
    final s = r.resumen(e);
    asist += s.p + s.t;
    total += s.total;
    faltas += s.f;
    tardes += s.t;
    justif += s.j;
    if (s.pct != null && s.pct! < 80) riesgo++;
  }
  final pctAula = total == 0 ? '—' : '${(asist * 100 / total).round()}%';
  final porFecha = [
    for (final d in r.fechas)
      () {
        var a = 0, n = 0;
        for (final e in r.estudiantes) {
          final m = r.marcas[(e.id, d)]?.estado;
          if (m == null) continue;
          n++;
          if (m == 'P' || m == 'T') a++;
        }
        return n == 0 ? null : a / n;
      }(),
  ];

  pw.Widget indicador(
    String valor,
    String etiqueta,
    String sub,
    Color c, {
    double? progreso,
  }) => pw.Expanded(
    child: pw.Container(
      height: 58,
      padding: const pw.EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: pw.BoxDecoration(
        color: _suave(c, .92),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              texto(valor, size: 17, font: fuerte, color: _osc(c, .2)),
              pw.SizedBox(width: 6),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: texto(sub, size: 7, color: _osc(c, .05)),
              ),
            ],
          ),
          texto(etiqueta, size: 7.5, color: _pdf(_gris)),
          if (progreso != null) ...[
            pw.SizedBox(height: 4),
            pw.Stack(
              children: [
                pw.Container(
                  height: 3.5,
                  decoration: pw.BoxDecoration(
                    color: _suave(c, .78),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.LayoutBuilder(
                  builder: (ctx, k) => pw.Container(
                    width: (k?.maxWidth ?? 100) * progreso.clamp(0, 1),
                    height: 3.5,
                    decoration: pw.BoxDecoration(
                      color: _pdf(c),
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  pw.Widget dato(String k, String v) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      texto(k, size: 6.3, font: negrita, color: _pdf(_gris), ls: 1.2),
      texto(v, size: 9.3, font: media),
    ],
  );

  // Tabla principal.
  const wN = 22.0, wNom = 168.0, wPct = 52.0, wMini = 19.0;
  final muchas = r.fechas.length > 24;
  final cab = _pdf(Colors.white);

  final meses = <(String, int)>[];
  for (final d in dias) {
    final n = DateFormat('MMMM', 'es_PE').format(d).toUpperCase();
    if (meses.isEmpty || meses.last.$1 != n) {
      meses.add((n, 1));
    } else {
      meses[meses.length - 1] = (n, meses.last.$2 + 1);
    }
  }
  final filaMeses = pw.Row(
    children: [
      pw.SizedBox(width: wN + wNom),
      pw.Expanded(
        child: pw.Row(
          children: [
            for (final g in meses)
              pw.Expanded(
                flex: g.$2,
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                  padding: const pw.EdgeInsets.only(bottom: 2.5, left: 2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: _pdf(base), width: 1.2),
                    ),
                  ),
                  child: texto(
                    // Si el mes tiene pocas clases, solo cabe la abreviatura.
                    g.$2 < 2 ? g.$1.substring(0, 3) : g.$1,
                    size: 6.5,
                    font: negrita,
                    color: _pdf(base),
                    ls: 1.2,
                  ),
                ),
              ),
          ],
        ),
      ),
      pw.SizedBox(width: wPct + wMini * 3),
    ],
  );

  final filas = <pw.TableRow>[
    pw.TableRow(
      decoration: pw.BoxDecoration(color: _osc(base, .15)),
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        _pad(texto('N.°', size: 7, font: negrita, color: cab), centro: true),
        _pad(
          texto(
            'APELLIDOS Y NOMBRES',
            size: 7,
            font: negrita,
            color: cab,
            ls: .4,
          ),
        ),
        for (final d in dias)
          _pad(
            pw.Column(
              children: [
                texto(
                  _iniciales[d.weekday - 1],
                  size: 5.5,
                  color: _suave(base, .55),
                ),
                texto(
                  '${d.day}',
                  size: muchas ? 7 : 8.3,
                  font: negrita,
                  color: cab,
                ),
              ],
            ),
            centro: true,
          ),
        _pad(
          texto('ASIST.', size: 6.5, font: negrita, color: cab),
          centro: true,
        ),
        for (final (s, c) in [('F', _falta), ('T', _tarde), ('J', _justif)])
          _pad(
            texto(s, size: 7.5, font: fuerte, color: _suave(c, .45)),
            centro: true,
          ),
      ],
    ),
  ];

  for (var i = 0; i < r.estudiantes.length; i++) {
    final e = r.estudiantes[i];
    final s = r.resumen(e);
    final bajo = s.pct != null && s.pct! < 80;
    final tinta = bajo ? _osc(_falta, .35) : _pdf(_tinta);
    final fondoResumen = _suave(base, .92);
    filas.add(
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        decoration: pw.BoxDecoration(
          color: bajo
              ? _suave(_falta, .94)
              : i.isOdd
              ? _suave(base, .968)
              : PdfColors.white,
          border: pw.Border(bottom: pw.BorderSide(color: linea, width: .5)),
        ),
        children: [
          _pad(texto('${i + 1}', size: 7.3, color: _pdf(_gris)), centro: true),
          _pad(
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.RichText(
                    maxLines: 1,
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '${e.apellidos.toUpperCase()}, ',
                          style: pw.TextStyle(
                            font: media,
                            fontSize: 7.8,
                            color: tinta,
                          ),
                        ),
                        pw.TextSpan(
                          text: e.nombres,
                          style: pw.TextStyle(
                            font: normal,
                            fontSize: 7.8,
                            color: tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (bajo)
                  pw.Container(
                    width: 9,
                    height: 9,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: _pdf(_falta),
                      shape: pw.BoxShape.circle,
                    ),
                    child: texto('!', size: 6.5, font: fuerte, color: cab),
                  ),
              ],
            ),
          ),
          for (final d in r.fechas) celda(r.marcas[(e.id, d)]?.estado),
          pw.Container(
            color: fondoResumen,
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            alignment: pw.Alignment.center,
            child: pastilla(s.pct),
          ),
          for (final (n, c) in [(s.f, _falta), (s.t, _tarde), (s.j, _justif)])
            pw.Container(
              color: fondoResumen,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              alignment: pw.Alignment.center,
              child: texto(
                '$n',
                size: 7.8,
                font: n == 0 ? normal : fuerte,
                color: n == 0 ? _suave(_gris, .5) : _osc(c, .25),
              ),
            ),
        ],
      ),
    );
  }

  // Asistencia de cada clase y del aula.
  filas.add(
    pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _pdf(_tinta), width: .8)),
      ),
      children: [
        pw.SizedBox(),
        _pad(
          texto(
            'Asistencia por clase',
            size: 7.3,
            font: negrita,
            color: _pdf(_gris),
          ),
        ),
        for (final v in porFecha)
          _pad(
            texto(
              v == null ? '—' : '${(v * 100).round()}',
              size: 7,
              font: negrita,
              color: v != null && v < .8 ? _osc(_falta, .25) : _osc(base, .1),
            ),
            centro: true,
          ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          alignment: pw.Alignment.center,
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: _pdf(base),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: texto(pctAula, size: 7.5, font: fuerte, color: cab),
          ),
        ),
        pw.SizedBox(),
        pw.SizedBox(),
        pw.SizedBox(),
      ],
    ),
  );

  pw.Widget leyenda() => pw.Row(
    children: [
      for (final e in ['P', 'T', 'F', 'J']) ...[
        pw.SizedBox(width: 16, height: 14, child: celda(e)),
        texto(_nombreEstado[e]!, size: 7.3, color: _pdf(_gris)),
        pw.SizedBox(width: 10),
      ],
      pw.SizedBox(width: 16, height: 14, child: celda(null)),
      texto('Sin registro', size: 7.3, color: _pdf(_gris)),
      pw.SizedBox(width: 14),
      for (final (k, c) in [
        ('95 % a más', _verde),
        ('80 – 94 %', base),
        ('menos de 80 %', _falta),
      ]) ...[
        pw.Container(
          width: 7,
          height: 7,
          decoration: pw.BoxDecoration(
            color: _suave(c, .6),
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 3),
        texto(k, size: 7, color: _pdf(_gris)),
        pw.SizedBox(width: 8),
      ],
      pw.Spacer(),
      texto(
        '% = (presentes + tardanzas) / clases registradas',
        size: 6.8,
        color: _suave(_gris, .3),
      ),
    ],
  );

  final notas = r.conNota;
  final porId = {for (final e in r.estudiantes) e.id: e};
  final subtitulo = [
    '${r.curso.nombre} · ${r.curso.grado} ${r.curso.seccion} · ${r.curso.nivel}',
    r.periodo,
    if (r.rango.isNotEmpty) r.rango,
  ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 26),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: texto('${r.titulo} · ${r.periodo}', color: _pdf(_gris)),
            ),
      footer: (ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: linea, width: .6)),
        ),
        child: pw.Row(
          children: [
            texto(
              'Emitido el $hoy con Kipu Docente',
              size: 7,
              color: _pdf(_gris),
            ),
            pw.Spacer(),
            texto(
              'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              size: 7,
              color: _pdf(_gris),
            ),
          ],
        ),
      ),
      build: (ctx) => [
        // Membrete
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 4,
              height: 58,
              decoration: pw.BoxDecoration(
                color: _pdf(base),
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  texto(
                    r.colegio.toUpperCase(),
                    size: 8.5,
                    font: negrita,
                    color: _pdf(base),
                    ls: 1.6,
                  ),
                  pw.SizedBox(height: 3),
                  texto('Registro de asistencia', size: 23, font: fuerte),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    children: [
                      for (final (i, s) in subtitulo.indexed) ...[
                        if (i > 0)
                          pw.Container(
                            width: 3,
                            height: 3,
                            margin: const pw.EdgeInsets.symmetric(
                              horizontal: 7,
                            ),
                            decoration: pw.BoxDecoration(
                              color: _suave(_gris, .4),
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                        texto(s, size: 9, color: _pdf(_gris)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            pw.Container(
              width: 250,
              padding: const pw.EdgeInsets.fromLTRB(12, 9, 12, 9),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: linea, width: .8),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        dato('DOCENTE', r.docente.isEmpty ? '—' : r.docente),
                        if (tutor.isNotEmpty) ...[
                          pw.SizedBox(height: 5),
                          dato('TUTOR(A)', tutor),
                        ],
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      dato('ESTUDIANTES', '${r.estudiantes.length}'),
                      pw.SizedBox(height: 5),
                      dato('CLASES', '${r.fechas.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          children: [
            indicador(
              pctAula,
              'Asistencia del aula',
              '',
              base,
              progreso: total == 0 ? null : asist / total,
            ),
            pw.SizedBox(width: 8),
            indicador('$riesgo', 'Estudiantes bajo 80 %', 'en riesgo', _falta),
            pw.SizedBox(width: 8),
            indicador('$faltas', 'Faltas', '+ $justif justificadas', _falta),
            pw.SizedBox(width: 8),
            indicador(
              '$tardes',
              'Tardanzas',
              total == 0
                  ? ''
                  : '${(tardes * 100 / total).toStringAsFixed(1)} % de marcas',
              _tarde,
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        filaMeses,
        pw.SizedBox(height: 3),
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(wN),
            1: const pw.FixedColumnWidth(wNom),
            for (var i = 0; i < r.fechas.length; i++)
              i + 2: const pw.FlexColumnWidth(),
            r.fechas.length + 2: const pw.FixedColumnWidth(wPct),
            for (var i = 3; i < 6; i++)
              r.fechas.length + i: const pw.FixedColumnWidth(wMini),
          },
          children: filas,
        ),
        pw.SizedBox(height: 8),
        leyenda(),
        if (notas.isNotEmpty) ...[
          pw.SizedBox(height: 18),
          texto(
            'OBSERVACIONES',
            size: 8.5,
            font: negrita,
            color: _pdf(base),
            ls: 1.4,
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            columnWidths: const {
              0: pw.FixedColumnWidth(58),
              1: pw.FixedColumnWidth(190),
              2: pw.FixedColumnWidth(80),
              3: pw.FixedColumnWidth(90),
              4: pw.FlexColumnWidth(),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: _pdf(_tinta), width: .8),
                  ),
                ),
                children: [
                  for (final t in [
                    'Fecha',
                    'Estudiante',
                    'Estado',
                    'Motivo',
                    'Nota',
                  ])
                    _pad(texto(t, size: 7.5, font: negrita)),
                ],
              ),
              for (final (i, a) in notas.indexed)
                if (porId[a.estudianteId] case final e?)
                  pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    decoration: pw.BoxDecoration(
                      color: i.isOdd ? _suave(base, .965) : null,
                      border: pw.Border(
                        bottom: pw.BorderSide(color: linea, width: .5),
                      ),
                    ),
                    children: [
                      _pad(texto(_dia(a.fecha), size: 7.8, font: media)),
                      _pad(
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: '${e.apellidos.toUpperCase()}, ',
                                style: pw.TextStyle(font: media, fontSize: 7.8),
                              ),
                              pw.TextSpan(
                                text: e.nombres,
                                style: const pw.TextStyle(fontSize: 7.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _pad(
                        pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: _pdf(colorEstado(a.estado, base)),
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            texto(
                              _nombreEstado[a.estado] ?? a.estado,
                              size: 7.8,
                              font: media,
                              color: _osc(colorEstado(a.estado, base), .3),
                            ),
                          ],
                        ),
                      ),
                      _pad(
                        texto(a.motivo ?? '—', size: 7.8, color: _pdf(_gris)),
                      ),
                      _pad(texto(a.nota ?? '', size: 7.8, color: _pdf(_gris))),
                    ],
                  ),
            ],
          ),
        ],
        // Firmas
        pw.Row(
          children: [
            for (final (rol, nombre) in [
              (
                'Docente de ${r.curso.nombre}',
                r.docente.isEmpty ? 'Firma del docente' : r.docente,
              ),
              if (tutor.isNotEmpty) ('Tutor(a) del aula', tutor),
              ('Dirección', 'Sello y firma'),
            ])
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 40),
                    pw.Container(
                      height: .7,
                      color: _suave(_tinta, .4),
                      margin: const pw.EdgeInsets.symmetric(horizontal: 40),
                    ),
                    pw.SizedBox(height: 4),
                    texto(nombre, size: 8.3, font: media),
                    texto(rol, size: 7, color: _pdf(_gris)),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _pad(pw.Widget w, {bool centro = false}) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
  alignment: centro ? pw.Alignment.center : pw.Alignment.centerLeft,
  child: w,
);

// Excel

Uint8List excelAsistencia(ReporteAsistencia r) {
  final x = xl.Excel.createExcel();
  final defecto = x.getDefaultSheet()!;
  x.rename(defecto, 'Asistencia');
  final h = x['Asistencia'];
  String hex(Color c) =>
      'FF${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  xl.ExcelColor col(Color c) => xl.ExcelColor.fromHexString(hex(c));
  final base = r.color;
  final oscuro = Color.lerp(base, Colors.black, .15)!;
  final borde = xl.Border(
    borderStyle: xl.BorderStyle.Thin,
    borderColorHex: col(const Color(0xFFE2E3EE)),
  );
  xl.CellStyle estilo({
    Color? fondo,
    Color texto = _tinta,
    bool negrita = false,
    int tam = 10,
    bool centro = false,
    bool bordes = true,
  }) => xl.CellStyle(
    backgroundColorHex: fondo == null ? xl.ExcelColor.none : col(fondo),
    fontColorHex: col(texto),
    bold: negrita,
    fontSize: tam,
    fontFamily: 'Calibri',
    horizontalAlign: centro
        ? xl.HorizontalAlign.Center
        : xl.HorizontalAlign.Left,
    verticalAlign: xl.VerticalAlign.Center,
    leftBorder: bordes ? borde : null,
    rightBorder: bordes ? borde : null,
    topBorder: bordes ? borde : null,
    bottomBorder: bordes ? borde : null,
  );
  void poner(int c, int f, Object? v, xl.CellStyle s) => h.updateCell(
    xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: f),
    switch (v) {
      final int n => xl.IntCellValue(n),
      null => null,
      _ => xl.TextCellValue('$v'),
    },
    cellStyle: s,
  );

  final ultima = r.fechas.length + 5;
  void titulo(int fila, String t, xl.CellStyle s) {
    poner(0, fila, t, s);
    h.merge(
      xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: fila),
      xl.CellIndex.indexByColumnRow(columnIndex: ultima, rowIndex: fila),
    );
  }

  titulo(
    0,
    r.colegio.toUpperCase(),
    estilo(texto: base, negrita: true, tam: 10, bordes: false),
  );
  titulo(
    1,
    'Registro de asistencia',
    estilo(negrita: true, tam: 18, bordes: false),
  );
  titulo(
    2,
    [
      '${r.curso.nombre} · ${r.curso.grado} ${r.curso.seccion} · ${r.curso.nivel}',
      r.periodo,
      if (r.rango.isNotEmpty) r.rango,
      if (r.docente.isNotEmpty) 'Docente: ${r.docente}',
    ].join('   |   '),
    estilo(texto: _gris, bordes: false),
  );
  h.setRowHeight(1, 28);

  const f0 = 4;
  final cab = estilo(
    fondo: oscuro,
    texto: Colors.white,
    negrita: true,
    centro: true,
  );
  poner(0, f0, 'N.°', cab);
  poner(
    1,
    f0,
    'APELLIDOS Y NOMBRES',
    estilo(fondo: oscuro, texto: Colors.white, negrita: true),
  );
  for (var i = 0; i < r.fechas.length; i++) {
    poner(
      i + 2,
      f0,
      DateFormat('dd/MM').format(DateTime.parse(r.fechas[i])),
      cab,
    );
  }
  final resumenes = ['%', 'F', 'T', 'J'];
  for (var i = 0; i < 4; i++) {
    poner(r.fechas.length + 2 + i, f0, resumenes[i], cab);
  }
  h.setRowHeight(f0, 22);

  for (var i = 0; i < r.estudiantes.length; i++) {
    final e = r.estudiantes[i];
    final f = f0 + 1 + i;
    final zebra = i.isOdd
        ? Color.lerp(base, Colors.white, .965)!
        : Colors.white;
    poner(0, f, i + 1, estilo(fondo: zebra, texto: _gris, centro: true));
    poner(
      1,
      f,
      '${e.apellidos.toUpperCase()}, ${e.nombres}',
      estilo(fondo: Color.lerp(base, Colors.white, .94)),
    );
    for (var j = 0; j < r.fechas.length; j++) {
      final m = r.marcas[(e.id, r.fechas[j])]?.estado;
      final c = m == null ? null : colorEstado(m, base);
      poner(
        j + 2,
        f,
        m ?? '',
        m == null
            ? estilo(fondo: zebra, centro: true)
            : estilo(
                fondo: m == 'P' ? zebra : Color.lerp(c, Colors.white, .8),
                texto: Color.lerp(c, Colors.black, .2)!,
                negrita: m != 'P',
                centro: true,
              ),
      );
    }
    final s = r.resumen(e);
    final calc = Color.lerp(base, Colors.white, .88)!;
    final cc = r.fechas.length + 2;
    poner(
      cc,
      f,
      s.pct == null ? '—' : '${s.pct}%',
      estilo(
        fondo: calc,
        negrita: true,
        centro: true,
        texto: s.pct != null && s.pct! < 80
            ? Color.lerp(_falta, Colors.black, .2)!
            : _tinta,
      ),
    );
    poner(cc + 1, f, s.f, estilo(fondo: calc, centro: true));
    poner(cc + 2, f, s.t, estilo(fondo: calc, centro: true));
    poner(cc + 3, f, s.j, estilo(fondo: calc, centro: true));
    h.setRowHeight(f, 18);
  }
  final fl = f0 + r.estudiantes.length + 2;
  poner(
    1,
    fl,
    'P = Presente   T = Tarde   F = Falta   J = Justificada   % = (presentes + tardanzas) / clases',
    estilo(texto: _gris, tam: 9, bordes: false),
  );

  h.setColumnWidth(0, 6);
  h.setColumnWidth(1, 38);
  for (var i = 0; i < r.fechas.length; i++) {
    h.setColumnWidth(i + 2, 6.5);
  }
  for (var i = 0; i < 4; i++) {
    h.setColumnWidth(r.fechas.length + 2 + i, i == 0 ? 8 : 5.5);
  }

  // Hoja con las notitas de cada asistencia.
  final notas = r.conNota;
  if (notas.isNotEmpty) {
    final o = x['Observaciones'];
    final porId = {for (final e in r.estudiantes) e.id: e};
    final cabO = estilo(fondo: oscuro, texto: Colors.white, negrita: true);
    final titulos = ['Fecha', 'Estudiante', 'Estado', 'Motivo', 'Nota'];
    for (var i = 0; i < titulos.length; i++) {
      o.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        xl.TextCellValue(titulos[i]),
        cellStyle: cabO,
      );
    }
    var f = 1;
    for (final a in notas) {
      final e = porId[a.estudianteId];
      if (e == null) continue;
      final valores = [
        DateFormat('dd/MM/yyyy').format(DateTime.parse(a.fecha)),
        '${e.apellidos.toUpperCase()}, ${e.nombres}',
        _nombreEstado[a.estado] ?? a.estado,
        a.motivo ?? '',
        a.nota ?? '',
      ];
      for (var i = 0; i < valores.length; i++) {
        o.updateCell(
          xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: f),
          xl.TextCellValue(valores[i]),
          cellStyle: estilo(
            fondo: f.isEven
                ? Color.lerp(base, Colors.white, .965)
                : Colors.white,
          ),
        );
      }
      f++;
    }
    for (final (i, w) in [12.0, 38.0, 14.0, 18.0, 60.0].indexed) {
      o.setColumnWidth(i, w);
    }
  }
  return Uint8List.fromList(x.encode()!);
}
