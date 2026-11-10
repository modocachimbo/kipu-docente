import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/evaluacion_db.dart';
import '../data/instrumentos.dart';
import '../data/paises.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'cursos.dart' show confirmar;
import 'evaluacion.dart' show numeroCorto;

const _linea = Color(0xFFE6E7F0);
const _rojo = Color(0xFFC2334A);

double? _leerNumero(String s) =>
    double.tryParse(s.replaceAll(',', '.').replaceAll('%', '').trim());

// ═════════════════════════════ EDITOR ═════════════════════════════

/// Crear o editar una rúbrica, lista de cotejo o escala de valoración.
/// Devuelve el instrumento al guardar, o null si se cancela.
class EditorInstrumento extends StatefulWidget {
  final Instrumento inicial;
  final bool nuevo;
  const EditorInstrumento({
    super.key,
    required this.inicial,
    this.nuevo = false,
  });

  @override
  State<EditorInstrumento> createState() => _EditorInstrumentoState();
}

class _EditorInstrumentoState extends State<EditorInstrumento> {
  late Instrumento _x = widget.inicial;
  bool _cambios = false;
  bool _saliendo = false;
  List<String> _errores = const [];

  /// Sube cuando se reemplazan varios campos de golpe (una plantilla de
  /// niveles, mover filas) para que los campos de texto se redibujen.
  int _v = 0;

  bool get _rubrica => _x.tipo == TipoInstrumento.rubrica;
  bool get _cotejo => _x.tipo == TipoInstrumento.cotejo;

  void _set(Instrumento n, {bool refrescar = false}) => setState(() {
    _x = n;
    _cambios = true;
    _errores = const [];
    if (refrescar) _v++;
  });

  void _item(int i, ItemInstrumento it) =>
      _set(_x.copiar(items: [..._x.items]..[i] = it));

  void _agregarItem() {
    final n = _x.items.length;
    _set(
      _x.copiar(
        items: [
          ..._x.items,
          ItemInstrumento(
            id: nuevoId(),
            texto: '',
            peso: _rubrica
                ? (n == 0 ? 100 : (100 / (n + 1)).roundToDouble())
                : 1,
            descriptores: _rubrica ? List.filled(_x.escala.length, '') : const [],
          ),
        ],
      ),
    );
  }

  void _quitarItem(int i) =>
      _set(_x.copiar(items: [..._x.items]..removeAt(i)), refrescar: true);

  void _moverItem(int i, int paso) {
    final j = i + paso;
    if (j < 0 || j >= _x.items.length) return;
    final l = [..._x.items];
    final t = l[i];
    l[i] = l[j];
    l[j] = t;
    _set(_x.copiar(items: l), refrescar: true);
  }

  /// Cambia los niveles y ajusta los descriptores de la rúbrica.
  void _niveles(List<NivelInstrumento> n) {
    _set(
      _x.copiar(
        escala: n,
        items: _rubrica
            ? [
                for (final it in _x.items)
                  it.copiar(
                    descriptores: [
                      for (var k = 0; k < n.length; k++)
                        k < it.descriptores.length ? it.descriptores[k] : '',
                    ],
                  ),
              ]
            : _x.items,
      ),
      refrescar: true,
    );
  }

  void _nivel(int k, NivelInstrumento n) =>
      _set(_x.copiar(escala: [..._x.escala]..[k] = n));

