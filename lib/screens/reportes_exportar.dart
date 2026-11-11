import 'dart:math' show max;

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import '../data/diario_db.dart';
import '../data/registro.dart' show tituloNombre;
import '../data/reportes.dart';

const _tinta = Color(0xFF1F1B2E);
const _gris = Color(0xFF6E6A80);
const _verde = Color(0xFF16A37F);
const _rojo = Color(0xFFC2334A);

PdfColor _pdf(Color c) => PdfColor(c.r, c.g, c.b);
PdfColor _suave(Color c, double t) => _pdf(Color.lerp(c, Colors.white, t)!);

String _nombre(Estudiante e) =>
    '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres)}';

/// Color de una nota en 0–20 según «Color de las notas».
Color colorNota(double? n) {
  if (n == null) return _gris;
  final t = tramosReporte();
  var c = t.first.color;
  for (final x in t) {
    if (n.roundToDouble() >= x.desde) c = x.color;
  }
  return Color(c);
}

String nombrePeriodoCorto(String nombre, int i) {
  final m = RegExp(r'^(\d+)').firstMatch(nombre);
  final letra = nombre.toLowerCase().contains('trimestre')
      ? 'T'
      : (nombre.toLowerCase().contains('semestre') ? 'S' : 'B');
  return '$letra${m?.group(1) ?? i}';
}

/// Lo común de las descargas.
class InfoReporte {
  final String docente;
  final String alcance; // «2.° bimestre», «Año 2026»…
  final int anio;
  final int? periodo;
  final Color color;
  const InfoReporte({
    required this.docente,
    required this.alcance,
    required this.anio,
    required this.periodo,
    required this.color,
  });
}

class _Fuentes {
  final pw.Font normal, media, negrita, fuerte;
  _Fuentes(this.normal, this.media, this.negrita, this.fuerte);

  static Future<_Fuentes> cargar() async {
    Future<pw.Font> f(String n) async =>
        pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-$n.ttf'));
    return _Fuentes(
      await f('Regular'),
      await f('Medium'),
      await f('SemiBold'),
      await f('Bold'),
    );
  }
}

String get _hoy =>
    DateFormat("d 'de' MMMM 'de' yyyy", 'es_PE').format(DateTime.now());

// ───────────────────────── PDF: consolidado ─────────────────────────

