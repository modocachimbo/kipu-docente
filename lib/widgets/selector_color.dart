import 'package:flutter/material.dart';

import '../theme.dart';
import 'kipu_icono.dart';
import 'ventana.dart';

/// Colores claros (pasteles) llevan texto oscuro para que se lea bien.
bool esClaro(Color c) => c.computeLuminance() > .4;

Color textoSobre(Color fondo) =>
    esClaro(fondo) ? KipuColores.tinta : Colors.white;

/// El mismo color, oscurecido si es pastel, para usarlo como texto sobre blanco.
Color tonoTexto(Color c) => esClaro(c) ? Color.lerp(c, Colors.black, .55)! : c;

/// Colores vivos en varias tonalidades (índigo, azul italiano, turquesa…).
const coloresSolidos = <(String, Color)>[
  ('Índigo', Color(0xFF4F46E5)),
  ('Índigo noche', Color(0xFF3730A3)),
  ('Azul italiano', Color(0xFF1F5FD1)),
  ('Cobalto', Color(0xFF0047AB)),
  ('Zafiro', Color(0xFF1E40AF)),
  ('Azul cielo', Color(0xFF0EA5E9)),
  ('Celeste', Color(0xFF0891B2)),
  ('Turquesa', Color(0xFF14B8A6)),
  ('Turquesa mar', Color(0xFF0D9488)),
  ('Esmeralda', Color(0xFF10B981)),
  ('Jade', Color(0xFF059669)),
  ('Bosque', Color(0xFF15803D)),
  ('Lima', Color(0xFF65A30D)),
  ('Ámbar', Color(0xFFF59E0B)),
  ('Mostaza', Color(0xFFCA8A04)),
  ('Naranja', Color(0xFFF97316)),
  ('Coral', Color(0xFFF2654A)),
  ('Carmín', Color(0xFFDC2626)),
  ('Rubí', Color(0xFFBE123C)),
  ('Frambuesa', Color(0xFFDB2777)),
  ('Fucsia', Color(0xFFC026D3)),
  ('Púrpura', Color(0xFF9333EA)),
  ('Violeta', Color(0xFF7C3AED)),
  ('Medianoche', Color(0xFF1E1B4B)),
];

/// Pasteles vivos pero suaves para fondo, con texto oscuro.
const coloresPasteles = <(String, Color)>[
  ('Rubor', Color(0xFFFECDD3)),
  ('Fresa', Color(0xFFFDA4AF)),
  ('Rosa', Color(0xFFF9A8D4)),
  ('Chicle', Color(0xFFF8B4D9)),
  ('Malva', Color(0xFFE9A8C9)),
  ('Coral', Color(0xFFFCA5A5)),
  ('Melocotón', Color(0xFFFFC4A3)),
  ('Durazno', Color(0xFFFDBA74)),
  ('Arena', Color(0xFFF5D0A9)),
  ('Mango', Color(0xFFFCD34D)),
  ('Limón', Color(0xFFFDE047)),
  ('Lima', Color(0xFFD9F99D)),
  ('Salvia', Color(0xFFA7D7B8)),
  ('Menta', Color(0xFF6EE7B7)),
  ('Agua', Color(0xFF5EEAD4)),
  ('Turquesa', Color(0xFF67E8F9)),
  ('Hielo', Color(0xFFBAE6FD)),
  ('Cielo', Color(0xFF7DD3FC)),
  ('Azul', Color(0xFF93C5FD)),
  ('Pervinca', Color(0xFFA5B4FC)),
  ('Lavanda', Color(0xFFC4B5FD)),
  ('Lila', Color(0xFFD8B4FE)),
  ('Orquídea', Color(0xFFF0ABFC)),
  ('Algodón', Color(0xFFFBCFE8)),
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
      spacing: 1,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final (nombre, c) in colores)
          InkWell(
            onTap: () => onTap(c),
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 58,
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
                  // Nombres de dos palabras van en dos líneas.
                  Text(
                    nombre,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.1,
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
