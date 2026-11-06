import 'dart:math' show min;

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import '../data/paises.dart';
import '../data/registro.dart';

/// Notas de un periodo tal como se ven en el registro.
class HojaRegistro {
  final String periodo;
  final List<Estudiante> estudiantes;
  final List<RegistroColumna> columnas;

  /// {columnaId: {estudianteId: valor}}
  final Map<int, Map<int, String>> notas;

  const HojaRegistro({
    required this.periodo,
    required this.estudiantes,
    required this.columnas,
    required this.notas,
  });

  String? nota(RegistroColumna c, Estudiante e) => notas[c.id]?[e.id];
}

/// Todo lo que va en la descarga del registro de notas: un periodo o el año.
class ReporteRegistro {
  final String colegio;
  final Curso curso;
  final String docente;
  final Color color;
  final String alcance; // "1.° bimestre" o "Año completo"
  final List<HojaRegistro> hojas;
  final Escala? Function(RegistroColumna) escalaDe;

  const ReporteRegistro({
    required this.colegio,
    required this.curso,
    required this.docente,
    required this.color,
    required this.alcance,
    required this.hojas,
    required this.escalaDe,
  });

  String get titulo =>
      'Registro ${curso.nombre} ${curso.grado} ${curso.seccion}';
  String get archivo =>
      'registro-${curso.nombre}-${curso.grado}${curso.seccion}-$alcance'
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9áéíóúñ]+'), '-');

  /// Escalas por letras que aparecen, para la leyenda.
  List<Escala> get escalasConLetras {
    final r = <String, Escala>{};
    for (final h in hojas) {
      for (final c in h.columnas) {
        final e = escalaDe(c);
        if (e != null && !e.numerica && !esSiNo(e)) r[e.id] = e;
      }
    }
    return r.values.toList();
  }
}

/// Columnas por bloque en el PDF: más que esto ya no se leen en A4.
const _porBloque = 15;

const _tinta = Color(0xFF1F1B2E);
const _gris = Color(0xFF6E6A80);
const _rojo = Color(0xFFC2334A);

PdfColor _pdf(Color c) => PdfColor(c.r, c.g, c.b);
PdfColor _suave(Color c, double t) => _pdf(Color.lerp(c, Colors.white, t)!);
PdfColor _osc(Color c, double t) => _pdf(Color.lerp(c, Colors.black, t)!);

double? _numero(String v) => double.tryParse(v.replaceAll(',', '.'));

/// "15.5" → "15,5"; "17.0" → "17".
String _mostrar(String v) {
  final n = _numero(v);
  if (n == null) return v;
  return n == n.roundToDouble()
      ? n.toStringAsFixed(0)
      : n.toString().replaceAll('.', ',');
}

/// Lo mismo que la fila de media del registro.
String? _media(List<String> valores, Escala? e) {
  if (valores.isEmpty) return null;
  if (e == null || e.numerica) {
    final n = [for (final v in valores) ?_numero(v)];
    if (n.isEmpty) return null;
    return (n.reduce((a, b) => a + b) / n.length)
        .toStringAsFixed(1)
        .replaceAll('.', ',');
  }
  if (esSiNo(e)) {
    final si = valores.where((v) => v == e.valores.first.codigo).length;
    return '$si de ${valores.length}';
  }
  final cuenta = <String, int>{};
  for (final v in valores) {
    cuenta[v] = (cuenta[v] ?? 0) + 1;
  }
  final orden = [for (final x in e.valores) x.codigo];
  return (cuenta.keys.toList()..sort((a, b) {
        final d = cuenta[b]!.compareTo(cuenta[a]!);
        return d != 0 ? d : orden.indexOf(a).compareTo(orden.indexOf(b));
      }))
      .first;
}

String _detalleColumna(RegistroColumna c, Escala? e) => [
  if (DateTime.tryParse(c.fecha ?? '') case final d?)
    DateFormat('d MMM', 'es_PE').format(d).replaceAll('.', ''),
  escalaCorta(e),
].where((s) => s.isNotEmpty).join(' · ');

