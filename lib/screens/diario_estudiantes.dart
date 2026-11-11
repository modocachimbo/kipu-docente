import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/avisos.dart';
import '../data/database.dart';
import '../data/diario_db.dart';
import '../data/registro.dart' show tituloNombre;
import '../main.dart' show db;
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'diario.dart';
import 'estudiantes.dart' show AvatarEstudiante;

String _nombre(Estudiante e) =>
    '${tituloNombre(e.apellidos)}, ${tituloNombre(e.nombres).split(' ').first}';

String _textoCurso(Curso c) => '${c.nombre} · ${c.grado} ${c.seccion}';

/// Foto de evidencia, reducida para no llenar la base de datos.
Future<Uint8List?> _elegirEvidencia(ImageSource origen) async {
  final img = await ImagePicker().pickImage(
    source: origen,
    maxWidth: 1000,
    maxHeight: 1000,
    imageQuality: 78,
  );
  return img?.readAsBytes();
}

String _internacional(String celular) {
  final d = celular.replaceAll(RegExp(r'\D'), '');
  return d.length == 9 ? '51$d' : d;
}

Future<void> _whatsapp(String celular, String texto) => launchUrl(
  Uri.https('wa.me', '/${_internacional(celular)}', {
    if (texto.isNotEmpty) 'text': texto,
  }),
  mode: LaunchMode.externalApplication,
);

/// Filtro por curso arriba de las listas.
class _FiltroCurso extends StatelessWidget {
  final int? cursoId;
  final ValueChanged<int?> onCambio;
  const _FiltroCurso({required this.cursoId, required this.onCambio});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        KipuIcon(KipuIcono.cursos, size: 20, color: KipuColores.gris),
        const SizedBox(width: 10),
        Expanded(
          child: ElegirCurso(
            cursoId: cursoId,
            vacio: 'Todos los cursos',
            onCambio: onCambio,
          ),
        ),
      ],
    ),
  );
}

class _Vacio extends StatelessWidget {
  final KipuIcono icono;
  final String texto;
  const _Vacio(this.icono, this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    child: Column(
      children: [
        KipuIcon(
          icono,
          size: 48,
          color: Color.lerp(KipuColores.morado, Colors.white, .45),
        ),
        const SizedBox(height: 12),
        Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: KipuColores.gris),
        ),
      ],
    ),
  );
}

/// Elige curso y estudiante.
class _ElegirEstudiante extends StatelessWidget {
  final int? cursoId;
  final int? estudianteId;
  final ValueChanged<int?> onCurso;
  final ValueChanged<Estudiante?> onEstudiante;
  const _ElegirEstudiante({
    required this.cursoId,
    required this.estudianteId,
    required this.onCurso,
    required this.onEstudiante,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElegirCurso(cursoId: cursoId, vacio: 'Elige el curso', onCambio: onCurso),
      const SizedBox(height: 8),
      if (cursoId != null)
        StreamBuilder<List<Estudiante>>(
          stream: db.verEstudiantes(cursoId!),
          builder: (context, snap) {
            final lista = [
              for (final e in snap.data ?? const <Estudiante>[])
                if (e.hasta == null || e.id == estudianteId) e,
            ];
            final valido = lista.any((e) => e.id == estudianteId);
            return DropdownButtonFormField<int>(
              initialValue: valido ? estudianteId : null,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Elige el estudiante',
              ),
              items: [
                for (final e in lista)
                  DropdownMenuItem(
                    value: e.id,
                    child: Text(_nombre(e), overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) =>
                  onEstudiante(lista.where((e) => e.id == id).firstOrNull),
            );
          },
        ),
    ],
  );
}

// ───────────────────────── Anecdotario ─────────────────────────

class Anecdotario extends StatefulWidget {
  const Anecdotario({super.key});

  @override
  State<Anecdotario> createState() => AnecdotarioState();
}

class AnecdotarioState extends State<Anecdotario> {
  int? _curso;
  String? _tipo;

