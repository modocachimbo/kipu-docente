import 'package:flutter/material.dart';

import '../data/academico.dart';
import '../data/calculo.dart';
import '../data/cneb.dart';
import '../data/columnas.dart';
import '../data/columnas_db.dart';
import '../data/database.dart';
import '../data/paises.dart';
import '../data/registro.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';

const _linea = Color(0xFFE6E7F0);
const _rojo = Color(0xFFC2334A);
const _verde = Color(0xFF0E7A5F);

/// Configura una columna calculada: qué calcula, qué columnas entran, los
/// pesos por grupo o la fórmula, y muestra cómo quedaría con 3 estudiantes.
class EditorCalculo extends StatefulWidget {
  final int cursoId;
  final int periodo;
  final int? columnaId;
  final Calculo calculo;
  final ConfigColumna cfg;
  final Escala salida;
  final Color base;
  final ValueChanged<Calculo> onCambio;

  const EditorCalculo({
    super.key,
    required this.cursoId,
    required this.periodo,
    this.columnaId,
    required this.calculo,
    required this.cfg,
    required this.salida,
    required this.base,
    required this.onCambio,
  });

  @override
  State<EditorCalculo> createState() => _EditorCalculoState();
}

class _EditorCalculoState extends State<EditorCalculo> {
  ConfigAcademica? _config;
  List<ColumnaDato> _todas = const [];
  List<(Estudiante, Desglose)>? _muestra;
  int _pedido = 0;

  Calculo get c => widget.calculo;
  Color get base => widget.base;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(EditorCalculo old) {
    super.didUpdateWidget(old);
    if (old.calculo.aJson().toString() != c.aJson().toString() ||
        old.salida.id != widget.salida.id ||
        old.cfg.aTexto() != widget.cfg.aTexto()) {
      _previa();
    }
  }

  Future<void> _cargar() async {
    final anio = await db.verAnioActivo().first;
    final config = await db.verConfigAcademica(anio).first;
    final todas = await db.columnasParaCalculo(widget.cursoId, config);
    if (!mounted) return;
    setState(() {
      _config = config;
      _todas = todas;
    });
    _previa();
  }

  Future<void> _previa() async {
    final config = _config;
    if (config == null) return;
    final n = ++_pedido;
    final r = await db.simularCalculo(
      cursoId: widget.cursoId,
      periodo: widget.periodo,
      columnaId: widget.columnaId,
      calculo: c,
      cfg: widget.cfg,
      escala: widget.salida.id,
      config: config,
    );
    if (mounted && n == _pedido) setState(() => _muestra = r);
  }

  ColumnaDato get _propia => ColumnaDato(
    id: widget.columnaId ?? -1,
    codigo: '',
    periodo: widget.periodo,
    orden: 1 << 30,
    tipo: 'calculada',
    escala: widget.salida,
  );

  List<ColumnaDato> get _entran => columnasDelCalculo(c, _propia, _todas);

  void _set(Calculo n) => widget.onCambio(n);

