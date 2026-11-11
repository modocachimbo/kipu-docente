import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;

import 'cneb.dart';
import 'database.dart';
import 'instrumentos_excel.dart' show normalizar;
import 'planificacion.dart';

/// Una sesión lista para el Excel.
class FilaSesion {
  final int numero;
  final String unidad;
  final String fecha; // dd/MM/yyyy o vacío
  final String hora;
  final String tema;
  final String competencia;
  final String proposito;
  final String actividades;
  final String materiales;
  final String tarea;
  const FilaSesion({
    required this.numero,
    required this.unidad,
    required this.fecha,
    required this.hora,
    required this.tema,
    required this.competencia,
    required this.proposito,
    required this.actividades,
    required this.materiales,
    required this.tarea,
  });

  factory FilaSesion.de(Sesion s, int numero, Unidad u, {String? unidad}) {
    String f = '';
    if (s.fecha != null) {
      final p = s.fecha!.split('-');
      f = '${p[2]}/${p[1]}/${p[0]}';
    }
    final acts = [
      if (s.inicio != null) 'Inicio: ${s.inicio}',
      if (s.desarrollo != null)
        s.inicio == null && s.cierre == null
            ? s.desarrollo!
            : 'Desarrollo: ${s.desarrollo}',
      if (s.cierre != null) 'Cierre: ${s.cierre}',
    ].join('\n');
    return FilaSesion(
      numero: numero,
      unidad: unidad ?? u.titulo,
      fecha: f,
      hora: s.hora ?? '',
      tema: s.titulo,
      competencia: competenciaPorId(s.competencia ?? '')?.corto ?? '',
      proposito: s.proposito ?? '',
      actividades: acts,
      materiales: s.materiales ?? '',
      tarea: s.tarea ?? '',
    );
  }
}

/// Bloque de una unidad en el Excel.
class BloqueUnidad {
  final int numero;
  final Unidad unidad;
  final List<Sesion> sesiones;
  const BloqueUnidad(this.numero, this.unidad, this.sesiones);

  List<FilaSesion> get filas => [
    for (var i = 0; i < sesiones.length; i++)
      FilaSesion.de(sesiones[i], i + 1, unidad, unidad: 'U$numero'),
  ];
}

const _columnas = [
  ('N.°', 6.0),
  ('Fecha', 12.0),
  ('Hora', 8.0),
  ('Tema / sesión', 34.0),
  ('Competencia', 26.0),
  ('Propósito', 36.0),
  ('Actividades', 50.0),
  ('Materiales', 24.0),
  ('Tarea', 24.0),
];

List<String> _valores(FilaSesion f) => [
  '${f.numero}',
  f.fecha,
  f.hora,
  f.tema,
  f.competencia,
  f.proposito,
  f.actividades,
  f.materiales,
  f.tarea,
];

String _fechaDmy(String? f) {
  if (f == null) return '';
  final p = f.split('-');
  return '${p[2]}/${p[1]}';
}

/// Planificación en Excel con el formato de Kipu: por cada unidad, una fila
/// con sus datos y debajo una fila por sesión.
Uint8List excelPlanificacion({
  required String titulo,
  required List<BloqueUnidad> bloques,
}) {
  final x = xl.Excel.createExcel();
  final defecto = x.getDefaultSheet()!;
  x.rename(defecto, 'Planificación');
  final h = x['Planificación'];
  final borde = xl.Border(
    borderStyle: xl.BorderStyle.Thin,
    borderColorHex: xl.ExcelColor.fromHexString('FFD6D9DF'),
  );
  xl.CellStyle estilo({
    String? fondo,
    bool negrita = false,
    String texto = 'FF1F1B2E',
    bool bordes = true,
  }) => xl.CellStyle(
    backgroundColorHex: fondo == null
        ? xl.ExcelColor.none
        : xl.ExcelColor.fromHexString(fondo),
    fontColorHex: xl.ExcelColor.fromHexString(texto),
    bold: negrita,
    fontFamily: 'Calibri',
    fontSize: 11,
    verticalAlign: xl.VerticalAlign.Top,
    textWrapping: xl.TextWrapping.WrapText,
    leftBorder: bordes ? borde : null,
    rightBorder: bordes ? borde : null,
    topBorder: bordes ? borde : null,
    bottomBorder: bordes ? borde : null,
  );
  final cab = estilo(fondo: 'FF1D6F42', negrita: true, texto: 'FFFFFFFF');
  final uni = estilo(fondo: 'FFE6F2EA', negrita: true, texto: 'FF14532D');
  final normal = estilo();
  void poner(int f, int c, String v, xl.CellStyle? e) => h.updateCell(
    xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: f),
    xl.TextCellValue(v),
    cellStyle: e,
  );

  var f = 0;
  poner(
    f++,
    0,
    titulo,
    xl.CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: xl.ExcelColor.fromHexString('FF1D6F42'),
    ),
  );
  f++;
  for (final b in bloques) {
    final u = b.unidad;
    final comps = [
      for (final c in u.listaCompetencias) competenciaPorId(c)?.corto ?? c,
    ].join(', ');
    final datos = [
      'Unidad ${b.numero}: ${u.titulo}',
      if (u.desde != null || u.hasta != null)
        '${_fechaDmy(u.desde)} – ${_fechaDmy(u.hasta)}',
      if (comps.isNotEmpty) 'Competencias: $comps',
      if ((u.temas ?? '').isNotEmpty) 'Temas: ${u.temas}',
      if ((u.producto ?? '').isNotEmpty) 'Producto: ${u.producto}',
    ].join(' · ');
    poner(f, 0, datos, uni);
    for (var c = 1; c < _columnas.length; c++) {
      poner(f, c, '', uni);
    }
    h.merge(
      xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: f),
      xl.CellIndex.indexByColumnRow(
        columnIndex: _columnas.length - 1,
        rowIndex: f,
      ),
    );
    f++;
    for (var c = 0; c < _columnas.length; c++) {
      poner(f, c, _columnas[c].$1, cab);
    }
    f++;
    for (final fila in b.filas) {
      final v = _valores(fila);
      for (var c = 0; c < v.length; c++) {
        poner(f, c, v[c], normal);
      }
      f++;
    }
    if (b.sesiones.isEmpty) {
      poner(
        f++,
        0,
        'Sin sesiones todavía',
        estilo(texto: 'FF6E6A80', bordes: false),
      );
    }
    f++;
  }
  for (var c = 0; c < _columnas.length; c++) {
    h.setColumnWidth(c, _columnas[c].$2);
  }
  return Uint8List.fromList(x.encode()!);
}

