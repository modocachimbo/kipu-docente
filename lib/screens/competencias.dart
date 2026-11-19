import 'package:flutter/material.dart';

import '../data/cneb.dart';
import '../data/instrumentos.dart' show nivelesEducativos;
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'evaluacion.dart' show PantallaEvaluacion;

/// Configuración académica › Competencias y criterios: las competencias del
/// CNEB por nivel y área, con los criterios que usan los instrumentos que
/// trae Kipu.
class PantallaCompetencias extends StatefulWidget {
  final String curriculo;
  const PantallaCompetencias({super.key, required this.curriculo});

  @override
  State<PantallaCompetencias> createState() => _PantallaCompetenciasState();
}

class _PantallaCompetenciasState extends State<PantallaCompetencias> {
  String _nivel = 'Primaria';
  final _buscar = TextEditingController();

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  /// Competencias del nivel agrupadas por área, en el orden de [ordenAreas].
  List<(String, List<Competencia>)> get _grupos {
    final q = _buscar.text.trim().toLowerCase();
    final porArea = <String, List<Competencia>>{};
    for (final c in competenciasCneb) {
      final area = c.areas[_nivel];
      if (area == null) continue;
      if (q.isNotEmpty &&
          !c.nombre.toLowerCase().contains(q) &&
          !area.toLowerCase().contains(q)) {
        continue;
      }
      porArea.putIfAbsent(area, () => []).add(c);
    }
    final areas = porArea.keys.toList()
      ..sort((a, b) {
        int i(String x) {
          final p = ordenAreas.indexOf(x);
          return p < 0 ? ordenAreas.length : p;
        }

        return i(a).compareTo(i(b));
      });
    return [for (final a in areas) (a, porArea[a]!)];
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _grupos;
    final total = grupos.fold(0, (n, g) => n + g.$2.length);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competencias y criterios'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PantallaEvaluacion()),
            ),
            child: const Text('Instrumentos'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Del ${widget.curriculo}. Los criterios son los que usan '
                    'las rúbricas y listas de cotejo que vienen en Kipu.',
                    style: const TextStyle(color: KipuColores.gris),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in nivelesEducativos)
                        ChoiceChip(
                          label: Text(n),
                          selected: _nivel == n,
                          onSelected: (_) => setState(() => _nivel = n),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _buscar,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar competencia o área',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: KipuIcon(
                          KipuIcono.buscar,
                          size: 20,
                          color: KipuColores.gris,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 8, 0, 4),
                    child: Text(
                      total == 1 ? '1 competencia' : '$total competencias',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                  if (grupos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No hay competencias con ese nombre.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KipuColores.gris),
                      ),
                    ),
                  for (final (area, comps) in grupos) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 16, 0, 8),
                      child: Text(
                        area.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: KipuColores.gris,
                        ),
                      ),
                    ),
                    for (final c in comps) _TarjetaCompetencia(c, _nivel),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCompetencia extends StatelessWidget {
  final Competencia c;
  final String nivel;
  const _TarjetaCompetencia(this.c, this.nivel);

  @override
  Widget build(BuildContext context) {
    final datos = criteriosCneb(c.id, nivel);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey('comp-${c.id}-$nivel'),
            tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: KipuIcon(
              c.transversal ? KipuIcono.estrella : KipuIcono.diana,
              size: 26,
              color: KipuColores.morado,
            ),
            title: Text(
              c.nombre,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              datos == null
                  ? 'Sin criterios sugeridos para $nivel'
                  : '${datos.$2.length} criterios',
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (datos == null)
                const Text(
                  'Puedes crear tus propios instrumentos para esta '
                  'competencia en Evaluación.',
                  style: TextStyle(color: KipuColores.gris),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KipuColores.moradoClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Evidencia sugerida: ${datos.$1}',
                    style: TextStyle(
                      fontSize: 13,
                      color: KipuColores.moradoOscuro,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                for (final (i, cr) in datos.$2.indexed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: KipuColores.morado,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cr.criterio,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Logrado: ${cr.logro}.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: KipuColores.tinta,
                                ),
                              ),
                              Text(
                                'Destacado: además, ${cr.destacado}.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
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
            ],
          ),
        ),
      ),
    );
  }
}
