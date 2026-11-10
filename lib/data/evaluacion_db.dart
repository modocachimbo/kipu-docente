import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'instrumentos.dart';
import 'instrumentos_ejemplos.dart';
import 'paises.dart';

const gestionPublica = 'publica';
const gestionPrivada = 'privada';

/// Guardado de instrumentos en la tabla Ajustes (sin cambiar el esquema).
extension EvaluacionDb on KipuDb {
  static const _clave = 'instrumentos';
  static const _prefijoCol = 'instrumento_col_';
  static const _prefijoMarcas = 'instrumento_marcas_';

  /// La primera vez deja algunos ejemplos en la biblioteca para no empezar
  /// vacía. Si el docente borra todo, no se vuelven a poner.
  Future<void> prepararBiblioteca() async {
    if (await leerAjuste(_clave) != null) return;
    final iniciales = [
      for (final id in ejemplosIniciales)
        for (final e in ejemplosInstrumentos)
          if (e.id == id) duplicar(e, ejemplo: true),
    ];
    await guardarAjuste(_clave, Instrumento.listaAJson(iniciales));
  }

  Stream<List<Instrumento>> verBiblioteca() =>
      verAjuste(_clave).map(Instrumento.listaDeJson);

  Future<List<Instrumento>> leerBiblioteca() async =>
      Instrumento.listaDeJson(await leerAjuste(_clave));

  /// Agrega o reemplaza (por id). Los nuevos van primero.
  Future<void> guardarInstrumento(Instrumento ins) async {
    final l = await leerBiblioteca();
    final i = l.indexWhere((x) => x.id == ins.id);
    if (i >= 0) {
      l[i] = ins;
    } else {
      l.insert(0, ins);
    }
    await guardarAjuste(_clave, Instrumento.listaAJson(l));
  }

  Future<void> borrarInstrumento(String id) async {
    final l = await leerBiblioteca()..removeWhere((x) => x.id == id);
    await guardarAjuste(_clave, Instrumento.listaAJson(l));
  }

  /// Vuelve a poner un instrumento borrado en su lugar (para «Deshacer»).
  Future<void> restaurarInstrumento(Instrumento ins, int posicion) async {
    final l = await leerBiblioteca();
    if (l.any((x) => x.id == ins.id)) return;
    l.insert(posicion.clamp(0, l.length), ins);
    await guardarAjuste(_clave, Instrumento.listaAJson(l));
  }

  Future<void> borrarAjuste(String clave) =>
      (delete(ajustes)..where((a) => a.clave.equals(clave))).go();

  // Columnas del registro

  /// Instrumento de cada columna que tiene uno: {columnaId: copia}.
  Stream<Map<int, Instrumento>> verInstrumentosDeColumnas() =>
      (select(ajustes)..where((a) => a.clave.like('$_prefijoCol%')))
          .watch()
          .map((filas) {
            final r = <int, Instrumento>{};
            for (final f in filas) {
              final id = int.tryParse(f.clave.substring(_prefijoCol.length));
              if (id == null || f.valor.isEmpty) continue;
              try {
                r[id] = Instrumento.deJson(
                  jsonDecode(f.valor) as Map<String, dynamic>,
                );
              } catch (_) {}
            }
            return r;
          });

  Future<Instrumento?> instrumentoDeColumna(int columnaId) async {
    final v = await leerAjuste('$_prefijoCol$columnaId');
    if (v == null || v.isEmpty) return null;
    try {
      return Instrumento.deJson(jsonDecode(v) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Guarda una copia del instrumento en la columna. Si cambia por otro
  /// instrumento distinto, las marcas anteriores ya no sirven y se borran
  /// (las notas puestas se quedan hasta que se vuelva a evaluar).
  Future<void> vincularInstrumento(int columnaId, Instrumento? ins) async {
    final antes = await instrumentoDeColumna(columnaId);
    if (ins == null) {
      await borrarAjuste('$_prefijoCol$columnaId');
      await borrarAjuste('$_prefijoMarcas$columnaId');
      return;
    }
    if (antes != null && antes.id != ins.id) {
      await borrarAjuste('$_prefijoMarcas$columnaId');
    }
    await guardarAjuste('$_prefijoCol$columnaId', jsonEncode(ins.aJson()));
  }

  Stream<Map<int, Marcas>> verMarcas(int columnaId) =>
      verAjuste('$_prefijoMarcas$columnaId').map(Marcas.mapaDeJson);

  Future<Map<int, Marcas>> leerMarcas(int columnaId) async =>
      Marcas.mapaDeJson(await leerAjuste('$_prefijoMarcas$columnaId'));

  /// Guarda las marcas de varios estudiantes a la vez (un equipo).
  Future<void> guardarMarcas(
    int columnaId,
    Iterable<int> estudiantes,
    Marcas? m,
  ) async {
    final todas = await leerMarcas(columnaId);
    for (final e in estudiantes) {
      if (m == null || m.vacia) {
        todas.remove(e);
      } else {
        todas[e] = m;
      }
    }
    await guardarAjuste('$_prefijoMarcas$columnaId', Marcas.mapaAJson(todas));
  }

  // Gestión del colegio

  Stream<String> verGestion(int colegioId) => verAjuste(
    'gestion_colegio_$colegioId',
  ).map((v) => v == gestionPrivada ? gestionPrivada : gestionPublica);

  Future<String> leerGestion(int colegioId) async =>
      await leerAjuste('gestion_colegio_$colegioId') == gestionPrivada
      ? gestionPrivada
      : gestionPublica;

  Future<void> guardarGestion(int colegioId, String gestion) =>
      guardarAjuste('gestion_colegio_$colegioId', gestion);

  /// Gestión de todos los colegios: {colegioId: 'publica' | 'privada'}.
  Stream<Map<int, String>> verGestiones() =>
      (select(ajustes)..where((a) => a.clave.like('gestion_colegio_%')))
          .watch()
          .map(
            (filas) => {
              for (final f in filas)
                if (int.tryParse(f.clave.substring('gestion_colegio_'.length))
                    case final id?)
                  id: f.valor,
            },
          );

  // Conversión a la escala

  Stream<List<double>> verTramos(Escala e) => verAjuste(
    'tramos_${e.id}',
  ).map((v) => _tramos(v, e));

  Future<List<double>> leerTramos(Escala e) async =>
      _tramos(await leerAjuste('tramos_${e.id}'), e);

  Future<void> guardarTramos(Escala e, List<double>? t) => t == null
      ? borrarAjuste('tramos_${e.id}')
      : guardarAjuste('tramos_${e.id}', jsonEncode(t));

  List<double> _tramos(String? v, Escala e) {
    final defecto = tramosPorDefecto(e);
    if (v == null || v.isEmpty) return defecto;
    try {
      final l = [for (final x in jsonDecode(v) as List) (x as num).toDouble()];
      return l.length == defecto.length && validarTramos(l) == null
          ? l
          : defecto;
    } catch (_) {
      return defecto;
    }
  }
}
