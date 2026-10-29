import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/selector_color.dart';
import 'database.dart';
import 'paises.dart';

/// Colores del registro de un curso. Salen del color del colegio; el docente
/// puede cambiarlos solo para ese curso (se guardan en `registro_colores_<id>`).
class ColoresRegistro {
  final Color base;
  final Color cabecera;
  final Color nombres;
  final Color calculadas;
  final Color fijada;
  final bool propios;

  const ColoresRegistro({
    required this.base,
    required this.cabecera,
    required this.nombres,
    required this.calculadas,
    required this.fijada,
    this.propios = false,
  });

  factory ColoresRegistro.delColegio(Color base) {
    // Los colores pastel se oscurecen para que el texto y las calculadas se lean.
    final fuerte = esClaro(base) ? Color.lerp(base, Colors.black, .35)! : base;
    return ColoresRegistro(
      base: fuerte,
      cabecera: Color.lerp(fuerte, Colors.white, .88)!,
      nombres: Color.lerp(fuerte, Colors.white, .94)!,
      calculadas: fuerte,
      fijada: Color.lerp(fuerte, Colors.black, .38)!,
    );
  }

  /// Tono para textos sobre la cabecera (códigos de columna).
  Color get tintaCabecera => Color.lerp(calculadas, Colors.black, .2)!;

  /// Fondo suave de las celdas de una columna calculada.
  Color get celdaCalculada => Color.lerp(calculadas, Colors.white, .9)!;

  ColoresRegistro con(Map<String, dynamic> j) => ColoresRegistro(
    base: base,
    cabecera: _c(j['cabecera']) ?? cabecera,
    nombres: _c(j['nombres']) ?? nombres,
    calculadas: _c(j['calculadas']) ?? calculadas,
    fijada: _c(j['fijada']) ?? fijada,
    propios: true,
  );

  static Color? _c(Object? v) => v is int ? Color(v) : null;

  Map<String, int> aJson() => {
    'cabecera': cabecera.toARGB32(),
    'nombres': nombres.toARGB32(),
    'calculadas': calculadas.toARGB32(),
    'fijada': fijada.toARGB32(),
  };
}

/// "QUISPE MAMANI" → "Quispe Mamani".
String tituloNombre(String s) => s
    .toLowerCase()
    .split(' ')
    .where((p) => p.isNotEmpty)
    .map(
      (p) => _particulas.contains(p) ? p : p[0].toUpperCase() + p.substring(1),
    )
    .join(' ');

const _particulas = {'de', 'del', 'la', 'las', 'los', 'y'};

/// "DE LA CRUZ MAMANI" → "de la Cruz M."; "CASTILLO DE LA CRUZ" → "Castillo C.".
/// El primer apellido completo (con sus partículas) y la inicial del segundo.
String apellidoCorto(String apellidos) {
  final p = tituloNombre(apellidos).split(' ');
  var i = 0;
  while (i < p.length - 1 && _particulas.contains(p[i].toLowerCase())) {
    i++;
  }
  final primero = p.sublist(0, i + 1).join(' ');
  final resto = p.sublist(i + 1).where((x) => !_particulas.contains(x));
  return resto.isEmpty ? primero : '$primero ${resto.first[0]}.';
}

/// Iniciales del primer apellido y el primer nombre.
String iniciales(Estudiante e) {
  String primera(String s) {
    final p = s.trim().split(' ').where((x) => x.isNotEmpty);
    return p.isEmpty ? '' : p.first[0].toUpperCase();
  }

  return '${primera(e.apellidos)}${primera(e.nombres)}';
}

/// Texto corto de una escala para la cabecera: "0–20", "AD/A/B/C", "Logrado".
String escalaCorta(Escala? e) {
  if (e == null) return '';
  if (e.numerica) {
    String n(double? v) => v == null ? '' : v.toStringAsFixed(0);
    return '${n(e.minimo)}–${n(e.maximo)}';
  }
  final codigos = e.valores.map((v) => v.codigo).join('/');
  return codigos.length <= 10 ? codigos : e.valores.first.codigo;
}

/// Escala "Logrado / No logrado" (dos valores con texto largo).
bool esSiNo(Escala e) => !e.numerica && e.valores.length == 2;

extension RegistroDb on KipuDb {
  Stream<Map<String, dynamic>?> verColoresRegistro(int cursoId) =>
      verAjuste('registro_colores_$cursoId').map(
        (v) => v == null || v.isEmpty
            ? null
            : jsonDecode(v) as Map<String, dynamic>,
      );

  Future<void> guardarColoresRegistro(int cursoId, ColoresRegistro? c) =>
      guardarAjuste(
        'registro_colores_$cursoId',
        c == null ? '' : jsonEncode(c.aJson()),
      );

  /// Equipos del curso: {estudianteId: número de equipo}.
  Stream<Map<int, int>> verEquipos(int cursoId) =>
      verAjuste('equipos_$cursoId').map((v) {
        if (v == null || v.isEmpty) return <int, int>{};
        final j = jsonDecode(v) as Map<String, dynamic>;
        return {for (final e in j.entries) int.parse(e.key): e.value as int};
      });

  Future<void> guardarEquipos(int cursoId, Map<int, int> equipos) =>
      guardarAjuste(
        'equipos_$cursoId',
        jsonEncode({for (final e in equipos.entries) '${e.key}': e.value}),
      );

  /// Último periodo abierto en el registro del curso (el 1.° la primera vez).
  Future<int> periodoRegistro(int cursoId) async =>
      int.tryParse(await leerAjuste('registro_periodo_$cursoId') ?? '') ?? 1;

  Future<void> guardarPeriodoRegistro(int cursoId, int periodo) =>
      guardarAjuste('registro_periodo_$cursoId', '$periodo');
}
