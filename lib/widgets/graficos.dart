import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Un trozo de un gráfico: nombre, valor y color.
typedef Segmento = (String, double, Color);

/// Gráfico circular tipo dona con leyenda.
class GraficoDona extends StatelessWidget {
  final List<Segmento> segmentos;
  final String centro;
  final String? debajo;
  final double tam;
  final bool leyenda;

  const GraficoDona({
    super.key,
    required this.segmentos,
    this.centro = '',
    this.debajo,
    this.tam = 150,
    this.leyenda = true,
  });

  @override
  Widget build(BuildContext context) {
    final total = segmentos.fold<double>(0, (s, x) => s + x.$2);
    final dona = SizedBox(
      width: tam,
      height: tam,
      child: CustomPaint(
        painter: _PintaDona(segmentos, total),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centro,
                style: TextStyle(
                  fontSize: tam * .17,
                  fontWeight: FontWeight.w700,
                  color: KipuColores.tinta,
                ),
              ),
              if (debajo != null)
                Text(
                  debajo!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: KipuColores.gris,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (!leyenda) return dona;
    return Wrap(
      spacing: 24,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        dona,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (n, v, c) in segmentos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: Text(
                        n,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    SizedBox(
                      width: 34,
                      child: Text(
                        v.round().toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        total == 0 ? '' : '${(v / total * 100).round()} %',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: KipuColores.gris,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PintaDona extends CustomPainter {
  final List<Segmento> segmentos;
  final double total;
  _PintaDona(this.segmentos, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final grosor = size.width * .16;
    final r = Rect.fromLTWH(
      grosor / 2,
      grosor / 2,
      size.width - grosor,
      size.height - grosor,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;
    if (total <= 0) {
      p.color = const Color(0xFFEDEDF4);
      canvas.drawArc(r, 0, 2 * pi, false, p);
      return;
    }
    var a = -pi / 2;
    const hueco = .025;
    final varios = segmentos.where((s) => s.$2 > 0).length > 1;
    for (final (_, v, c) in segmentos) {
      if (v <= 0) continue;
      final ang = v / total * 2 * pi;
      p.color = c;
      canvas.drawArc(
        r,
        a + (varios ? hueco : 0),
        max(0.001, ang - (varios ? 2 * hueco : 0)),
        false,
        p,
      );
      a += ang;
    }
  }

  @override
  bool shouldRepaint(covariant _PintaDona old) =>
      old.segmentos != segmentos || old.total != total;
}

/// Barra de un gráfico de barras.
class Barra {
  final String etiqueta;
  final double? valor;
  final Color color;
  final String? texto;
  final String? detalle;
  const Barra(
    this.etiqueta,
    this.valor,
    this.color, {
    this.texto,
    this.detalle,
  });
}

/// Barras verticales con su valor encima.
class GraficoBarras extends StatelessWidget {
  final List<Barra> barras;
  final double maximo;
  final double alto;

  /// Línea de referencia (p. ej. la nota aprobatoria).
  final double? referencia;

  const GraficoBarras({
    super.key,
    required this.barras,
    this.maximo = 20,
    this.alto = 180,
    this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    if (barras.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = max(c.maxWidth, barras.length * 46.0);
        final grafico = SizedBox(
          width: ancho,
          height: alto + 44,
          child: Stack(
            children: [
              if (referencia != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 18 + alto * (1 - referencia! / maximo),
                  child: Container(
                    height: 1.2,
                    color: const Color(0x55C2334A),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final b in barras)
                    Expanded(
                      child: Tooltip(
                        message: b.detalle ?? b.etiqueta,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              b.texto ??
                                  (b.valor == null
                                      ? '—'
                                      : b.valor!
                                            .toStringAsFixed(1)
                                            .replaceAll('.', ',')),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: (b.valor ?? 0).clamp(0, maximo) / maximo,
                              ),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, f, _) => Container(
                                height: max(3, alto * f),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                constraints: const BoxConstraints(maxWidth: 48),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      b.color,
                                      Color.lerp(b.color, Colors.white, .3)!,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                    bottom: Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 16,
                              child: Text(
                                b.etiqueta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: KipuColores.gris,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
        if (ancho <= c.maxWidth) return grafico;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: grafico,
        );
      },
    );
  }
}

/// Una serie de un gráfico de líneas.
class Serie {
  final String nombre;
  final List<double?> valores;
  final Color color;
  const Serie(this.nombre, this.valores, this.color);
}

/// Líneas con puntos (evolución por periodo).
class GraficoLinea extends StatelessWidget {
  final List<String> etiquetas;
  final List<Serie> series;
  final double minimo;
  final double maximo;
  final double alto;
  final double? referencia;

  const GraficoLinea({
    super.key,
    required this.etiquetas,
    required this.series,
    this.minimo = 0,
    this.maximo = 20,
    this.alto = 180,
    this.referencia,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: alto,
        child: CustomPaint(
          painter: _PintaLinea(this),
          child: const SizedBox.expand(),
        ),
      ),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(left: 28),
        child: Row(
          children: [
            for (final e in etiquetas)
              Expanded(
                child: Text(
                  e,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: KipuColores.gris,
                  ),
                ),
              ),
          ],
        ),
      ),
      if (series.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 14,
            alignment: WrapAlignment.center,
            children: [
              for (final s in series)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 3, color: s.color),
                    const SizedBox(width: 6),
                    Text(s.nombre, style: const TextStyle(fontSize: 12)),
                  ],
                ),
            ],
          ),
        ),
    ],
  );
}

class _PintaLinea extends CustomPainter {
  final GraficoLinea g;
  _PintaLinea(this.g);

  @override
  void paint(Canvas canvas, Size size) {
    const izq = 28.0;
    final w = size.width - izq;
    final h = size.height - 16;
    final n = g.etiquetas.length;
    if (n == 0) return;
    double y(double v) =>
        8 + h * (1 - (v - g.minimo) / (g.maximo - g.minimo));
    double x(int i) => izq + w * (i + .5) / n;

    final guia = Paint()
      ..color = const Color(0xFFEDEDF4)
      ..strokeWidth = 1;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var k = 0; k <= 4; k++) {
      final v = g.minimo + (g.maximo - g.minimo) * k / 4;
      canvas.drawLine(Offset(izq, y(v)), Offset(size.width, y(v)), guia);
      tp.text = TextSpan(
        text: v.round().toString(),
        style: const TextStyle(fontSize: 10.5, color: KipuColores.gris),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y(v) - tp.height / 2));
    }
    if (g.referencia != null) {
      canvas.drawLine(
        Offset(izq, y(g.referencia!)),
        Offset(size.width, y(g.referencia!)),
        Paint()
          ..color = const Color(0x66C2334A)
          ..strokeWidth = 1.2,
      );
    }
    for (final s in g.series) {
      final linea = Paint()
        ..color = s.color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final relleno = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [s.color.withValues(alpha: .18), s.color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      final pts = <Offset>[
        for (var i = 0; i < s.valores.length && i < n; i++)
          if (s.valores[i] != null) Offset(x(i), y(s.valores[i]!)),
      ];
      if (pts.length > 1) {
        final path = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (final p in pts.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
        if (g.series.length == 1) {
          final area = Path.from(path)
            ..lineTo(pts.last.dx, y(g.minimo))
            ..lineTo(pts.first.dx, y(g.minimo))
            ..close();
          canvas.drawPath(area, relleno);
        }
        canvas.drawPath(path, linea);
      }
      for (final p in pts) {
        canvas.drawCircle(p, 5, Paint()..color = Colors.white);
        canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintaLinea old) => true;
}

/// Barra horizontal de porcentaje con texto.
class BarraPorcentaje extends StatelessWidget {
  final double valor; // 0–100
  final Color color;
  final double alto;
  const BarraPorcentaje(
    this.valor, {
    super.key,
    required this.color,
    this.alto = 8,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(alto),
    child: LinearProgressIndicator(
      value: (valor / 100).clamp(0, 1),
      minHeight: alto,
      backgroundColor: const Color(0xFFEDEDF4),
      color: color,
    ),
  );
}