/// Qué dato va en una columna del formato del colegio, según su título.
String? campoDeTitulo(String titulo) {
  final t = normalizar(titulo);
  if (t.isEmpty) return null;
  bool tiene(List<String> l) => l.any(t.contains);
  if (t == 'N' ||
      t == 'NO' ||
      t == 'N°' ||
      t == 'Nº' ||
      t == 'N.°' ||
      t == '#' ||
      tiene(['NRO', 'NUMERO', 'N° DE SESION', 'Nº DE SESION'])) {
    return 'numero';
  }
  if (t.contains('FECHA') || t == 'DIA') return 'fecha';
  if (tiene(['HORA'])) return 'hora';
  if (tiene(['UNIDAD', 'EXPERIENCIA'])) return 'unidad';
  if (tiene(['COMPETENCIA'])) return 'competencia';
  if (tiene(['PROPOSITO', 'OBJETIVO', 'APRENDIZAJE ESPERADO'])) {
    return 'proposito';
  }
  if (tiene([
    'ACTIVIDAD',
    'ESTRATEGIA',
    'SECUENCIA',
    'DESARROLLO',
    'PROCESO',
  ])) {
    return 'actividades';
  }
  if (tiene(['MATERIAL', 'RECURSO'])) return 'materiales';
  if (tiene(['TAREA', 'EXTENSION'])) return 'tarea';
  if (tiene(['TEMA', 'TITULO', 'SESION', 'CONTENIDO', 'NOMBRE'])) {
    return 'tema';
  }
  return null;
}

String _valor(FilaSesion f, String campo) => switch (campo) {
  'numero' => '${f.numero}',
  'fecha' => f.fecha,
  'hora' => f.hora,
  'unidad' => f.unidad,
  'competencia' => f.competencia,
  'proposito' => f.proposito,
  'actividades' => f.actividades,
  'materiales' => f.materiales,
  'tarea' => f.tarea,
  'tema' => f.tema,
  _ => '',
};

/// Resultado de llenar el formato del colegio.
class FormatoLleno {
  final Uint8List? bytes;
  final List<String> columnas; // títulos que se reconocieron
  final String? error;
  const FormatoLleno(this.bytes, this.columnas, [this.error]);
}

/// Busca en el Excel del colegio la fila de títulos (la primera con al menos
/// dos columnas reconocidas) y llena debajo una fila por sesión.
FormatoLleno llenarFormato(List<int> plantilla, List<FilaSesion> filas) {
  final xl.Excel x;
  try {
    x = xl.Excel.decodeBytes(plantilla);
  } catch (_) {
    return const FormatoLleno(
      null,
      [],
      'No se pudo abrir el Excel del colegio.',
    );
  }
  for (final nombre in x.tables.keys) {
    final h = x[nombre];
    final limite = h.maxRows < 40 ? h.maxRows : 40;
    for (var r = 0; r < limite; r++) {
      final fila = r < h.rows.length ? h.rows[r] : const <xl.Data?>[];
      final campos = <int, String>{};
      final titulos = <String>[];
      for (var c = 0; c < fila.length; c++) {
        final v = fila[c]?.value?.toString() ?? '';
        final campo = campoDeTitulo(v);
        if (campo != null && !campos.containsValue(campo)) {
          campos[c] = campo;
          titulos.add(v.trim());
        }
      }
      if (campos.length < 2) continue;
      final estilos = <int, xl.CellStyle?>{
        for (final c in campos.keys)
          c: r + 1 < h.rows.length && c < h.rows[r + 1].length
              ? h.rows[r + 1][c]?.cellStyle
              : null,
      };
      for (var i = 0; i < filas.length; i++) {
        for (final e in campos.entries) {
          h.updateCell(
            xl.CellIndex.indexByColumnRow(
              columnIndex: e.key,
              rowIndex: r + 1 + i,
            ),
            xl.TextCellValue(_valor(filas[i], e.value)),
            cellStyle: estilos[e.key],
          );
        }
      }
      final out = x.encode();
      return FormatoLleno(
        out == null ? null : Uint8List.fromList(out),
        titulos,
      );
    }
  }
  return const FormatoLleno(
    null,
    [],
    'No encontré la fila de títulos. Pon títulos como Fecha, Tema, '
    'Competencia o Actividades en una fila del Excel.',
  );
}