/// Reporte de notas: portada con resumen y, por curso, la tabla de notas de
/// cada periodo con el promedio anual.
Future<Uint8List> pdfConsolidado(List<DatosCurso> cursos, InfoReporte info) async {
  final f = await _Fuentes.cargar();
  final base = info.color;
  final doc = pw.Document(
    title: 'Reporte de notas · ${info.alcance}',
    author: info.docente,
    creator: 'Kipu Docente',
    theme: pw.ThemeData.withFont(base: f.normal, bold: f.negrita),
  );

  pw.Widget t(
    String s, {
    double size = 9,
    pw.Font? font,
    PdfColor? color,
    pw.TextAlign? align,
  }) => pw.Text(
    s,
    textAlign: align,
    style: pw.TextStyle(
      font: font ?? f.normal,
      fontSize: size,
      color: color ?? _pdf(_tinta),
    ),
  );

  pw.Widget cabecera(String titulo, String sub) => pw.Container(
    padding: const pw.EdgeInsets.fromLTRB(18, 14, 18, 14),
    margin: const pw.EdgeInsets.only(bottom: 14),
    decoration: pw.BoxDecoration(
      color: _pdf(base),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              t(sub.toUpperCase(), size: 8, font: f.media, color: _suave(base, .65)),
              pw.SizedBox(height: 3),
              t(titulo, size: 17, font: f.fuerte, color: PdfColors.white),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            t(info.alcance, size: 10, font: f.negrita, color: PdfColors.white),
            t(info.docente, size: 8, color: _suave(base, .65)),
          ],
        ),
      ],
    ),
  );

  pw.Widget kpi(String titulo, String valor, {String? nota, Color? color}) =>
      pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.only(right: 8),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: _suave(color ?? base, .92),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              t(titulo, size: 8, color: _pdf(_gris)),
              pw.SizedBox(height: 2),
              t(valor, size: 16, font: f.fuerte, color: _pdf(color ?? base)),
              if (nota != null) t(nota, size: 7.5, color: _pdf(_gris)),
            ],
          ),
        ),
      );

  final tramos = tramosReporte();
  final nombresT = nombresTramos(tramos);

  /// Barra apilada con la distribución por niveles.
  pw.Widget distribucionPdf(List<double> notas) {
    final d = distribucion(notas, tramos);
    final total = d.fold<int>(0, (s, x) => s + x);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.ClipRRect(
          horizontalRadius: 5,
          verticalRadius: 5,
          child: pw.SizedBox(
            height: 12,
            child: pw.Row(
              children: [
                if (total == 0)
                  pw.Expanded(child: pw.Container(color: _suave(_gris, .85))),
                for (var i = tramos.length - 1; i >= 0; i--)
                  if (d[i] > 0)
                    pw.Expanded(
                      flex: d[i],
                      child: pw.Container(color: _pdf(Color(tramos[i].color))),
                    ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Wrap(
          spacing: 12,
          children: [
            for (var i = tramos.length - 1; i >= 0; i--)
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    width: 7,
                    height: 7,
                    decoration: pw.BoxDecoration(
                      color: _pdf(Color(tramos[i].color)),
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  t(
                    '${nombresT[i]} ${d[i]}'
                    '${total == 0 ? '' : ' (${(d[i] / total * 100).round()} %)'}',
                    size: 7.5,
                    color: _pdf(_gris),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // Portada: un renglón por curso.
  final todasNotas = [
    for (final c in cursos) ...c.notas(info.periodo).values,
  ];
  final asisTodas = conteoAsistencia([
    for (final c in cursos) ...c.asistenciaEn(info.periodo, info.anio),
  ]);
  final riesgos = [
    for (final c in cursos) ...enRiesgo(c, info.periodo, info.anio),
  ];
  final prom = promedioDe(todasNotas);
  final apr = porcentajeAprobados(todasNotas);
  final asis = porcentajeAsistencia(asisTodas);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 26, 28, 26),
      footer: (ctx) => pw.Row(
        children: [
          t('Kipu Docente · $_hoy', size: 7, color: _pdf(_gris)),
          pw.Spacer(),
          t('${ctx.pageNumber} / ${ctx.pagesCount}', size: 7, color: _pdf(_gris)),
        ],
      ),
      build: (ctx) => [
        cabecera('Reporte de notas', 'Resumen general'),
        pw.Row(
          children: [
            kpi('Promedio', prom == null ? '—' : numeroCorto(prom),
                color: colorNota(prom)),
            kpi('Aprobados', apr == null ? '—' : '${numeroCorto(apr, 0)} %',
                nota: '${todasNotas.length} estudiantes con nota'),
            kpi('Asistencia', asis == null ? '—' : '${numeroCorto(asis, 0)} %',
                color: _verde),
            kpi('Necesitan apoyo', '${riesgos.length}', color: _rojo),
          ],
        ),
        pw.SizedBox(height: 14),
        t('Niveles de logro', size: 10, font: f.negrita),
        pw.SizedBox(height: 6),
        distribucionPdf(todasNotas),
        pw.SizedBox(height: 16),
        t('Por curso', size: 10, font: f.negrita),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _suave(_tinta, .9), width: .5),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3.2),
            1: const pw.FlexColumnWidth(2.2),
            for (var i = 2; i <= 6; i++) i: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: _suave(base, .9)),
              children: [
                for (final (i, h) in const [
                  'Curso',
                  'Colegio',
                  'Alumnos',
                  'Promedio',
                  'Aprob.',
                  'Asist.',
                  'Apoyo',
                ].indexed)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: t(h, size: 8, font: f.negrita,
                        align: i < 2 ? null : pw.TextAlign.center),
                  ),
              ],
            ),
            for (final c in cursos)
              () {
                final n = c.notas(info.periodo).values.toList();
                final p = promedioDe(n);
                final a = porcentajeAprobados(n);
                final s = porcentajeAsistencia(
                  conteoAsistencia(c.asistenciaEn(info.periodo, info.anio)),
                );
                final r = enRiesgo(c, info.periodo, info.anio).length;
                pw.Widget celda(String v, {Color? color}) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: t(v, size: 8.5, font: color == null ? null : f.negrita,
                      color: color == null ? null : _pdf(color),
                      align: pw.TextAlign.center),
                );
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: t(c.nombre, size: 8.5, font: f.media),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: t(c.curso.colegio.nombre, size: 8, color: _pdf(_gris)),
                    ),
                    celda('${c.estudiantes.length}'),
                    celda(p == null ? '—' : numeroCorto(p), color: colorNota(p)),
                    celda(a == null ? '—' : '${numeroCorto(a, 0)} %'),
                    celda(s == null ? '—' : '${numeroCorto(s, 0)} %'),
                    celda('$r', color: r > 0 ? _rojo : null),
                  ],
                );
              }(),
          ],
        ),
        if (riesgos.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          t('Necesitan apoyo', size: 10, font: f.negrita),
          pw.SizedBox(height: 6),
          for (final r in riesgos.take(25))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 5,
                    height: 5,
                    margin: const pw.EdgeInsets.only(top: 3, right: 6),
                    decoration: pw.BoxDecoration(
                      color: _pdf(_rojo),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Expanded(
                    child: t(
                      '${_nombre(r.estudiante)} · ${r.curso.nombre} — '
                      '${r.motivos.join('; ')}',
                      size: 8.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    ),
  );

  // Una página por curso: notas por periodo y anual.
  for (final c in cursos) {
    final ps = c.periodos;
    final heads = [
      'N.°',
      'Estudiante',
      for (final (i, p) in ps.indexed) nombrePeriodoCorto(p.nombre, i + 1),
      'Anual',
      '',
    ];
    final anuales = [
      for (final e in c.estudiantes) ?c.anual(e.id),
    ];
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 26, 28, 26),
        footer: (ctx) => pw.Row(
          children: [
            t('${c.nombre} · ${c.curso.colegio.nombre}', size: 7, color: _pdf(_gris)),
            pw.Spacer(),
            t('${ctx.pageNumber} / ${ctx.pagesCount}', size: 7, color: _pdf(_gris)),
          ],
        ),
        build: (ctx) => [
          cabecera(c.nombre, c.curso.colegio.nombre),
          pw.Row(
            children: [
              for (final (i, p) in ps.indexed)
                () {
                  final n = c.notaPeriodo[i + 1]?.values.toList() ?? const <double>[];
                  final pr = promedioDe(n);
                  return kpi(
                    p.nombre,
                    pr == null ? '—' : numeroCorto(pr),
                    nota: n.isEmpty
                        ? 'Sin notas'
                        : '${numeroCorto(porcentajeAprobados(n)!, 0)} % aprobados',
                    color: colorNota(pr),
                  );
                }(),
              () {
                final pr = promedioDe(anuales);
                return kpi('Anual', pr == null ? '—' : numeroCorto(pr),
                    color: colorNota(pr));
              }(),
            ],
          ),
          pw.SizedBox(height: 10),
          distribucionPdf(c.notas(info.periodo).values.toList()),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _suave(_tinta, .9), width: .5),
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(24),
              1: const pw.FlexColumnWidth(5),
              for (var i = 0; i < ps.length + 1; i++) i + 2: const pw.FlexColumnWidth(1),
              ps.length + 3: const pw.FixedColumnWidth(26),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _suave(base, .9)),
                children: [
                  for (final (i, h) in heads.indexed)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      child: t(h, size: 8, font: f.negrita,
                          align: i == 1 ? null : pw.TextAlign.center),
                    ),
                ],
              ),
              for (final (k, e) in c.estudiantes.indexed)
                () {
                  pw.Widget nota(double? n, String? texto, {bool fuerte = false}) =>
                      pw.Container(
                        alignment: pw.Alignment.center,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2.5),
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        decoration: n != null && n < aprobatoria
                            ? pw.BoxDecoration(
                                color: _suave(_rojo, .88),
                                borderRadius: pw.BorderRadius.circular(4),
                              )
                            : null,
                        child: t(texto ?? '·', size: 9,
                            font: fuerte ? f.fuerte : f.negrita,
                            color: _pdf(texto == null ? _gris : colorNota(n))),
                      );
                  final ult = [
                    for (var p = ps.length; p >= 1; p--)
                      if (c.notaPeriodo[p]?[e.id] != null) c.notaPeriodo[p]![e.id]!,
                  ];
                  final dif = ult.length >= 2 ? ult[0] - ult[1] : 0.0;
                  return pw.TableRow(
                    decoration: k.isOdd ? pw.BoxDecoration(color: _suave(_tinta, .975)) : null,
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      t('${k + 1}', size: 8, color: _pdf(_gris), align: pw.TextAlign.center),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: t(_nombre(e), size: 8.5),
                      ),
                      for (var p = 1; p <= ps.length; p++)
                        nota(c.notaPeriodo[p]?[e.id], c.texto(p, e.id)),
                      nota(c.anual(e.id), c.textoAnual(e.id), fuerte: true),
                      t(
                        dif >= 1
                            ? '+${numeroCorto(dif)}'
                            : (dif <= -1 ? '-${numeroCorto(-dif)}' : ''),
                        size: 7.5,
                        color: _pdf(dif > 0 ? _verde : _rojo),
                        align: pw.TextAlign.center,
                      ),
                    ],
                  );
                }(),
            ],
          ),
          pw.SizedBox(height: 10),
          t(
            c.letras
                ? 'Nota anual: nivel del último periodo con nota (Minedu).'
                : 'Nota anual: promedio de los periodos con nota. '
                      'La última columna muestra cuánto subió (+) o bajó (-) '
                      'respecto al periodo anterior.',
            size: 7.5,
            color: _pdf(_gris),
          ),
        ],
      ),
    );
  }
  return doc.save();
}

