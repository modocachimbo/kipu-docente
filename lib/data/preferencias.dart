import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'database.dart';

/// Ajustes de Configuración › General › Más ajustes.
const claveLetra = 'tamano_letra';
const clavePin = 'pin';

/// Tamaños de letra que se ofrecen: (nombre, escala).
const tamanosLetra = [
  ('Pequeña', .9),
  ('Normal', 1.0),
  ('Grande', 1.15),
  ('Muy grande', 1.3),
];

/// Escala de la letra de toda la app (1 = normal).
final escalaLetra = ValueNotifier<double>(1.0);

/// Hay PIN y la app está bloqueada hasta escribirlo.
final appBloqueada = ValueNotifier<bool>(false);

double escalaDeTexto(String? v) {
  final n = double.tryParse(v ?? '');
  return n == null ? 1.0 : n.clamp(.8, 1.5).toDouble();
}

String _hashPin(String sal, String pin) =>
    sha256.convert(utf8.encode('pin:$sal:$pin')).toString();

extension PreferenciasDb on KipuDb {
  Future<void> guardarEscalaLetra(double e) async {
    escalaLetra.value = e;
    await guardarAjuste(claveLetra, '$e');
  }

  Stream<bool> verHayPin() => verAjuste(clavePin).map((v) => v != null);

  Future<bool> hayPin() async => await leerAjuste(clavePin) != null;

  /// Guarda el PIN (4 dígitos) con sal; no se guarda el número.
  Future<void> guardarPin(String pin) {
    final r = Random.secure();
    final sal = base64Url.encode(List.generate(12, (_) => r.nextInt(256)));
    return guardarAjuste(
      clavePin,
      jsonEncode({'sal': sal, 'hash': _hashPin(sal, pin)}),
    );
  }

  Future<bool> pinCorrecto(String pin) async {
    final v = await leerAjuste(clavePin);
    if (v == null) return true;
    try {
      final m = jsonDecode(v) as Map<String, dynamic>;
      return m['hash'] == _hashPin(m['sal'] as String, pin);
    } catch (_) {
      return true; // un PIN dañado no debe dejar la app cerrada
    }
  }

  Future<void> quitarPin() async {
    await (delete(ajustes)..where((a) => a.clave.equals(clavePin))).go();
    appBloqueada.value = false;
  }
}
