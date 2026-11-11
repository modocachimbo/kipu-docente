import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'database.dart';

/// Cuenta del docente y su plan.
///
/// Por ahora todo se guarda en este dispositivo (en Ajustes). El inicio con
/// Google y Facebook y los cobros por Google Play se conectarán más adelante;
/// entonces estas mismas claves se llenarán desde el servidor.
const claveCuenta = 'cuenta';
const claveSesion = 'sesion';
const clavePlan = 'plan';

/// Versión de los Términos y la Política de privacidad que aceptó el docente.
const claveLegal = 'legal_aceptado';
const versionLegal = '2026-11-11';

/// Precios en soles.
const precioMensual = 15;
const precioAnual = 120;
const diasPrueba = 7;

class Cuenta {
  /// 'correo', 'google', 'facebook' o 'demo' (cuenta de prueba).
  final String proveedor;
  final String nombre;
  final String correo;
  final DateTime creada;
  final String? sal;
  final String? claveHash;

  const Cuenta({
    required this.proveedor,
    required this.nombre,
    required this.correo,
    required this.creada,
    this.sal,
    this.claveHash,
  });

  String get nombreProveedor => switch (proveedor) {
    'google' => 'Google',
    'facebook' => 'Facebook',
    'demo' => 'la cuenta de prueba',
    _ => 'tu correo',
  };

  Map<String, dynamic> aJson() => {
    'proveedor': proveedor,
    'nombre': nombre,
    'correo': correo,
    'creada': creada.toIso8601String(),
    if (sal != null) 'sal': sal,
    if (claveHash != null) 'clave': claveHash,
  };

  static Cuenta? deTexto(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return Cuenta(
        proveedor: m['proveedor'] as String? ?? 'correo',
        nombre: m['nombre'] as String? ?? '',
        correo: m['correo'] as String? ?? '',
        creada: DateTime.tryParse(m['creada'] as String? ?? '') ??
            DateTime.now(),
        sal: m['sal'] as String?,
        claveHash: m['clave'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class Plan {
  /// 'prueba', 'mensual' o 'anual'.
  final String tipo;
  final DateTime inicio;

  const Plan(this.tipo, this.inicio);

  bool get esPrueba => tipo == 'prueba';

  String get nombre => switch (tipo) {
    'anual' => 'Plan anual',
    'mensual' => 'Plan mensual',
    _ => 'Prueba gratis',
  };

  int get diasTotales => switch (tipo) {
    'anual' => 365,
    'mensual' => 30,
    _ => diasPrueba,
  };

  DateTime get fin => DateTime(
    inicio.year,
    inicio.month,
    inicio.day,
  ).add(Duration(days: diasTotales));

  int diasRestantes([DateTime? hoy]) {
    final h = hoy ?? DateTime.now();
    final d = fin.difference(DateTime(h.year, h.month, h.day)).inDays;
    return d.clamp(0, diasTotales);
  }

  bool vencido([DateTime? hoy]) => diasRestantes(hoy) == 0;

  String aTexto() =>
      jsonEncode({'tipo': tipo, 'inicio': inicio.toIso8601String()});

  static Plan? deTexto(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      final inicio = DateTime.tryParse(m['inicio'] as String? ?? '');
      if (inicio == null) return null;
      return Plan(m['tipo'] as String? ?? 'prueba', inicio);
    } catch (_) {
      return null;
    }
  }
}

String _hash(String sal, String clave) =>
    sha256.convert(utf8.encode('$sal:$clave')).toString();

String _nuevaSal() {
  final r = Random.secure();
  return base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
}

String normalizarCorreo(String c) => c.trim().toLowerCase();

bool correoValido(String c) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(c.trim());

extension CuentaDb on KipuDb {
  Stream<Cuenta?> verCuenta() => verAjuste(claveCuenta).map(Cuenta.deTexto);
  Future<Cuenta?> leerCuenta() async =>
      Cuenta.deTexto(await leerAjuste(claveCuenta));

  Stream<bool> verSesion() => verAjuste(claveSesion).map((v) => v == '1');

  Stream<Plan?> verPlan() => verAjuste(clavePlan).map(Plan.deTexto);

  Future<void> _abrirSesion() async {
    await guardarAjuste(claveSesion, '1');
    await guardarAjuste(claveLegal, versionLegal);
  }

  /// Crea la cuenta con correo en este dispositivo. Devuelve un mensaje de
  /// error o null si todo salió bien.
  Future<String?> crearCuentaCorreo({
    String nombre = '',
    required String correo,
    required String clave,
  }) async {
    final existente = await leerCuenta();
    final c = normalizarCorreo(correo);
    if (existente != null && existente.correo != c) {
      return 'En este equipo ya hay una cuenta con ${existente.correo}. '
          'Inicia sesión con ella.';
    }
    final sal = _nuevaSal();
    final cuenta = Cuenta(
      proveedor: 'correo',
      nombre: nombre.trim(),
      correo: c,
      creada: DateTime.now(),
      sal: sal,
      claveHash: _hash(sal, clave),
    );
    await guardarAjuste(claveCuenta, jsonEncode(cuenta.aJson()));
    await _abrirSesion();
    return null;
  }

  Future<String?> iniciarSesionCorreo(String correo, String clave) async {
    final cuenta = await leerCuenta();
    if (cuenta == null) {
      return 'No hay ninguna cuenta en este equipo. Crea tu cuenta primero.';
    }
    if (cuenta.correo != normalizarCorreo(correo) ||
        cuenta.sal == null ||
        cuenta.claveHash != _hash(cuenta.sal!, clave)) {
      return 'El correo o la contraseña no coinciden.';
    }
    await _abrirSesion();
    return null;
  }

  Future<void> cerrarSesion() =>
      (delete(ajustes)..where((a) => a.clave.equals(claveSesion))).go();

  Future<void> empezarPlan(String tipo) =>
      guardarAjuste(clavePlan, Plan(tipo, DateTime.now()).aTexto());

  /// Entra con una cuenta de prueba ya llena con datos de ejemplo, para
  /// revisar Kipu (y para los revisores de Google Play) sin registrarse.
  Future<void> entrarConCuentaDePrueba(
    Future<void> Function() cargarEjemplo,
  ) async {
    await cargarEjemplo();
    final cuenta = Cuenta(
      proveedor: 'demo',
      nombre: 'Javier Rojas',
      correo: 'prueba@kipu.app',
      creada: DateTime.now(),
    );
    await guardarAjuste(claveCuenta, jsonEncode(cuenta.aJson()));
    await guardarAjuste('genero', 'profesor');
    await guardarAjuste('lugar', 'Huacho, Perú');
    await guardarAjuste('nombre', 'Javier Rojas');
    await empezarPlan('prueba');
    await _abrirSesion();
  }

  /// Datos del perfil del docente. El personaje sale del sexo elegido.
  Future<void> guardarPerfil({
    required String nombre,
    required String genero,
    required String lugar,
    DateTime? cumple,
    String celular = '',
  }) async {
    await guardarAjuste('genero', genero);
    await guardarAjuste('lugar', lugar.trim());
    await guardarAjuste('celular', celular.trim());
    await guardarAjuste(
      'cumple',
      cumple == null ? '' : cumple.toIso8601String().substring(0, 10),
    );
    // El nombre va al final: al guardarlo se pasa del perfil al Dashboard.
    await guardarAjuste('nombre', nombre.trim());
  }

  /// Borra la cuenta y todos los datos de este dispositivo.
  Future<void> borrarCuenta() => transaction(() async {
    await borrarTodo();
    await delete(ajustes).go();
  });
}
