import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;

import 'cneb.dart';
import 'instrumentos.dart';

/// Plantillas de Excel para crear instrumentos fuera de la app (en la
/// computadora o en Google Sheets) y subirlos. El mismo formato sirve para
/// descargar un instrumento ya hecho, editarlo y volver a subirlo.
///
/// Formato (columna A = etiqueta o texto, B = peso, C en adelante = niveles):
///
///   NOMBRE           | Exposición oral
///   TIPO             | Rúbrica
///   DESCRIPCIÓN      | …
///   NIVEL EDUCATIVO  | Primaria, Secundaria
///   ÁREA             | Comunicación
///   OPCIONES         | No observado, Ponderada
///   NIVELES          |        | En inicio | En proceso | …
///   PUNTOS           |        | 1         | 2          | …
///   CRITERIO         | PESO   | (descriptores debajo de cada nivel)
///   Habla            | 25     | Habla rápido… | …
///
/// Las filas en blanco y la fila de título se ignoran.

const _hojaInstrumento = 'Instrumento';
const _hojaInstrucciones = 'Instrucciones';

String _tipoTexto(TipoInstrumento t) => t.nombre;

/// Mayúsculas y sin tildes, para comparar etiquetas sin importar cómo se
/// escribieron.
String normalizar(String s) {
  const de = 'ÁÉÍÓÚÜÑáéíóúüñ', a = 'AEIOUUNAEIOUUN';
  var r = s.trim();
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i], a[i]);
  }
  return r.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Filas de texto que representan un instrumento (lo que va al Excel o CSV).
/// «A–D», «V/F» o «Desarrollo».
String tipoPreguntaTexto(ItemInstrumento i) => i.desarrollo
    ? 'Desarrollo'
    : (i.opciones == 2 ? 'V/F' : 'A–${String.fromCharCode(64 + i.opciones)}');

List<List<Object?>> filasDeInstrumento(Instrumento ins) {
  final rubrica = ins.tipo == TipoInstrumento.rubrica;
  final opciones = [
    if (ins.noObservado) 'No observado',
    if (ins.ponderada && ins.tipo != TipoInstrumento.prueba) 'Ponderada',
  ].join(', ');
  final cabecera = <List<Object?>>[
    ['KIPU · INSTRUMENTO DE EVALUACIÓN'],
    ['NOMBRE', ins.nombre],
    ['TIPO', _tipoTexto(ins.tipo)],
    ['DESCRIPCIÓN', ins.descripcion],
    ['NIVEL EDUCATIVO', ins.niveles.join(', ')],
    ['ÁREA', ins.area],
    [
      'COMPETENCIAS',
      [
        for (final id in ins.competencias) competenciaPorId(id)?.nombre ?? id,
      ].join('; '),
    ],
    ['OPCIONES', opciones],
    [],
  ];
  if (ins.tipo == TipoInstrumento.prueba) {
    return [
      ...cabecera,
      ['PREGUNTA', 'PUNTOS', 'TIPO DE PREGUNTA', 'CLAVE'],
      for (final it in ins.items)
        [
          it.texto,
          it.peso,
          tipoPreguntaTexto(it),
          it.desarrollo || it.clave == null ? '' : it.letras[it.clave!],
        ],
    ];
  }
  return [
    ...cabecera,
    ['NIVELES', '', for (final n in ins.escala) n.nombre],
    ['PUNTOS', '', for (final n in ins.escala) n.puntos],
    [rubrica ? 'CRITERIO' : 'ÍTEM', rubrica ? 'PESO %' : 'PESO'],
    for (final it in ins.items)
      [
        it.texto,
        ins.ponderada ? it.peso : '',
        if (rubrica)
          for (var k = 0; k < ins.escala.length; k++)
            k < it.descriptores.length ? it.descriptores[k] : '',
      ],
  ];
}

