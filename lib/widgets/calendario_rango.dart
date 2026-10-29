import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';
import 'kipu_icono.dart';
import 'ventana.dart';

const _rojo = Color(0xFFC2334A);
const _apagado = Color(0xFFB5B2C4);

String _clave(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Calendario para elegir inicio y fin de una vez: primero se toca el inicio y
/// luego el fin. Devuelve las dos fechas como 'yyyy-MM-dd'.
///
/// [feriados] se marcan en rojo y [otros] (rangos ya usados, como los demás
/// periodos) con un punto gris.
Future<(String, String)?> elegirRango(
  BuildContext context, {
  required KipuIcono icono,
  required String titulo,
  required int anio,
  String? inicio,
  String? fin,
  bool empezarPorFin = false,
  Map<String, String> feriados = const {},
  List<(String, String)> otros = const [],
}) {
  return showDialog<(String, String)>(
    context: context,
    builder: (_) => _CalendarioRango(
      icono: icono,
      titulo: titulo,
      anio: anio,
      inicio: inicio,
      fin: fin,
      empezarPorFin: empezarPorFin && inicio != null,
      feriados: feriados,
      otros: otros,
    ),
  );
}

class _CalendarioRango extends StatefulWidget {
  final KipuIcono icono;
  final String titulo;
  final int anio;
  final String? inicio;
  final String? fin;
  final bool empezarPorFin;
  final Map<String, String> feriados;
  final List<(String, String)> otros;

  const _CalendarioRango({
    required this.icono,
    required this.titulo,
    required this.anio,
    required this.inicio,
    required this.fin,
    required this.empezarPorFin,
    required this.feriados,
    required this.otros,
  });

  @override
  State<_CalendarioRango> createState() => _CalendarioRangoState();
}

class _CalendarioRangoState extends State<_CalendarioRango> {
  late String? _inicio = widget.inicio;
  late String? _fin = widget.fin;
  late bool _tocaFin = widget.empezarPorFin;
  late DateTime _mes;
  bool _verMeses = false;

  @override
  void initState() {
    super.initState();
    final base = (_tocaFin ? _fin ?? _inicio : _inicio) ?? _primerDia();
    final d = DateTime.parse(base);
    _mes = DateTime(d.year, d.month);
  }

  // Sin fechas, se abre en marzo: cuando suele empezar el año escolar.
  String _primerDia() => _clave(DateTime(widget.anio, 3));

  void _tocar(String dia) => setState(() {
    if (!_tocaFin || _inicio == null || dia.compareTo(_inicio!) < 0) {
      _inicio = dia;
      if (_fin != null && _fin!.compareTo(dia) < 0) _fin = null;
      _tocaFin = true;
    } else {
      _fin = dia;
    }
  });

  bool _enOtro(String dia) => widget.otros.any(
    (r) => dia.compareTo(r.$1) >= 0 && dia.compareTo(r.$2) <= 0,
  );

  String? get _resumen {
    if (_inicio == null || _fin == null) return null;
    final a = DateTime.parse(_inicio!);
    final b = DateTime.parse(_fin!);
    final dias = b.difference(a).inDays + 1;
    final semanas = (dias / 7).ceil();
    final feriados = widget.feriados.keys
        .where((f) => f.compareTo(_inicio!) >= 0 && f.compareTo(_fin!) <= 0)
        .where((f) => DateTime.parse(f).weekday <= 5)
        .length;
    return '$semanas ${semanas == 1 ? 'semana' : 'semanas'} · '
        '${_corta(_inicio!)} al ${_corta(_fin!)}'
        '${feriados == 0 ? '' : ' · $feriados ${feriados == 1 ? 'feriado' : 'feriados'}'}';
  }

  @override
  Widget build(BuildContext context) {
    final nombreMes = DateFormat('MMMM yyyy', 'es_PE').format(_mes);
    final feriadosMes = widget.feriados.entries
        .where((e) => e.key.startsWith(DateFormat('yyyy-MM').format(_mes)))
        .toList();
    final resumen = _resumen;
    return Ventana(
      compacta: true,
      icono: widget.icono,
      titulo: widget.titulo,
      subtitulo: _tocaFin ? 'Ahora toca el día final' : 'Toca el día de inicio',
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _Caja(
                  'INICIO',
                  _inicio,
                  activa: !_tocaFin,
                  onTap: () => setState(() => _tocaFin = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Caja(
                  'FIN',
                  _fin,
                  activa: _tocaFin,
                  onTap: _inicio == null
                      ? null
                      : () => setState(() => _tocaFin = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _BotonMes(
                KipuIcono.flecha,
                atras: true,
                onTap: () => setState(
                  () => _mes = DateTime(
                    _mes.year,
                    _mes.month - (_verMeses ? 12 : 1),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _verMeses = !_verMeses),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _verMeses ? '${_mes.year}' : _mayuscula(nombreMes),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _verMeses ? .5 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: KipuIcon(
                              KipuIcono.abajo,
                              size: 18,
                              color: KipuColores.morado,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _BotonMes(
                KipuIcono.flecha,
                onTap: () => setState(
                  () => _mes = DateTime(
                    _mes.year,
                    _mes.month + (_verMeses ? 12 : 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _verMeses ? _meses() : _grilla(),
          if (feriadosMes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feriadosMes
                    .map((e) => '${_corta(e.key)} · ${e.value}')
                    .join('   ·   '),
                style: const TextStyle(fontSize: 13, color: _rojo),
              ),
            ),
          ],
          if (resumen != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: KipuColores.moradoClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                resumen,
                style: TextStyle(
                  fontSize: 13.5,
                  color: KipuColores.moradoOscuro,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _inicio == null || _fin == null
                      ? null
                      : () => Navigator.pop(context, (_inicio!, _fin!)),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grilla() {
    final hoy = _clave(DateTime.now());
    final vacios = DateTime(_mes.year, _mes.month).weekday - 1;
    final dias = DateTime(_mes.year, _mes.month + 1, 0).day;
    return Column(
      children: [
        Row(
          children: [
            for (final l in 'LMXJVSD'.split(''))
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KipuColores.gris,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2,
          // Celdas bajas para que la ventana entre sin scroll en una laptop.
          childAspectRatio: 1.85,
          children: [
            for (var i = 0; i < vacios; i++) const SizedBox(),
            for (var d = 1; d <= dias; d++)
              _dia(DateTime(_mes.year, _mes.month, d), hoy),
          ],
        ),
      ],
    );
  }

  /// Los 12 meses del año para saltar directo a uno.
  Widget _meses() {
    final conFecha = {
      for (final f in [_inicio, _fin])
        if (f != null) f.substring(0, 7),
    };
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.1,
      children: [
        for (var m = 1; m <= 12; m++)
          Builder(
            builder: (context) {
              final fecha = DateTime(_mes.year, m);
              final actual = m == _mes.month;
              final marcado = conFecha.contains(
                DateFormat('yyyy-MM').format(fecha),
              );
              return Material(
                color: actual
                    ? KipuColores.morado
                    : marcado
                    ? KipuColores.moradoClaro
                    : KipuColores.fondo,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => setState(() {
                    _mes = fecha;
                    _verMeses = false;
                  }),
                  child: Center(
                    child: Text(
                      _mayuscula(
                        DateFormat(
                          'MMM',
                          'es_PE',
                        ).format(fecha).replaceAll('.', ''),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: actual
                            ? Colors.white
                            : marcado
                            ? KipuColores.moradoOscuro
                            : KipuColores.tinta,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _dia(DateTime fecha, String hoy) {
    final k = _clave(fecha);
    final esInicio = k == _inicio;
    final esFin = k == _fin;
    final elegido = esInicio || esFin;
    final dentro =
        _inicio != null &&
        _fin != null &&
        k.compareTo(_inicio!) > 0 &&
        k.compareTo(_fin!) < 0;
    final feriado = widget.feriados.containsKey(k);
    final finDeSemana = fecha.weekday > 5;
    const r = Radius.circular(13);
    final tramo = _inicio != null && _fin != null && _inicio != _fin;
    final punto = feriado
        ? _rojo
        : _enOtro(k)
        ? _apagado
        : null;
    return Tooltip(
      message: widget.feriados[k] ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _tocar(k),
        child: Container(
          decoration: BoxDecoration(
            color: elegido
                ? KipuColores.morado
                : dentro
                ? KipuColores.moradoClaro
                : null,
            borderRadius: elegido && tramo
                ? BorderRadius.horizontal(
                    left: esInicio ? r : Radius.zero,
                    right: esFin ? r : Radius.zero,
                  )
                : dentro
                ? null
                : BorderRadius.circular(13),
            border: k == hoy && !elegido
                ? Border.all(color: KipuColores.morado, width: 1.5)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${fecha.day}',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: elegido || feriado
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: elegido
                      ? Colors.white
                      : feriado
                      ? _rojo
                      : dentro
                      ? KipuColores.moradoOscuro
                      : finDeSemana
                      ? _apagado
                      : KipuColores.tinta,
                ),
              ),
              if (punto != null && !elegido)
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: punto,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _corta(String clave) => DateFormat(
  'd MMM',
  'es_PE',
).format(DateTime.parse(clave)).replaceAll('.', '');

String _mayuscula(String t) => t[0].toUpperCase() + t.substring(1);

class _Caja extends StatelessWidget {
  final String etiqueta;
  final String? valor;
  final bool activa;
  final VoidCallback? onTap;

  const _Caja(this.etiqueta, this.valor, {required this.activa, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: activa ? KipuColores.fondo : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: activa
                ? KipuColores.morado
                : KipuColores.morado.withValues(alpha: .28),
            width: activa ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: activa ? KipuColores.morado : KipuColores.gris,
              ),
            ),
            Text(
              valor == null
                  ? 'Elegir'
                  : _mayuscula(
                      DateFormat(
                        'EEE d MMM',
                        'es_PE',
                      ).format(DateTime.parse(valor!)).replaceAll('.', ''),
                    ),
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: valor == null ? KipuColores.gris : KipuColores.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonMes extends StatelessWidget {
  final KipuIcono icono;
  final bool atras;
  final VoidCallback onTap;

  const _BotonMes(this.icono, {this.atras = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KipuColores.fondo,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Transform.flip(
              flipX: atras,
              child: KipuIcon(icono, size: 18, color: KipuColores.morado),
            ),
          ),
        ),
      ),
    );
  }
}