  void nueva() => editarAnecdota(context, cursoId: _curso);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnecdotaCompleta>>(
      stream: db.verAnecdotas(cursoId: _curso),
      builder: (context, snap) {
        final todas = snap.data ?? const <AnecdotaCompleta>[];
        final lista = [
          for (final x in todas)
            if (_tipo == null || x.$1.tipo == _tipo) x,
        ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            _FiltroCurso(
              cursoId: _curso,
              onCambio: (v) => setState(() => _curso = v),
            ),
            const SizedBox(height: 10),
            ChipsDiario<String?>(
              opciones: [
                (null, 'Todas (${todas.length})'),
                for (final t in tiposAnecdota)
                  (
                    t.$1,
                    '${t.$2} (${todas.where((x) => x.$1.tipo == t.$1).length})',
                  ),
              ],
              valor: _tipo,
              colorDe: (t) => t == null ? null : Color(colorTipoAnecdota(t)),
              onCambio: (v) => setState(() => _tipo = v),
            ),
            const SizedBox(height: 12),
            if (snap.hasData && lista.isEmpty)
              const _Vacio(
                KipuIcono.apuntes,
                'Aquí van los incidentes, logros y observaciones de cada '
                'estudiante. Toca «Anotar» para empezar.',
              ),
            for (final x in lista) TarjetaAnecdota(x),
          ],
        );
      },
    );
  }
}

/// Tarjeta de una anotación (también se usa en la ficha del estudiante).
class TarjetaAnecdota extends StatelessWidget {
  final AnecdotaCompleta x;
  final bool conNombre;
  const TarjetaAnecdota(this.x, {super.key, this.conNombre = true});