/// Plantilla en blanco de un tipo, con un ejemplo corto para guiar.
Instrumento plantillaDe(TipoInstrumento t) => switch (t) {
  TipoInstrumento.rubrica => Instrumento(
    id: 'plantilla',
    tipo: t,
    nombre: 'Mi rúbrica',
    niveles: const ['Secundaria'],
    area: 'Comunicación',
    escala: plantillaNivelesRubrica,
    ponderada: true,
    items: const [
      ItemInstrumento(
        id: '1',
        texto: 'Escribe aquí el criterio 1',
        peso: 50,
        descriptores: [
          'Qué hace en inicio',
          'Qué hace en proceso',
          'Qué hace con logro esperado',
          'Qué hace con logro destacado',
        ],
      ),
      ItemInstrumento(
        id: '2',
        texto: 'Escribe aquí el criterio 2',
        peso: 50,
        descriptores: ['…', '…', '…', '…'],
      ),
    ],
  ),
  TipoInstrumento.cotejo => Instrumento(
    id: 'plantilla',
    tipo: t,
    nombre: 'Mi lista de cotejo',
    niveles: const ['Primaria'],
    escala: etiquetasCotejo.first.niveles,
    noObservado: true,
    items: const [
      ItemInstrumento(id: '1', texto: 'Escribe aquí el ítem 1'),
      ItemInstrumento(id: '2', texto: 'Escribe aquí el ítem 2'),
      ItemInstrumento(id: '3', texto: 'Escribe aquí el ítem 3'),
    ],
  ),
  TipoInstrumento.prueba => const Instrumento(
    id: 'plantilla',
    tipo: TipoInstrumento.prueba,
    nombre: 'Mi examen',
    niveles: ['Secundaria'],
    area: 'Matemática',
    ponderada: true,
    items: [
      ItemInstrumento(id: '1', texto: 'Pregunta 1 (opcional: escribe el enunciado)', peso: 4, opciones: 4, clave: 1),
      ItemInstrumento(id: '2', texto: '', peso: 4, opciones: 4, clave: 0),
      ItemInstrumento(id: '3', texto: '', peso: 2, opciones: 2, clave: 0),
      ItemInstrumento(id: '4', texto: '', peso: 2, opciones: 2, clave: 1),
      ItemInstrumento(id: '5', texto: 'Problema de desarrollo', peso: 8),
    ],
  ),
  TipoInstrumento.escala => Instrumento(
    id: 'plantilla',
    tipo: t,
    nombre: 'Mi escala de valoración',
    niveles: const ['Primaria', 'Secundaria'],
    escala: nivelesEscala.first.niveles,
    items: const [
      ItemInstrumento(id: '1', texto: 'Escribe aquí el ítem 1'),
      ItemInstrumento(id: '2', texto: 'Escribe aquí el ítem 2'),
      ItemInstrumento(id: '3', texto: 'Escribe aquí el ítem 3'),
    ],
  ),
};

List<String> _instrucciones(TipoInstrumento t) => [
  'CÓMO LLENAR ESTA PLANTILLA',
  '',
  '1. Escribe el NOMBRE del instrumento (columna B).',
  '2. No cambies las palabras de la columna A: NOMBRE, TIPO, NIVELES, PUNTOS…',
  '3. TIPO puede ser: Rúbrica, Lista de cotejo, Escala de valoración o Examen con clave.',
  '   COMPETENCIAS (opcional): nombres del Currículo Nacional separados por «;».',
  '4. NIVEL EDUCATIVO: Inicial, Primaria o Secundaria (puedes poner varios separados por coma).',
  '5. OPCIONES (opcional): «No observado» agrega esa marca; «Ponderada» usa la columna PESO.',
  if (t == TipoInstrumento.prueba) ...[
    '6. Debajo de PREGUNTA, una fila por pregunta. El enunciado es opcional.',
    '7. PUNTOS: cuánto vale la pregunta. Lo ideal es que todo sume 20.',
    '8. TIPO DE PREGUNTA: A–D (opción múltiple de A a D), A–C, A–E, V/F o Desarrollo.',
    '9. CLAVE: la respuesta correcta (A, B, C… o V / F). En desarrollo déjala vacía.',
  ] else if (t == TipoInstrumento.rubrica) ...[
    '6. NIVELES: escribe los niveles de logro de MENOR a MAYOR, desde la columna C.',
    '7. PUNTOS: cuánto vale cada nivel (por ejemplo 1, 2, 3, 4).',
    '8. Debajo de CRITERIO, una fila por criterio: en A el criterio, en B su peso en % y',
    '   debajo de cada nivel lo que hace el estudiante en ese nivel (descriptor).',
    '9. Si no pones pesos, todos los criterios valen lo mismo.',
  ] else if (t == TipoInstrumento.cotejo) ...[
    '6. NIVELES: la etiqueta positiva y la negativa (Sí / No, Logrado / No logrado…).',
    '7. PUNTOS: deja 1 y 0.',
    '8. Debajo de ÍTEM, una fila por ítem. Si es ponderada, escribe en B los puntos de cada ítem.',
  ] else ...[
    '6. NIVELES: del MEJOR al más bajo (Siempre, Casi siempre, A veces, Nunca).',
    '7. PUNTOS: cuánto vale cada nivel (por ejemplo 3, 2, 1, 0).',
    '8. Debajo de ÍTEM, una fila por ítem. Si es ponderada, escribe en B el peso de cada ítem.',
  ],
  '',
  'Cuando termines, en Kipu ve a Evaluación › + › Subir desde Excel.',
  'También puedes guardar como CSV (separado por comas o punto y coma).',
];

