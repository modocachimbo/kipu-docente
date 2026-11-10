import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/cneb.dart';
import '../data/instrumentos.dart';

/// PDF de un instrumento para imprimir o compartir con los estudiantes antes
/// de la tarea. El examen sale sin respuestas o, para el docente, con clave.

const _morado = PdfColor.fromInt(0xFF4F5BD5);
const _moradoClaro = PdfColor.fromInt(0xFFE6E8FB);
const _fondo = PdfColor.fromInt(0xFFF3F4FB);
const _gris = PdfColor.fromInt(0xFF6E6A80);
const _linea = PdfColor.fromInt(0xFFD6D8E6);
const _tinta = PdfColor.fromInt(0xFF1F1B2E);

/// El PDF no tiene emojis: las caritas se quitan del texto.
String _limpio(String s) => s
    .replaceAll(
      RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]', unicode: true),
      '',
    )
    .trim();

String _num(double n) => n == n.roundToDouble()
    ? n.round().toString()
    : n.toStringAsFixed(1).replaceAll('.', ',');

Future<Uint8List> pdfInstrumento(Instrumento ins, {bool conClave = false}) async {
  Future<pw.Font> fuente(String f) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/Outfit-$f.ttf'));
  final normal = await fuente('Regular');
  final negrita = await fuente('SemiBold');
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: normal, bold: negrita),
    title: ins.nombre,
    creator: 'Kipu Docente',
  );
  final horizontal =
      ins.tipo == TipoInstrumento.rubrica && ins.escala.length >= 4;

  pw.Widget texto(
    String t, {
    double tam = 9.5,
    bool fuerte = false,
    PdfColor color = _tinta,
    pw.TextAlign alinear = pw.TextAlign.left,
  }) => pw.Text(
    _limpio(t),
    textAlign: alinear,
    style: pw.TextStyle(
      fontSize: tam,
      color: color,
      fontWeight: fuerte ? pw.FontWeight.bold : pw.FontWeight.normal,
      lineSpacing: 1.5,
    ),
  );

  pw.Widget celda(
    String t, {
    bool fuerte = false,
    PdfColor color = _tinta,
    pw.TextAlign alinear = pw.TextAlign.left,
    double tam = 9,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: texto(t, tam: tam, fuerte: fuerte, color: color, alinear: alinear),
  );

  final comps = [
    for (final c in ins.competencias) ?competenciaPorId(c)?.nombre,
  ];

  final cabecera = <pw.Widget>[
    texto(
      [ins.tipo.nombre, ...ins.niveles, if (ins.area.isNotEmpty) ins.area]
          .join(' · ')
          .toUpperCase(),
      tam: 8,
      fuerte: true,
      color: _morado,
    ),
    pw.SizedBox(height: 3),
    texto(
      conClave ? '${ins.nombre} · Clave de respuestas' : ins.nombre,
      tam: 16,
      fuerte: true,
    ),
    for (final c in comps) texto('Competencia: $c', tam: 9, color: _gris),
    if (ins.descripcion.isNotEmpty) ...[
      pw.SizedBox(height: 4),
      texto(ins.descripcion, tam: 9, color: _gris, alinear: pw.TextAlign.justify),
    ],
    pw.SizedBox(height: 10),
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const pw.BoxDecoration(
        color: _fondo,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 5, child: texto('Estudiante: ______________________________')),
          pw.Expanded(flex: 3, child: texto('Grado y sección: __________')),
          pw.Expanded(flex: 2, child: texto('Fecha: ___________')),
        ],
      ),
    ),
    pw.SizedBox(height: 12),
  ];

  final cuerpo = <pw.Widget>[];
  switch (ins.tipo) {
    case TipoInstrumento.rubrica:
      final n = ins.escala.length;
      final suma = ins.items.fold<double>(0, (s, i) => s + ins.pesoDe(i));
      cuerpo.add(
        pw.Table(
          border: pw.TableBorder.all(color: _linea, width: .6),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.3),
            for (var k = 0; k < n; k++) k + 1: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _moradoClaro),
              children: [
                celda('Criterio', fuerte: true),
                for (final nv in ins.escala)
                  celda(
                    '${nv.nombre}\n${_num(nv.puntos)} pts',
                    fuerte: true,
                    alinear: pw.TextAlign.center,
                  ),
              ],
            ),
            for (final it in ins.items)
              pw.TableRow(
                children: [
                  pw.Container(
                    color: _fondo,
                    child: celda(
                      ins.ponderada && suma > 0
                          ? '${it.texto}\n(${_num(ins.pesoDe(it) / suma * 100)} %)'
                          : it.texto,
                      fuerte: true,
                    ),
                  ),
                  for (var k = 0; k < n; k++)
                    celda(
                      k < it.descriptores.length ? it.descriptores[k] : '',
                      alinear: pw.TextAlign.justify,
                    ),
                ],
              ),
          ],
        ),
      );
    case TipoInstrumento.cotejo || TipoInstrumento.escala:
      final niveles = [
        for (final nv in ins.escala) nv.nombre,
        if (ins.noObservado) 'No obs.',
      ];
      cuerpo.add(
        pw.Table(
          border: pw.TableBorder.all(color: _linea, width: .6),
          columnWidths: {
            0: const pw.FixedColumnWidth(24),
            1: const pw.FlexColumnWidth(5),
            for (var k = 0; k < niveles.length; k++)
              k + 2: const pw.FixedColumnWidth(54),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _moradoClaro),
              children: [
                celda('N.°', fuerte: true, alinear: pw.TextAlign.center),
                celda(
                  ins.ponderada ? 'Ítem (puntos)' : 'Ítem',
                  fuerte: true,
                ),
                for (final nv in niveles)
                  celda(nv, fuerte: true, alinear: pw.TextAlign.center, tam: 8),
              ],
            ),
            for (final (k, it) in ins.items.indexed)
              pw.TableRow(
                children: [
                  celda('${k + 1}', alinear: pw.TextAlign.center),
                  celda(
                    ins.ponderada ? '${it.texto} (${_num(it.peso)})' : it.texto,
                  ),
                  for (var j = 0; j < niveles.length; j++) pw.SizedBox(height: 18),
                ],
              ),
          ],
        ),
      );
    case TipoInstrumento.prueba:
      for (final (k, it) in ins.items.indexed) {
        cuerpo.add(
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 22, child: texto('${k + 1}.', fuerte: true)),
                    pw.Expanded(
                      child: texto(
                        it.texto.isEmpty ? '' : it.texto,
                        alinear: pw.TextAlign.justify,
                      ),
                    ),
                    texto('(${_num(it.peso)} pts)', color: _gris, tam: 8.5),
                  ],
                ),
                pw.SizedBox(height: 4),
                if (it.desarrollo)
                  for (var l = 0; l < 3; l++)
                    pw.Container(
                      height: 14,
                      margin: const pw.EdgeInsets.only(left: 22, top: 8),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: _linea, width: .6)),
                      ),
                    )
                else
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 22),
                    child: pw.Row(
                      children: [
                        for (final (j, l) in it.letras.indexed)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 18),
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 12,
                                  height: 12,
                                  decoration: pw.BoxDecoration(
                                    shape: pw.BoxShape.circle,
                                    color: conClave && j == it.clave ? _morado : null,
                                    border: pw.Border.all(color: _gris, width: .7),
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                texto(l, fuerte: conClave && j == it.clave),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }
      cuerpo.add(
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: texto(
            'Puntaje: ______ / ${_num(ins.puntajeTotal)}',
            fuerte: true,
            tam: 11,
          ),
        ),
      );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: horizontal ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          texto('Kipu Docente', tam: 7.5, color: _gris),
          texto('${ctx.pageNumber} de ${ctx.pagesCount}', tam: 7.5, color: _gris),
        ],
      ),
      build: (_) => [...cabecera, ...cuerpo],
    ),
  );
  return doc.save();
}
