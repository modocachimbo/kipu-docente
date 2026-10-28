import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'cursos.dart' show confirmar;

class Configuracion extends StatelessWidget {
  const Configuracion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: KipuIcon(
                    KipuIcono.editar,
                    color: KipuColores.morado,
                  ),
                  title: const Text('Editar mi perfil'),
                  subtitle: const Text('Nombre, ciudad y personaje'),
                  onTap: () => editarPerfil(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: KipuColores.morado,
                  ),
                  title: const Text('Color de la app'),
                  subtitle: Text(estiloActual.value.nombre),
                  onTap: () => elegirEstilo(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: KipuIcon(
                    KipuIcono.estudiantes,
                    color: KipuColores.morado,
                  ),
                  title: const Text('Cargar datos de ejemplo'),
                  subtitle: const Text(
                    'Llena la app con colegios, alumnos y notas inventados para probarla',
                  ),
                  onTap: () async {
                    if (await confirmar(
                      context,
                      '¿Cargar datos de ejemplo?',
                      'Se reemplazarán los colegios, cursos y alumnos que tengas ahora.',
                      accion: 'Cargar',
                    )) {
                      await cargarDatosDeEjemplo(db);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Datos de ejemplo cargados'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFE5566B),
                  ),
                  title: const Text('Borrar todos mis datos'),
                  subtitle: const Text(
                    'Colegios, cursos, alumnos, asistencia, notas y calendario',
                  ),
                  onTap: () async {
                    if (await confirmar(
                      context,
                      '¿Borrar todo?',
                      'Esta acción no se puede deshacer.',
                    )) {
                      await db.borrarTodo();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> editarPerfil(BuildContext context) async {
  final nombre = TextEditingController(text: await db.leerAjuste('nombre'));
  final lugar = TextEditingController(text: await db.leerAjuste('lugar'));
  var genero = await db.leerAjuste('genero') ?? 'profesor';
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Mi perfil'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'profesor', label: Text('Profesor')),
                  ButtonSegment(value: 'profesora', label: Text('Profesora')),
                ],
                selected: {genero},
                onSelectionChanged: (s) => setState(() => genero = s.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombre,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lugar,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Ciudad'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (nombre.text.trim().isEmpty) return;
              await db.guardarAjuste('nombre', nombre.text.trim());
              await db.guardarAjuste('lugar', lugar.text.trim());
              await db.guardarAjuste('genero', genero);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

Future<void> elegirEstilo(BuildContext context) async {
  final elegido = await showDialog<KipuEstilo>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Color de la app'),
      content: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final e in estilosKipu)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(ctx, e),
              child: SizedBox(
                width: 64,
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [e.principal, e.oscuro],
                        ),
                        border: e.id == estiloActual.value.id
                            ? Border.all(color: KipuColores.tinta, width: 3)
                            : null,
                      ),
                      child: e.id == estiloActual.value.id
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(e.nombre, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
  if (elegido == null) return;
  await db.guardarAjuste('estilo', elegido.id);
  estiloActual.value = elegido;
}
