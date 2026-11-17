import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'respaldo.dart';

/// ID de cliente OAuth «Aplicación web» de Google Cloud (no es secreto).
/// Mientras esté vacío, Google Drive aparece como «disponible pronto».
const driveClientIdWeb = '';

/// Se pone en true cuando en Google Cloud ya existe el cliente Android
/// (paquete pe.kipu.kipu + huella SHA-1 de la llave del APK).
const driveAndroidListo = false;

/// Permisos mínimos: solo los archivos que crea Kipu (no ve el resto del
/// Drive) y el correo para mostrar qué cuenta está conectada. Ambos son «no
/// sensibles» para Google, así que no piden verificación especial.
const _permisos = [
  'https://www.googleapis.com/auth/drive.file',
  'email',
];

const nombreCarpetaDrive = 'Kipu Docente - copias';

/// Una copia guardada en Drive.
class ArchivoDrive {
  final String id;
  final String nombre;
  final int tamano;
  final DateTime fecha;
  final String dispositivo;
  final int estudiantes;
  final bool anonima;
  const ArchivoDrive({
    required this.id,
    required this.nombre,
    required this.tamano,
    required this.fecha,
    required this.dispositivo,
    required this.estudiantes,
    required this.anonima,
  });
}

/// Hace falta que el docente toque «Conectar» otra vez (el permiso venció o
/// lo quitó desde su cuenta de Google).
class DriveSinPermiso implements Exception {
  const DriveSinPermiso();
  @override
  String toString() => 'Vuelve a conectar Google Drive.';
}

class DriveError implements Exception {
  final String mensaje;
  const DriveError(this.mensaje);
  @override
  String toString() => mensaje;
}

class DriveKipu {
  DriveKipu._();
  static final instancia = DriveKipu._();

  bool get disponible => kIsWeb
      ? driveClientIdWeb.isNotEmpty
      : defaultTargetPlatform == TargetPlatform.android && driveAndroidListo;

  Future<void>? _inicio;
  String? _token;
  DateTime? _vence;
  String? _carpeta;

  Future<void> _iniciar() => _inicio ??= GoogleSignIn.instance.initialize(
    clientId: kIsWeb ? driveClientIdWeb : null,
  );

  /// Pide permiso (abre la ventana de Google). Debe llamarse desde un toque.
  /// Devuelve el correo de la cuenta conectada.
  Future<String> conectar() async {
    await _iniciar();
    final a = await GoogleSignIn.instance.authorizationClient.authorizeScopes(
      _permisos,
    );
    _guardarToken(a.accessToken);
    return await _correo() ?? 'Cuenta de Google';
  }

  void _guardarToken(String t) {
    _token = t;
    // En la web el permiso dura una hora; se renueva un poco antes.
    _vence = DateTime.now().add(const Duration(minutes: 50));
  }

  /// Token sin mostrar nada; null si hace falta tocar «Conectar».
  Future<String?> _tokenSilencioso() async {
    if (_token != null && _vence != null && DateTime.now().isBefore(_vence!)) {
      return _token;
    }
    try {
      await _iniciar();
      final a = await GoogleSignIn.instance.authorizationClient
          .authorizationForScopes(_permisos);
      if (a == null) return null;
      _guardarToken(a.accessToken);
      return _token;
    } catch (_) {
      return null;
    }
  }

  /// ¿Se puede usar Drive ahora mismo sin pedir nada al docente?
  Future<bool> listoSinPreguntar() async =>
      disponible && await _tokenSilencioso() != null;