  void _quitarNivel(int k) {
    if (_x.escala.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hacen falta al menos 2 niveles')),
      );
      return;
    }
    _set(
      _x.copiar(
        escala: [..._x.escala]..removeAt(k),
        items: _rubrica
            ? [
                for (final it in _x.items)
                  it.copiar(
                    descriptores: [
                      for (var j = 0; j < it.descriptores.length; j++)
                        if (j != k) it.descriptores[j],
                    ],
                  ),
              ]
            : _x.items,
      ),
      refrescar: true,
    );
  }

  void _agregarNivel() {
    final e = _x.escala;
    if (_rubrica) {
      // Las columnas de la rúbrica van de menor a mayor: el nuevo es el mejor.
      final p = e.isEmpty ? 1.0 : _x.puntosMax + 1;
      _niveles([...e, NivelInstrumento('Nivel ${e.length + 1}', p)]);
    } else {
      // En la escala el mejor va arriba: el nuevo es el más bajo.
      final p = e.isEmpty ? 0.0 : (_x.puntosMin - 1).clamp(0, 999).toDouble();
      _niveles([...e, NivelInstrumento('Nivel ${e.length + 1}', p)]);
    }
  }

  void _guardar() {
    final limpio = _x.copiar(
      nombre: _x.nombre.trim(),
      descripcion: _x.descripcion.trim(),
      area: _x.area.trim(),
      items: [
        for (final it in _x.items)
          it.copiar(
            texto: it.texto.trim(),
            descriptores: [for (final d in it.descriptores) d.trim()],
          ),
      ],
      escala: [
        for (final n in _x.escala) NivelInstrumento(n.nombre.trim(), n.puntos),
      ],
    );
    final err = limpio.validar();
    if (err.isNotEmpty) {
      setState(() => _errores = err);
      return;
    }
    setState(() => _saliendo = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Navigator.pop(context, limpio),
    );
  }

  Future<void> _salir() async {
    if (await confirmar(
      context,
      '¿Salir sin guardar?',
      'Se perderán los cambios que hiciste.',
      accion: 'Salir',
    )) {
      setState(() => _saliendo = true);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pop(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = _x.tipo.nombre.toLowerCase();
    return PopScope<Instrumento>(
      canPop: !_cambios || _saliendo,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.nuevo ? 'Nueva $tipo' : 'Editar $tipo'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _rubrica ? 1200 : 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              children: [
                if (_errores.isNotEmpty) _Errores(_errores),
                _Seccion(
                  titulo: 'DATOS',
                  child: _Datos(x: _x, v: _v, onCambio: _set),
                ),
                if (!_rubrica)
                  _Seccion(
                    titulo: _cotejo ? 'TIPO DE LISTA' : 'TIPO DE ESCALA',
                    child: _TipoLista(x: _x, onCambio: _set),
                  ),
                if (_cotejo)
                  _Seccion(
                    titulo: 'ETIQUETAS',
                    child: _Etiquetas(
                      x: _x,
                      v: _v,
                      onPreset: _niveles,
                      onNivel: _nivel,
                    ),
                  )
                else if (!_rubrica)
                  _Seccion(
                    titulo: 'NIVELES DE LA ESCALA (${_x.escala.length}) · EL MEJOR ARRIBA',
                    child: _NivelesEscala(
                      x: _x,
                      v: _v,
                      onPreset: _niveles,
                      onNivel: _nivel,
                      onQuitar: _quitarNivel,
                      onAgregar: _agregarNivel,
                    ),
                  ),
                if (_rubrica)
                  _Seccion(
                    titulo: 'RÚBRICA · ${_x.items.length} CRITERIOS × ${_x.escala.length} NIVELES',
                    child: _TablaRubrica(
                      x: _x,
                      v: _v,
                      onCambio: _set,
                      onItem: _item,
                      onQuitarItem: _quitarItem,
                      onMoverItem: _moverItem,
                      onAgregarItem: _agregarItem,
                      onPreset: _niveles,
                      onNivel: _nivel,
                      onQuitarNivel: _quitarNivel,
                      onAgregarNivel: _agregarNivel,
                    ),
                  )
                else
                  _Seccion(
                    titulo: 'ÍTEMS (${_x.items.length})',
                    child: _Items(
                      x: _x,
                      v: _v,
                      onItem: _item,
                      onQuitar: _quitarItem,
                      onMover: _moverItem,
                      onAgregar: _agregarItem,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Text(
                    switch (_x.tipo) {
                      TipoInstrumento.cotejo =>
                        'Nota de la celda = ítems logrados ÷ ítems aplicables × '
                            'escala de la columna. ${_x.noObservado ? '«No observado» no cuenta. ' : ''}'
                            '${_x.ponderada ? 'Cada ítem vale sus puntos.' : ''}',
                      TipoInstrumento.escala =>
                        'Nota de la celda = puntos obtenidos ÷ puntos posibles × '
                            'escala de la columna.',
                      TipoInstrumento.rubrica =>
                        'Con AD/A/B/C y 4 niveles, la nota es el nivel promedio. '
                            'Con nota numérica: puntos obtenidos ÷ máximo × nota máxima.',
                    },
                    style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Errores extends StatelessWidget {
  final List<String> errores;
  const _Errores(this.errores);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFCE8EB),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Falta completar:',
          style: TextStyle(fontWeight: FontWeight.w600, color: _rojo),
        ),
        for (final e in errores) Text('• $e'),
      ],
    ),
  );
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: .6,
            fontWeight: FontWeight.w600,
            color: KipuColores.gris,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _Datos extends StatelessWidget {
  final Instrumento x;
  final int v;
  final void Function(Instrumento, {bool refrescar}) onCambio;
  const _Datos({required this.x, required this.v, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: ValueKey('nombre-$v'),
          initialValue: x.nombre,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej. Exposición sobre el ciclo del agua',
          ),
          onChanged: (t) => onCambio(x.copiar(nombre: t)),
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey('desc-$v'),
          initialValue: x.descripcion,
          textCapitalization: TextCapitalization.sentences,
          minLines: 1,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descripción o indicaciones (opcional)',
          ),
          onChanged: (t) => onCambio(x.copiar(descripcion: t)),
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey('area-$v'),
          initialValue: x.area,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Área o curso (opcional)',
            hintText: 'Ej. Ciencia y Tecnología',
          ),
          onChanged: (t) => onCambio(x.copiar(area: t)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Para:', style: TextStyle(color: KipuColores.gris)),
            for (final n in nivelesEducativos)
              FilterChip(
                label: Text(n),
                selected: x.niveles.contains(n),
                selectedColor: KipuColores.moradoClaro,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: x.niveles.contains(n) ? KipuColores.morado : _linea,
                ),
                onSelected: (on) => onCambio(
                  x.copiar(
                    niveles: [
                      for (final m in nivelesEducativos)
                        if (m == n ? on : x.niveles.contains(m)) m,
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Opcion extends StatelessWidget {
  final String titulo;
  final String detalle;
  final bool activo;
  final VoidCallback onTap;
  const _Opcion({
    required this.titulo,
    required this.detalle,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: activo ? KipuColores.fondo : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: activo ? KipuColores.morado : _linea,
          width: activo ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activo ? KipuColores.morado : Colors.white,
                  border: Border.all(
                    color: activo ? KipuColores.morado : const Color(0xFFB0B4D0),
                    width: 1.6,
                  ),
                ),
                child: activo
                    ? const Center(
                        child: KipuIcon(KipuIcono.check, size: 14, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TipoLista extends StatelessWidget {
  final Instrumento x;
  final void Function(Instrumento, {bool refrescar}) onCambio;
  const _TipoLista({required this.x, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    final cotejo = x.tipo == TipoInstrumento.cotejo;
    return Column(
      children: [
        _Opcion(
          titulo: cotejo ? 'Simple' : 'Escala común',
          detalle: cotejo
              ? 'Cada ítem se marca como logrado o no. Nota = % de ítems logrados.'
              : 'Todos los ítems se valoran con los mismos niveles y valen igual.',
          activo: !x.noObservado && !x.ponderada,
          onTap: () => onCambio(x.copiar(noObservado: false, ponderada: false)),
        ),
        _Opcion(
          titulo: 'Con «No observado»',
          detalle:
              'Añade una opción más; los ítems no observados no cuentan en la '
              'nota. Útil en Inicial y en la observación del día a día.',
          activo: x.noObservado,
          onTap: () => onCambio(x.copiar(noObservado: !x.noObservado)),
        ),
        _Opcion(
          titulo: 'Ponderada',
          detalle: cotejo
              ? 'Cada ítem tiene sus puntos. Nota = puntos logrados ÷ total.'
              : 'Cada ítem tiene un peso: los importantes cuentan más.',
          activo: x.ponderada,
          onTap: () => onCambio(x.copiar(ponderada: !x.ponderada)),
        ),
      ],
    );
  }
}

Widget _presets(
  List<PresetNiveles> presets,
  List<NivelInstrumento> actual,
  ValueChanged<List<NivelInstrumento>> onPreset,
) {
  bool igual(List<NivelInstrumento> a) =>
      a.length == actual.length &&
      [
        for (var i = 0; i < a.length; i++)
          a[i].nombre == actual[i].nombre && a[i].puntos == actual[i].puntos,
      ].every((b) => b);
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final p in presets)
        ChoiceChip(
          label: Text(p.nombre),
          selected: igual(p.niveles),
          showCheckmark: false,
          selectedColor: KipuColores.moradoClaro,
          backgroundColor: KipuColores.fondo,
          side: BorderSide.none,
          onSelected: (_) => onPreset(p.niveles),
        ),
    ],
  );
}

class _Etiquetas extends StatelessWidget {
  final Instrumento x;
  final int v;
  final ValueChanged<List<NivelInstrumento>> onPreset;
  final void Function(int, NivelInstrumento) onNivel;
  const _Etiquetas({
    required this.x,
    required this.v,
    required this.onPreset,
    required this.onNivel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _presets(etiquetasCotejo, x.escala, onPreset),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var k = 0; k < x.escala.length && k < 2; k++) ...[
              if (k > 0) const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  key: ValueKey('et-$k-$v'),
                  initialValue: x.escala[k].nombre,
                  decoration: InputDecoration(
                    labelText: k == 0 ? 'Positiva' : 'Negativa',
                  ),
                  onChanged: (t) =>
                      onNivel(k, NivelInstrumento(t, x.escala[k].puntos)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CampoPuntos extends StatelessWidget {
  final Key campo;
  final double valor;
  final String sufijo;
  final ValueChanged<double> onCambio;
  final double ancho;
  const _CampoPuntos({
    required this.campo,
    required this.valor,
    required this.onCambio,
    this.sufijo = 'pts',
    this.ancho = 92,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: ancho,
    child: TextFormField(
      key: campo,
      initialValue: numeroCorto(valor),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        isDense: true,
        suffixText: sufijo,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      onChanged: (t) {
        final n = _leerNumero(t);
        if (n != null && n >= 0) onCambio(n);
      },
    ),
  );
}

class _NivelesEscala extends StatelessWidget {
  final Instrumento x;
  final int v;
  final ValueChanged<List<NivelInstrumento>> onPreset;
  final void Function(int, NivelInstrumento) onNivel;
  final ValueChanged<int> onQuitar;
  final VoidCallback onAgregar;
  const _NivelesEscala({
    required this.x,
    required this.v,
    required this.onPreset,
    required this.onNivel,
    required this.onQuitar,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _presets(nivelesEscala, x.escala, onPreset),
        const SizedBox(height: 12),
        for (var k = 0; k < x.escala.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('niv-$k-$v'),
                    initialValue: x.escala[k].nombre,
                    decoration: const InputDecoration(isDense: true),
                    onChanged: (t) =>
                        onNivel(k, NivelInstrumento(t, x.escala[k].puntos)),
                  ),
                ),
                const SizedBox(width: 8),
                _CampoPuntos(
                  campo: ValueKey('nivp-$k-$v'),
                  valor: x.escala[k].puntos,
                  onCambio: (p) =>
                      onNivel(k, NivelInstrumento(x.escala[k].nombre, p)),
                ),
                IconButton(
                  tooltip: 'Quitar nivel',
                  onPressed: () => onQuitar(k),
                  icon: const KipuIcon(KipuIcono.borrar, size: 20, color: KipuColores.gris),
                ),
              ],
            ),
          ),
        OutlinedButton(onPressed: onAgregar, child: const Text('+ Añadir nivel')),
      ],
    );
  }
}

class _Items extends StatelessWidget {
  final Instrumento x;
  final int v;
  final void Function(int, ItemInstrumento) onItem;
  final ValueChanged<int> onQuitar;
  final void Function(int, int) onMover;
  final VoidCallback onAgregar;
  const _Items({
    required this.x,
    required this.v,
    required this.onItem,
    required this.onQuitar,
    required this.onMover,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    final total = x.items.fold<double>(0, (s, i) => s + i.peso);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < x.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}.',
                    style: const TextStyle(color: KipuColores.gris),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('it-${x.items[i].id}-$v'),
                    initialValue: x.items[i].texto,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Lo que debe hacer o mostrar el estudiante',
                    ),
                    onChanged: (t) => onItem(i, x.items[i].copiar(texto: t)),
                  ),
                ),
                if (x.ponderada) ...[
                  const SizedBox(width: 8),
                  _CampoPuntos(
                    campo: ValueKey('itp-${x.items[i].id}-$v'),
                    valor: x.items[i].peso,
                    sufijo: x.tipo == TipoInstrumento.cotejo ? 'pts' : 'peso',
                    onCambio: (p) => onItem(i, x.items[i].copiar(peso: p)),
                  ),
                ],
                PopupMenuButton<String>(
                  tooltip: 'Opciones del ítem',
                  icon: const Icon(Icons.more_vert, color: KipuColores.gris),
                  onSelected: (a) {
                    if (a == 'arriba') {
                      onMover(i, -1);
                    } else if (a == 'abajo') {
                      onMover(i, 1);
                    } else {
                      onQuitar(i);
                    }
                  },
                  itemBuilder: (_) => [
                    if (i > 0)
                      const PopupMenuItem(value: 'arriba', child: Text('Subir')),
                    if (i < x.items.length - 1)
                      const PopupMenuItem(value: 'abajo', child: Text('Bajar')),
                    const PopupMenuItem(value: 'quitar', child: Text('Quitar')),
                  ],
                ),
              ],
            ),
          ),
        if (x.ponderada && x.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 24),
            child: Text(
              'Total: ${numeroCorto(total)} ${x.tipo == TipoInstrumento.cotejo ? 'puntos' : ''}',
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
          ),
        OutlinedButton(onPressed: onAgregar, child: const Text('+ Añadir ítem')),
      ],
    );
  }
}

class _TablaRubrica extends StatelessWidget {
  final Instrumento x;
  final int v;
  final void Function(Instrumento, {bool refrescar}) onCambio;
  final void Function(int, ItemInstrumento) onItem;
  final ValueChanged<int> onQuitarItem;
  final void Function(int, int) onMoverItem;
  final VoidCallback onAgregarItem;
  final ValueChanged<List<NivelInstrumento>> onPreset;
  final void Function(int, NivelInstrumento) onNivel;
  final ValueChanged<int> onQuitarNivel;
  final VoidCallback onAgregarNivel;
  const _TablaRubrica({
    required this.x,
    required this.v,
    required this.onCambio,
    required this.onItem,
    required this.onQuitarItem,
    required this.onMoverItem,
    required this.onAgregarItem,
    required this.onPreset,
    required this.onNivel,
    required this.onQuitarNivel,
    required this.onAgregarNivel,
  });

  static const _anchoCriterio = 170.0;
  static const _anchoNivel = 190.0;

  Future<void> _editarDescriptor(BuildContext context, int i, int k) async {
    final it = x.items[i];
    final c = TextEditingController(
      text: k < it.descriptores.length ? it.descriptores[k] : '',
    );
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${it.texto.isEmpty ? 'Criterio ${i + 1}' : it.texto} · ${x.escala[k].nombre}',
        ),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: c,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Qué hace el estudiante en este nivel',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
    c.dispose();
    if (r == null) return;
    final d = [
      for (var j = 0; j < x.escala.length; j++)
        j == k ? r : (j < it.descriptores.length ? it.descriptores[j] : ''),
    ];
    onItem(i, it.copiar(descriptores: d));
  }

  @override
  Widget build(BuildContext context) {
    final suma = x.items.fold<double>(0, (s, i) => s + i.peso);
    final auto = !x.ponderada;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Porcentajes automáticos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Switch(
              value: auto,
              onChanged: (on) {
                if (on) {
                  onCambio(x.copiar(ponderada: false));
                } else {
                  // Al pasar a manual, repartimos 100 % para empezar.
                  final n = x.items.length;
                  onCambio(
                    x.copiar(
                      ponderada: true,
                      items: [
                        for (final it in x.items)
                          it.copiar(peso: n == 0 ? 0 : (100 / n).roundToDouble()),
                      ],
                    ),
                    refrescar: true,
                  );
                }
              },
            ),
          ],
        ),
        Text(
          auto
              ? 'Todos los criterios valen lo mismo.'
              : 'Escribe el % de cada criterio. Suman ${numeroCorto(suma)} %'
                    '${(suma - 100).abs() > .5 ? ' (lo ideal es 100 %; se usarán en proporción)' : ''}.',
          style: TextStyle(
            fontSize: 12.5,
            color: !auto && (suma - 100).abs() > .5 ? _rojo : KipuColores.gris,
          ),
        ),
        const SizedBox(height: 12),
        _presets(nivelesRubrica, x.escala, onPreset),
        const SizedBox(height: 6),
        const Text(
          'Toca un descriptor para escribirlo. Los niveles van de menor a mayor logro.',
          style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: niveles
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: _anchoCriterio + 8),
                  for (var k = 0; k < x.escala.length; k++)
                    Container(
                      width: _anchoNivel,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.fromLTRB(8, 6, 2, 8),
                      decoration: BoxDecoration(
                        color: KipuColores.moradoClaro,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey('rn-$k-$v'),
                                  initialValue: x.escala[k].nombre,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                  onChanged: (t) => onNivel(
                                    k,
                                    NivelInstrumento(t, x.escala[k].puntos),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Quitar nivel',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => onQuitarNivel(k),
                                icon: const KipuIcon(
                                  KipuIcono.borrar,
                                  size: 18,
                                  color: KipuColores.gris,
                                ),
                              ),
                            ],
                          ),
                          _CampoPuntos(
                            campo: ValueKey('rp-$k-$v'),
                            valor: x.escala[k].puntos,
                            ancho: 100,
                            onCambio: (p) => onNivel(
                              k,
                              NivelInstrumento(x.escala[k].nombre, p),
                            ),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton(
                    onPressed: onAgregarNivel,
                    child: const Text('+ Nivel'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Filas: criterios
              for (var i = 0; i < x.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: _anchoCriterio,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.fromLTRB(8, 4, 0, 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: _linea),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey('rc-${x.items[i].id}-$v'),
                                      initialValue: x.items[i].texto,
                                      minLines: 1,
                                      maxLines: 4,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        hintText: 'Criterio',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                      onChanged: (t) => onItem(
                                        i,
                                        x.items[i].copiar(texto: t),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    tooltip: 'Opciones del criterio',
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 20,
                                      color: KipuColores.gris,
                                    ),
                                    onSelected: (a) {
                                      if (a == 'arriba') {
                                        onMoverItem(i, -1);
                                      } else if (a == 'abajo') {
                                        onMoverItem(i, 1);
                                      } else {
                                        onQuitarItem(i);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      if (i > 0)
                                        const PopupMenuItem(
                                          value: 'arriba',
                                          child: Text('Subir'),
                                        ),
                                      if (i < x.items.length - 1)
                                        const PopupMenuItem(
                                          value: 'abajo',
                                          child: Text('Bajar'),
                                        ),
                                      const PopupMenuItem(
                                        value: 'quitar',
                                        child: Text('Quitar criterio'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (!auto)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _CampoPuntos(
                                    campo: ValueKey('rw-${x.items[i].id}-$v'),
                                    valor: x.items[i].peso,
                                    sufijo: '%',
                                    ancho: 90,
                                    onCambio: (p) =>
                                        onItem(i, x.items[i].copiar(peso: p)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        for (var k = 0; k < x.escala.length; k++)
                          Container(
                            width: _anchoNivel,
                            constraints: const BoxConstraints(minHeight: 110),
                            margin: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: _linea),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _editarDescriptor(context, i, k),
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 110),
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.topLeft,
                                  child: Builder(
                                    builder: (_) {
                                      final d = k < x.items[i].descriptores.length
                                          ? x.items[i].descriptores[k]
                                          : '';
                                      return Text(
                                        d.isEmpty ? 'Toca para escribir…' : d,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: d.isEmpty
                                              ? const Color(0xFFB0B4D0)
                                              : KipuColores.tinta,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: onAgregarItem,
            child: const Text('+ Criterio'),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════ EVALUAR ═════════════════════════════

/// Abre el instrumento de una columna para evaluar estudiante por estudiante.
Future<void> evaluarConInstrumento(
  BuildContext context, {
  required RegistroColumna columna,
  required Instrumento instrumento,
  required Escala escala,
  required List<Estudiante> estudiantes,
  required int inicio,
  required Map<int, int> equipos,
  required Color color,
}) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EvaluarInstrumento(
      columna: columna,
      instrumento: instrumento,
      escala: escala,
      estudiantes: estudiantes,
      inicio: inicio,
      equipos: equipos,
      color: color,
    ),
  ),
);

class EvaluarInstrumento extends StatefulWidget {
  final RegistroColumna columna;
  final Instrumento instrumento;
  final Escala escala;
  final List<Estudiante> estudiantes;
  final int inicio;
  final Map<int, int> equipos;
  final Color color;

  const EvaluarInstrumento({
    super.key,
    required this.columna,
    required this.instrumento,
    required this.escala,
    required this.estudiantes,
    required this.inicio,
    required this.equipos,
    required this.color,
  });

  @override
  State<EvaluarInstrumento> createState() => _EvaluarInstrumentoState();
}

class _EvaluarInstrumentoState extends State<EvaluarInstrumento> {
  late int _i = widget.inicio.clamp(0, widget.estudiantes.length - 1).toInt();
  Map<int, Marcas>? _todas;
  List<double>? _tramos;
  Map<String, int> _m = {};
  final _comentario = TextEditingController();
  bool _guardando = false;
  final _scroll = ScrollController();

  Instrumento get _ins => widget.instrumento;
  Estudiante get _e => widget.estudiantes[_i];
  bool get _equipo =>
      widget.columna.enEquipo && widget.equipos[_e.id] != null;
  List<Estudiante> get _integrantes => _equipo
      ? widget.estudiantes
            .where((x) => widget.equipos[x.id] == widget.equipos[_e.id])
            .toList()
      : [_e];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final m = await db.leerMarcas(widget.columna.id);
    final t = widget.escala.numerica ? null : await db.leerTramos(widget.escala);
    if (!mounted) return;
    setState(() {
      _todas = m;
      _tramos = t;
      _abrir();
    });
  }

  void _abrir() {
    final m = _todas?[_e.id] ?? const Marcas();
    _m = {...m.porItem};
    _comentario.text = m.comentario;
  }

  @override
  void dispose() {
    _comentario.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Resultado? get _resultado => calcular(_ins, Marcas(_m));

  String? get _valor {
    final r = _resultado;
    return r == null ? null : valorEnEscala(_ins, r, widget.escala, tramos: _tramos);
  }

  Future<void> _guardar({bool borrar = false}) async {
    if (_guardando) return;
    setState(() => _guardando = true);
    final marcas = borrar ? null : Marcas({..._m}, _comentario.text);
    final valor = borrar ? null : _valor;
    final ids = [for (final x in _integrantes) x.id];
    await db.guardarMarcas(widget.columna.id, ids, marcas);
    for (final id in ids) {
      await db.ponerNota(widget.columna.id, id, valor);
      if (marcas == null || marcas.vacia) {
        _todas?.remove(id);
      } else {
        _todas?[id] = marcas;
      }
    }
    if (!mounted) return;
    setState(() => _guardando = false);
    _mover(1);
  }

  void _mover(int paso) {
    var j = _i + paso;
    final eq = _equipo ? widget.equipos[_e.id] : null;
    while (eq != null &&
        j >= 0 &&
        j < widget.estudiantes.length &&
        widget.equipos[widget.estudiantes[j].id] == eq) {
      j += paso;
    }
    if (j < 0) return;
    if (j >= widget.estudiantes.length) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _i = j;
      _abrir();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _marcar(String item, int k) => setState(() {
    if (_m[item] == k) {
      _m.remove(item);
    } else {
      _m[item] = k;
    }
  });

  /// Marca todos los ítems sin marcar con el mejor nivel: lo más rápido
  /// cuando casi todo está bien y solo hay que corregir un par.
  void _todoMejor() => setState(() {
    final mejor = _ins.tipo == TipoInstrumento.rubrica
        ? _ins.escala.length - 1
        : 0;
    for (final it in _ins.items) {
      _m.putIfAbsent(it.id, () => mejor);
    }
  });

  @override
  Widget build(BuildContext context) {
    final cargando = _todas == null;
    final base = widget.color;
    final r = _resultado;
    final valor = _valor;
    final total = widget.estudiantes.length;
    final mejor = _ins.tipo == TipoInstrumento.rubrica
        ? _ins.escala.last.nombre
        : _ins.escala.first.nombre;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tituloNombre(_e.apellidos)}, ${_e.nombres}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              '${_i + 1} de $total · ${widget.columna.codigo} · ${_ins.nombre}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
          ],
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _ResultadoVivo(
                      valor: valor,
                      escala: widget.escala,
                      detalle: r == null
                          ? 'Marca los ítems para calcular la nota'
                          : describirResultado(_ins, r),
                      color: base,
                      equipo: _equipo
                          ? 'Equipo ${widget.equipos[_e.id]} · se guarda para '
                                '${_integrantes.length} integrantes'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _todoMejor,
                        child: Text('Lo que falta: «$mejor»'),
                      ),
                    ),
                    for (final (n, it) in _ins.items.indexed)
                      _ins.tipo == TipoInstrumento.rubrica
                          ? _CriterioEvaluar(
                              n: n,
                              item: it,
                              ins: _ins,
                              marca: _m[it.id],
                              color: base,
                              onMarca: (k) => _marcar(it.id, k),
                            )
                          : _ItemEvaluar(
                              n: n,
                              item: it,
                              ins: _ins,
                              marca: _m[it.id],
                              color: base,
                              onMarca: (k) => _marcar(it.id, k),
                            ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _comentario,
                      minLines: 2,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Comentario (opcional)',
                        hintText:
                            'Lo que observaste. Te servirá para la conclusión '
                            'descriptiva.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _linea)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Anterior',
                onPressed: _i > 0 ? () => _mover(-1) : null,
                icon: KipuIcon(KipuIcono.izquierda, color: KipuColores.tinta),
              ),
              TextButton(
                onPressed: cargando || _guardando
                    ? null
                    : () => _guardar(borrar: true),
                child: const Text('Borrar'),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: base),
                onPressed: cargando || _guardando ? null : _guardar,
                child: Text(
                  _i + 1 >= total ? 'Guardar y terminar' : 'Guardar y seguir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultadoVivo extends StatelessWidget {
  final String? valor;
  final Escala escala;
  final String detalle;
  final Color color;
  final String? equipo;
  const _ResultadoVivo({
    required this.valor,
    required this.escala,
    required this.detalle,
    required this.color,
    this.equipo,
  });

  @override
  Widget build(BuildContext context) {
    Color tono = color;
    if (valor != null && !escala.numerica) {
      final v = escala.valores.where((x) => x.codigo == valor).firstOrNull;
      if (v != null) tono = Color(v.color);
    } else if (valor != null && escala.aprueba != null) {
      final n = double.tryParse(valor!);
      if (n != null && n < escala.aprueba!) tono = _rojo;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 64),
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: valor == null ? KipuColores.fondo : tono.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                valor ?? '—',
                style: TextStyle(
                  fontSize: valor != null && valor!.length > 3 ? 16 : 24,
                  fontWeight: FontWeight.w800,
                  color: valor == null ? KipuColores.gris : tono,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota en la columna (${escala.nombre})',
                  style: const TextStyle(fontSize: 12, color: KipuColores.gris),
                ),
                Text(detalle, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (equipo != null)
                  Text(
                    equipo!,
                    style: TextStyle(fontSize: 12.5, color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemEvaluar extends StatelessWidget {
  final int n;
  final ItemInstrumento item;
  final Instrumento ins;
  final int? marca;
  final Color color;
  final ValueChanged<int> onMarca;
  const _ItemEvaluar({
    required this.n,
    required this.item,
    required this.ins,
    required this.marca,
    required this.color,
    required this.onMarca,
  });

  @override
  Widget build(BuildContext context) {
    Widget opcion(int k, String t, Color c) {
      final on = marca == k;
      return ChoiceChip(
        label: Text(t),
        selected: on,
        showCheckmark: false,
        selectedColor: c,
        backgroundColor: Colors.white,
        side: BorderSide(color: on ? c : _linea),
        labelStyle: TextStyle(
          color: on ? Colors.white : KipuColores.tinta,
          fontWeight: on ? FontWeight.w600 : FontWeight.w400,
        ),
        onSelected: (_) => onMarca(k),
      );
    }

    final niveles = ins.escala.length;
    Color tono(int k) {
      // Del color base (mejor) a rojo (peor).
      if (niveles <= 1) return color;
      return Color.lerp(color, _rojo, k / (niveles - 1))!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: marca == null ? Colors.white : color.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${n + 1}. ', style: const TextStyle(color: KipuColores.gris)),
              Expanded(
                child: Text(item.texto, style: const TextStyle(fontSize: 15)),
              ),
              if (ins.ponderada)
                Text(
                  '${numeroCorto(item.peso)} pts',
                  style: const TextStyle(fontSize: 12, color: KipuColores.gris),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var k = 0; k < niveles; k++)
                opcion(k, ins.escala[k].nombre, tono(k)),
              if (ins.noObservado)
                opcion(marcaNoObservado, 'No observado', KipuColores.gris),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriterioEvaluar extends StatelessWidget {
  final int n;
  final ItemInstrumento item;
  final Instrumento ins;
  final int? marca;
  final Color color;
  final ValueChanged<int> onMarca;
  const _CriterioEvaluar({
    required this.n,
    required this.item,
    required this.ins,
    required this.marca,
    required this.color,
    required this.onMarca,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${n + 1}. ${item.texto}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (ins.ponderada)
                Text(
                  '${numeroCorto(item.peso)} %',
                  style: const TextStyle(fontSize: 12, color: KipuColores.gris),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Del mejor nivel al más bajo, como se lee una rúbrica al evaluar.
          for (var k = ins.escala.length - 1; k >= 0; k--)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: marca == k ? color.withValues(alpha: .1) : KipuColores.fondo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: marca == k ? color : Colors.transparent,
                    width: 1.6,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onMarca(k),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            ins.escala[k].nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: marca == k ? color : KipuColores.tinta,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            k < item.descriptores.length &&
                                    item.descriptores[k].isNotEmpty
                                ? item.descriptores[k]
                                : '—',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
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