/// Archivo .xlsx de un instrumento (o de una plantilla) con su hoja de
/// instrucciones.
Uint8List excelDeInstrumento(Instrumento ins) {
  final x = xl.Excel.createExcel();
  final defecto = x.getDefaultSheet()!;
  x.rename(defecto, _hojaInstrumento);
  final h = x[_hojaInstrumento];
  final filas = filasDeInstrumento(ins);

  final borde = xl.Border(
    borderStyle: xl.BorderStyle.Thin,
    borderColorHex: xl.ExcelColor.fromHexString('FFE2E3EE'),
  );
  xl.CellStyle estilo({String? fondo, bool negrita = false, String texto = 'FF1F1B2E'}) =>
      xl.CellStyle(
        backgroundColorHex: fondo == null
            ? xl.ExcelColor.none
            : xl.ExcelColor.fromHexString(fondo),
        fontColorHex: xl.ExcelColor.fromHexString(texto),
        bold: negrita,
        fontFamily: 'Calibri',
        fontSize: 11,
        verticalAlign: xl.VerticalAlign.Top,
        textWrapping: xl.TextWrapping.WrapText,
        leftBorder: borde,
        rightBorder: borde,
        topBorder: borde,
        bottomBorder: borde,
      );
  final etiqueta = estilo(fondo: 'FFE6E8FB', negrita: true, texto: 'FF3A44B0');
  final normal = estilo();
  final titulo = xl.CellStyle(
    bold: true,
    fontSize: 13,
    fontColorHex: xl.ExcelColor.fromHexString('FF4F5BD5'),
  );

  for (var f = 0; f < filas.length; f++) {
    final fila = filas[f];
    for (var c = 0; c < fila.length; c++) {
      final v = fila[c];
      final primera = fila.isEmpty ? '' : normalizar('${fila.first}');
      final esEtiqueta =
          f >= 1 &&
          ((c == 0 && _etiquetas.contains(primera)) ||
              _filasCabecera.contains(primera));
      h.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: f),
        switch (v) {
          final double n when n == n.roundToDouble() => xl.IntCellValue(n.round()),
          final double n => xl.DoubleCellValue(n),
          final int n => xl.IntCellValue(n),
          null => xl.TextCellValue(''),
          _ => xl.TextCellValue('$v'),
        },
        cellStyle: f == 0 ? titulo : (esEtiqueta ? etiqueta : normal),
      );
    }
  }
  h.setColumnWidth(0, 34);
  h.setColumnWidth(1, 10);
  if (ins.tipo == TipoInstrumento.prueba) {
    h.setColumnWidth(0, 46);
    h.setColumnWidth(2, 20);
    h.setColumnWidth(3, 10);
  }
  for (var c = 0; c < ins.escala.length; c++) {
    h.setColumnWidth(c + 2, ins.tipo == TipoInstrumento.rubrica ? 30 : 16);
  }

  final ayuda = x[_hojaInstrucciones];
  final lineas = _instrucciones(ins.tipo);
  for (var f = 0; f < lineas.length; f++) {
    ayuda.updateCell(
      xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: f),
      xl.TextCellValue(lineas[f]),
      cellStyle: f == 0 ? titulo : null,
    );
  }
  ayuda.setColumnWidth(0, 110);
  x.setDefaultSheet(_hojaInstrumento);
  return Uint8List.fromList(x.encode()!);
}

const _etiquetas = {
  'NOMBRE',
  'TIPO',
  'DESCRIPCION',
  'NIVEL EDUCATIVO',
  'AREA',
  'COMPETENCIAS',
  'OPCIONES',
};
const _filasCabecera = {'NIVELES', 'PUNTOS', 'CRITERIO', 'ITEM', 'PREGUNTA'};

