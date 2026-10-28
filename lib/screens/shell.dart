import 'package:flutter/material.dart';

import '../theme.dart';
import 'cursos.dart';
import 'inicio.dart';
import 'proximamente.dart';

class _Seccion {
  final String titulo;
  final IconData icono;
  final IconData iconoActivo;
  final bool enBarra; // visible en la barra inferior del celular
  final Widget Function() pantalla;

  const _Seccion(this.titulo, this.icono, this.iconoActivo, this.pantalla,
      {this.enBarra = false});
}

final _secciones = <_Seccion>[
  _Seccion('Inicio', Icons.dashboard_outlined, Icons.dashboard,
      () => const Inicio(),
      enBarra: true),
  _Seccion('Mis cursos', Icons.menu_book_outlined, Icons.menu_book,
      () => const MisCursos(),
      enBarra: true),
  _Seccion('Asistencia', Icons.fact_check_outlined, Icons.fact_check,
      () => const Proximamente('Asistencia',
          'Pasa lista con un toque: presente, tarde, falta o justificada.'),
      enBarra: true),
  _Seccion('Notas', Icons.grading_outlined, Icons.grading,
      () => const Proximamente('Registro de notas',
          'Calificación por competencias con la escala AD, A, B y C.'),
      enBarra: true),
  _Seccion('Horario', Icons.schedule_outlined, Icons.schedule,
      () => const Proximamente(
          'Horario', 'Tus clases de la semana con recordatorios.')),
  _Seccion('Reportes', Icons.pie_chart_outline, Icons.pie_chart,
      () => const Proximamente('Reportes',
          'Registro auxiliar, consolidado y libretas en PDF y Excel.')),
  _Seccion('Mi diario', Icons.contact_page_outlined, Icons.contact_page,
      () => const Proximamente(
          'Mi diario', 'Anecdotario y observaciones por estudiante.')),
  _Seccion('Planificación', Icons.assignment_outlined, Icons.assignment,
      () => const Proximamente('Planificación',
          'Planificación anual, unidades y sesiones de aprendizaje.')),
  _Seccion('Copia de seguridad', Icons.cloud_sync_outlined, Icons.cloud_sync,
      () => const Proximamente('Copia de seguridad',
          'Guarda y recupera tus datos desde tu Google Drive.')),
];

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _actual = 0;

  void _ir(int i) => setState(() => _actual = i);

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width >= 900;
    final pantalla = KeyedSubtree(
      key: ValueKey(_actual),
      child: _secciones[_actual].pantalla(),
    );

    if (ancho) {
      return Scaffold(
        body: Row(
          children: [
            _MenuLateral(actual: _actual, onTap: _ir),
            Expanded(child: pantalla),
          ],
        ),
      );
    }

    // Celular: barra inferior con las secciones principales + "Más".
    final enBarra = [
      for (var i = 0; i < _secciones.length; i++)
        if (_secciones[i].enBarra) i
    ];
    final idxBarra = enBarra.indexOf(_actual);
    return Scaffold(
      body: pantalla,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idxBarra == -1 ? enBarra.length : idxBarra,
        onDestinationSelected: (i) {
          if (i < enBarra.length) {
            _ir(enBarra[i]);
          } else {
            _mostrarMas(context);
          }
        },
        destinations: [
          for (final i in enBarra)
            NavigationDestination(
              icon: Icon(_secciones[i].icono),
              selectedIcon: Icon(_secciones[i].iconoActivo),
              label: _secciones[i].titulo,
            ),
          const NavigationDestination(
              icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }

  void _mostrarMas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _secciones.length; i++)
              if (!_secciones[i].enBarra)
                ListTile(
                  leading: Icon(_secciones[i].icono, color: KipuColores.morado),
                  title: Text(_secciones[i].titulo),
                  onTap: () {
                    Navigator.pop(ctx);
                    _ir(i);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onTap;

  const _MenuLateral({required this.actual, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: KipuColores.morado,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text('Kipu',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 32),
          for (var i = 0; i < _secciones.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: i == actual ? KipuColores.morado : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          i == actual
                              ? _secciones[i].iconoActivo
                              : _secciones[i].icono,
                          color: i == actual ? Colors.white : KipuColores.tinta,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _secciones[i].titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color:
                                i == actual ? Colors.white : KipuColores.tinta,
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
