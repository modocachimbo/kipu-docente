import 'package:flutter/material.dart';

import '../theme.dart';
import 'kipu_icono.dart';
import 'ventana.dart';

/// Colores claros (pasteles) llevan texto oscuro para que se lea bien.
bool esClaro(Color c) => c.computeLuminance() > .45;

Color textoSobre(Color fondo) =>
    esClaro(fondo) ? KipuColores.tinta : Colors.white;

/// El mismo color, oscurecido si es pastel, para usarlo como texto sobre blanco.
Color tonoTexto(Color c) => esClaro(c) ? Color.lerp(c, Colors.black, .55)! : c;

/// Los colores clásicos y otros más finos, en tonos aptos para fondo con texto blanco.
const coloresSolidos = <(String, Color)>[
  ('Rojo', Color(0xFFB23A3A)),
  ('Vino', Color(0xFF7A2E3B)),
  ('Rosado', Color(0xFFB05A6E)),
  ('Fucsia', Color(0xFFA23B72)),
  ('Naranja', Color(0xFFC2621F)),
  ('Terracota', Color(0xFFB4573E)),
  ('Mostaza', Color(0xFFA87F2A)),
  ('Oliva', Color(0xFF6F7A3A)),
  ('Verde', Color(0xFF2E7D4F)),
  ('Salvia', Color(0xFF5E7D6A)),
  ('Bosque', Color(0xFF2F5D4A)),
  ('Jade', Color(0xFF2E7D6B)),
  ('Petróleo', Color(0xFF1F5F6B)),
  ('Turquesa', Color(0xFF1F7F8C)),
  ('Azul', Color(0xFF2F5FA8)),
  ('Acero', Color(0xFF3B5B83)),
  ('Marino', Color(0xFF1E2A47)),
  ('Índigo', Color(0xFF5458A8)),
  ('Morado', Color(0xFF6E4BA8)),
  ('Ciruela', Color(0xFF6B3F6E)),
  ('Café', Color(0xFF6B4A3A)),
  ('Topo', Color(0xFF7A6A5F)),
  ('Pizarra', Color(0xFF4B5563)),
  ('Grafito', Color(0xFF2F3640)),
];

/// Pasteles empolvados para fondo con texto oscuro.
const coloresPasteles = <(String, Color)>[
  ('Rubor', Color(0xFFEBCFD2)),
  ('Palo rosa', Color(0xFFE4C3C6)),
  ('Malva', Color(0xFFE2CCD6)),
  ('Orquídea', Color(0xFFE9D0E3)),
  ('Lila', Color(0xFFE6D5EA)),
  ('Lavanda', Color(0xFFDDD3EE)),
  ('Pervinca', Color(0xFFD3D6F0)),
  ('Cielo', Color(0xFFCFDDF0)),
  ('Niebla', Color(0xFFD3E0EA)),
  ('Agua', Color(0xFFC9E4E4)),
  ('Menta', Color(0xFFCDE8DD)),
  ('Eucalipto', Color(0xFFC9DDD4)),
  ('Salvia', Color(0xFFCFDDC8)),
  ('Pistacho', Color(0xFFDCE5C6)),
  ('Limón', Color(0xFFEEEBC4)),
  ('Vainilla', Color(0xFFF4E9C5)),
  ('Damasco', Color(0xFFF3DCC0)),
  ('Melocotón', Color(0xFFF2D3C2)),
  ('Arena', Color(0xFFEADFCB)),
  ('Marfil', Color(0xFFF2EEE3)),
  ('Piedra', Color(0xFFDAD5CE)),
  ('Perla', Color(0xFFE3E3E8)),
  ('Humo', Color(0xFFD5D9DE)),
  ('Crema', Color(0xFFF3EBDB)),
];

/// Ventana "Más colores": sólidos, pasteles o uno personalizado (cuadro,
/// barra de tonos o código hex). Devuelve el color elegido o null.
Future<Color?> elegirColor(
  BuildContext context, {
  required Color actual,
  required String nombre,
  String? detalle,
}) => showDialog<Color>(
  context: context,
  barrierColor: KipuColores.tinta.withValues(alpha: .45),
  builder: (_) =>
      _SelectorColor(actual: actual, nombre: nombre, detalle: detalle),
);

class _SelectorColor extends StatefulWidget {
  final Color actual;
  final String nombre;
  final String? detalle;
  const _SelectorColor({
    required this.actual,
    required this.nombre,
    this.detalle,
  });

  @override
  State<_SelectorColor> createState() => _SelectorColorState();
}

class _SelectorColorState extends State<_SelectorColor> {
  late Color _color = widget.actual;
  late int _pestana = coloresPasteles.any((p) => p.$2 == widget.actual)
      ? 1
      : coloresSolidos.any((p) => p.$2 == widget.actual)
      ? 0
      : 2;
  late HSVColor _hsv = HSVColor.fromColor(widget.actual);
  late final _hex = TextEditingController(text: _aHex(widget.actual));