/// Nombre de archivo seguro: «rubrica-exposicion-oral.xlsx».
String nombreArchivo(Instrumento ins, {String ext = 'xlsx'}) {
  final base = normalizar('${ins.tipo.nombre} ${ins.nombre}')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final corto = base.length > 60 ? base.substring(0, 60) : base;
  return '${corto.isEmpty ? 'instrumento' : corto}.$ext';
}

// ───────────────────────────── Leer ─────────────────────────────

/// Resultado de leer un archivo: el instrumento (si se pudo) y los avisos.
class Lectura {
  final Instrumento? instrumento;
  final List<String> errores;
  final List<String> avisos;
  const Lectura(this.instrumento, this.errores, [this.avisos = const []]);
  bool get ok => instrumento != null && errores.isEmpty;
}

/// Lee un .xlsx (bytes) o un .csv (texto). [esCsv] lo decide quien llama
/// por la extensión; si los bytes no son un Excel válido se intenta CSV.
Lectura leerArchivo(List<int> bytes, {bool esCsv = false}) {
  if (!esCsv) {
    try {
      final x = xl.Excel.decodeBytes(bytes);
      final hoja = x.tables[_hojaInstrumento] ??
          x.tables.values.firstWhere(
            (t) => t.rows.isNotEmpty,
            orElse: () => x.tables.values.first,
          );
      final filas = [
        for (final fila in hoja.rows)
          [for (final c in fila) _texto(c?.value)],
      ];
      return leerFilas(filas);
    } catch (_) {
      // Puede ser un CSV con extensión equivocada.
    }
  }
  try {
    var texto = utf8.decode(bytes, allowMalformed: true);
    if (texto.startsWith('﻿')) texto = texto.substring(1);
    return leerFilas(leerCsv(texto));
  } catch (_) {
    return const Lectura(null, [
      'No se pudo abrir el archivo. Usa la plantilla de Kipu en Excel (.xlsx) o CSV.',
    ]);
  }
}

String _texto(Object? v) {
  if (v == null) return '';
  final t = v.toString().trim();
  // Excel guarda 3 como 3.0 a veces.
  return t.endsWith('.0') && double.tryParse(t) != null
      ? t.substring(0, t.length - 2)
      : t;
}

/// CSV con comas o punto y coma (Excel en español usa «;»), con comillas.
List<List<String>> leerCsv(String texto) {
  // El separador se decide mirando las primeras líneas (la primera puede
  // ser solo un título).
  final muestra = texto.split('\n').take(12).join('\n');
  final sep = ';'.allMatches(muestra).length > ','.allMatches(muestra).length
      ? ';'
      : ',';
  final filas = <List<String>>[];
  var fila = <String>[];
  final celda = StringBuffer();
  var comillas = false;
  for (var i = 0; i < texto.length; i++) {
    final ch = texto[i];
    if (comillas) {
      if (ch == '"') {
        if (i + 1 < texto.length && texto[i + 1] == '"') {
          celda.write('"');
          i++;
        } else {
          comillas = false;
        }
      } else {
        celda.write(ch);
      }
    } else if (ch == '"') {
      comillas = true;
    } else if (ch == sep) {
      fila.add(celda.toString().trim());
      celda.clear();
    } else if (ch == '\n' || ch == '\r') {
      if (ch == '\r' && i + 1 < texto.length && texto[i + 1] == '\n') i++;
      fila.add(celda.toString().trim());
      celda.clear();
      filas.add(fila);
      fila = [];
    } else {
      celda.write(ch);
    }
  }
  if (celda.isNotEmpty || fila.isNotEmpty) {
    fila.add(celda.toString().trim());
    filas.add(fila);
  }
  return filas;
}

/// CSV de un instrumento (punto y coma, para Excel en español).
String csvDeInstrumento(Instrumento ins) {
  String esc(Object? v) {
    var t = v is double
        ? (v == v.roundToDouble() ? '${v.round()}' : '$v')
        : '${v ?? ''}';
    if (t.contains(';') || t.contains('"') || t.contains('\n')) {
      t = '"${t.replaceAll('"', '""')}"';
    }
    return t;
  }

  return [
    for (final f in filasDeInstrumento(ins)) f.map(esc).join(';'),
  ].join('\r\n');
}