  @override
  Widget build(BuildContext context) {
    final (a, e, c) = x;
    final color = Color(colorTipoAnecdota(a.tipo));
    final tipo = tiposAnecdota.where((t) => t.$1 == a.tipo).firstOrNull?.$2;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => editarAnecdota(context, anecdota: a, estudiante: e),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (conNombre) ...[
                AvatarEstudiante(e, tam: 38),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (conNombre)
                      Text(
                        _nombre(e),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      [
                        fechaCorta(a.fecha),
                        ?tipo,
                        nombreCategoria(a.categoria),
                        if (conNombre) _textoCurso(c),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(a.texto, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              if (a.foto != null) ...[
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    a.foto!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> editarAnecdota(
  BuildContext context, {
  Anecdota? anecdota,
  Estudiante? estudiante,
  int? cursoId,
}) => hojaDiario(
  context,
  _EditorAnecdota(
    anecdota: anecdota,
    estudiante: estudiante,
    cursoId: cursoId ?? estudiante?.cursoId,
  ),
);

class _EditorAnecdota extends StatefulWidget {
  final Anecdota? anecdota;
  final Estudiante? estudiante;
  final int? cursoId;
  const _EditorAnecdota({this.anecdota, this.estudiante, this.cursoId});

  @override
  State<_EditorAnecdota> createState() => _EditorAnecdotaState();
}

class _EditorAnecdotaState extends State<_EditorAnecdota> {
  late int? _curso = widget.cursoId;
  late int? _est = widget.estudiante?.id;
  late String _fecha =
      widget.anecdota?.fecha ?? claveFecha(DateTime.now());
  late String _tipo = widget.anecdota?.tipo ?? 'neutro';
  late String _cat = widget.anecdota?.categoria ?? 'conducta';
  late Uint8List? _foto = widget.anecdota?.foto;
  late final _texto = TextEditingController(text: widget.anecdota?.texto);
  String? _error;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = _texto.text.trim();
    if (_est == null) {
      setState(() => _error = 'Elige el estudiante');
      return;
    }
    if (t.isEmpty) {
      setState(() => _error = 'Escribe lo que pasó');
      return;
    }
    final a = widget.anecdota;
    await db.guardarAnecdota(
      AnecdotasCompanion(
        id: a == null ? const Value.absent() : Value(a.id),
        estudianteId: Value(_est!),
        fecha: Value(_fecha),
        tipo: Value(_tipo),
        categoria: Value(_cat),
        texto: Value(t),
        foto: Value(_foto),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.anecdota;
    final color = Color(colorTipoAnecdota(_tipo));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabezaDiario(
          icono: KipuIcono.apuntes,
          color: color,
          titulo: a == null ? 'Anotar en el anecdotario' : 'Editar anotación',
          subtitulo: widget.estudiante == null
              ? null
              : _nombre(widget.estudiante!),
        ),
        const SizedBox(height: 12),
        if (widget.estudiante == null)
          _ElegirEstudiante(
            cursoId: _curso,
            estudianteId: _est,
            onCurso: (v) => setState(() {
              _curso = v;
              _est = null;
            }),
            onEstudiante: (e) => setState(() {
              _est = e?.id;
              _error = null;
            }),
          ),
        const RotuloDiario('Fecha'),
        BotonFecha(
          fecha: _fecha,
          onCambio: (f) => setState(() => _fecha = f ?? _fecha),
        ),
        const RotuloDiario('Tipo'),
        ChipsDiario<String>(
          opciones: [for (final t in tiposAnecdota) (t.$1, t.$2)],
          valor: _tipo,
          colorDe: (t) => Color(colorTipoAnecdota(t)),
          onCambio: (v) => setState(() => _tipo = v),
        ),
        const RotuloDiario('Sobre'),
        ChipsDiario<String>(
          opciones: categoriasAnecdota,
          valor: _cat,
          onCambio: (v) => setState(() => _cat = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _texto,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: '¿Qué pasó?',
            hintText: 'Describe el hecho tal como ocurrió, sin juicios.',
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const RotuloDiario('Evidencia (opcional)'),
        Row(
          children: [
            if (_foto != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _foto!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              IconButton(
                tooltip: 'Quitar foto',
                onPressed: () => setState(() => _foto = null),
                icon: const KipuIcon(
                  KipuIcono.cerrar,
                  size: 16,
                  color: KipuColores.gris,
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final f = await _elegirEvidencia(ImageSource.camera);
                  if (f != null) setState(() => _foto = f);
                },
                icon: KipuIcon(
                  KipuIcono.camara,
                  size: 18,
                  color: KipuColores.morado,
                ),
                label: const Text('Cámara'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final f = await _elegirEvidencia(ImageSource.gallery);
                  if (f != null) setState(() => _foto = f);
                },
                icon: KipuIcon(
                  KipuIcono.pegar,
                  size: 18,
                  color: KipuColores.morado,
                ),
                label: const Text('Galería'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (a != null) ...[
              IconButton(
                tooltip: 'Borrar',
                onPressed: () async {
                  await db.borrarAnecdota(a.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const KipuIcon(
                  KipuIcono.borrar,
                  color: Color(0xFFC2334A),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── Diario de clase ─────────────────────────

class DiarioClases extends StatefulWidget {
  const DiarioClases({super.key});

  @override
  State<DiarioClases> createState() => DiarioClasesState();
}

class DiarioClasesState extends State<DiarioClases> {
  int? _curso;

  void nueva() => anotarClase(context, cursoId: _curso, fecha: DateTime.now());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<(ClaseDiario, Curso)>>(
      stream: db.verClasesDiario(cursoId: _curso),
      builder: (context, snap) {
        final lista = snap.data ?? const <(ClaseDiario, Curso)>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            _FiltroCurso(
              cursoId: _curso,
              onCambio: (v) => setState(() => _curso = v),
            ),
            const SizedBox(height: 12),
            if (snap.hasData && lista.isEmpty)
              const _Vacio(
                KipuIcono.libro,
                'Anota en una línea qué trabajaste en cada clase y qué faltó. '
                'Así sabes por dónde vas con cada sección. También puedes '
                'tocar una clase en la Agenda.',
              ),
            for (final (k, c) in lista)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => anotarClase(context, clase: k),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${fechaCorta(k.fecha)} · ${_textoCurso(c)}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: KipuColores.morado,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(k.trabajado, style: const TextStyle(fontSize: 15)),
                        if ((k.falta ?? '').isNotEmpty)
                          _Linea('Faltó', k.falta!, const Color(0xFFE07B1F)),
                        if ((k.material ?? '').isNotEmpty)
                          _Linea('Material', k.material!, KipuColores.gris),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Linea extends StatelessWidget {
  final String rotulo;
  final String texto;
  final Color color;
  const _Linea(this.rotulo, this.texto, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$rotulo: ',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          TextSpan(text: texto),
        ],
      ),
      style: const TextStyle(fontSize: 13.5),
    ),
  );
}

/// Anota (o edita) lo que se trabajó en una clase. Si ya hay una anotación
/// del mismo curso y fecha, la abre.
Future<void> anotarClase(
  BuildContext context, {
  CursoConColegio? curso,
  int? cursoId,
  DateTime? fecha,
  ClaseDiario? clase,
}) async {
  final id = clase?.cursoId ?? curso?.curso.id ?? cursoId;
  final f = clase?.fecha ?? claveFecha(fecha ?? DateTime.now());
  final existente =
      clase ?? (id == null ? null : await db.leerClaseDiario(id, f));
  if (!context.mounted) return;
  await hojaDiario(
    context,
    _EditorClase(clase: existente, cursoId: id, fecha: f),
  );
}

class _EditorClase extends StatefulWidget {
  final ClaseDiario? clase;
  final int? cursoId;
  final String fecha;
  const _EditorClase({this.clase, this.cursoId, required this.fecha});

  @override
  State<_EditorClase> createState() => _EditorClaseState();
}

class _EditorClaseState extends State<_EditorClase> {
  late int? _curso = widget.cursoId;
  late String _fecha = widget.fecha;
  late final _hecho = TextEditingController(text: widget.clase?.trabajado);
  late final _falta = TextEditingController(text: widget.clase?.falta);
  late final _material = TextEditingController(text: widget.clase?.material);
  String? _error;

  @override
  void dispose() {
    _hecho.dispose();
    _falta.dispose();
    _material.dispose();
    super.dispose();
  }

  String? _o(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _guardar() async {
    if (_curso == null) {
      setState(() => _error = 'Elige el curso');
      return;
    }
    if (_hecho.text.trim().isEmpty) {
      setState(() => _error = 'Escribe qué se trabajó');
      return;
    }
    final k = widget.clase;
    await db.guardarClaseDiario(
      ClasesDiarioCompanion(
        id: k == null ? const Value.absent() : Value(k.id),
        cursoId: Value(_curso!),
        fecha: Value(_fecha),
        trabajado: Value(_hecho.text.trim()),
        falta: Value(_o(_falta)),
        material: Value(_o(_material)),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.clase;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabezaDiario(
          icono: KipuIcono.libro,
          titulo: k == null ? 'Anotar clase' : 'Editar clase',
          subtitulo: 'Lo que trabajaste hoy, para no perder el hilo',
        ),
        const SizedBox(height: 12),
        ElegirCurso(
          cursoId: _curso,
          vacio: 'Elige el curso',
          onCambio: (v) => setState(() {
            _curso = v;
            _error = null;
          }),
        ),
        const SizedBox(height: 8),
        BotonFecha(
          fecha: _fecha,
          onCambio: (f) => setState(() => _fecha = f ?? _fecha),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _hecho,
          autofocus: k == null,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: '¿Qué se trabajó?',
            hintText: 'Ej.: Fracciones equivalentes, págs. 34–36',
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _falta,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: '¿Qué faltó? (opcional)',
            hintText: 'Para retomarlo la próxima clase',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _material,
          minLines: 1,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Material (opcional)',
            hintText: 'Fichas, video, laboratorio…',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (k != null) ...[
              IconButton(
                tooltip: 'Borrar',
                onPressed: () async {
                  await db.borrarClaseDiario(k.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const KipuIcon(
                  KipuIcono.borrar,
                  color: Color(0xFFC2334A),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── Reuniones con padres ─────────────────────────

class Reuniones extends StatefulWidget {
  const Reuniones({super.key});

  @override
  State<Reuniones> createState() => ReunionesState();
}

class ReunionesState extends State<Reuniones> {
  int? _curso;

  void nueva() => editarReunion(context, cursoId: _curso);

  @override
  Widget build(BuildContext context) {
    final hoy = claveFecha(DateTime.now());
    return StreamBuilder<List<AnecdotaCompleta>>(
      stream: db.verAnecdotas(cursoId: _curso, reuniones: true),
      builder: (context, snap) {
        final lista = snap.data ?? const <AnecdotaCompleta>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            _FiltroCurso(
              cursoId: _curso,
              onCambio: (v) => setState(() => _curso = v),
            ),
            const SizedBox(height: 12),
            if (snap.hasData && lista.isEmpty)
              const _Vacio(
                KipuIcono.familia,
                'Registra las reuniones con padres: motivo, acuerdos y una '
                'fecha para dar seguimiento (te avisa ese día).',
              ),
            for (final (a, e, c) in lista)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      editarReunion(context, reunion: a, estudiante: e),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarEstudiante(e, tam: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nombre(e),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                [
                                  fechaCorta(a.fecha),
                                  if ((a.apoderado ?? '').isNotEmpty)
                                    a.apoderado!,
                                  _textoCurso(c),
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFFE07B1F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(a.texto),
                              if ((a.acuerdos ?? '').isNotEmpty)
                                _Linea(
                                  'Acuerdos',
                                  a.acuerdos!,
                                  KipuColores.tinta,
                                ),
                              if (a.seguimiento != null)
                                _Linea(
                                  'Seguimiento',
                                  fechaCorta(a.seguimiento!),
                                  a.seguimiento!.compareTo(hoy) < 0
                                      ? KipuColores.gris
                                      : const Color(0xFFE07B1F),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<void> editarReunion(
  BuildContext context, {
  Anecdota? reunion,
  Estudiante? estudiante,
  int? cursoId,
}) => hojaDiario(
  context,
  _EditorReunion(
    reunion: reunion,
    estudiante: estudiante,
    cursoId: cursoId ?? estudiante?.cursoId,
  ),
);

class _EditorReunion extends StatefulWidget {
  final Anecdota? reunion;
  final Estudiante? estudiante;
  final int? cursoId;
  const _EditorReunion({this.reunion, this.estudiante, this.cursoId});

  @override
  State<_EditorReunion> createState() => _EditorReunionState();
}

class _EditorReunionState extends State<_EditorReunion> {
  late int? _curso = widget.cursoId;
  late Estudiante? _est = widget.estudiante;
  late String _fecha = widget.reunion?.fecha ?? claveFecha(DateTime.now());
  late String? _seguimiento = widget.reunion?.seguimiento;
  late final _apoderado = TextEditingController(
    text:
        widget.reunion?.apoderado ??
        (widget.estudiante == null ? '' : _apoderadoDe(widget.estudiante!)),
  );
  late final _motivo = TextEditingController(text: widget.reunion?.texto);
  late final _acuerdos = TextEditingController(text: widget.reunion?.acuerdos);
  String? _error;

  static String _apoderadoDe(Estudiante e) => [
    if ((e.apoderado ?? '').isNotEmpty) tituloNombre(e.apoderado!),
    if ((e.parentesco ?? '').isNotEmpty) '(${e.parentesco})',
  ].join(' ');

  @override
  void dispose() {
    _apoderado.dispose();
    _motivo.dispose();
    _acuerdos.dispose();
    super.dispose();
  }

  String? _o(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<bool> _guardar() async {
    final e = _est;
    if (e == null) {
      setState(() => _error = 'Elige el estudiante');
      return false;
    }
    if (_motivo.text.trim().isEmpty) {
      setState(() => _error = 'Escribe el motivo');
      return false;
    }
    final r = widget.reunion;
    await db.guardarAnecdota(
      AnecdotasCompanion(
        id: r == null ? const Value.absent() : Value(r.id),
        estudianteId: Value(e.id),
        fecha: Value(_fecha),
        tipo: const Value('neutro'),
        categoria: const Value('reunion'),
        texto: Value(_motivo.text.trim()),
        apoderado: Value(_o(_apoderado)),
        acuerdos: Value(_o(_acuerdos)),
        seguimiento: Value(_seguimiento),
      ),
    );
    // El seguimiento queda en la agenda con aviso ese día.
    final s = _seguimiento;
    if (s != null && s != r?.seguimiento) {
      await db.guardarEvento(
        EventosCompanion.insert(
          fecha: s,
          titulo: 'Seguimiento: ${_nombre(e)}',
          tipo: const Value('reunion'),
          recordar: const Value(0),
          cursoId: Value(e.cursoId),
          detalle: Value(_o(_acuerdos)),
        ),
      );
      if (mounted) await asegurarPermiso(context);
    }
    return true;
  }

  String _mensaje() {
    final e = _est;
    return [
      'Buen día${_apoderado.text.trim().isEmpty ? '' : ', ${_apoderado.text.trim()}'}.',
      if (e != null)
        'Le comparto los acuerdos de la reunión del ${fechaCorta(_fecha)} '
            'sobre ${tituloNombre(e.nombres).split(' ').first}:',
      if (_o(_acuerdos) != null) _acuerdos.text.trim(),
      if (_seguimiento != null)
        'Volveremos a conversar el ${fechaCorta(_seguimiento!)}.',
      'Gracias.',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reunion;
    final celular = _est?.telefono;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabezaDiario(
          icono: KipuIcono.familia,
          color: const Color(0xFFE07B1F),
          titulo: r == null ? 'Reunión con padres' : 'Editar reunión',
          subtitulo: widget.estudiante == null
              ? null
              : _nombre(widget.estudiante!),
        ),
        const SizedBox(height: 12),
        if (widget.estudiante == null)
          _ElegirEstudiante(
            cursoId: _curso,
            estudianteId: _est?.id,
            onCurso: (v) => setState(() {
              _curso = v;
              _est = null;
            }),
            onEstudiante: (e) => setState(() {
              _est = e;
              _error = null;
              if (e != null && _apoderado.text.trim().isEmpty) {
                _apoderado.text = _apoderadoDe(e);
              }
            }),
          ),
        const RotuloDiario('Fecha'),
        BotonFecha(
          fecha: _fecha,
          onCambio: (f) => setState(() => _fecha = f ?? _fecha),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _apoderado,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Con quién'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _motivo,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Motivo y lo conversado',
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _acuerdos,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Acuerdos',
            hintText: 'Qué se comprometió cada uno',
          ),
        ),
        const RotuloDiario('Seguimiento (te avisa ese día)'),
        BotonFecha(
          fecha: _seguimiento,
          vacio: 'Sin seguimiento',
          quitable: true,
          onCambio: (f) => setState(() => _seguimiento = f),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (r != null) ...[
              IconButton(
                tooltip: 'Borrar',
                onPressed: () async {
                  await db.borrarAnecdota(r.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const KipuIcon(
                  KipuIcono.borrar,
                  color: Color(0xFFC2334A),
                ),
              ),
              const SizedBox(width: 4),
            ],
            if ((celular ?? '').isNotEmpty) ...[
              IconButton(
                tooltip: 'Guardar y enviar acuerdos por WhatsApp',
                onPressed: () async {
                  if (!await _guardar()) return;
                  await _whatsapp(celular!, _mensaje());
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const KipuIcon(
                  KipuIcono.whatsapp,
                  color: Color(0xFF16A37F),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE07B1F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (await _guardar() && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
