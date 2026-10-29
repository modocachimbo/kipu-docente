import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/academico.dart';
import '../data/paises.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/calendario_rango.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/selector_color.dart';
import '../widgets/ventana.dart';

/// Configuración académica: año escolar, periodos y escalas de calificación,
/// con lo que viene listo según el país de los colegios.
class ConfigAcademicaPantalla extends StatelessWidget {
  const ConfigAcademicaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: db.verAnioActivo(),
      builder: (context, snapAnio) {
        final anio = snapAnio.data ?? DateTime.now().year;
        return StreamBuilder<ConfigAcademica>(
          stream: db.verConfigAcademica(anio),
          builder: (context, snap) {
            final c = snap.data;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  MediaQuery.sizeOf(context).width < 600
                      ? 'Académica'
                      : 'Configuración académica',
                ),
                actions: [
                  if (c != null) _ChipAnio(c),
                  const SizedBox(width: 12),
                ],
              ),
              body: c == null
                  ? const Center(child: CircularProgressIndicator())
                  : _Contenido(c),
            );
          },
        );
      },
    );
  }
}

class _ChipAnio extends StatelessWidget {
  final ConfigAcademica c;
  const _ChipAnio(this.c);

  @override
  Widget build(BuildContext context) {
    final pais = paisPorCodigo(c.pais);
    final hoy = DateTime.now().year;
    return PopupMenuButton<int>(
      tooltip: 'Año escolar',
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (a) => db.guardarAjuste('anio_activo', '$a'),
      itemBuilder: (_) => [
        for (final a in [hoy - 1, hoy, hoy + 1])
          PopupMenuItem(value: a, child: Text('Año escolar $a')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${pais.bandera} ${c.anio}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: KipuColores.moradoOscuro,
              ),
            ),
            const SizedBox(width: 4),
            KipuIcon(
              KipuIcono.abajo,
              size: 18,
              color: KipuColores.moradoOscuro,
            ),
          ],
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final ConfigAcademica c;
  const _Contenido(this.c);

  @override
  Widget build(BuildContext context) {
    final pais = paisPorCodigo(c.pais);
    final porDefecto = c.escalas
        .where((e) => e.id == c.escalaPorDefecto)
        .firstOrNull;
    final faltan = c.fechasFaltantes;
    final calendario = [
      _Tarjeta(
        icono: KipuIcono.calendario,
        titulo: 'Año escolar',
        resumen: c.inicio != null && c.fin != null
            ? '${c.anio} · ${_corta(c.inicio!)} al ${_corta(c.fin!)}'
            : '${c.anio} · ${pais.nombre}',
        estado: c.inicio != null && c.fin != null
            ? const _Estado('Listo', _TipoEstado.listo)
            : const _Estado('Faltan fechas', _TipoEstado.falta),
        onTap: () => editarAnio(context, c),
      ),
      _Tarjeta(
        icono: KipuIcono.horario,
        titulo: 'Periodos',
        resumen: '${c.periodos.length} ${_plural(c.tipoPeriodo)}',
        estado: faltan == 0
            ? const _Estado('Listo', _TipoEstado.listo)
            : _Estado(
                faltan == 1 ? 'Falta 1 fecha' : 'Faltan $faltan fechas',
                _TipoEstado.falta,
              ),
        onTap: () => editarPeriodos(context, c),
      ),
    ];
    final evaluacion = [
      _Tarjeta(
        icono: KipuIcono.estrella,
        titulo: 'Escalas de calificación',
        resumen: c.escalas.map((e) => e.nombre).join(', '),
        estado: _Estado(
          porDefecto == null
              ? '${c.escalas.length} escalas'
              : 'Por defecto: ${porDefecto.nombre}',
          _TipoEstado.listo,
        ),
        onTap: () => editarEscalas(context, c),
      ),
      const _Tarjeta(
        icono: KipuIcono.notas,
        titulo: 'Instrumentos de evaluación',
        resumen: 'Numérica, lista de cotejo, rúbrica, participaciones…',
        estado: _Estado('Próximamente', _TipoEstado.pronto),
      ),
      _Tarjeta(
        icono: KipuIcono.diana,
        titulo: 'Competencias y criterios',
        resumen: 'Del ${pais.curriculo} por área',
        estado: const _Estado('Próximamente', _TipoEstado.pronto),
      ),
      const _Tarjeta(
        icono: KipuIcono.promedio,
        titulo: 'Promedio y redondeo',
        resumen: 'Pesos, nota aprobatoria y redondeo',
        estado: _Estado('Próximamente', _TipoEstado.pronto),
      ),
    ];
    return LayoutBuilder(
      builder: (context, caja) {
        final columnas = caja.maxWidth >= 640 ? 2 : 1;
        Widget grilla(List<Widget> hijos) => LayoutBuilder(
          builder: (context, c2) {
            const espacio = 14.0;
            final ancho = (c2.maxWidth - espacio * (columnas - 1)) / columnas;
            return Wrap(
              spacing: espacio,
              runSpacing: espacio,
              children: [
                for (final h in hijos) SizedBox(width: ancho, child: h),
              ],
            );
          },
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Todo lo que define cómo evalúas. Viene listo para '
                      '${pais.nombre}; solo revisa y completa lo que falta.',
                      style: const TextStyle(color: KipuColores.gris),
                    ),
                    const SizedBox(height: 16),
                    if (!c.configurado) ...[
                      _Aviso(onEmpezar: () => configurarAnio(context, c)),
                      const SizedBox(height: 6),
                    ],
                    const _Bloque('CALENDARIO'),
                    grilla(calendario),
                    const _Bloque('EVALUACIÓN'),
                    grilla(evaluacion),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _plural(String tipo) => '${tipo}s';

String _corta(String clave) => DateFormat(
  'd MMM',
  'es_PE',
).format(DateTime.parse(clave)).replaceAll('.', '');

class _Bloque extends StatelessWidget {
  final String texto;
  const _Bloque(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 18, 0, 10),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: KipuColores.gris,
      ),
    ),
  );
}

class _Aviso extends StatelessWidget {
  final VoidCallback onEmpezar;
  const _Aviso({required this.onEmpezar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [KipuColores.morado, KipuColores.moradoOscuro],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configura tu año en 3 pasos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Año, periodos y escalas · 2 minutos',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: KipuColores.moradoOscuro,
            ),
            onPressed: onEmpezar,
            child: const Text('Empezar'),
          ),
        ],
      ),
    );
  }
}