  Future<void> desconectar() async {
    final t = _token;
    _token = null;
    _vence = null;
    _carpeta = null;
    try {
      await _iniciar();
      if (t != null) {
        await GoogleSignIn.instance.authorizationClient.clearAuthorizationToken(
          accessToken: t,
        );
      }
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }

  Future<http.Response> _pedir(
    Future<http.Response> Function(Map<String, String> cabeceras) hacer,
  ) async {
    var t = await _tokenSilencioso();
    if (t == null) throw const DriveSinPermiso();
    var r = await hacer({'Authorization': 'Bearer $t'});
    if (r.statusCode == 401) {
      // El permiso venció: se intenta una vez más sin preguntar.
      try {
        await GoogleSignIn.instance.authorizationClient.clearAuthorizationToken(
          accessToken: t,
        );
      } catch (_) {}
      _token = null;
      t = await _tokenSilencioso();
      if (t == null) throw const DriveSinPermiso();
      r = await hacer({'Authorization': 'Bearer $t'});
      if (r.statusCode == 401) throw const DriveSinPermiso();
    }
    if (r.statusCode == 403 && r.body.contains('storageQuotaExceeded')) {
      throw const DriveError('Tu Google Drive está lleno.');
    }
    if (r.statusCode >= 400) {
      throw DriveError('Google Drive respondió ${r.statusCode}.');
    }
    return r;
  }

  Future<String?> _correo() async {
    try {
      final r = await _pedir(
        (h) => http.get(
          Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
          headers: h,
        ),
      );
      return (jsonDecode(r.body) as Map<String, dynamic>)['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Carpeta visible «Kipu Docente - copias» en el Drive del docente.
  Future<String> _idCarpeta() async {
    if (_carpeta != null) return _carpeta!;
    final q =
        "name = '$nombreCarpetaDrive' and "
        "mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final r = await _pedir(
      (h) => http.get(
        Uri.https('www.googleapis.com', '/drive/v3/files', {
          'q': q,
          'fields': 'files(id)',
          'spaces': 'drive',
        }),
        headers: h,
      ),
    );
    final l = (jsonDecode(r.body) as Map<String, dynamic>)['files'] as List;
    if (l.isNotEmpty) return _carpeta = (l.first as Map)['id'] as String;
    final c = await _pedir(
      (h) => http.post(
        Uri.parse('https://www.googleapis.com/drive/v3/files?fields=id'),
        headers: {...h, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nombreCarpetaDrive,
          'mimeType': 'application/vnd.google-apps.folder',
          'description': 'Copias de seguridad de Kipu Docente. No las borres.',
        }),
      ),
    );
    return _carpeta = (jsonDecode(c.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> subir(Copia c) async {
    final carpeta = await _idCarpeta();
    const borde = 'kipu-copia-limite';
    final meta = jsonEncode({
      'name': c.nombreArchivo,
      'parents': [carpeta],
      'mimeType': 'application/octet-stream',
      'appProperties': {
        'kipu': '1',
        'fecha': c.info.fecha.toIso8601String(),
        'dispositivo': c.info.dispositivo,
        'esquema': '${c.info.esquema}',
        'estudiantes': '${c.info.estudiantes}',
        'anonima': c.info.anonima ? '1' : '0',
      },
    });
    final cuerpo = BytesBuilder()
      ..add(utf8.encode(
        '--$borde\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n'
        '$meta\r\n--$borde\r\nContent-Type: application/octet-stream\r\n\r\n',
      ))
      ..add(c.bytes)
      ..add(utf8.encode('\r\n--$borde--\r\n'));
    await _pedir(
      (h) => http.post(
        Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id',
        ),
        headers: {...h, 'Content-Type': 'multipart/related; boundary=$borde'},
        body: cuerpo.toBytes(),
      ),
    );
  }

  Future<List<ArchivoDrive>> listar() async {
    final carpeta = await _idCarpeta();
    final r = await _pedir(
      (h) => http.get(
        Uri.https('www.googleapis.com', '/drive/v3/files', {
          'q': "'$carpeta' in parents and trashed = false",
          'fields': 'files(id,name,size,createdTime,appProperties)',
          'orderBy': 'createdTime desc',
          'pageSize': '200',
        }),
        headers: h,
      ),
    );
    final l = (jsonDecode(r.body) as Map<String, dynamic>)['files'] as List;
    return [
      for (final f in l.cast<Map<String, dynamic>>())
        () {
          final p = (f['appProperties'] as Map?)?.cast<String, dynamic>() ?? {};
          return ArchivoDrive(
            id: f['id'] as String,
            nombre: f['name'] as String? ?? '',
            tamano: int.tryParse('${f['size'] ?? 0}') ?? 0,
            fecha:
                DateTime.tryParse(p['fecha'] as String? ?? '') ??
                DateTime.tryParse(f['createdTime'] as String? ?? '')?.toLocal() ??
                DateTime(2000),
            dispositivo: p['dispositivo'] as String? ?? '',
            estudiantes: int.tryParse('${p['estudiantes'] ?? ''}') ?? 0,
            anonima: p['anonima'] == '1',
          );
        }(),
    ];
  }

  Future<Uint8List> descargar(String id) async {
    final r = await _pedir(
      (h) => http.get(
        Uri.parse('https://www.googleapis.com/drive/v3/files/$id?alt=media'),
        headers: h,
      ),
    );
    return r.bodyBytes;
  }

  Future<void> borrar(String id) async {
    await _pedir(
      (h) => http.delete(
        Uri.parse('https://www.googleapis.com/drive/v3/files/$id'),
        headers: h,
      ),
    );
  }
}

final drive = DriveKipu.instancia;
