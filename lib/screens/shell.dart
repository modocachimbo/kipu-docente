import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'asistencia.dart';
import 'configuracion.dart';
import 'cursos.dart';
import 'inicio.dart';
import 'proximamente.dart';

class _Seccion {
  final String titulo;
  final KipuIcono icono;
  final bool enBarra; // visible en la barra inferior del celular
  final Widget Function() pantalla;

  const _Seccion(
    this.titulo,
    this.icono,
    this.pantalla, {
    this.enBarra = false,
  });
}

final _secciones = <_Seccion>[
  _Seccion('Dashboard', KipuIcono.inicio, () => const Inicio(), enBarra: true),
  _Seccion(
    'Mis cursos',
    KipuIcono.cursos,
    () => const MisCursos(),
    enBarra: true,
  ),
  _Seccion(
    'Asistencia',
    KipuIcono.asistencia,
    () => const Asistencia(),
    enBarra: true,
  ),
  _Seccion(
    'Horario',
    KipuIcono.horario,
    () => const Proximamente(
      'Horario',
      'Tus clases de la semana con recordatorios.',
    ),
  ),
  _Seccion(
    'Reportes',
    KipuIcono.reportes,
    () => const Proximamente(
      'Reportes',
      'Registro auxiliar, consolidado y libretas en PDF y Excel.',
    ),
  ),
  _Seccion(
    'Mi diario',
    KipuIcono.diario,
    () => const Proximamente(
      'Mi diario',
      'Anecdotario y observaciones por estudiante.',
    ),
  ),
  _Seccion(
    'Planificación',
    KipuIcono.planificacion,
    () => const Proximamente(
      'Planificación',
      'Planificación anual, unidades y sesiones de aprendizaje.',
    ),
  ),
  _Seccion(
    'Evaluación',
    KipuIcono.notas,
    () => const Proximamente(
      'Evaluación',
      'Calificación por competencias con la escala AD, A, B y C.',
    ),
    enBarra: true,
  ),
  _Seccion('Configuración', KipuIcono.ajustes, () => const Configuracion()),
  _Seccion(
    'Sincronizar',
    KipuIcono.copia,
    () => const Proximamente(
      'Sincronizar',
      'Guarda y recupera tus datos desde tu Google Drive.',
    ),
  ),
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
        if (_secciones[i].enBarra) i,
    ];
    final idxBarra = enBarra.indexOf(_actual);
    final elegido = idxBarra == -1 ? enBarra.length : idxBarra;
    return Scaffold(
      body: pantalla,
      bottomNavigationBar: NavigationBar(
        selectedIndex: elegido,
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
              icon: KipuIcon(_secciones[i].icono, color: KipuColores.tinta),
              selectedIcon: KipuIcon(
                _secciones[i].icono,
                color: KipuColores.morado,
              ),
              label: i == 0 ? 'Inicio' : _secciones[i].titulo,
            ),
          NavigationDestination(
            icon: KipuIcon(KipuIcono.mas, color: KipuColores.tinta),
            selectedIcon: KipuIcon(KipuIcono.mas, color: KipuColores.morado),
            label: 'Más',
          ),
        ],
      ),
    );
  }

  void _mostrarMas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _secciones.length; i++)
              if (!_secciones[i].enBarra)
                ListTile(
                  leading: KipuIcon(
                    _secciones[i].icono,
                    color: KipuColores.morado,
                  ),
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

  Widget _item(String titulo, KipuIcono icono, bool activo, VoidCallback tap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: activo ? KipuColores.morado : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                KipuIcon(
                  icono,
                  size: 24,
                  color: activo ? Colors.white : KipuColores.tinta,
                ),
                const SizedBox(width: 14),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: activo ? Colors.white : KipuColores.tinta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: KipuColores.morado,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: KipuIcon(
                    KipuIcono.cursos,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kipu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < _secciones.length; i++)
                  _item(
                    _secciones[i].titulo,
                    _secciones[i].icono,
                    i == actual,
                    () => onTap(i),
                  ),
              ],
            ),
          ),
          _item('Ayuda', KipuIcono.ayuda, false, () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Ayuda'),
                content: const Text(
                  'Kipu guarda todo en este dispositivo y funciona sin internet. '
                  'Empieza en "Mis cursos" creando tu colegio, o carga datos de '
                  'ejemplo desde "Configuración" para explorar.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
