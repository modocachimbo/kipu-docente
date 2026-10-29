import 'dart:convert';

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, OrderingTerm, Value;
import 'package:flutter/material.dart';

import '../widgets/selector_color.dart';
import 'academico.dart';
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

/// ¿El estudiante figura en ese periodo? Entra en `desde` y deja de estar
/// en `hasta` si se retiró.
bool estaEnPeriodo(Estudiante e, int periodo) =>
    e.desde <= periodo && (e.hasta == null || periodo < e.hasta!);

/// Clave para ordenar por apellidos sin que las tildes ni la Ñ los desordenen.
String claveOrden(Estudiante e) {
  const de = 'áéíóúüñ', a = 'aeiouun';
  var t = '${e.apellidos} ${e.nombres}'.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    t = t.replaceAll(de[i], i == 6 ? 'n~' : a[i]);
  }
  return t;
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

  /// Grupos de equipos del curso, del más antiguo al más nuevo. Cada tema o
  /// actividad puede tener sus propios equipos.
  Stream<List<GrupoEquipos>> verGruposEquipos(int cursoId) =>
      verAjuste('grupos_equipos_$cursoId').asyncMap((v) async {
        if (v != null && v.isNotEmpty) {
          return [
            for (final g in jsonDecode(v) as List)
              GrupoEquipos.deJson(g as Map<String, dynamic>),
          ];
        }
        // Antes había un solo juego de equipos por curso.
        final viejo = await leerAjuste('equipos_$cursoId');
        if (viejo == null || viejo.isEmpty) return <GrupoEquipos>[];
        final j = jsonDecode(viejo) as Map<String, dynamic>;
        return [
          GrupoEquipos(
            id: 1,
            nombre: 'Equipos 1',
            creado: claveFecha(DateTime.now()),
            equipos: {
              for (final e in j.entries) int.parse(e.key): e.value as int,
            },
          ),
        ];
      });

  Future<void> guardarGruposEquipos(int cursoId, List<GrupoEquipos> grupos) =>
      guardarAjuste(
        'grupos_equipos_$cursoId',
        jsonEncode([for (final g in grupos) g.aJson()]),
      );

  /// Último periodo abierto en el registro del curso (el 1.° la primera vez).
  Future<int> periodoRegistro(int cursoId) async =>
      int.tryParse(await leerAjuste('registro_periodo_$cursoId') ?? '') ?? 1;

  /// Todas las columnas de todos los cursos, para importarlas a otro registro.
  Future<List<RegistroColumna>> todasLasColumnas() => (select(
    registroColumnas,
  )..orderBy([(c) => OrderingTerm.asc(c.orden)])).get();

  /// Copia columnas (sin notas ni fecha) al final del registro indicado.
  Future<void> copiarColumnas(
    List<RegistroColumna> origen,
    int cursoId,
    int periodo,
  ) async {
    for (final c in origen) {
      await crearColumna(
        RegistroColumnasCompanion.insert(
          cursoId: cursoId,
          periodo: periodo,
          orden: 0,
          codigo: c.codigo,
          tema: Value(c.tema),
          tipo: Value(c.tipo),
          escala: Value(c.escala),
          enEquipo: Value(c.enEquipo),
        ),
      );
    }
  }

  Future<void> guardarPeriodoRegistro(int cursoId, int periodo) =>
      guardarAjuste('registro_periodo_$cursoId', '$periodo');

  /// Asistencia, notas y conducta de un estudiante en un periodo (o en todo el
  /// año si [periodo] es null). Se actualiza solo al anotar algo nuevo.
  Stream<ResumenFicha> verResumenFicha(
    Estudiante e, {
    int? periodo,
    String? desde,
    String? hasta,
  }) =>
      customSelect(
        'SELECT 1',
        readsFrom: {asistencias, registroNotas, registroColumnas, conductas},
      ).watch().asyncMap((_) async {
        bool enRango(String f) =>
            (desde == null || f.compareTo(desde) >= 0) &&
            (hasta == null || f.compareTo(hasta) <= 0);
        final asis = <String, int>{};
        for (final a in await (select(
          asistencias,
        )..where((a) => a.estudianteId.equals(e.id))).get()) {
          if (enRango(a.fecha)) asis[a.estado] = (asis[a.estado] ?? 0) + 1;
        }
        final cols = [
          for (final c
              in await (select(registroColumnas)..where(
                    (c) => c.cursoId.equals(e.cursoId) & c.tipo.equals('nota'),
                  ))
                  .get())
            if (periodo == null
                ? estaEnPeriodo(e, c.periodo)
                : c.periodo == periodo)
              c,
        ];
        final valores = {
          for (final n in await (select(
            registroNotas,
          )..where((n) => n.estudianteId.equals(e.id))).get())
            n.columnaId: n.valor,
        };
        final cond = [
          for (final c
              in await (select(conductas)
                    ..where((c) => c.estudianteId.equals(e.id))
                    ..orderBy([
                      (c) => OrderingTerm.desc(c.fecha),
                      (c) => OrderingTerm.desc(c.id),
                    ]))
                  .get())
            if (enRango(c.fecha)) c,
        ];
        return ResumenFicha(
          asistencia: asis,
          notas: [
            for (final c in cols)
              if (valores[c.id] != null) (c, valores[c.id]!),
          ],
          pendientes: cols.where((c) => valores[c.id] == null).length,
          conductas: cond,
        );
      });
}

class ResumenFicha {
  /// Cuántos días de cada estado: P, T, F, J.
  final Map<String, int> asistencia;
  final List<(RegistroColumna, String)> notas;
  final int pendientes;
  final List<Conducta> conductas;

  const ResumenFicha({
    required this.asistencia,
    required this.notas,
    required this.pendientes,
    required this.conductas,
  });
}

/// Equipos armados para un tema o actividad: {estudianteId: número de equipo}.
class GrupoEquipos {
  final int id;
  final String nombre;
  final String creado; // yyyy-MM-dd
  final Map<int, int> equipos;

  const GrupoEquipos({
    required this.id,
    required this.nombre,
    required this.creado,
    required this.equipos,
  });

  int get cantidad => equipos.values.fold(0, (a, b) => a > b ? a : b);

  /// Integrantes de cada equipo, en el orden de la lista.
  Map<int, List<int>> get integrantes {
    final r = <int, List<int>>{};
    for (final e in equipos.entries) {
      (r[e.value] ??= []).add(e.key);
    }
    return Map.fromEntries(
      r.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  GrupoEquipos copiar({String? nombre, Map<int, int>? equipos}) => GrupoEquipos(
    id: id,
    nombre: nombre ?? this.nombre,
    creado: creado,
    equipos: equipos ?? this.equipos,
  );

  Map<String, dynamic> aJson() => {
    'id': id,
    'nombre': nombre,
    'creado': creado,
    'equipos': {for (final e in equipos.entries) '${e.key}': e.value},
  };

  factory GrupoEquipos.deJson(Map<String, dynamic> j) => GrupoEquipos(
    id: j['id'] as int,
    nombre: j['nombre'] as String,
    creado: j['creado'] as String,
    equipos: {
      for (final e in (j['equipos'] as Map<String, dynamic>).entries)
        int.parse(e.key): e.value as int,
    },
  );
}

/// Los equipos que usa una columna: los suyos o, si no eligió, los más nuevos.
GrupoEquipos? grupoDe(List<GrupoEquipos> grupos, RegistroColumna c) {
  if (!c.enEquipo || grupos.isEmpty) return null;
  return grupos.where((g) => g.id == c.grupo).firstOrNull ?? grupos.last;
}