bool _bajo(String v, Escala? e) {
  final n = _numero(v);
  return n != null && e?.aprueba != null && n < e!.aprueba!;
}

// PDF

Future<Uint8List> pdfRegistro(ReporteRegistro r) async {
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
  final tutor = r.curso.tutor?.trim() ?? '';

  pw.Widget texto(
    String s, {
    double size = 8,
    pw.Font? font,
    PdfColor? color,
    double ls = 0,
    pw.TextAlign? align,
    int? maxLines,
  }) => pw.Text(
    s,
    textAlign: align,
    maxLines: maxLines,
    overflow: maxLines == null ? null : pw.TextOverflow.clip,
    style: pw.TextStyle(
      font: font,
      fontSize: size,
      color: color ?? _pdf(_tinta),
      letterSpacing: ls,
    ),
  );

  pw.Widget pastilla(String t, PdfColor fondo, PdfColor color, double size) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
        decoration: pw.BoxDecoration(
          color: fondo,
          borderRadius: pw.BorderRadius.circular(3.5),
        ),
        child: texto(t, size: size, font: negrita, color: color),
      );

  pw.Widget celda(String? v, Escala? e, double size) {
    if (v == null) {
      return pw.Center(
        child: texto('·', size: size, color: _suave(_gris, .5)),
      );
    }
    if (e == null || e.numerica) {
      return pw.Center(
        child: _bajo(v, e)
            ? pastilla(_mostrar(v), _suave(_rojo, .88), _pdf(_rojo), size)
            : texto(_mostrar(v), size: size, font: media),
      );
    }
    final i = e.valores.indexWhere((x) => x.codigo == v);
    if (i < 0) return pw.Center(child: texto(v, size: size));
    final c = Color(e.valores[i].color);
    if (esSiNo(e)) {
      return pw.Center(
        child: pastilla(
          i == 0 ? 'Sí' : 'No',
          _suave(c, .85),
          _osc(c, .15),
          size * .9,
        ),
      );
    }
    return pw.Center(
      child: i == 0
          ? pastilla(v, _pdf(c), _pdf(Colors.white), size)
          : pastilla(v, _suave(c, .84), _osc(c, .1), size),
    );
  }

  pw.Widget dato(String k, String v) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      texto(k, size: 6.3, font: negrita, color: _pdf(_gris), ls: 1.2),
      texto(v, size: 9.3, font: media),
    ],
  );

  pw.Widget tabla(HojaRegistro h, List<RegistroColumna> cols) {
    const wN = 20.0, wNom = 168.0;
    final n = cols.length;
    final size = n > 16 ? 7.0 : (n > 10 ? 7.8 : 8.6);
    final cab = <pw.Widget>[
      pw.Container(
        alignment: pw.Alignment.bottomCenter,
        padding: const pw.EdgeInsets.fromLTRB(2, 6, 2, 5),
        child: texto('N.°', size: 7, font: negrita, color: _pdf(_gris)),
      ),
      pw.Container(
        alignment: pw.Alignment.bottomLeft,
        padding: const pw.EdgeInsets.fromLTRB(4, 6, 4, 5),
        child: texto(
          'APELLIDOS Y NOMBRES',
          size: 7,
          font: negrita,
          color: _osc(base, .2),
          ls: .6,
        ),
      ),
      for (final c in cols)
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(2, 6, 2, 5),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              texto(
                c.codigo,
                size: size + .6,
                font: fuerte,
                color: _osc(base, .2),
                maxLines: 1,
              ),
              if ((c.tema ?? '').isNotEmpty)
                texto(
                  c.tema!,
                  size: 6,
                  color: _pdf(_gris),
                  align: pw.TextAlign.center,
                  maxLines: 2,
                ),
              texto(
                _detalleColumna(c, r.escalaDe(c)),
                size: 5.5,
                color: _suave(_gris, .3),
                maxLines: 1,
              ),
            ],
          ),
        ),
    ];
    final filas = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: _suave(base, .88),
          borderRadius: const pw.BorderRadius.vertical(
            top: pw.Radius.circular(6),
          ),
        ),
        verticalAlignment: pw.TableCellVerticalAlignment.bottom,
        children: cab,
      ),
      for (final (i, e) in h.estudiantes.indexed)
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          decoration: pw.BoxDecoration(
            color: i.isOdd ? _suave(base, .965) : null,
            border: pw.Border(bottom: pw.BorderSide(color: linea, width: .5)),
          ),
          children: [
            pw.Container(
              height: 17,
              alignment: pw.Alignment.center,
              child: texto('${i + 1}', size: 7, color: _pdf(_gris)),
            ),
            pw.Container(
              height: 17,
              alignment: pw.Alignment.centerLeft,
              padding: const pw.EdgeInsets.symmetric(horizontal: 4),
              color: _suave(base, .94),
              child: pw.RichText(
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: '${e.apellidos.toUpperCase()}, ',
                      style: pw.TextStyle(font: media, fontSize: 7.6),
                    ),
                    pw.TextSpan(
                      text: e.nombres,
                      style: const pw.TextStyle(fontSize: 7.6),
                    ),
                  ],
                ),
              ),
            ),
            for (final c in cols) celda(h.nota(c, e), r.escalaDe(c), size),
          ],
        ),
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _pdf(_tinta), width: .8)),
        ),
        children: [
          pw.SizedBox(),
          pw.Container(
            height: 19,
            alignment: pw.Alignment.centerLeft,
            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
            child: texto(
              'MEDIA DEL AULA',
              size: 7,
              font: negrita,
              color: _osc(base, .2),
              ls: .6,
            ),
          ),
          for (final c in cols)
            () {
              final e = r.escalaDe(c);
              final m = _media([
                for (final s in h.estudiantes) ?h.nota(c, s),
              ], e);
              return pw.Center(
                child: texto(
                  m ?? '—',
                  size: size,
                  font: negrita,
                  color: m == null
                      ? _suave(_gris, .5)
                      : (_bajo(m, e) ? _pdf(_rojo) : _pdf(_tinta)),
                ),
              );
            }(),
        ],
      ),
    ];
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(wN),
        1: const pw.FixedColumnWidth(wNom),
        for (var i = 0; i < n; i++) i + 2: const pw.FlexColumnWidth(),
      },
      children: filas,
    );
  }

  pw.Widget leyenda() {
    final escalas = r.escalasConLetras;
    final numericas = {
      for (final h in r.hojas)
        for (final c in h.columnas)
          if (r.escalaDe(c) case final e? when e.numerica && e.aprueba != null)
            e.aprueba!,
    };
    return pw.Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final e in escalas)
          for (final (i, v) in e.valores.indexed)
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                i == 0
                    ? pastilla(
                        v.codigo,
                        _pdf(Color(v.color)),
                        _pdf(Colors.white),
                        6.5,
                      )
                    : pastilla(
                        v.codigo,
                        _suave(Color(v.color), .84),
                        _osc(Color(v.color), .1),
                        6.5,
                      ),
                pw.SizedBox(width: 4),
                texto(v.descripcion, size: 7, color: _pdf(_gris)),
              ],
            ),
        if (numericas.isNotEmpty)
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pastilla(
                '< ${_mostrar('${numericas.first}')}',
                _suave(_rojo, .88),
                _pdf(_rojo),
                6.5,
              ),
              pw.SizedBox(width: 4),
              texto('Nota desaprobatoria', size: 7, color: _pdf(_gris)),
            ],
          ),
        texto('·  Sin nota', size: 7, color: _pdf(_gris)),
      ],
    );
  }

  final firmas = pw.Row(
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
  );

  final subtitulo = [
    '${r.curso.nombre} · ${r.curso.grado} ${r.curso.seccion} · ${r.curso.nivel}',
    r.alcance,
  ];
  final estudiantes = {
    for (final h in r.hojas)
      for (final e in h.estudiantes) e.id,
  }.length;
  final evaluaciones = r.hojas.fold(0, (s, h) => s + h.columnas.length);

  final membrete = pw.Row(
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
            texto('Registro de notas', size: 23, font: fuerte),
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                for (final (i, s) in subtitulo.indexed) ...[
                  if (i > 0)
                    pw.Container(
                      width: 3,
                      height: 3,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 7),
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
                dato('ESTUDIANTES', '$estudiantes'),
                pw.SizedBox(height: 5),
                dato('EVALUACIONES', '$evaluaciones'),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  final varias = r.hojas.length > 1;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 26),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: texto('${r.titulo} · ${r.alcance}', color: _pdf(_gris)),
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
        membrete,
        pw.SizedBox(height: 16),
        for (final (i, h) in r.hojas.indexed) ...[
          if (i > 0) pw.NewPage(),
          if (varias) ...[
            texto(
              h.periodo.toUpperCase(),
              size: 9,
              font: negrita,
              color: _pdf(base),
              ls: 1.4,
            ),
            pw.SizedBox(height: 6),
          ],
          if (h.columnas.isEmpty || h.estudiantes.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: _suave(base, .95),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: texto(
                h.estudiantes.isEmpty
                    ? 'No hay estudiantes en este periodo.'
                    : 'Todavía no hay evaluaciones en este periodo.',
                size: 9,
                color: _pdf(_gris),
              ),
            )
          else
            // Con muchas columnas, el registro se parte en bloques de hasta
            // 15 y cada bloque repite los nombres, para que todo se lea.
            for (var k = 0; k < h.columnas.length; k += _porBloque) ...[
              if (k > 0) ...[
                // Cada bloque empieza en su página para no cortarse.
                pw.NewPage(),
                texto(
                  '${h.periodo} · columnas ${k + 1} a '
                  '${min(k + _porBloque, h.columnas.length)} '
                  'de ${h.columnas.length}',
                  size: 7.5,
                  color: _pdf(_gris),
                ),
                pw.SizedBox(height: 5),
              ],
              tabla(
                h,
                h.columnas.sublist(k, min(k + _porBloque, h.columnas.length)),
              ),
            ],
        ],
        pw.SizedBox(height: 8),
        leyenda(),
        firmas,
      ],
    ),
  );
  return doc.save();
}

