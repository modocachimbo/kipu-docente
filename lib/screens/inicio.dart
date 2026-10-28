import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../main.dart';
import '../theme.dart';
import 'curso_detalle.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text('Inicio',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const Text('Tu enseñanza, bien organizada',
                style: TextStyle(color: KipuColores.morado, fontSize: 13)),
            const SizedBox(height: 18),
            const _Saludo(),
            const SizedBox(height: 18),
            const _Resumen(),
            const SizedBox(height: 26),
            const Text('Mis cursos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const _CursosRecientes(),
          ],
        ),
      ),
    );
  }
}

class _Saludo extends StatelessWidget {
  const _Saludo();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: db.verAjuste('genero'),
      builder: (context, genero) => StreamBuilder<String?>(
        stream: db.verAjuste('nombre'),
        builder: (context, nombre) {
          final esProfesora = genero.data == 'profesora';
          final primerNombre = (nombre.data ?? '').split(' ').first;
          final hoy = DateFormat("EEEE d 'de' MMMM", 'es_PE')
              .format(DateTime.now());
          return Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [KipuColores.morado, KipuColores.moradoOscuro],
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned(
                  left: 4,
                  bottom: -70,
                  child: Image.asset(
                    esProfesora
                        ? 'assets/img/profesora.png'
                        : 'assets/img/profesor.png',
                    height: 230,
                  ),
                ),
                Positioned(
                  left: 120,
                  right: 18,
                  top: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hoy[0].toUpperCase() + hoy.substring(1),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${esProfesora ? 'Bienvenida' : 'Bienvenido'}, '
                        'Prof. $primerNombre',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '¡Que tengas un gran día de clases!',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: db.verResumen(),
      builder: (context, snap) {
        final r = snap.data;
        final items = [
          (Icons.account_balance, r?.colegios ?? 0, 'Colegios'),
          (Icons.menu_book, r?.cursos ?? 0, 'Cursos'),
          (Icons.groups, r?.secciones ?? 0, 'Secciones'),
          (Icons.school, r?.estudiantes ?? 0, 'Estudiantes'),
        ];
        return LayoutBuilder(builder: (context, c) {
          final columnas = c.maxWidth >= 640 ? 4 : 2;
          final ancho = (c.maxWidth - 12 * (columnas - 1)) / columnas;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < items.length; i++)
                Container(
                  width: ancho,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: KipuColores.tarjetas[i]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(items[i].$1,
                            size: 20, color: KipuColores.tarjetas[i][0]),
                      ),
                      const SizedBox(height: 10),
                      Text('${items[i].$2}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      Text(items[i].$3,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}

class _CursosRecientes extends StatelessWidget {
  const _CursosRecientes();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CursoConColegio>>(
      stream: db.verCursos(),
      builder: (context, snap) {
        final cursos = snap.data ?? [];
        if (cursos.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: KipuColores.morado),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                        'Empieza creando tu colegio y tus cursos en la '
                        'pestaña "Mis cursos".'),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final c in cursos.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: KipuColores.moradoClaro,
                      child: Text(c.curso.seccion,
                          style: const TextStyle(
                              color: KipuColores.moradoOscuro,
                              fontWeight: FontWeight.w700)),
                    ),
                    title: Text(c.curso.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${c.curso.grado} ${c.curso.seccion} · ${c.colegio.nombre}'),
                    trailing: Text('${c.totalEstudiantes} est.',
                        style: const TextStyle(color: KipuColores.gris)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CursoDetalle(datos: c)),
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