// ───────────────────────── PDF: libreta del estudiante ─────────────────────────

Future<Uint8List> pdfLibreta(
  DatosCurso c,
  Estudiante e,
  InfoReporte info,
) async {
  final f = await _Fuentes.cargar();
  final base = info.color;
  final doc = pw.Document(
    title: 'Informe de ${_nombre(e)}',
    author: info.docente,
    creator: 'Kipu Docente',
    theme: pw.ThemeData.withFont(base: f.normal, bold: f.negrita),
  );
  pw.Widget t(String s, {double size = 9, pw.Font? font, PdfColor? color,
      pw.TextAlign? align}) => pw.Text(s, textAlign: align,
      style: pw.TextStyle(font: font ?? f.normal, fontSize: size,
          color: color ?? _pdf(_tinta)));

  final ps = c.periodos;
  final asis = conteoAsistencia(
    c.asistenciaEn(info.periodo, info.anio).where((a) => a.estudianteId == e.id),
  );
  final pa = porcentajeAsistencia(asis);
  final cond = c.conductasEn(info.periodo, info.anio)
      .where((x) => x.estudianteId == e.id)
      .toList();
  final anec = [
    for (final x in c.anecdotas)
      if (x.$2.id == e.id) x,
  ];
  final pr = c.anual(e.id);

  pw.Widget caja(String titulo, pw.Widget hijo) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _suave(_tinta, .88), width: .7),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        t(titulo.toUpperCase(), size: 8, font: f.negrita, color: _pdf(base)),
        pw.SizedBox(height: 8),
        hijo,
      ],
    ),
  );

  // Gráfico de barras de los periodos.
  pw.Widget barras() {
    const alto = 90.0;
    return pw.SizedBox(
      height: alto + 30,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          for (var p = 1; p <= ps.length; p++)
            pw.Expanded(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  t(c.texto(p, e.id) ?? '—', size: 9, font: f.fuerte,
                      color: _pdf(colorNota(c.notaPeriodo[p]?[e.id]))),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    width: 30,
                    height: max(2, alto * ((c.notaPeriodo[p]?[e.id] ?? 0) / 20)),
                    decoration: pw.BoxDecoration(
                      color: _pdf(colorNota(c.notaPeriodo[p]?[e.id])),
                      borderRadius: const pw.BorderRadius.vertical(
                        top: pw.Radius.circular(5),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  t(nombrePeriodoCorto(ps[p - 1].nombre, p), size: 8,
                      color: _pdf(_gris)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 30, 32, 30),
      footer: (ctx) => t('Kipu Docente · $_hoy', size: 7, color: _pdf(_gris)),
      build: (ctx) => [
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(18, 16, 18, 16),
          margin: const pw.EdgeInsets.only(bottom: 14),
          decoration: pw.BoxDecoration(
            color: _pdf(base),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    t('INFORME DEL ESTUDIANTE', size: 8, font: f.media,
                        color: _suave(base, .65)),
                    pw.SizedBox(height: 3),
                    t(_nombre(e), size: 17, font: f.fuerte, color: PdfColors.white),
                    pw.SizedBox(height: 2),
                    t('${c.nombre} · ${c.curso.colegio.nombre}', size: 9,
                        color: _suave(base, .75)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  t('Promedio anual', size: 8, color: _suave(base, .65)),
                  t(c.textoAnual(e.id) ?? '—', size: 24, font: f.fuerte,
                      color: PdfColors.white),
                ],
              ),
            ],
          ),
        ),
        caja(
          'Notas por ${ps.isEmpty ? 'periodo' : ps.first.nombre.replaceAll(RegExp(r'^\S+\s'), '')}',
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(child: barras()),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (var p = 1; p <= ps.length; p++)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 3),
                      child: t('${ps[p - 1].nombre}: ${c.texto(p, e.id) ?? 'sin nota'}',
                          size: 8.5),
                    ),
                  pw.SizedBox(height: 4),
                  t('Anual: ${c.textoAnual(e.id) ?? '—'}', size: 9, font: f.negrita,
                      color: _pdf(colorNota(pr))),
                ],
              ),
            ],
          ),
        ),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: caja(
                'Asistencia · ${info.alcance}',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    t(pa == null ? 'Sin registros' : '${numeroCorto(pa, 0)} %',
                        size: 18, font: f.fuerte, color: _pdf(_verde)),
                    pw.SizedBox(height: 4),
                    t('Presente ${asis['P']} · Tarde ${asis['T']} · '
                        'Falta ${asis['F']} · Justificada ${asis['J']}', size: 8.5),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: caja(
                'Conducta · ${info.alcance}',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(children: [
                      t('+${cond.where((x) => x.positiva).length}', size: 18,
                          font: f.fuerte, color: _pdf(_verde)),
                      pw.SizedBox(width: 14),
                      t('-${cond.where((x) => !x.positiva).length}', size: 18,
                          font: f.fuerte, color: _pdf(_rojo)),
                    ]),
                    pw.SizedBox(height: 4),
                    t(
                      cond.isEmpty
                          ? 'Sin anotaciones'
                          : cond.take(3).map((x) => x.motivo).join(' · '),
                      size: 8.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (anec.isNotEmpty)
          caja(
            'Anecdotario',
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (final (a, _, _) in anec.take(8))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 4,
                          height: 18,
                          margin: const pw.EdgeInsets.only(right: 6),
                          color: _pdf(Color(colorTipoAnecdota(a.tipo))),
                        ),
                        pw.Expanded(
                          child: t('${a.fecha} · ${nombreCategoria(a.categoria)}: ${a.texto}',
                              size: 8.5),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        pw.SizedBox(height: 30),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(children: [
                pw.Container(height: .7, color: _suave(_tinta, .6)),
                pw.SizedBox(height: 4),
                t(info.docente.isEmpty ? 'Docente' : info.docente, size: 8.5),
              ]),
            ),
            pw.SizedBox(width: 40),
            pw.Expanded(
              child: pw.Column(children: [
                pw.Container(height: .7, color: _suave(_tinta, .6)),
                pw.SizedBox(height: 4),
                t('Padre, madre o apoderado', size: 8.5),
              ]),
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

// ───────────────────────── Excel ─────────────────────────

/// Excel con una hoja de resumen y una por curso.
Uint8List excelConsolidado(List<DatosCurso> cursos, InfoReporte info) {
  final x = xl.Excel.createExcel();
  final defecto = x.getDefaultSheet()!;
  String hex(Color c) =>
      'FF${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  xl.ExcelColor col(Color c) => xl.ExcelColor.fromHexString(hex(c));
  final base = info.color;
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
    horizontalAlign: centro ? xl.HorizontalAlign.Center : xl.HorizontalAlign.Left,
    verticalAlign: xl.VerticalAlign.Center,
    leftBorder: bordes ? borde : null,
    rightBorder: bordes ? borde : null,
    topBorder: bordes ? borde : null,
    bottomBorder: bordes ? borde : null,
  );
  final cabeza = estilo(
    fondo: base,
    texto: Colors.white,
    negrita: true,
    centro: true,
  );
  final usados = <String>{};
  String nombreHoja(String n) {
    var s = n.replaceAll(RegExp(r'[\\/?*\[\]:]'), '-');
    if (s.length > 28) s = s.substring(0, 28);
    var r = s;
    var i = 2;
    while (!usados.add(r)) {
      r = '$s $i';
      i++;
    }
    return r;
  }

  void poner(xl.Sheet h, int c, int f, Object? v, xl.CellStyle s) =>
      h.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: f),
        switch (v) {
          final int n => xl.IntCellValue(n),
          final double n => n == n.roundToDouble()
              ? xl.IntCellValue(n.round())
              : xl.DoubleCellValue(double.parse(n.toStringAsFixed(1))),
          null => null,
          _ => xl.TextCellValue('$v'),
        },
        cellStyle: s,
      );

  void titulo(xl.Sheet h, String t1, String t2, int ultima) {
    poner(h, 0, 0, t2.toUpperCase(),
        estilo(texto: base, negrita: true, bordes: false));
    poner(h, 0, 1, t1, estilo(negrita: true, tam: 16, bordes: false));
    poner(h, 0, 2, '${info.alcance} · ${info.docente} · $_hoy',
        estilo(texto: _gris, bordes: false));
    for (final f in [0, 1, 2]) {
      h.merge(
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: f),
        xl.CellIndex.indexByColumnRow(columnIndex: ultima, rowIndex: f),
      );
    }
    h.setRowHeight(1, 26);
  }

  // Resumen.
  x.rename(defecto, 'Resumen');
  usados.add('Resumen');
  final hr = x['Resumen'];
  titulo(hr, 'Reporte de notas', 'Resumen general', 7);
  const cab = ['Curso', 'Colegio', 'Alumnos', 'Promedio', 'Aprobados %',
      'Asistencia %', 'Necesitan apoyo', 'Desaprobados'];
  for (final (i, h) in cab.indexed) {
    poner(hr, i, 4, h, cabeza);
  }
  for (final (k, c) in cursos.indexed) {
    final n = c.notas(info.periodo).values.toList();
    final p = promedioDe(n);
    final fila = 5 + k;
    final s = estilo(fondo: k.isOdd ? const Color(0xFFF7F7FB) : null);
    final sc = estilo(fondo: k.isOdd ? const Color(0xFFF7F7FB) : null, centro: true);
    poner(hr, 0, fila, c.nombre, s);
    poner(hr, 1, fila, c.curso.colegio.nombre, s);
    poner(hr, 2, fila, c.estudiantes.length, sc);
    poner(hr, 3, fila, p, estilo(
      fondo: k.isOdd ? const Color(0xFFF7F7FB) : null,
      centro: true,
      negrita: true,
      texto: colorNota(p),
    ));
    poner(hr, 4, fila, porcentajeAprobados(n)?.roundToDouble(), sc);
    poner(hr, 5, fila, porcentajeAsistencia(
      conteoAsistencia(c.asistenciaEn(info.periodo, info.anio)),
    )?.roundToDouble(), sc);
    poner(hr, 6, fila, enRiesgo(c, info.periodo, info.anio).length, sc);
    poner(hr, 7, fila, n.where((v) => v < aprobatoria).length, sc);
  }
  hr.setColumnWidth(0, 34);
  hr.setColumnWidth(1, 28);
  for (var i = 2; i < cab.length; i++) {
    hr.setColumnWidth(i, 15);
  }

  // Una hoja por curso.
  for (final c in cursos) {
    final h = x[nombreHoja('${c.curso.curso.grado} ${c.curso.curso.seccion} ${c.curso.curso.nombre}')];
    final ps = c.periodos;
    final ultima = ps.length + 3;
    titulo(h, c.nombre, c.curso.colegio.nombre, ultima);
    final heads = [
      'N.°',
      'Estudiante',
      for (final (i, p) in ps.indexed) nombrePeriodoCorto(p.nombre, i + 1),
      'Anual',
      'Asistencia %',
    ];
    for (final (i, t) in heads.indexed) {
      poner(h, i, 4, t, cabeza);
    }
    for (final (k, e) in c.estudiantes.indexed) {
      final fila = 5 + k;
      final fondo = k.isOdd ? const Color(0xFFF7F7FB) : null;
      poner(h, 0, fila, k + 1, estilo(fondo: fondo, centro: true, texto: _gris));
      poner(h, 1, fila, _nombre(e), estilo(fondo: fondo));
      for (var p = 1; p <= ps.length; p++) {
        final n = c.notaPeriodo[p]?[e.id];
        final txt = c.texto(p, e.id);
        poner(h, p + 1, fila,
            c.letras ? txt : (n == null ? null : double.parse(numeroCorto(n, 0).replaceAll(',', '.'))),
            estilo(
              fondo: n != null && n < aprobatoria ? const Color(0xFFFCE8EB) : fondo,
              centro: true,
              negrita: true,
              texto: colorNota(n),
            ));
      }
      final a = c.anual(e.id);
      poner(h, ps.length + 2, fila,
          c.letras ? c.textoAnual(e.id) : (a == null ? null : double.parse(a.toStringAsFixed(1))),
          estilo(
            fondo: a != null && a < aprobatoria
                ? const Color(0xFFFCE8EB)
                : Color.lerp(base, Colors.white, .9),
            centro: true,
            negrita: true,
            texto: colorNota(a),
          ));
      final pa = porcentajeAsistencia(conteoAsistencia(
        c.asistencia.where((x) => x.estudianteId == e.id),
      ));
      poner(h, ps.length + 3, fila, pa?.roundToDouble(),
          estilo(fondo: fondo, centro: true));
    }
    // Fila de promedios.
    final fm = 5 + c.estudiantes.length;
    final sm = estilo(fondo: Color.lerp(base, Colors.white, .85), negrita: true, centro: true);
    poner(h, 1, fm, 'Promedio del aula', estilo(fondo: Color.lerp(base, Colors.white, .85), negrita: true));
    poner(h, 0, fm, '', sm);
    for (var p = 1; p <= ps.length; p++) {
      poner(h, p + 1, fm, promedioDe(c.notaPeriodo[p]?.values ?? const []), sm);
    }
    poner(h, ps.length + 2, fm, promedioDe(c.notas(null).values), sm);
    poner(h, ps.length + 3, fm,
        porcentajeAsistencia(conteoAsistencia(c.asistencia))?.roundToDouble(), sm);
    h.setColumnWidth(0, 6);
    h.setColumnWidth(1, 38);
    for (var i = 2; i <= ultima; i++) {
      h.setColumnWidth(i, 11);
    }
  }
  return Uint8List.fromList(x.encode()!);
}