// Excel

Uint8List excelRegistro(ReporteRegistro r) {
  final x = xl.Excel.createExcel();
  final defecto = x.getDefaultSheet()!;
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
    bool ajustar = false,
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
    textWrapping: ajustar ? xl.TextWrapping.WrapText : null,
    leftBorder: bordes ? borde : null,
    rightBorder: bordes ? borde : null,
    topBorder: bordes ? borde : null,
    bottomBorder: bordes ? borde : null,
  );

  final usados = <String>{};
  for (final (k, hoja) in r.hojas.indexed) {
    // Nombres de hoja: máximo 31 caracteres y sin / \ ? * [ ] :
    var nombre = hoja.periodo.replaceAll(RegExp(r'[\\/?*\[\]:]'), '-');
    if (nombre.length > 31) nombre = nombre.substring(0, 31);
    while (!usados.add(nombre)) {
      nombre = '$nombre ${usados.length}';
    }
    if (k == 0) x.rename(defecto, nombre);
    final h = x[nombre];

    void poner(int c, int f, Object? v, xl.CellStyle s) => h.updateCell(
      xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: f),
      switch (v) {
        final int n => xl.IntCellValue(n),
        final double n =>
          n == n.roundToDouble()
              ? xl.IntCellValue(n.round())
              : xl.DoubleCellValue(n),
        null => null,
        _ => xl.TextCellValue('$v'),
      },
      cellStyle: s,
    );

    final ultima = hoja.columnas.length + 1 < 6 ? 6 : hoja.columnas.length + 1;
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
      'Registro de notas',
      estilo(negrita: true, tam: 18, bordes: false),
    );
    titulo(
      2,
      [
        '${r.curso.nombre} · ${r.curso.grado} ${r.curso.seccion} · ${r.curso.nivel}',
        hoja.periodo,
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
    final cabTema = estilo(
      fondo: Color.lerp(base, Colors.white, .85),
      texto: _tinta,
      tam: 9,
      centro: true,
      ajustar: true,
    );
    poner(0, f0, 'N.°', cab);
    poner(
      1,
      f0,
      'APELLIDOS Y NOMBRES',
      estilo(fondo: oscuro, texto: Colors.white, negrita: true),
    );
    poner(0, f0 + 1, '', cabTema);
    poner(1, f0 + 1, '', cabTema);
    for (final (i, c) in hoja.columnas.indexed) {
      poner(i + 2, f0, c.codigo, cab);
      final detalle = _detalleColumna(c, r.escalaDe(c));
      poner(
        i + 2,
        f0 + 1,
        [
          if ((c.tema ?? '').isNotEmpty) c.tema!,
          if (detalle.isNotEmpty) detalle,
        ].join('\n'),
        cabTema,
      );
    }
    h.setRowHeight(f0, 22);
    h.setRowHeight(f0 + 1, 40);

    for (final (i, e) in hoja.estudiantes.indexed) {
      final f = f0 + 2 + i;
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
      for (final (j, c) in hoja.columnas.indexed) {
        final v = hoja.nota(c, e);
        final esc = r.escalaDe(c);
        if (v == null) {
          poner(j + 2, f, null, estilo(fondo: zebra, centro: true));
          continue;
        }
        if (esc == null || esc.numerica) {
          final n = _numero(v);
          poner(
            j + 2,
            f,
            n ?? v,
            _bajo(v, esc)
                ? estilo(
                    fondo: const Color(0xFFFCE8EB),
                    texto: _rojo,
                    negrita: true,
                    centro: true,
                  )
                : estilo(fondo: zebra, centro: true),
          );
          continue;
        }
        final k = esc.valores.indexWhere((x) => x.codigo == v);
        final c0 = k < 0 ? _gris : Color(esc.valores[k].color);
        poner(
          j + 2,
          f,
          v,
          estilo(
            fondo: k == 0 ? c0 : Color.lerp(c0, Colors.white, .84),
            texto: k == 0 ? Colors.white : Color.lerp(c0, Colors.black, .1)!,
            negrita: true,
            centro: true,
          ),
        );
      }
      h.setRowHeight(f, 18);
    }

    // Fila de media, con fórmula en las columnas numéricas.
    final fm = f0 + 2 + hoja.estudiantes.length;
    final calc = Color.lerp(base, Colors.white, .88)!;
    poner(0, fm, '', estilo(fondo: calc));
    poner(1, fm, 'MEDIA DEL AULA', estilo(fondo: calc, negrita: true));
    for (final (j, c) in hoja.columnas.indexed) {
      final esc = r.escalaDe(c);
      final s = estilo(fondo: calc, negrita: true, centro: true);
      final valores = [for (final e in hoja.estudiantes) ?hoja.nota(c, e)];
      final hayNumeros = valores.any((v) => _numero(v) != null);
      if ((esc == null || esc.numerica) &&
          hayNumeros &&
          hoja.estudiantes.isNotEmpty) {
        final letra = xl.CellIndex.indexByColumnRow(
          columnIndex: j + 2,
          rowIndex: 0,
        ).cellId.replaceAll(RegExp(r'\d'), '');
        h.updateCell(
          xl.CellIndex.indexByColumnRow(columnIndex: j + 2, rowIndex: fm),
          xl.FormulaCellValue('ROUND(AVERAGE($letra${f0 + 3}:$letra$fm),1)'),
          cellStyle: s,
        );
      } else {
        poner(j + 2, fm, _media(valores, esc) ?? '—', s);
      }
    }
    h.setRowHeight(fm, 20);

    if (hoja.columnas.isEmpty) {
      poner(
        1,
        fm + 2,
        'Todavía no hay evaluaciones en este periodo.',
        estilo(texto: _gris, bordes: false),
      );
    }

    h.setColumnWidth(0, 6);
    h.setColumnWidth(1, 38);
    for (var i = 0; i < hoja.columnas.length; i++) {
      h.setColumnWidth(i + 2, 12);
    }
  }
  return Uint8List.fromList(x.encode()!);
}
