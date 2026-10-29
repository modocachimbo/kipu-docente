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

  pw.Widget celda(String? e) {
    if (e == null) {
      return pw.Center(
        child: pw.Text('·', style: pw.TextStyle(color: _suave(_gris, .5))),
      );
    }
    if (e == 'P') {
      return pw.Center(
        child: pw.Container(
          width: 6,
          height: 6,
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
          color: _suave(c, .82),
          borderRadius: pw.BorderRadius.circular(3.5),
        ),
        child: pw.Text(
          e,
          style: pw.TextStyle(
            font: fuerte,
            fontSize: 7.5,
            color: _pdf(Color.lerp(c, Colors.black, .25)!),
          ),
        ),
      ),
    );
  }

  final muchas = r.fechas.length > 24;
  final cabecera = pw.TextStyle(
    font: negrita,
    fontSize: muchas ? 6.5 : 7.5,
    color: PdfColors.white,
  );
  final filas = <pw.TableRow>[
    pw.TableRow(
      decoration: pw.BoxDecoration(
        color: _pdf(Color.lerp(base, Colors.black, .15)!),
      ),
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        _pad(pw.Text('N.°', style: cabecera), centro: true),
        _pad(pw.Text('APELLIDOS Y NOMBRES', style: cabecera)),
        for (final d in r.fechas)
          _pad(
            pw.Column(
              children: [
                pw.Text(
                  d.substring(8),
                  style: cabecera.copyWith(fontSize: muchas ? 7 : 8.5),
                ),
                pw.Text(
                  DateFormat(
                    'MMM',
                    'es_PE',
                  ).format(DateTime.parse(d)).replaceAll('.', ''),
                  style: cabecera.copyWith(font: normal, fontSize: 6),
                ),
              ],
            ),
            centro: true,
          ),
        for (final t in ['%', 'F', 'T', 'J'])
          _pad(pw.Text(t, style: cabecera), centro: true),
      ],
    ),
  ];
  for (var i = 0; i < r.estudiantes.length; i++) {
    final e = r.estudiantes[i];
    final s = r.resumen(e);
    final bajo = s.pct != null && s.pct! < 80;
    final num = pw.TextStyle(font: negrita, fontSize: 8);
    filas.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: i.isOdd ? _suave(base, .965) : PdfColors.white,
          border: pw.Border(bottom: pw.BorderSide(color: linea, width: .5)),
        ),
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          _pad(
            pw.Text(
              '${i + 1}',
              style: pw.TextStyle(fontSize: 7.5, color: _pdf(_gris)),
            ),
            centro: true,
          ),
          _pad(
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '${e.apellidos.toUpperCase()}, ',
                    style: pw.TextStyle(font: media, fontSize: 8),
                  ),
                  pw.TextSpan(
                    text: e.nombres,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
          for (final d in r.fechas) celda(r.marcas[(e.id, d)]?.estado),
          pw.Container(
            color: _suave(base, .9),
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            alignment: pw.Alignment.center,
            child: pw.Text(
              s.pct == null ? '—' : '${s.pct}%',
              style: num.copyWith(
                color: bajo
                    ? _pdf(Color.lerp(_falta, Colors.black, .2)!)
                    : _pdf(_tinta),
              ),
            ),
          ),
          for (final (n, c) in [(s.f, _falta), (s.t, _tarde), (s.j, _justif)])
            pw.Container(
              color: _suave(base, .9),
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              alignment: pw.Alignment.center,
              child: pw.Text(
                '$n',
                style: num.copyWith(
                  color: n == 0
                      ? _suave(_gris, .45)
                      : _pdf(Color.lerp(c, Colors.black, .2)!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Indicadores del aula.
  var asist = 0, total = 0, faltas = 0, tardes = 0;
  for (final e in r.estudiantes) {
    final s = r.resumen(e);
    asist += s.p + s.t;
    total += s.total;
    faltas += s.f + s.j;
    tardes += s.t;
  }
  final pctAula = total == 0 ? '—' : '${(asist * 100 / total).round()}%';

  pw.Widget indicador(String valor, String texto, Color c) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _suave(c, .92),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            valor,
            style: pw.TextStyle(
              font: fuerte,
              fontSize: 15,
              color: _pdf(Color.lerp(c, Colors.black, .2)!),
            ),
          ),
          pw.Text(
            texto,
            style: pw.TextStyle(fontSize: 7.5, color: _pdf(_gris)),
          ),
        ],
      ),
    ),
  );

  pw.Widget leyenda() => pw.Row(
    children: [
      for (final e in ['P', 'T', 'F', 'J']) ...[
        pw.SizedBox(width: 18, height: 14, child: celda(e)),
        pw.Text(
          _nombreEstado[e]!,
          style: pw.TextStyle(fontSize: 7.5, color: _pdf(_gris)),
        ),
        pw.SizedBox(width: 10),
      ],
      pw.Text(
        '·  Sin registro',
        style: pw.TextStyle(fontSize: 7.5, color: _pdf(_gris)),
      ),
      pw.Spacer(),
      pw.Text(
        '% = (presentes + tardanzas) / clases registradas',
        style: pw.TextStyle(fontSize: 7, color: _suave(_gris, .3)),
      ),
    ],
  );

  final notas = r.conNota;
  final porId = {for (final e in r.estudiantes) e.id: e};

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 26),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                '${r.titulo} · ${r.periodo}',
                style: pw.TextStyle(fontSize: 8, color: _pdf(_gris)),
              ),
            ),
      footer: (ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: linea, width: .6)),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              'Emitido el $hoy con Kipu Docente',
              style: pw.TextStyle(fontSize: 7, color: _pdf(_gris)),
            ),
            pw.Spacer(),
            pw.Text(
              'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 7, color: _pdf(_gris)),
            ),
          ],
        ),
      ),
      build: (ctx) => [
        // Membrete
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 4, height: 54, color: _pdf(base)),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    r.colegio.toUpperCase(),
                    style: pw.TextStyle(
                      font: negrita,
                      fontSize: 8.5,
                      letterSpacing: 1.6,
                      color: _pdf(base),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Registro de asistencia',
                    style: pw.TextStyle(
                      font: fuerte,
                      fontSize: 22,
                      color: _pdf(_tinta),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    [
                      '${r.curso.nombre} · ${r.curso.grado} ${r.curso.seccion} · ${r.curso.nivel}',
                      r.periodo,
                      if (r.rango.isNotEmpty) r.rango,
                    ].join('   |   '),
                    style: pw.TextStyle(fontSize: 9, color: _pdf(_gris)),
                  ),
                ],
              ),
            ),
            pw.Container(
              width: 190,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: linea, width: .8),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DOCENTE',
                    style: pw.TextStyle(
                      font: negrita,
                      fontSize: 6.5,
                      letterSpacing: 1.2,
                      color: _pdf(_gris),
                    ),
                  ),
                  pw.Text(
                    r.docente.isEmpty ? '—' : r.docente,
                    style: pw.TextStyle(font: media, fontSize: 9.5),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'ESTUDIANTES · CLASES',
                    style: pw.TextStyle(
                      font: negrita,
                      fontSize: 6.5,
                      letterSpacing: 1.2,
                      color: _pdf(_gris),
                    ),
                  ),
                  pw.Text(
                    '${r.estudiantes.length} · ${r.fechas.length}',
                    style: pw.TextStyle(font: media, fontSize: 9.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          children: [
            indicador(pctAula, 'Asistencia del aula', base),
            pw.SizedBox(width: 8),
            indicador('${r.fechas.length}', 'Clases registradas', _justif),
            pw.SizedBox(width: 8),
            indicador('$faltas', 'Faltas (incluye justificadas)', _falta),
            pw.SizedBox(width: 8),
            indicador('$tardes', 'Tardanzas', _tarde),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Table(
          columnWidths: {
            0: const pw.FixedColumnWidth(22),
            1: const pw.FixedColumnWidth(170),
            for (var i = 0; i < r.fechas.length; i++)
              i + 2: const pw.FlexColumnWidth(),
            r.fechas.length + 2: const pw.FixedColumnWidth(34),
            for (var i = 3; i < 6; i++)
              r.fechas.length + i: const pw.FixedColumnWidth(20),
          },
          children: filas,
        ),
        pw.SizedBox(height: 8),
        leyenda(),
        if (notas.isNotEmpty) ...[
          pw.SizedBox(height: 18),
          pw.Text(
            'OBSERVACIONES',
            style: pw.TextStyle(
              font: negrita,
              fontSize: 8.5,
              letterSpacing: 1.4,
              color: _pdf(base),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            columnWidths: const {
              0: pw.FixedColumnWidth(54),
              1: pw.FixedColumnWidth(170),
              2: pw.FixedColumnWidth(62),
              3: pw.FixedColumnWidth(80),
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
                    _pad(
                      pw.Text(
                        t,
                        style: pw.TextStyle(font: negrita, fontSize: 7.5),
                      ),
                    ),
                ],
              ),
              for (final a in notas)
                if (porId[a.estudianteId] case final e?)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: linea, width: .5),
                      ),
                    ),
                    children: [
                      _pad(
                        pw.Text(
                          _dia(a.fecha),
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                      _pad(
                        pw.Text(
                          '${e.apellidos.toUpperCase()}, ${e.nombres}',
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                      _pad(
                        pw.Text(
                          _nombreEstado[a.estado] ?? a.estado,
                          style: pw.TextStyle(
                            font: media,
                            fontSize: 7.5,
                            color: _pdf(
                              Color.lerp(
                                colorEstado(a.estado, base),
                                Colors.black,
                                .2,
                              )!,
                            ),
                          ),
                        ),
                      ),
                      _pad(
                        pw.Text(
                          a.motivo ?? '—',
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                      _pad(
                        pw.Text(
                          a.nota ?? '',
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ],
        pw.SizedBox(height: 46),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 200, height: .8, color: _pdf(_tinta)),
                pw.SizedBox(height: 4),
                pw.Text(
                  r.docente.isEmpty ? 'Firma del docente' : r.docente,
                  style: pw.TextStyle(font: media, fontSize: 8.5),
                ),
                pw.Text(
                  'Docente de ${r.curso.nombre}',
                  style: pw.TextStyle(fontSize: 7.5, color: _pdf(_gris)),
                ),
              ],
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