enum _TipoEstado { listo, falta, pronto }

class _Estado {
  final String texto;
  final _TipoEstado tipo;
  const _Estado(this.texto, this.tipo);
}

class _Tarjeta extends StatelessWidget {
  final KipuIcono icono;
  final String titulo;
  final String resumen;
  final _Estado estado;
  final VoidCallback? onTap;

  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.resumen,
    required this.estado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (fondo, texto) = switch (estado.tipo) {
      _TipoEstado.listo => (const Color(0xFFDCF5EC), const Color(0xFF0E7A5F)),
      _TipoEstado.falta => (const Color(0xFFFFF1DB), const Color(0xFFB86E00)),
      _TipoEstado.pronto => (const Color(0xFFF0EEF6), KipuColores.gris),
    };
    return Opacity(
      opacity: onTap == null ? .7 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: KipuIcon(icono, size: 32, color: KipuColores.morado),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resumen,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: KipuColores.gris,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: fondo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estado.texto,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: texto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const KipuIcon(
                    KipuIcono.flecha,
                    size: 18,
                    color: Color(0xFFB5B2C4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ventanas ────────────────────────────────────────────────────────────────

/// "Configura tu año": año, periodos y escalas seguidos.
Future<void> configurarAnio(BuildContext context, ConfigAcademica c) async {
  var actual = c;
  final pasos = [editarAnio, editarPeriodos, editarEscalas];
  for (var i = 0; i < pasos.length; i++) {
    final r = await pasos[i](context, actual, paso: i + 1);
    if (r == null || !context.mounted) return;
    actual = r;
  }
  await db.guardarConfigAcademica(actual.copiar(configurado: true));
}

/// Subtítulo y texto del botón cuando la ventana es un paso del asistente.
String _sub(String normal, int? paso) =>
    paso == null ? normal : 'Paso $paso de 3';

String _boton(int? paso) => switch (paso) {
  null => 'Guardar',
  3 => 'Terminar',
  _ => 'Siguiente',
};

Future<ConfigAcademica?> editarAnio(
  BuildContext context,
  ConfigAcademica c, {
  int? paso,
}) {
  var inicio = c.inicio;
  var fin = c.fin;
  Future<void> rango(
    BuildContext ctx,
    StateSetter setState,
    bool porFin,
  ) async {
    final r = await elegirRango(
      ctx,
      icono: KipuIcono.calendario,
      titulo: 'Año escolar ${c.anio}',
      anio: c.anio,
      inicio: inicio,
      fin: fin,
      empezarPorFin: porFin,
      feriados: paisPorCodigo(c.pais).feriadosDe(c.anio),
    );
    if (r != null) setState(() => (inicio, fin) = r);
  }

  return showDialog<ConfigAcademica>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Ventana(
        icono: KipuIcono.calendario,
        titulo: 'Año escolar ${c.anio}',
        subtitulo: _sub('Cuándo empiezan y terminan las clases', paso),
        contenido: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _CampoFecha(
                    'Inicio de clases',
                    inicio,
                    onTap: () => rango(ctx, setState, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CampoFecha(
                    'Fin de clases',
                    fin,
                    onTap: () => rango(ctx, setState, true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _BotonesVentana(
              texto: _boton(paso),
              onGuardar: () async {
                final nueva = c.copiar(inicio: inicio, fin: fin);
                await db.guardarConfigAcademica(nueva);
                if (ctx.mounted) Navigator.pop(ctx, nueva);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<ConfigAcademica?> editarPeriodos(
  BuildContext context,
  ConfigAcademica c, {
  int? paso,
}) {
  var tipo = c.tipoPeriodo;
  var periodos = [...c.periodos];
  const tipos = ['bimestre', 'trimestre', 'semestre'];
  return showDialog<ConfigAcademica>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final actual = c
            .copiar(periodos: periodos)
            .periodoActual(DateTime.now());
        return Ventana(
          icono: KipuIcono.horario,
          titulo: paso == null ? 'Periodos' : '¿Cómo divides tu año?',
          subtitulo: _sub('Año escolar ${c.anio}', paso),
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KipuSegmentos(
                const ['Bimestres', 'Trimestres', 'Semestres'],
                tipos.indexOf(tipo),
                (i) => setState(() {
                  if (tipos[i] == tipo) return;
                  tipo = tipos[i];
                  periodos = periodosDe(tipo);
                }),
              ),
              const SizedBox(height: 14),
              if (actual != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: KipuColores.moradoClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Estás en el ${periodos[actual - 1].nombre} · termina el '
                    '${_corta(periodos[actual - 1].fin!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: KipuColores.moradoOscuro,
                    ),
                  ),
                ),
              for (var i = 0; i < periodos.length; i++)
                _FilaPeriodo(
                  numero: i + 1,
                  periodo: periodos[i],
                  onElegir: (porFin) async {
                    final p = periodos[i];
                    final r = await elegirRango(
                      ctx,
                      icono: KipuIcono.horario,
                      titulo: p.nombre,
                      anio: c.anio,
                      inicio: p.inicio,
                      fin: p.fin,
                      empezarPorFin: porFin,
                      feriados: paisPorCodigo(c.pais).feriadosDe(c.anio),
                      otros: [
                        for (final o in periodos)
                          if (o != p && o.inicio != null && o.fin != null)
                            (o.inicio!, o.fin!),
                      ],
                    );
                    if (r != null) {
                      setState(
                        () => periodos[i] = p.copiar(inicio: r.$1, fin: r.$2),
                      );
                    }
                  },
                ),
              const SizedBox(height: 10),
              _BotonesVentana(
                texto: _boton(paso),
                onGuardar: () async {
                  final nueva = c.copiar(tipoPeriodo: tipo, periodos: periodos);
                  await db.guardarConfigAcademica(nueva);
                  if (ctx.mounted) Navigator.pop(ctx, nueva);
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _FilaPeriodo extends StatelessWidget {
  final int numero;
  final Periodo periodo;
  final ValueChanged<bool> onElegir; // true: empezar por el fin

  const _FilaPeriodo({
    required this.numero,
    required this.periodo,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KipuColores.morado.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: KipuColores.moradoClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$numero',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: KipuColores.moradoOscuro,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              periodo.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          _Fecha(periodo.inicio, 'Inicio', onTap: () => onElegir(false)),
          const SizedBox(width: 6),
          _Fecha(periodo.fin, 'Fin', onTap: () => onElegir(true)),
        ],
      ),
    );
  }
}

/// Píldora de fecha: muestra "9 mar" o, si falta, el texto en ámbar.
class _Fecha extends StatelessWidget {
  final String? valor;
  final String vacio;
  final VoidCallback onTap;

  const _Fecha(this.valor, this.vacio, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final falta = valor == null;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: falta ? const Color(0xFFFFF8EC) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: falta
                ? const Color(0xFFF3C98B)
                : KipuColores.morado.withValues(alpha: .3),
          ),
        ),
        child: Text(
          falta ? vacio : _corta(valor!),
          style: TextStyle(
            fontSize: 13,
            color: falta ? const Color(0xFFB86E00) : KipuColores.tinta,
          ),
        ),
      ),
    );
  }
}

class _CampoFecha extends StatelessWidget {
  final String etiqueta;
  final String? valor;
  final VoidCallback onTap;

  const _CampoFecha(this.etiqueta, this.valor, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: KipuColores.morado.withValues(alpha: .45),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valor == null
                        ? 'Elegir fecha'
                        : DateFormat(
                            "d 'de' MMMM",
                            'es_PE',
                          ).format(DateTime.parse(valor!)),
                    style: TextStyle(
                      color: valor == null
                          ? KipuColores.gris
                          : KipuColores.tinta,
                    ),
                  ),
                ),
                KipuIcon(
                  KipuIcono.calendario,
                  size: 20,
                  color: KipuColores.morado,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<ConfigAcademica?> editarEscalas(
  BuildContext context,
  ConfigAcademica c, {
  int? paso,
}) {
  var escalas = [...c.escalas];
  var porDefecto = c.escalaPorDefecto;
  return showDialog<ConfigAcademica>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Ventana(
        icono: KipuIcono.estrella,
        titulo: 'Escalas de calificación',
        subtitulo: _sub('Toca una para usarla por defecto', paso),
        contenido: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final e in escalas)
              _TarjetaEscala(
                e,
                elegida: e.id == porDefecto,
                onTap: () => setState(() => porDefecto = e.id),
                // Las que vienen con el país no se borran.
                onBorrar: e.id.startsWith('p_')
                    ? () => setState(() {
                        escalas.remove(e);
                        if (porDefecto == e.id) porDefecto = escalas.first.id;
                      })
                    : null,
              ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final nueva = await _nuevaEscala(ctx);
                if (nueva != null) setState(() => escalas.add(nueva));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: KipuColores.morado.withValues(alpha: .4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KipuIcon(
                      KipuIcono.agregar,
                      size: 18,
                      color: KipuColores.morado,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Nueva escala',
                      style: TextStyle(
                        color: KipuColores.morado,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _BotonesVentana(
              texto: _boton(paso),
              onGuardar: () async {
                final nueva = c.copiar(
                  escalas: escalas,
                  escalaPorDefecto: porDefecto,
                );
                await db.guardarConfigAcademica(nueva);
                if (ctx.mounted) Navigator.pop(ctx, nueva);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _TarjetaEscala extends StatelessWidget {
  final Escala escala;
  final bool elegida;
  final VoidCallback onTap;
  final VoidCallback? onBorrar;

  const _TarjetaEscala(
    this.escala, {
    required this.elegida,
    required this.onTap,
    this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: elegida ? KipuColores.fondo : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: elegida
                  ? KipuColores.morado
                  : KipuColores.morado.withValues(alpha: .3),
              width: elegida ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      escala.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (elegida)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: KipuColores.moradoClaro,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'POR DEFECTO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: KipuColores.moradoOscuro,
                        ),
                      ),
                    ),
                  if (onBorrar != null)
                    IconButton(
                      tooltip: 'Borrar escala',
                      visualDensity: VisualDensity.compact,
                      onPressed: onBorrar,
                      icon: const KipuIcon(
                        KipuIcono.borrar,
                        size: 18,
                        color: Color(0xFFE5566B),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final v in escala.valores)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(v.color).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        v.descripcion.isEmpty
                            ? v.codigo
                            : '${v.codigo} · ${v.descripcion}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(v.color),
                        ),
                      ),
                    ),
                  if (escala.aprueba != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EEF6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'Aprueba con ${_numero(escala.aprueba!)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: KipuColores.gris,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _numero(double n) =>
    n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

// Colores de los tramos de una escala nueva, del más alto al más bajo.
const _coloresTramos = [
  0xFF5B4BD6,
  0xFF2557C7,
  0xFF0E7A5F,
  0xFFB86E00,
  0xFFC2334A,
];

Future<Escala?> _nuevaEscala(BuildContext context) {
  final nombre = TextEditingController();
  final valores = TextEditingController();
  final minimo = TextEditingController(text: '0');
  final maximo = TextEditingController(text: '10');
  final aprueba = TextEditingController(text: '6');
  var numerica = false;
  final form = GlobalKey<FormState>();
  return showDialog<Escala>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Ventana(
        icono: KipuIcono.estrella,
        titulo: 'Nueva escala',
        subtitulo: 'Letras, conceptos o números',
        contenido: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KipuSegmentos(
                const ['Letras o conceptos', 'Numérica'],
                numerica ? 1 : 0,
                (i) => setState(() => numerica = i == 1),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  hintText: numerica ? 'Ej. Numérica 1 a 10' : 'Ej. Conceptos',
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
              ),
              const SizedBox(height: 12),
              if (!numerica)
                TextFormField(
                  controller: valores,
                  decoration: const InputDecoration(
                    labelText: 'Valores, del mejor al más bajo',
                    hintText: 'Ej. Excelente, Bueno, Regular, Malo',
                  ),
                  validator: (v) => _partes(v).length < 2
                      ? 'Escribe al menos 2 valores'
                      : null,
                )
              else
                Row(
                  children: [
                    for (final (etiqueta, ctrl) in [
                      ('Mínima', minimo),
                      ('Máxima', maximo),
                      ('Aprueba con', aprueba),
                    ]) ...[
                      Expanded(
                        child: TextFormField(
                          controller: ctrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(labelText: etiqueta),
                          validator: (v) =>
                              double.tryParse((v ?? '').replaceAll(',', '.')) ==
                                  null
                              ? 'Número'
                              : null,
                        ),
                      ),
                      if (etiqueta != 'Aprueba con') const SizedBox(width: 10),
                    ],
                  ],
                ),
              const SizedBox(height: 18),
              _BotonesVentana(
                texto: 'Agregar',
                onGuardar: () {
                  if (!form.currentState!.validate()) return;
                  final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
                  if (!numerica) {
                    final partes = _partes(valores.text);
                    Navigator.pop(
                      ctx,
                      Escala(
                        id: id,
                        nombre: nombre.text.trim(),
                        valores: [
                          for (var i = 0; i < partes.length; i++)
                            ValorEscala(
                              partes[i],
                              '',
                              _coloresTramos[(i *
                                      (_coloresTramos.length - 1) ~/
                                      (partes.length - 1))
                                  .clamp(0, _coloresTramos.length - 1)],
                            ),
                        ],
                      ),
                    );
                    return;
                  }
                  double n(TextEditingController t) =>
                      double.parse(t.text.replaceAll(',', '.'));
                  final (lo, hi, ap) = (n(minimo), n(maximo), n(aprueba));
                  Navigator.pop(
                    ctx,
                    Escala(
                      id: id,
                      nombre: nombre.text.trim(),
                      numerica: true,
                      minimo: lo,
                      maximo: hi,
                      aprueba: ap,
                      valores: [
                        ValorEscala(
                          '${_numero(ap)}–${_numero(hi)}',
                          'Aprobado',
                          _coloresTramos[1],
                          desde: ap,
                        ),
                        ValorEscala(
                          '${_numero(lo)}–${_numero(ap)}',
                          'Desaprobado',
                          _coloresTramos.last,
                          desde: lo,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

List<String> _partes(String? texto) => (texto ?? '')
    .split(',')
    .map((p) => p.trim())
    .where((p) => p.isNotEmpty)
    .toList();

class _BotonesVentana extends StatelessWidget {
  final String texto;
  final VoidCallback onGuardar;
  const _BotonesVentana({required this.texto, required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(onPressed: onGuardar, child: Text(texto)),
        ),
      ],
    );
  }
}