  Widget _etiqueta(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: KipuColores.gris,
      ),
    ),
  );

  Widget _chip(String t, bool on, VoidCallback tap) => ChoiceChip(
    label: Text(t),
    selected: on,
    showCheckmark: false,
    selectedColor: Color.lerp(base, Colors.white, .85),
    backgroundColor: Colors.white,
    side: BorderSide(color: on ? base : _linea),
    labelStyle: TextStyle(
      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
      color: KipuColores.tinta,
    ),
    onSelected: (_) => tap(),
  );

  @override
  Widget build(BuildContext context) {
    final letras = !widget.salida.numerica;
    final tipos = [
      TipoCalculo.promedio,
      if (letras) TipoCalculo.nivel,
      TipoCalculo.suma,
      TipoCalculo.maxima,
      TipoCalculo.minima,
      TipoCalculo.formula,
    ];
    final entran = _entran;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _etiqueta('¿Qué calcula?'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in tipos)
              _chip(t.nombre, c.tipo == t, () {
                var n = c.copiar(tipo: t);
                if (t == TipoCalculo.formula && c.formula.isEmpty) {
                  n = n.copiar(seleccion: Seleccion.todas);
                }
                _set(n);
              }),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 2),
          child: Text(
            c.tipo.ayuda,
            style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
          ),
        ),
        if (letras && c.tipo == TipoCalculo.promedio)
          _Aviso(
            base: base,
            texto:
                'El Minedu pide no promediar letras. Para AD, A, B, C usa '
                '«Nivel de la competencia»; si promedias, las letras se '
                'convierten con las equivalencias (AD = 19, A = 15…).',
          ),
        if (c.tipo == TipoCalculo.nivel) ...[
          _etiqueta('¿Cómo se decide el nivel?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in ModoNivel.values)
                _chip(m.nombre, c.nivel == m, () => _set(c.copiar(nivel: m))),
            ],
          ),
          if (c.nivel == ModoNivel.sugerida)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 2),
              child: Text(
                'Kipu pone la más frecuente; toca una celda para confirmarla o '
                'cambiarla.',
                style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
              ),
            ),
        ],
        if (c.tipo == TipoCalculo.formula)
          _Formula(
            tokens: c.formula,
            columnas: [
              for (final x in _todas)
                if (x.periodo == widget.periodo &&
                    x.tipo != 'calculada' &&
                    x.id != widget.columnaId)
                  x,
            ],
            base: base,
            onCambio: (t) => _set(c.copiar(formula: t)),
          )
        else ...[
          _etiqueta('¿Qué columnas entran?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                'Todas las del periodo',
                c.seleccion == Seleccion.todas,
                () => _set(c.copiar(seleccion: Seleccion.todas)),
              ),
              _chip('Por tipo', c.seleccion == Seleccion.porTipo, _elegirTipo),
              _chip(
                'Por competencia',
                c.seleccion == Seleccion.porCompetencia,
                _elegirCompetencia,
              ),
              _chip('Elegir', c.seleccion == Seleccion.manual, _elegirColumnas),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 2),
            child: Text(
              entran.isEmpty
                  ? 'Todavía no hay columnas que entren en el cálculo.'
                  : 'Entran ${entran.length}: '
                        '${entran.map((x) => x.periodo == widget.periodo ? x.codigo : '${x.codigo} (${x.periodo}.°)').join(', ')}'
                        '${c.seleccion == Seleccion.todas ? '. Las que crees después también entran.' : ''}',
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
          ),
          if (c.tipo == TipoCalculo.promedio) ...[
            const SizedBox(height: 12),
            _Grupos(
              calculo: c,
              columnas: entran,
              base: base,
              onCambio: _set,
            ),
          ],
        ],
        _etiqueta('Notas vacías'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in SinNota.values)
              _chip(s.nombre, c.sinNota == s, () => _set(c.copiar(sinNota: s))),
          ],
        ),
        if (c.tipo == TipoCalculo.formula && c.sinNota == SinNota.noCuenta)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 2),
            child: Text(
              'En una fórmula, una nota vacía vale 0.',
              style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
          ),
        _etiqueta('Así queda'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color.lerp(base, Colors.white, .93),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                calculoEnPalabras(c, c.tipo == TipoCalculo.formula ? _todas : entran),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (c.tipo == TipoCalculo.formula &&
                  validarFormula(c.formula) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    validarFormula(c.formula)!,
                    style: const TextStyle(fontSize: 12.5, color: _rojo),
                  ),
                ),
              const SizedBox(height: 8),
              if (_muestra == null)
                const Text(
                  'Calculando…',
                  style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
                )
              else if (_muestra!.isEmpty)
                const Text(
                  'Cuando haya estudiantes con notas verás aquí el resultado.',
                  style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
                )
              else
                for (final (e, d) in _muestra!)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 46,
                          child: Text(
                            d.valor ?? '—',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: base,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tituloNombre(e.apellidos)}, ${e.nombres}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                d.resumen,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KipuColores.gris,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _elegirTipo() async {
    final prefijos = <String>[];
    for (final x in _todas) {
      if (x.periodo != widget.periodo || x.tipo == 'calculada') continue;
      final p = prefijoDe(x.codigo);
      if (!prefijos.contains(p)) prefijos.add(p);
    }
    if (prefijos.isEmpty) return _sinColumnas();
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('¿Qué tipo de columnas?'),
        children: [
          for (final p in prefijos)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, p),
              child: Text(
                '${nombreGrupo(p)} · códigos que empiezan con $p',
                style: const TextStyle(fontSize: 15),
              ),
            ),
        ],
      ),
    );
    if (r != null) _set(c.copiar(seleccion: Seleccion.porTipo, filtro: r));
  }

  Future<void> _elegirCompetencia() async {
    final ids = <String>[
      for (final x in _todas)
        if (x.periodo == widget.periodo && x.competencia.isNotEmpty) x.competencia,
    ].toSet().toList();
    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ninguna columna del periodo tiene competencia. Se asigna al usar '
            'un instrumento de la colección CNEB.',
          ),
        ),
      );
      return;
    }
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('¿Qué competencia?'),
        children: [
          for (final id in ids)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, id),
              child: Text(
                competenciaPorId(id)?.nombre ?? id,
                style: const TextStyle(fontSize: 15),
              ),
            ),
        ],
      ),
    );
    if (r != null) {
      _set(c.copiar(seleccion: Seleccion.porCompetencia, filtro: r));
    }
  }

  void _sinColumnas() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Primero crea columnas de notas en el periodo.')),
  );

  Future<void> _elegirColumnas() async {
    final disponibles = [
      for (final x in _todas)
        if (x.id != widget.columnaId &&
            !(x.tipo == 'calculada' && x.periodo == widget.periodo))
          x,
    ];
    if (disponibles.isEmpty) return _sinColumnas();
    final elegidas = {
      ...(c.seleccion == Seleccion.manual
          ? c.columnas
          : [for (final x in _entran) x.id]),
    };
    final periodos = _config?.periodos ?? const <Periodo>[];
    String nombrePeriodo(int p) =>
        p >= 1 && p <= periodos.length ? periodos[p - 1].nombre : '$p.° periodo';
    final r = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final porPeriodo = <int, List<ColumnaDato>>{};
          for (final x in disponibles) {
            (porPeriodo[x.periodo] ??= []).add(x);
          }
          final ps = porPeriodo.keys.toList()..sort();
          return AlertDialog(
            title: const Text('Elige las columnas'),
            contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            content: SizedBox(
              width: 440,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${elegidas.length} elegidas. Puedes usar columnas de '
                      'otros periodos, por ejemplo para el promedio anual.',
                      style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
                    ),
                  ),
                  for (final p in ps) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 4, 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              nombrePeriodo(p).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: .5,
                                fontWeight: FontWeight.w700,
                                color: base,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              final ids = [for (final x in porPeriodo[p]!) x.id];
                              if (ids.every(elegidas.contains)) {
                                elegidas.removeAll(ids);
                              } else {
                                elegidas.addAll(ids);
                              }
                            }),
                            child: const Text('Todas'),
                          ),
                        ],
                      ),
                    ),
                    for (final x in porPeriodo[p]!)
                      CheckboxListTile(
                        dense: true,
                        value: elegidas.contains(x.id),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          x.tema.isEmpty ? x.codigo : '${x.codigo} · ${x.tema}',
                        ),
                        subtitle: x.tipo == 'calculada'
                            ? const Text('Calculada')
                            : null,
                        onChanged: (on) => setState(() {
                          if (on == true) {
                            elegidas.add(x.id);
                          } else {
                            elegidas.remove(x.id);
                          }
                        }),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, elegidas),
                child: const Text('Listo'),
              ),
            ],
          );
        },
      ),
    );
    if (r != null) {
      _set(c.copiar(seleccion: Seleccion.manual, columnas: r.toList()));
    }
  }
}

