import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'paises.dart';

/// Desde qué nota (en escala de 0 a 20) se usa un color.
class TramoColor {
  final double desde;
  final int color;
  const TramoColor(this.desde, this.color);
}

/// Colores de las notas numéricas del registro. Los rangos están en 0–20;
/// en otras escalas (0–10, 0–100…) se usan en proporción.
class ColoresNotas {
  final bool activo;
  final List<TramoColor> tramos;
  const ColoresNotas({this.activo = true, this.tramos = tramosPorDefecto});

  static const rojo = 0xFFC2334A;
  static const naranja = 0xFFE07B1F;
  static const celeste = 0xFF1A9BD7;
  static const azul = 0xFF2F4FD6;

  /// 0–10 rojo · 11–13 naranja · 14–17 celeste · 18–20 azul.
  static const tramosPorDefecto = [
    TramoColor(0, rojo),
    TramoColor(11, naranja),
    TramoColor(14, celeste),
    TramoColor(18, azul),
  ];

  /// Colores para elegir en el editor.
  static const paleta = [
    rojo,
    naranja,
    0xFFC99A06, // ámbar
    0xFF16A37F, // verde
    celeste,
    azul,
    0xFF7B4FD6, // morado
    0xFF1F1B2E, // negro
  ];

  String aTexto() => jsonEncode({
    'activo': activo,
    'tramos': [
      for (final t in tramos) [t.desde, t.color],
    ],
  });

  static ColoresNotas deTexto(String? s) {
    if (s == null || s.isEmpty) return const ColoresNotas();
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      final l = [
        for (final x in (m['tramos'] as List? ?? const []))
          TramoColor(
            ((x as List)[0] as num).toDouble(),
            (x[1] as num).toInt(),
          ),
      ]..sort((a, b) => a.desde.compareTo(b.desde));
      return ColoresNotas(
        activo: m['activo'] != false,
        tramos: l.isEmpty ? tramosPorDefecto : l,
      );
    } catch (_) {
      return const ColoresNotas();
    }
  }

  /// Índice del tramo que le toca a la nota [n] de la escala [e], o null.
  int? tramoDe(double n, Escala? e) {
    if (!activo || tramos.isEmpty) return null;
    final min = e?.minimo ?? 0, max = e?.maximo ?? 20;
    if (max <= min) return null;
    final v = (n - min) / (max - min) * 20;
    var r = 0;
    for (var i = 0; i < tramos.length; i++) {
      // Margen pequeño para que 11 de 0–20 no caiga en el tramo anterior.
      if (v + 1e-9 >= tramos[i].desde) r = i;
    }
    return r;
  }

  /// Color de la nota, o null si no se colorea.
  int? colorDe(double n, Escala? e) {
    final i = tramoDe(n, e);
    return i == null ? null : tramos[i].color;
  }
}

/// Lo que eligió el profesor; se carga al abrir la app.
final coloresNotas = ValueNotifier<ColoresNotas>(const ColoresNotas());

const claveColoresNotas = 'colores_notas';