  static String _aHex(Color c) =>
      (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  void _usarHsv(HSVColor h) => setState(() {
    _hsv = h;
    _color = h.toColor();
    _hex.text = _aHex(_color);
  });

  @override
  Widget build(BuildContext context) {
    return Ventana(
      icono: KipuIcono.paleta,
      titulo: 'Más colores',
      subtitulo: 'Elige el color de tu colegio',
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Pestanas(
            const ['Sólidos', 'Pasteles', 'Personalizado'],
            _pestana,
            (i) => setState(() => _pestana = i),
          ),
          const SizedBox(height: 16),
          if (_pestana < 2)
            _Paleta(
              _pestana == 0 ? coloresSolidos : coloresPasteles,
              _color,
              (c) => setState(() {
                _color = c;
                _hsv = HSVColor.fromColor(c);
                _hex.text = _aHex(c);
              }),
            )
          else
            _Personalizado(
              hsv: _hsv,
              hex: _hex,
              onHsv: _usarHsv,
              onHex: (c) => setState(() {
                _color = c;
                _hsv = HSVColor.fromColor(c);
              }),
            ),
          const SizedBox(height: 16),
          const Text(
            'Vista previa',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _Vista(_color, widget.nombre, widget.detalle),
          const SizedBox(height: 18),
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
                  onPressed: () => Navigator.pop(context, _color),
                  child: const Text('Usar este color'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pestanas extends StatelessWidget {
  final List<String> textos;
  final int elegida;
  final ValueChanged<int> onTap;
  const _Pestanas(this.textos, this.elegida, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < textos.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == elegida ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: i == elegida
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .08),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    textos[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: i == elegida
                          ? KipuColores.tinta
                          : KipuColores.gris,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Paleta extends StatelessWidget {
  final List<(String, Color)> colores;
  final Color elegido;
  final ValueChanged<Color> onTap;
  const _Paleta(this.colores, this.elegido, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final (nombre, c) in colores)
          InkWell(
            onTap: () => onTap(c),
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 54,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c == elegido
                            ? KipuColores.tinta
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: c == elegido
                        ? KipuIcon(
                            KipuIcono.check,
                            color: textoSobre(c),
                            size: 18,
                          )
                        : null,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: KipuColores.gris,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Cuadro de saturación y brillo, barra de tonos y código hex.
class _Personalizado extends StatelessWidget {
  final HSVColor hsv;
  final TextEditingController hex;
  final ValueChanged<HSVColor> onHsv;
  final ValueChanged<Color> onHex;
  const _Personalizado({
    required this.hsv,
    required this.hex,
    required this.onHsv,
    required this.onHex,
  });

  @override
  Widget build(BuildContext context) {
    final puro = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, caja) {
            const alto = 180.0;
            final ancho = caja.maxWidth;
            void tocar(Offset p) => onHsv(
              hsv
                  .withSaturation((p.dx / ancho).clamp(0, 1))
                  .withValue(1 - (p.dy / alto).clamp(0, 1)),
            );
            return GestureDetector(
              onPanDown: (d) => tocar(d.localPosition),
              onPanUpdate: (d) => tocar(d.localPosition),
              child: SizedBox(
                height: alto,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.white, puro],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: hsv.saturation * ancho - 11,
                      top: (1 - hsv.value) * alto - 11,
                      child: _Punto(hsv.toColor()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, caja) {
            final ancho = caja.maxWidth;
            void tocar(Offset p) =>
                onHsv(hsv.withHue((p.dx / ancho).clamp(0, 1) * 359.9));
            return GestureDetector(
              onPanDown: (d) => tocar(d.localPosition),
              onPanUpdate: (d) => tocar(d.localPosition),
              child: SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            for (var h = 0; h <= 360; h += 60)
                              HSVColor.fromAHSV(1, h % 360, 1, 1).toColor(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: hsv.hue / 360 * ancho - 12,
                      child: _Punto(puro, tamano: 24),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hsv.toColor(),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: hex,
                maxLength: 7,
                decoration: const InputDecoration(
                  prefixText: '# ',
                  hintText: 'Pega el código, ej. 14B8A6',
                  counterText: '',
                ),
                onChanged: (v) {
                  final limpio = v.replaceAll('#', '').trim();
                  if (limpio.length != 6) return;
                  final n = int.tryParse(limpio, radix: 16);
                  if (n != null) onHex(Color(0xFF000000 | n));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Punto extends StatelessWidget {
  final Color color;
  final double tamano;
  const _Punto(this.color, {this.tamano = 22});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 4),
        ],
      ),
    ),
  );
}

/// Cómo se verá la portada del colegio con el color elegido.
class _Vista extends StatelessWidget {
  final Color color;
  final String nombre;
  final String? detalle;
  const _Vista(this.color, this.nombre, this.detalle);

  @override
  Widget build(BuildContext context) {
    final tinta = textoSobre(color);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color,
            Color.lerp(color, Colors.black, esClaro(color) ? .06 : .18)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombre,
            style: TextStyle(
              color: tinta,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (detalle != null)
            Text(
              detalle!,
              style: TextStyle(
                color: tinta.withValues(alpha: .75),
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final t in ['Cursos', 'Asistencia'])
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tinta.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: tinta,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
