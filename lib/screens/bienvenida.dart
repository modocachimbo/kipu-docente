import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../main.dart';
import '../theme.dart';

/// Primer ingreso: sin cuenta ni internet, solo el nombre del docente.
class Bienvenida extends StatefulWidget {
  const Bienvenida({super.key});

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _lugar = TextEditingController();
  String _genero = 'profesor';

  Future<void> _empezar() async {
    if (!_form.currentState!.validate()) return;
    await db.guardarAjuste('genero', _genero);
    await db.guardarAjuste('lugar', _lugar.text.trim());
    await db.guardarAjuste('nombre', _nombre.text.trim());
  }

  Future<void> _explorar() async {
    await cargarDatosDeEjemplo(db);
    await db.guardarAjuste('genero', _genero);
    await db.guardarAjuste('lugar',
        _lugar.text.trim().isEmpty ? 'Huacho, Perú' : _lugar.text.trim());
    await db.guardarAjuste('nombre',
        _nombre.text.trim().isEmpty ? 'Javier Rojas' : _nombre.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 28),
                    Text('Bienvenido a Kipu',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text(
                      'Tu registro docente: notas, asistencia y estudiantes, '
                      'aunque no tengas internet.',
                      style: TextStyle(color: KipuColores.gris),
                    ),
                    const SizedBox(height: 28),
                    const Text('¿Cómo te presentamos?',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _OpcionGenero(
                          imagen: 'assets/img/profesor.png',
                          texto: 'Profesor',
                          elegido: _genero == 'profesor',
                          onTap: () => setState(() => _genero = 'profesor'),
                        ),
                        const SizedBox(width: 14),
                        _OpcionGenero(
                          imagen: 'assets/img/profesora.png',
                          texto: 'Profesora',
                          elegido: _genero == 'profesora',
                          onTap: () => setState(() => _genero = 'profesora'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tu nombre',
                        hintText: 'Ej. Javier Rojas',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Escribe tu nombre'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _lugar,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad (opcional)',
                        hintText: 'Ej. Huacho, Perú',
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _empezar,
                      child: const Text('Empezar'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _explorar,
                      child: const Text('Explorar con datos de ejemplo'),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tus datos se guardan en este dispositivo. Luego podrás '
                      'activar la copia de seguridad en tu Google Drive.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: KipuColores.gris),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _OpcionGenero extends StatelessWidget {
  final String imagen;
  final String texto;
  final bool elegido;
  final VoidCallback onTap;

  const _OpcionGenero({
    required this.imagen,
    required this.texto,
    required this.elegido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
          decoration: BoxDecoration(
            color: elegido ? KipuColores.moradoClaro : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: elegido ? KipuColores.morado : const Color(0xFFDCD8F5),
              width: elegido ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 120, child: Image.asset(imagen)),
              const SizedBox(height: 8),
              Text(texto,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: elegido ? KipuColores.moradoOscuro : KipuColores.tinta,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
