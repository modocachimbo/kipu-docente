import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import 'database.dart';

/// Copias de seguridad de Kipu.
///
/// Una copia es un archivo .kipu: JSON comprimido con gzip que trae todas las
/// tablas. Se lee por nombre de columna, así una copia vieja se puede
/// restaurar en una versión nueva de Kipu (las columnas nuevas quedan con su
/// valor por defecto).
const formatoCopia = 'kipu-copia';
const extensionCopia = 'kipu';

/// Ajustes que son de este equipo y no viajan en la copia (ni se pisan al
/// restaurar): la sesión, la cuenta, el plan y el estado de las copias.
bool ajusteLocal(String clave) =>
    clave == 'sesion' ||
    clave == 'cuenta' ||
    clave == 'plan' ||
    clave.startsWith('respaldo_');

/// Datos de una copia, sin abrirla entera.
class InfoCopia {
  final DateTime fecha;
  final int esquema;
  final String dispositivo;
  final int estudiantes;
  final int cursos;
  final bool anonima;
  const InfoCopia({
    required this.fecha,
    required this.esquema,
    required this.dispositivo,
    required this.estudiantes,
    required this.cursos,
    this.anonima = false,
  });
}

/// Una copia lista para guardar o subir.
class Copia {
  final Uint8List bytes;
  final InfoCopia info;

  /// Huella de los datos (sin la fecha): si no cambió, no hace falta otra copia.
  final String huella;
  const Copia(this.bytes, this.info, this.huella);

  String get nombreArchivo {
    final f = info.fecha;
    String d(int n) => n.toString().padLeft(2, '0');
    return 'Kipu ${f.year}-${d(f.month)}-${d(f.day)} ${d(f.hour)}.${d(f.minute)}'
        '${info.anonima ? ' (soporte)' : ''}.$extensionCopia';
  }
}

class CopiaInvalida implements Exception {
  final String mensaje;
  const CopiaInvalida(this.mensaje);
  @override
  String toString() => mensaje;
}

Object? _aJson(Object? v) => v is Uint8List ? {r'$b': base64Encode(v)} : v;

Object? _deJson(Object? v) =>
    v is Map && v[r'$b'] is String ? base64Decode(v[r'$b'] as String) : v;

/// Cambia nombres y datos personales por otros inventados (copia de soporte).
void _anonimizar(Map<String, List<Map<String, Object?>>> tablas) {
  var n = 0;
  for (final e in tablas['estudiantes'] ?? const <Map<String, Object?>>[]) {
    n++;
    e['nombres'] = 'Estudiante';
    e['apellidos'] = 'Número $n';
    for (final k in const [
      'dni',
      'apoderado',
      'telefono',
      'apoderado2',
      'telefono2',
      'nacimiento',
      'observaciones',
      'codigo',
      'clave',
      'foto',
    ]) {
      if (e.containsKey(k)) e[k] = null;
    }
  }
  for (final a in tablas['anecdotas'] ?? const <Map<String, Object?>>[]) {
    a['texto'] = '(texto oculto)';
    a['foto'] = null;
    a['apoderado'] = null;
    a['acuerdos'] = null;
  }
  for (final a in tablas['ajustes'] ?? const <Map<String, Object?>>[]) {
    final k = a['clave'];
    if (k is String &&
        (k == 'nombre' || k == 'apellidos' || k == 'celular' || k == 'foto' ||
            k == 'cumple' || k.startsWith('perfil'))) {
      a['valor'] = '';
    }
  }
}