class _Aviso extends StatelessWidget {
  final String texto;
  final Color base;
  const _Aviso({required this.texto, required this.base});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4E0),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      texto,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 12.5, height: 1.35),
    ),
  );
}

/// Pesos por grupo: «Exámenes 40 % · Prácticas 30 % · Tareas 30 %».
class _Grupos extends StatelessWidget {
  final Calculo calculo;
  final List<ColumnaDato> columnas;
  final Color base;
  final ValueChanged<Calculo> onCambio;
  const _Grupos({
    required this.calculo,
    required this.columnas,
    required this.base,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    final c = calculo;
    final grupos = c.grupos;
    final total = totalPesos(grupos);
    final sinGrupo = [
      for (final x in columnas)
        if (!grupos.any((g) => g.prefijo.toUpperCase() == prefijoDe(x.codigo))) x,
    ];
    void grupo(int i, GrupoPeso g) =>
        onCambio(c.copiar(grupos: [...grupos]..[i] = g));
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _linea, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              KipuIcon(KipuIcono.promedio, size: 22, color: base),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesos por grupo',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Ej. Exámenes 40 %, Prácticas 30 %, Tareas 30 %',
                      style: TextStyle(fontSize: 12, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
              Switch(
                value: c.porGrupos,
                activeThumbColor: Colors.white,
                activeTrackColor: base,
                onChanged: (on) => onCambio(
                  c.copiar(
                    porGrupos: on,
                    grupos: on && grupos.isEmpty
                        ? gruposSugeridos(columnas)
                        : grupos,
                  ),
                ),
              ),
            ],
          ),
          if (c.porGrupos) ...[
            const SizedBox(height: 6),
            for (final (i, g) in grupos.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        key: ValueKey('gn-$i-${grupos.length}'),
                        initialValue: g.nombre,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Grupo',
                        ),
                        onChanged: (t) => grupo(i, g.copiar(nombre: t)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        key: ValueKey('gp-$i-${grupos.length}'),
                        initialValue: g.prefijo,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Código',
                          hintText: 'EX',
                        ),
                        onChanged: (t) =>
                            grupo(i, g.copiar(prefijo: t.trim().toUpperCase())),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 78,
                      child: TextFormField(
                        key: ValueKey('gw-$i-${grupos.length}'),
                        initialValue: numeroGuardado(g.peso, 1),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          suffixText: '%',
                        ),
                        onChanged: (t) {
                          final n = double.tryParse(t.replaceAll(',', '.'));
                          if (n != null && n >= 0) grupo(i, g.copiar(peso: n));
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Quitar grupo',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onCambio(
                        c.copiar(grupos: [...grupos]..removeAt(i)),
                      ),
                      icon: const KipuIcon(
                        KipuIcono.borrar,
                        size: 18,
                        color: KipuColores.gris,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                KipuIcon(
                  (total - 100).abs() < .01 ? KipuIcono.check : KipuIcono.aviso,
                  size: 18,
                  color: (total - 100).abs() < .01 ? _verde : const Color(0xFFB86E00),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (total - 100).abs() < .01
                        ? 'Total: 100 %'
                        : 'Total: ${numeroGuardado(total, 1).replaceAll('.', ',')} %. '
                              'Kipu usará los pesos en proporción.',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
            if (sinGrupo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'No entran porque su código no coincide con ningún grupo: '
                  '${sinGrupo.map((x) => x.codigo).join(', ')}.',
                  style: const TextStyle(fontSize: 12.5, color: _rojo),
                ),
              ),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => onCambio(
                    c.copiar(
                      grupos: [...grupos, const GrupoPeso('Nuevo grupo', '', 0)],
                    ),
                  ),
                  child: const Text('+ Grupo'),
                ),
                TextButton(
                  onPressed: () =>
                      onCambio(c.copiar(grupos: gruposSugeridos(columnas))),
                  child: const Text('Sugerir según los códigos'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Constructor de fórmulas: fichas con las columnas y un teclado.
class _Formula extends StatelessWidget {
  final List<String> tokens;
  final List<ColumnaDato> columnas;
  final Color base;
  final ValueChanged<List<String>> onCambio;
  const _Formula({
    required this.tokens,
    required this.columnas,
    required this.base,
    required this.onCambio,
  });

  void _poner(String t) {
    final l = [...tokens];
    // Dígitos seguidos forman un solo número: 1, 2 → 12.
    final esDigito = RegExp(r'^[0-9.]$').hasMatch(t);
    if (esDigito &&
        l.isNotEmpty &&
        RegExp(r'^[0-9.]+$').hasMatch(l.last) &&
        !(t == '.' && l.last.contains('.'))) {
      l[l.length - 1] = l.last + t;
    } else {
      l.add(t);
    }
    onCambio(l);
  }

  @override
  Widget build(BuildContext context) {
    final codigos = {for (final x in columnas) x.id: x.codigo};
    Widget tecla(String t, {String? ver, Color? color, double flex = 1}) =>
        Expanded(
          flex: (flex * 10).round(),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: color ?? Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _poner(t),
                child: Container(
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _linea),
                  ),
                  child: Text(
                    ver ?? t,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    final op = Color.lerp(base, Colors.white, .88);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: base, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: tokens.isEmpty
                    ? const Text(
                        'Toca una columna y luego las operaciones',
                        style: TextStyle(color: KipuColores.gris),
                      )
                    : Text(
                        formulaTexto(tokens, codigos),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              IconButton(
                tooltip: 'Borrar lo último',
                onPressed: tokens.isEmpty
                    ? null
                    : () => onCambio([...tokens]..removeLast()),
                icon: const KipuIcon(KipuIcono.izquierda, color: KipuColores.tinta),
              ),
              IconButton(
                tooltip: 'Borrar todo',
                onPressed: tokens.isEmpty ? null : () => onCambio(const []),
                icon: const KipuIcon(KipuIcono.borrar, color: _rojo, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'COLUMNAS (su nota sobre 20)',
          style: TextStyle(
            fontSize: 11.5,
            letterSpacing: .5,
            fontWeight: FontWeight.w600,
            color: KipuColores.gris,
          ),
        ),
        const SizedBox(height: 6),
        if (columnas.isEmpty)
          const Text(
            'Primero crea columnas de notas en el periodo.',
            style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final x in columnas)
                ActionChip(
                  label: Text(x.codigo),
                  tooltip: x.tema.isEmpty ? null : x.tema,
                  backgroundColor: Color.lerp(base, Colors.white, .9),
                  side: BorderSide.none,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700, color: base),
                  onPressed: () => _poner('c:${x.id}'),
                ),
            ],
          ),
        const SizedBox(height: 10),
        Row(children: [tecla('7'), tecla('8'), tecla('9'), tecla('/', ver: '÷', color: op), tecla('(', color: op)]),
        Row(children: [tecla('4'), tecla('5'), tecla('6'), tecla('*', ver: '×', color: op), tecla(')', color: op)]),
        Row(children: [tecla('1'), tecla('2'), tecla('3'), tecla('-', ver: '−', color: op), tecla('.', ver: ',')]),
        Row(children: [tecla('0', flex: 3), tecla('+', color: op), tecla('0.', ver: '0,')]),
        const Padding(
          padding: EdgeInsets.only(top: 6, left: 2),
          child: Text(
            'Ejemplo: (F1 + F2) ÷ 2 × 0,4 + EX1 × 0,6. El resultado se toma '
            'sobre 20 y se pasa a la escala de la columna.',
            style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
          ),
        ),
      ],
    );
  }
}

/// Ventana con el detalle de cómo salió la nota calculada de un estudiante.
/// En «Kipu sugiere y tú confirmas» deja elegir la nota final.
Future<void> mostrarDesglose(
  BuildContext context, {
  required RegistroColumna columna,
  required Estudiante estudiante,
  required Escala escala,
  required ConfigColumna cfg,
  required String? actual,
  required Color base,
}) async {
  final anio = await db.verAnioActivo().first;
  final config = await db.verConfigAcademica(anio).first;
  final d = await db.desgloseCalculo(
    columna: columna,
    estudiante: estudiante,
    config: config,
  );
  final confirmadas = await db.leerNotasConfirmadas(columna.id);
  if (!context.mounted) return;
  final calculo = cfg.calculo ?? const Calculo();
  final sugerida =
      calculo.tipo == TipoCalculo.nivel && calculo.nivel == ModoNivel.sugerida;
  final r = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${columna.codigo} · ${tituloNombre(estudiante.apellidos)}, ${estudiante.nombres}'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    actual ?? '—',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: base,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d?.resumen ?? 'Sin datos',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (sugerida && confirmadas.containsKey(estudiante.id))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Confirmada por ti. Kipu sugiere: ${d?.valor ?? '—'}',
                    style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
                  ),
                ),
              const Divider(height: 22),
              for (final (etq, v) in d?.lineas ?? const <(String, String)>[])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(etq, style: const TextStyle(fontSize: 13.5))),
                      Text(
                        v,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: v == 'sin nota' ? KipuColores.gris : KipuColores.tinta,
                        ),
                      ),
                    ],
                  ),
                ),
              if (sugerida) ...[
                const Divider(height: 22),
                const Text(
                  'Confirma o cambia el nivel:',
                  style: TextStyle(fontSize: 13, color: KipuColores.gris),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in escala.valores)
                      ChoiceChip(
                        label: Text(v.codigo),
                        selected: actual == v.codigo,
                        showCheckmark: false,
                        selectedColor: Color(v.color),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: actual == v.codigo ? Colors.white : Color(v.color),
                        ),
                        onSelected: (_) => Navigator.pop(ctx, v.codigo),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (sugerida && confirmadas.containsKey(estudiante.id))
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('Usar la sugerida'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
  if (r == null) return;
  await db.confirmarNota(columna.id, estudiante.id, r.isEmpty ? null : r);
  await db.actualizarAutomaticas(
    cursoId: columna.cursoId,
    periodo: columna.periodo,
    config: config,
  );
}
