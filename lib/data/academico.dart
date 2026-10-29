import 'dart:convert';

import 'database.dart';
import 'paises.dart';

/// Un bimestre, trimestre o semestre con sus fechas (yyyy-MM-dd).
class Periodo {
  final String nombre;
  final String? inicio;
  final String? fin;

  const Periodo(this.nombre, {this.inicio, this.fin});

  Periodo copiar({String? inicio, String? fin}) =>
      Periodo(nombre, inicio: inicio ?? this.inicio, fin: fin ?? this.fin);

  Map<String, dynamic> aJson() => {
    'nombre': nombre,
    'inicio': inicio,
    'fin': fin,
  };

  factory Periodo.deJson(Map<String, dynamic> j) => Periodo(
    j['nombre'] as String,
    inicio: j['inicio'] as String?,
    fin: j['fin'] as String?,
  );
}

const tiposPeriodo = {'bimestre': 4, 'trimestre': 3, 'semestre': 2};

/// "1.° bimestre", "2.° trimestre"...
List<Periodo> periodosDe(String tipo) => [
  for (var i = 1; i <= (tiposPeriodo[tipo] ?? 4); i++) Periodo('$i.° $tipo'),
];

/// Configuración académica de un año escolar. Se guarda en Ajustes como JSON
/// en `academico_<año>`. Los periodos y escalas son los que usa el registro
/// auxiliar (Notas.periodo es la posición del periodo, Notas.nota un valor).
class ConfigAcademica {
  final int anio;
  final String pais;
  final String? inicio;
  final String? fin;
  final String tipoPeriodo;
  final List<Periodo> periodos;
  final List<Escala> escalas;
  final String escalaPorDefecto;

  /// Ya pasó por "Configura tu año"; si no, se muestra el aviso.
  final bool configurado;

  const ConfigAcademica({
    required this.anio,
    required this.pais,
    this.inicio,
    this.fin,
    required this.tipoPeriodo,
    required this.periodos,
    required this.escalas,
    required this.escalaPorDefecto,
    this.configurado = false,
  });

  /// Lo que trae el país: periodos y escalas listos, sin fechas.
  factory ConfigAcademica.delPais(int anio, Pais pais) => ConfigAcademica(
    anio: anio,
    pais: pais.codigo,
    tipoPeriodo: pais.periodo,
    periodos: periodosDe(pais.periodo),
    escalas: pais.escalas,
    escalaPorDefecto: pais.escalas.first.id,
  );

  ConfigAcademica copiar({
    String? inicio,
    String? fin,
    String? tipoPeriodo,
    List<Periodo>? periodos,
    List<Escala>? escalas,
    String? escalaPorDefecto,
    bool? configurado,
  }) => ConfigAcademica(
    anio: anio,
    pais: pais,
    inicio: inicio ?? this.inicio,
    fin: fin ?? this.fin,
    tipoPeriodo: tipoPeriodo ?? this.tipoPeriodo,
    periodos: periodos ?? this.periodos,
    escalas: escalas ?? this.escalas,
    escalaPorDefecto: escalaPorDefecto ?? this.escalaPorDefecto,
    configurado: configurado ?? this.configurado,
  );

  int get fechasFaltantes => periodos.fold(
    0,
    (n, p) => n + (p.inicio == null ? 1 : 0) + (p.fin == null ? 1 : 0),
  );

  /// Periodo en el que cae [hoy] (posición desde 1), o null.
  int? periodoActual(DateTime hoy) {
    final h = _clave(hoy);
    for (var i = 0; i < periodos.length; i++) {
      final p = periodos[i];
      if (p.inicio != null &&
          p.fin != null &&
          h.compareTo(p.inicio!) >= 0 &&
          h.compareTo(p.fin!) <= 0) {
        return i + 1;
      }
    }
    return null;
  }

  Map<String, dynamic> aJson() => {
    'anio': anio,
    'pais': pais,
    'inicio': inicio,
    'fin': fin,
    'tipoPeriodo': tipoPeriodo,
    'periodos': [for (final p in periodos) p.aJson()],
    'escalas': [for (final e in escalas) e.aJson()],
    'escalaPorDefecto': escalaPorDefecto,
    'configurado': configurado,
  };

  factory ConfigAcademica.deJson(Map<String, dynamic> j) => ConfigAcademica(
    anio: j['anio'] as int,
    pais: j['pais'] as String? ?? 'PE',
    inicio: j['inicio'] as String?,
    fin: j['fin'] as String?,
    tipoPeriodo: j['tipoPeriodo'] as String? ?? 'bimestre',
    periodos: [
      for (final p in j['periodos'] as List)
        Periodo.deJson(p as Map<String, dynamic>),
    ],
    escalas: [
      for (final e in j['escalas'] as List)
        Escala.deJson(e as Map<String, dynamic>),
    ],
    escalaPorDefecto: j['escalaPorDefecto'] as String,
    configurado: j['configurado'] as bool? ?? false,
  );
}

String _clave(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String claveFecha(DateTime d) => _clave(d);

extension ConfigAcademicaDb on KipuDb {
  /// Año escolar activo; si no hay uno guardado, el año en curso.
  Stream<int> verAnioActivo() =>
      verAjuste('anio_activo')
          .map((v) => int.tryParse(v ?? '') ?? DateTime.now().year);

  /// País de la configuración: el del primer colegio, o Perú.
  Future<Pais> paisAcademico() async {
    final colegios = await verColegios().first;
    return paisPorCodigo(colegios.firstOrNull?.pais);
  }

  Stream<ConfigAcademica> verConfigAcademica(int anio) =>
      verAjuste('academico_$anio').asyncMap((v) async {
        if (v != null) {
          return ConfigAcademica.deJson(jsonDecode(v) as Map<String, dynamic>);
        }
        return ConfigAcademica.delPais(anio, await paisAcademico());
      });

  Future<void> guardarConfigAcademica(ConfigAcademica c) =>
      guardarAjuste('academico_${c.anio}', jsonEncode(c.aJson()));
}