extension RespaldoDb on KipuDb {
  /// Arma la copia con todas las tablas.
  Future<Copia> crearCopia({
    required String dispositivo,
    bool anonima = false,
  }) async {
    final tablas = <String, List<Map<String, Object?>>>{};
    for (final t in allTables) {
      final filas = await customSelect(
        'SELECT * FROM "${t.actualTableName}"',
      ).get();
      tablas[t.actualTableName] = [
        for (final f in filas)
          if (t.actualTableName != 'ajustes' ||
              !ajusteLocal(f.data['clave'] as String? ?? ''))
            {...f.data},
      ];
    }
    if (anonima) _anonimizar(tablas);
    final datos = {
      for (final e in tablas.entries)
        e.key: [
          for (final f in e.value)
            {for (final c in f.entries) c.key: _aJson(c.value)},
        ],
    };
    final textoDatos = jsonEncode(datos);
    final info = InfoCopia(
      fecha: DateTime.now(),
      esquema: schemaVersion,
      dispositivo: dispositivo,
      estudiantes: tablas['estudiantes']?.length ?? 0,
      cursos: tablas['cursos']?.length ?? 0,
      anonima: anonima,
    );
    final todo = utf8.encode(
      jsonEncode({
        'formato': formatoCopia,
        'esquema': info.esquema,
        'fecha': info.fecha.toIso8601String(),
        'dispositivo': info.dispositivo,
        'estudiantes': info.estudiantes,
        'cursos': info.cursos,
        'anonima': anonima,
        'tablas': jsonDecode(textoDatos),
      }),
    );
    final gz = GZipEncoder().encode(todo)!;
    return Copia(
      Uint8List.fromList(gz),
      info,
      sha256.convert(utf8.encode(textoDatos)).toString(),
    );
  }

  /// Lee la cabecera de una copia (para mostrarla antes de restaurar).
  InfoCopia leerInfo(Uint8List bytes) => _abrir(bytes).$1;

  (InfoCopia, Map<String, dynamic>) _abrir(Uint8List bytes) {
    Map<String, dynamic> m;
    try {
      final crudo = bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b
          ? GZipDecoder().decodeBytes(bytes)
          : bytes;
      m = jsonDecode(utf8.decode(crudo)) as Map<String, dynamic>;
    } catch (_) {
      throw const CopiaInvalida('El archivo no es una copia de Kipu o está dañado.');
    }
    if (m['formato'] != formatoCopia || m['tablas'] is! Map) {
      throw const CopiaInvalida('El archivo no es una copia de Kipu.');
    }
    final info = InfoCopia(
      fecha: DateTime.tryParse(m['fecha'] as String? ?? '') ?? DateTime(2000),
      esquema: (m['esquema'] as num?)?.toInt() ?? 0,
      dispositivo: m['dispositivo'] as String? ?? '',
      estudiantes: (m['estudiantes'] as num?)?.toInt() ?? 0,
      cursos: (m['cursos'] as num?)?.toInt() ?? 0,
      anonima: m['anonima'] == true,
    );
    return (info, m['tablas'] as Map<String, dynamic>);
  }

  /// Reemplaza todos los datos por los de la copia. Lo de este equipo
  /// (sesión, cuenta, plan, estado de copias) se conserva.
  Future<InfoCopia> restaurarCopia(Uint8List bytes) async {
    final (info, tablas) = _abrir(bytes);
    if (info.esquema > schemaVersion) {
      throw const CopiaInvalida(
        'La copia es de una versión más nueva de Kipu. Actualiza la app y '
        'vuelve a intentarlo.',
      );
    }
    final locales = await (select(ajustes)).get();
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        for (final t in allTables) {
          final nombre = t.actualTableName;
          await customStatement('DELETE FROM "$nombre"');
          final columnas = {for (final c in t.$columns) c.name};
          for (final fila in (tablas[nombre] as List? ?? const [])) {
            final f = (fila as Map).cast<String, Object?>();
            if (nombre == 'ajustes' && ajusteLocal(f['clave'] as String? ?? '')) {
              continue;
            }
            final cols = [
              for (final k in f.keys)
                if (columnas.contains(k)) k,
            ];
            if (cols.isEmpty) continue;
            await customStatement(
              'INSERT OR REPLACE INTO "$nombre" (${cols.map((c) => '"$c"').join(', ')}) '
              'VALUES (${List.filled(cols.length, '?').join(', ')})',
              [for (final c in cols) _deJson(f[c])],
            );
          }
        }
        // Lo propio de este equipo vuelve a su lugar.
        for (final a in locales) {
          if (ajusteLocal(a.clave)) {
            await into(ajustes).insertOnConflictUpdate(a);
          }
        }
      });
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
    notifyUpdates({for (final t in allTables) TableUpdate.onTable(t)});
    return info;
  }
}