double? _numero(String s) => double.tryParse(s.replaceAll(',', '.').replaceAll('%', '').trim());

/// Arma el instrumento a partir de las filas. Explica cada problema con el
/// número de fila, como lo ve el docente en Excel.
Lectura leerFilas(List<List<String>> filas) {
  final errores = <String>[], avisos = <String>[];
  String celda(List<String> f, int i) => i < f.length ? f[i].trim() : '';

  String nombre = '', tipoTxt = '', descripcion = '', nivelTxt = '', area = '';
  String opciones = '', competenciasTxt = '';
  var esPrueba = false;
  List<String>? nombresNiveles;
  List<String>? puntosTxt;
  var filaNiveles = 0;
  final items = <(int, List<String>)>[]; // (fila, celdas)
  var enItems = false;

  for (var f = 0; f < filas.length; f++) {
    final fila = filas[f];
    final a = celda(fila, 0);
    final clave = normalizar(a);
    final resto = [for (var i = 2; i < fila.length; i++) celda(fila, i)];
    if (fila.every((c) => c.trim().isEmpty)) continue;
    if (clave.startsWith('KIPU')) continue;
    if (!enItems) {
      switch (clave) {
        case 'NOMBRE':
          nombre = celda(fila, 1);
          continue;
        case 'TIPO':
          tipoTxt = celda(fila, 1);
          continue;
        case 'DESCRIPCION':
          descripcion = celda(fila, 1);
          continue;
        case 'NIVEL EDUCATIVO' || 'NIVEL' || 'NIVELES EDUCATIVOS':
          nivelTxt = celda(fila, 1);
          continue;
        case 'AREA':
          area = celda(fila, 1);
          continue;
        case 'OPCIONES':
          opciones = celda(fila, 1);
          continue;
        case 'COMPETENCIAS' || 'COMPETENCIA':
          competenciasTxt = celda(fila, 1);
          continue;
        case 'PREGUNTA' || 'PREGUNTAS':
          enItems = true;
          esPrueba = true;
          continue;
        case 'NIVELES' || 'ESCALA' || 'ETIQUETAS':
          // Quitamos celdas vacías del final.
          final n = [...resto];
          while (n.isNotEmpty && n.last.isEmpty) {
            n.removeLast();
          }
          nombresNiveles = n;
          filaNiveles = f + 1;
          continue;
        case 'PUNTOS' || 'VALOR' || 'VALORES':
          puntosTxt = resto;
          continue;
        case 'CRITERIO' || 'CRITERIOS' || 'ITEM' || 'ITEMS':
          enItems = true;
          continue;
      }
      // Fila desconocida antes de los ítems: probablemente ya son ítems.
      if (nombresNiveles != null) {
        enItems = true;
      } else {
        avisos.add('Fila ${f + 1}: no se reconoce «$a» y se ignoró.');
        continue;
      }
    }
    if (a.isEmpty) {
      // En el examen el enunciado es opcional: basta con los puntos.
      if (esPrueba && celda(fila, 1).isNotEmpty) {
        items.add((f + 1, fila));
      } else if (resto.any((c) => c.isNotEmpty)) {
        errores.add('Fila ${f + 1}: falta el texto del criterio o ítem (columna A).');
      }
      continue;
    }
    items.add((f + 1, fila));
  }

  // Tipo
  final tn = normalizar(tipoTxt);
  TipoInstrumento? tipo;
  if (tn.contains('EXAMEN') || tn.contains('PRUEBA') || (tn.isEmpty && esPrueba)) {
    tipo = TipoInstrumento.prueba;
  } else if (tn.contains('RUBRICA')) {
    tipo = TipoInstrumento.rubrica;
  } else if (tn.contains('COTEJO')) {
    tipo = TipoInstrumento.cotejo;
  } else if (tn.contains('ESCALA') || tn.contains('VALORACION')) {
    tipo = TipoInstrumento.escala;
  } else if (tn.isNotEmpty) {
    errores.add(
      'TIPO «$tipoTxt» no se reconoce. Usa: Rúbrica, Lista de cotejo o Escala de valoración.',
    );
  }
  final hayDescriptores = items.any(
    (it) => [for (var i = 2; i < it.$2.length; i++) it.$2[i]].any((c) => c.trim().isNotEmpty),
  );
  if (tipo == null && tn.isEmpty) {
    tipo = hayDescriptores
        ? TipoInstrumento.rubrica
        : ((nombresNiveles?.length ?? 2) == 2
              ? TipoInstrumento.cotejo
              : TipoInstrumento.escala);
    avisos.add('No se indicó el TIPO; se tomó como ${tipo.nombre}.');
  }

  if (nombre.isEmpty) errores.add('Falta el NOMBRE (fila NOMBRE, columna B).');
  if (items.isEmpty) {
    errores.add(
      'No hay criterios ni ítems. Escríbelos debajo de la fila «CRITERIO» o «ÍTEM».',
    );
  }
  if (tipo == null) return Lectura(null, errores, avisos);

  final comps = <String>[];
  for (final parte in competenciasTxt.split(RegExp(r'[;\n]'))) {
    final q = normalizar(parte);
    if (q.isEmpty) continue;
    final c = competenciasCneb.where(
      (c) =>
          normalizar(c.nombre) == q ||
          normalizar(c.corto) == q ||
          normalizar(c.id) == q ||
          normalizar(c.nombre).startsWith(q),
    );
    if (c.isEmpty) {
      avisos.add('No se reconoce la competencia «${parte.trim()}»; se ignoró.');
    } else if (!comps.contains(c.first.id)) {
      comps.add(c.first.id);
    }
  }
  final niv = [
    for (final n in nivelesEducativos)
      if (normalizar(nivelTxt).contains(normalizar(n))) n,
  ];

  if (tipo == TipoInstrumento.prueba) {
    final its = <ItemInstrumento>[];
    for (final (fila, celdas) in items) {
      final pesoTxt = celda(celdas, 1);
      final peso = pesoTxt.isEmpty ? 1.0 : _numero(pesoTxt);
      if (peso == null || peso <= 0) {
        errores.add('Fila $fila: PUNTOS «$pesoTxt» debe ser un número mayor que 0.');
      }
      final tp = normalizar(celda(celdas, 2)).replaceAll(' ', '');
      final claveTxt = normalizar(celda(celdas, 3));
      var opciones = 0;
      if (tp.contains('DESARROLLO') || (tp.isEmpty && claveTxt.isEmpty)) {
        opciones = 0;
      } else if (tp.contains('V/F') || tp == 'VF' || tp.contains('VERDADERO') ||
          (tp.isEmpty && (claveTxt == 'V' || claveTxt == 'F'))) {
        opciones = 2;
      } else {
        final m = RegExp(r'^A[-–—AL]*([B-F])$').firstMatch(tp);
        final n = int.tryParse(tp);
        if (m != null) {
          opciones = m.group(1)!.codeUnitAt(0) - 64;
        } else if (n != null && n >= 2 && n <= 6) {
          opciones = n;
        } else if (tp.isEmpty) {
          opciones = 4;
        } else {
          errores.add(
            'Fila $fila: TIPO DE PREGUNTA «${celda(celdas, 2)}» no se reconoce. '
            'Usa A–D, A–E, V/F o Desarrollo.',
          );
        }
      }
      int? clave;
      if (opciones > 0) {
        final letras = opciones == 2
            ? const ['V', 'F']
            : [for (var k = 0; k < opciones; k++) String.fromCharCode(65 + k)];
        final k = letras.indexOf(claveTxt.isEmpty ? '' : claveTxt.substring(0, 1));
        if (k < 0) {
          errores.add(
            'Fila $fila: falta la CLAVE o no es válida (${letras.join(', ')}).',
          );
        } else {
          clave = k;
        }
      }
      its.add(
        ItemInstrumento(
          id: nuevoId(),
          texto: celda(celdas, 0),
          peso: peso ?? 1,
          opciones: opciones,
          clave: clave,
        ),
      );
    }
    final ins = Instrumento(
      id: nuevoId(),
      tipo: tipo,
      nombre: nombre,
      descripcion: descripcion,
      niveles: niv,
      area: area,
      competencias: comps,
      ponderada: true,
      items: its,
    );
    if (errores.isEmpty) errores.addAll(ins.validar());
    final total = ins.puntajeTotal;
    if (errores.isEmpty && (total - 20).abs() > .01) {
      avisos.add(
        'El examen suma ${total.toStringAsFixed(total == total.roundToDouble() ? 0 : 1)} '
        'puntos. Kipu lo convierte igual a la escala de la columna.',
      );
    }
    return Lectura(errores.isEmpty ? ins : null, errores, avisos);
  }

  // Niveles y puntos
  var niveles = nombresNiveles ?? const <String>[];
  if (niveles.isEmpty) {
    final defecto = switch (tipo) {
      TipoInstrumento.rubrica => plantillaNivelesRubrica,
      TipoInstrumento.cotejo => etiquetasCotejo.first.niveles,
      TipoInstrumento.escala ||
      TipoInstrumento.prueba => nivelesEscala.first.niveles,
    };
    niveles = [for (final n in defecto) n.nombre];
    avisos.add('No se encontró la fila NIVELES; se usaron: ${niveles.join(', ')}.');
  }
  if (niveles.any((n) => n.isEmpty)) {
    errores.add('Fila $filaNiveles: hay un nivel vacío entre los NIVELES.');
  }
  if (niveles.length < 2) errores.add('Hacen falta al menos 2 NIVELES.');
  if (tipo == TipoInstrumento.cotejo && niveles.length > 2) {
    avisos.add(
      'La lista de cotejo usa solo 2 etiquetas; se tomaron «${niveles[0]}» y «${niveles[1]}».',
    );
    niveles = niveles.sublist(0, 2);
  }
  final escala = <NivelInstrumento>[];
  for (var k = 0; k < niveles.length; k++) {
    final defecto = switch (tipo) {
      TipoInstrumento.rubrica => (k + 1).toDouble(),
      TipoInstrumento.cotejo => k == 0 ? 1.0 : 0.0,
      TipoInstrumento.escala ||
      TipoInstrumento.prueba => (niveles.length - 1 - k).toDouble(),
    };
    final txt = puntosTxt != null && k < puntosTxt.length ? puntosTxt[k] : '';
    final p = txt.isEmpty ? defecto : _numero(txt);
    if (p == null) {
      errores.add('PUNTOS del nivel «${niveles[k]}» no es un número: «$txt».');
    }
    escala.add(NivelInstrumento(niveles[k], p ?? defecto));
  }

  // Opciones
  final op = normalizar(opciones);
  final noObservado = op.contains('NO OBSERVADO');
  var ponderada = op.contains('PONDERADA');

  // Ítems
  final its = <ItemInstrumento>[];
  var conPeso = 0;
  for (final (fila, celdas) in items) {
    final texto = celda(celdas, 0);
    final pesoTxt = celda(celdas, 1);
    double peso = 1;
    if (pesoTxt.isNotEmpty) {
      final p = _numero(pesoTxt);
      if (p == null || p < 0) {
        errores.add('Fila $fila: el PESO «$pesoTxt» debe ser un número positivo.');
      } else {
        peso = p;
        conPeso++;
      }
    }
    final desc = tipo == TipoInstrumento.rubrica
        ? [for (var k = 0; k < escala.length; k++) celda(celdas, k + 2)]
        : const <String>[];
    if (tipo == TipoInstrumento.rubrica && desc.every((d) => d.isEmpty)) {
      avisos.add('Fila $fila: el criterio «$texto» no tiene descriptores.');
    }
    its.add(
      ItemInstrumento(id: nuevoId(), texto: texto, peso: peso, descriptores: desc),
    );
  }
  if (!ponderada && conPeso > 0 && its.map((i) => i.peso).toSet().length > 1) {
    ponderada = true;
    avisos.add('Se usarán los PESOS que escribiste (instrumento ponderado).');
  }
  if (tipo == TipoInstrumento.rubrica && ponderada) {
    final suma = its.fold<double>(0, (s, i) => s + i.peso);
    if ((suma - 100).abs() > 0.5) {
      avisos.add(
        'Los pesos suman ${suma.toStringAsFixed(0)} %, no 100 %. Kipu los usará en proporción.',
      );
    }
  }

  final ins = Instrumento(
    id: nuevoId(),
    tipo: tipo,
    competencias: comps,
    nombre: nombre,
    descripcion: descripcion,
    niveles: niv,
    area: area,
    escala: escala,
    items: its,
    noObservado: noObservado,
    ponderada: ponderada,
  );
  for (final e in ins.validar()) {
    if (!errores.contains(e)) errores.add(e);
  }
  return Lectura(errores.isEmpty ? ins : null, errores, avisos);
}
