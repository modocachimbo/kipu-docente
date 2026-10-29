import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import '../widgets/selector_color.dart' show textoSobre;
import 'cursos.dart' show colorColegio;

class EstadoAsistencia {
  final String codigo;
  final String nombre;
  final Color color;
  final IconData icono;
  const EstadoAsistencia(this.codigo, this.nombre, this.color, this.icono);
}

const estadosAsistencia = [
  EstadoAsistencia('P', 'Presente', Color(0xFF2FBF8F), Icons.check),
  EstadoAsistencia('T', 'Tarde', Color(0xFFF2A93B), Icons.schedule),
  EstadoAsistencia('F', 'Falta', Color(0xFFE5566B), Icons.close),
  EstadoAsistencia(
    'J',
    'Justificada',
    Color(0xFF4F7CF5),
    Icons.description_outlined,
  ),
];

String fechaClave(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// Pestaña principal: elige un curso y pasa lista.
class Asistencia extends StatefulWidget {
  const Asistencia({super.key});

  @override
  State<Asistencia> createState() => _AsistenciaState();
}

class _AsistenciaState extends State<Asistencia> {
  int? _cursoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        actions: const [_SelectorColegio(), SizedBox(width: 12)],
      ),
      body: StreamBuilder<String?>(
        stream: db.verAjuste('colegio_activo'),
        builder: (context, snapAct) => StreamBuilder<List<CursoConColegio>>(
          stream: db.verCursos(),
          builder: (context, snap) {
            final todos = snap.data ?? [];
            // Solo los cursos del colegio activo (el elegido en Mis cursos).
            final colegios = {for (final c in todos) c.colegio.id: c.colegio};
            final activo =
                colegios[int.tryParse(snapAct.data ?? '')] ??
                (colegios.isEmpty ? null : colegios.values.first);
            final cursos = todos
                .where((c) => c.colegio.id == activo?.id)
                .toList();
            if (snap.hasData && cursos.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Primero crea un curso y agrega estudiantes en "Mis cursos".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KipuColores.gris),
                  ),
                ),
              );
            }
            if (cursos.isEmpty) return const SizedBox.shrink();
            final actual = cursos.firstWhere(
              (c) => c.curso.id == _cursoId,
              orElse: () => cursos.first,
            );
            return Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final c in cursos)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              '${c.curso.nombre} · ${c.curso.grado} ${c.curso.seccion}',
                            ),
                            selected: c.curso.id == actual.curso.id,
                            showCheckmark: false,
                            selectedColor: colorColegio(
                              colegios.values.toList(),
                              c.colegio.id,
                            ),
                            labelStyle: TextStyle(
                              color: c.curso.id == actual.curso.id
                                  ? textoSobre(
                                      colorColegio(
                                        colegios.values.toList(),
                                        c.colegio.id,
                                      ),
                                    )
                                  : KipuColores.tinta,
                            ),
                            onSelected: (_) =>
                                setState(() => _cursoId = c.curso.id),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PasarLista(
                    key: ValueKey(actual.curso.id),
                    datos: actual,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Muestra el colegio activo y permite cambiarlo (es el mismo de Mis cursos).
class _SelectorColegio extends StatelessWidget {
  const _SelectorColegio();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Colegio>>(
      stream: db.verColegios(),
      builder: (context, snapCol) => StreamBuilder<String?>(
        stream: db.verAjuste('colegio_activo'),
        builder: (context, snapAct) {
          final colegios = snapCol.data ?? [];
          if (colegios.length < 2) return const SizedBox.shrink();
          final activo = colegios.firstWhere(
            (c) => c.id.toString() == snapAct.data,
            orElse: () => colegios.first,
          );
          return PopupMenuButton<int>(
            tooltip: 'Cambiar de colegio',
            color: Colors.white,
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (id) =>
                db.guardarAjuste('colegio_activo', id.toString()),
            itemBuilder: (_) => [
              for (final c in colegios)
                PopupMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: KipuColores.moradoClaro,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      activo.nombre,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: KipuColores.moradoOscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  KipuIcon(
                    KipuIcono.abajo,
                    size: 18,
                    color: KipuColores.moradoOscuro,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Lista de un curso para una fecha. Se usa en la pestaña y desde el curso.
class PasarLista extends StatefulWidget {
  final CursoConColegio datos;
  const PasarLista({super.key, required this.datos});

  @override
  State<PasarLista> createState() => _PasarListaState();
}

class _PasarListaState extends State<PasarLista> {
  DateTime _fecha = DateTime.now();

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (f != null) setState(() => _fecha = f);
  }

  void _moverDia(int dias) =>
      setState(() => _fecha = _fecha.add(Duration(days: dias)));

  @override
  Widget build(BuildContext context) {
    final clave = fechaClave(_fecha);
    final texto = DateFormat("EEEE d 'de' MMMM", 'es_PE').format(_fecha);
    return StreamBuilder<List<Estudiante>>(
      stream: db.verEstudiantes(widget.datos.curso.id),
      builder: (context, snapEst) => StreamBuilder<Map<int, String>>(
        stream: db.verAsistencia(widget.datos.curso.id, clave),
        builder: (context, snapAs) {
          final lista = snapEst.data ?? [];
          final marcas = snapAs.data ?? {};
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _moverDia(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: _elegirFecha,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                KipuIcon(
                                  KipuIcono.calendario,
                                  size: 20,
                                  color: KipuColores.morado,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    texto[0].toUpperCase() + texto.substring(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _moverDia(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Resumen(total: lista.length, marcas: marcas),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(22),
                    child: Text(
                      'Este curso aún no tiene estudiantes. Agrégalos desde "Mis cursos".',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KipuColores.gris),
                    ),
                  ),
                )
              else ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => db.marcarTodos(
                      [for (final e in lista) e.id],
                      clave,
                      'P',
                    ),
                    icon: const Icon(Icons.done_all),
                    label: const Text('Todos presentes'),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < lista.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _FilaEstudiante(
                          numero: i + 1,
                          estudiante: lista[i],
                          estado: marcas[lista[i].id],
                          onMarcar: (estado) =>
                              db.marcarAsistencia(lista[i].id, clave, estado),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final int total;
  final Map<int, String> marcas;
  const _Resumen({required this.total, required this.marcas});

  @override
  Widget build(BuildContext context) {
    final sinMarcar = total - marcas.length;
    return Row(
      children: [
        for (final e in estadosAsistencia) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: e.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    '${marcas.values.where((v) => v == e.codigo).length}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: e.color,
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      e.nombre,
                      style: TextStyle(fontSize: 11, color: e.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '$sinMarcar',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: KipuColores.gris,
                  ),
                ),
                const FittedBox(
                  child: Text(
                    'Sin marcar',
                    style: TextStyle(fontSize: 11, color: KipuColores.gris),
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

class _FilaEstudiante extends StatelessWidget {
  final int numero;
  final Estudiante estudiante;
  final String? estado;
  final ValueChanged<String?> onMarcar;

  const _FilaEstudiante({
    required this.numero,
    required this.estudiante,
    required this.estado,
    required this.onMarcar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          estudiante.apellidos,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          estudiante.nombres,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: KipuColores.gris),
        ),
      ],
    );
    final botones = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in estadosAsistencia)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Tooltip(
              message: e.nombre,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                // Tocar el estado ya marcado lo desmarca.
                onTap: () => onMarcar(estado == e.codigo ? null : e.codigo),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: estado == e.codigo ? e.color : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: estado == e.codigo
                          ? e.color
                          : e.color.withValues(alpha: .4),
                    ),
                  ),
                  child: Text(
                    e.codigo,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: estado == e.codigo ? Colors.white : e.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$numero',
              style: TextStyle(
                color: KipuColores.morado,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: nombre),
          botones,
        ],
      ),
    );
  }
}
