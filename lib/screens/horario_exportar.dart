import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import 'cursos.dart' show colorColegio;
import 'horario_datos.dart';

PdfColor _pdf(Color c) => PdfColor(c.r, c.g, c.b);
const _tinta = Color(0xFF1F1B2E);
const _gris = Color(0xFF6E6A80);
const _morado = Color(0xFF4F5BD5);

/// Horario en PDF, horizontal. Con [colegio], la tabla de ese colegio con sus
/// horas y recreos; sin él, la semana de todos los colegios día por día.
Future<Uint8List> pdfHorario({
  required Colegio? colegio,
  required List<Colegio> colegios,
  required List<(Horario, CursoConColegio)> clases,
  required List<Franja> franjas,
  required String docente,
  required String semana,
}) async {
  Future<pw.Font> fuente(String f) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-$f.ttf'));
  final normal = await fuente('Regular');
  final media = await fuente('Medium');
  final negrita = await fuente('SemiBold');
  final fuerte = await fuente('Bold');

  final titulo = colegio == null
      ? 'Mi horario · Todos mis colegios'
      : 'Mi horario · ${colegio.nombre}';
  final doc = pw.Document(
    title: titulo,
    author: docente,
    creator: 'Kipu Docente',
    theme: pw.ThemeData.withFont(base: normal, bold: negrita),
  );
  final base = colegio == null ? _morado : colorColegio(colegios, colegio.id);
  final dias = diasVisibles(clases);
  final hoy = DateFormat(
    "d 'de' MMMM 'de' yyyy",
    'es_PE',
  ).format(DateTime.now());

  pw.Widget texto(
    String s, {
    double size = 9,
    pw.Font? font,
    Color color = _tinta,
    double ls = 0,
    pw.TextAlign? align,
  }) => pw.Text(
    s,
    textAlign: align,
    maxLines: 2,
    style: pw.TextStyle(
      font: font ?? normal,
      fontSize: size,
      color: _pdf(color),
      letterSpacing: ls,
    ),
  );

  pw.Widget cabeceraDia(int d) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    decoration: pw.BoxDecoration(
      color: _pdf(Color.lerp(base, Colors.white, .88)!),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    alignment: pw.Alignment.center,
    child: texto(
      diasLargos[d - 1].toUpperCase(),
      size: 9,
      font: fuerte,
      color: oscuroDe(base),
      ls: .6,
    ),
  );

  pw.Widget chip(String s, Color c) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: texto(s, size: 7, font: negrita, color: c),
  );

  final cuerpo = <pw.Widget>[];
  if (colegio != null) {
    final filas = filasDeColegio(colegio.id, franjas, clases);
    final mapa = {
      for (final x in clases)
        if (x.$2.colegio.id == colegio.id) (x.$1.dia, x.$1.inicio): x.$2.curso,
    };
    final claro = claroDe(base), osc = oscuroDe(base);
    cuerpo.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 62),
          for (final d in dias)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: cabeceraDia(d),
              ),
            ),
        ],
      ),
    );
    for (final f in filas) {
      final hora = pw.SizedBox(
        width: 62,
        child: pw.Column(
          children: [
            texto(
              f.inicio,
              size: f.recreo ? 7.5 : 9,
              font: negrita,
              color: _gris,
            ),
            if (!f.recreo) texto(f.fin, size: 7.5, color: _gris),
          ],
        ),
      );
      if (f.recreo) {
        cuerpo.add(
          pw.Row(
            children: [
              hora,
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(2),
                  height: 15,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: _pdf(const Color(0xFFEEF0FA)),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: texto(
                    'RECREO  ·  ${f.inicio} – ${f.fin}',
                    size: 7,
                    font: negrita,
                    color: _gris,
                    ls: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
        continue;
      }
      cuerpo.add(
        pw.Row(
          children: [
            hora,
            for (final d in dias)
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(2),
                  height: 46,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: mapa[(d, f.inicio)] == null ? null : _pdf(claro),
                    border: mapa[(d, f.inicio)] == null
                        ? pw.Border.all(
                            color: _pdf(const Color(0xFFE6E7F0)),
                            width: .8,
                          )
                        : null,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: switch (mapa[(d, f.inicio)]) {
                    final c? => pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        texto(
                          c.nombre,
                          size: 9.5,
                          font: fuerte,
                          color: osc,
                          align: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 3),
                        chip(aula(c), osc),
                      ],
                    ),
                    null => pw.SizedBox(),
                  },
                ),
              ),
          ],
        ),
      );
    }
  } else {
    cuerpo.add(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final d in dias)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: () {
                    final lista = [
                      for (final x in clases)
                        if (x.$1.dia == d) x,
                    ]..sort((a, b) => a.$1.inicio.compareTo(b.$1.inicio));
                    final w = <pw.Widget>[
                      cabeceraDia(d),
                      pw.SizedBox(height: 5),
                    ];
                    if (lista.isEmpty) {
                      w.add(
                        texto(
                          'Sin clases',
                          size: 8,
                          color: _gris,
                          align: pw.TextAlign.center,
                        ),
                      );
                    }
                    for (var i = 0; i < lista.length; i++) {
                      final (h, c) = lista[i];
                      final col = colorColegio(colegios, c.colegio.id);
                      final osc = oscuroDe(col);
                      w.add(
                        pw.Container(
                          padding: const pw.EdgeInsets.fromLTRB(7, 5, 6, 6),
                          decoration: pw.BoxDecoration(
                            color: _pdf(claroDe(col)),
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border(
                              left: pw.BorderSide(color: _pdf(col), width: 2.5),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              texto(
                                '${h.inicio} – ${h.fin}',
                                size: 7.5,
                                font: negrita,
                                color: osc,
                              ),
                              pw.Row(
                                children: [
                                  pw.Flexible(
                                    child: texto(
                                      c.curso.nombre,
                                      size: 9.5,
                                      font: fuerte,
                                      color: osc,
                                    ),
                                  ),
                                  pw.SizedBox(width: 4),
                                  chip(aula(c.curso), osc),
                                ],
                              ),
                              texto(
                                c.colegio.nombre,
                                size: 7,
                                font: media,
                                color: osc,
                              ),
                            ],
                          ),
                        ),
                      );
                      if (i < lista.length - 1) {
                        final entre = entreClases(
                          lista[i],
                          lista[i + 1],
                          franjas,
                        );
                        final cruce =
                            lista[i + 1].$1.inicio.compareTo(lista[i].$1.fin) <
                            0;
                        final cambio =
                            cruce ||
                            lista[i].$2.colegio.id !=
                                lista[i + 1].$2.colegio.id;
                        w.add(
                          entre == null
                              ? pw.SizedBox(height: 4)
                              : pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: texto(
                                    entre,
                                    size: 6.8,
                                    font: cambio ? negrita : normal,
                                    color: cruce
                                        ? const Color(0xFFD9475A)
                                        : cambio
                                        ? const Color(0xFFC25A16)
                                        : _gris,
                                    align: pw.TextAlign.center,
                                  ),
                                ),
                        );
                      }
                    }
                    return w;
                  }(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 22),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),
            decoration: pw.BoxDecoration(
              color: _pdf(base),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      texto(
                        colegio?.nombre ?? 'Todos mis colegios',
                        size: 16,
                        font: fuerte,
                        color: Colors.white,
                      ),
                      texto(
                        [
                          'Horario semanal',
                          ?colegio?.lugar,
                          if (docente.isNotEmpty) docente,
                        ].join(' · '),
                        size: 9,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                if (colegio == null)
                  for (final c in colegios)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 7,
                            height: 7,
                            decoration: pw.BoxDecoration(
                              color: _pdf(colorColegio(colegios, c.id)),
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                color: PdfColors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          texto(c.nombre, size: 8, color: Colors.white),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          ...cuerpo,
          pw.Spacer(),
          pw.Row(
            children: [
              texto(semana, size: 7.5, color: _gris),
              pw.Spacer(),
              texto(
                'Generado con Kipu Docente · $hoy',
                size: 7.5,
                color: _gris,
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
