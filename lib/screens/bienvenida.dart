import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/cuenta.dart';
import '../main.dart';
import '../theme.dart';

/// Último paso al crear la cuenta: los datos del docente. El personaje
/// (profesora o profesor) se elige solo según el sexo.
class CompletarPerfil extends StatelessWidget {
  const CompletarPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const FormularioPerfil(
                titulo: 'Completa tu perfil',
                subtitulo: 'Último paso · lo puedes cambiar después en Mi perfil',
                boton: 'Entrar a Kipu',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Editar los datos desde Mi perfil.
class EditarPerfil extends StatelessWidget {
  const EditarPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar mis datos')),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FormularioPerfil(
              boton: 'Guardar',
              alGuardar: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

class FormularioPerfil extends StatefulWidget {
  final String? titulo;
  final String? subtitulo;
  final String boton;
  final VoidCallback? alGuardar;

  const FormularioPerfil({
    super.key,
    required this.boton,
    this.titulo,
    this.subtitulo,
    this.alGuardar,
  });

  @override
  State<FormularioPerfil> createState() => _FormularioPerfilState();
}

class _FormularioPerfilState extends State<FormularioPerfil> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _lugar = TextEditingController();
  final _celular = TextEditingController();
  String? _genero;
  DateTime? _cumple;
  bool _faltaSexo = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final nombre = await db.leerAjuste('nombre');
    final cuenta = await db.leerCuenta();
    final genero = await db.leerAjuste('genero');
    final cumple = await db.leerAjuste('cumple');
    _nombre.text = (nombre?.isNotEmpty ?? false)
        ? nombre!
        : (cuenta?.nombre ?? '');
    _lugar.text = await db.leerAjuste('lugar') ?? '';
    _celular.text = await db.leerAjuste('celular') ?? '';
    if (!mounted) return;
    setState(() {
      // En un perfil nuevo no se marca ningún sexo hasta que el docente elija.
      _genero = nombre == null ? null : (genero ?? 'profesor');
      _cumple = DateTime.tryParse(cumple ?? '');
    });
  }

  Future<void> _elegirCumple() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _cumple ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.input,
      helpText: 'Tu cumpleaños',
    );
    if (d != null) setState(() => _cumple = d);
  }

  Future<void> _guardar() async {
    final ok = _form.currentState!.validate();
    setState(() => _faltaSexo = _genero == null);
    if (!ok || _genero == null) return;
    await db.guardarPerfil(
      nombre: _nombre.text,
      genero: _genero!,
      lugar: _lugar.text,
      cumple: _cumple,
      celular: _celular.text,
    );
    widget.alGuardar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final mujer = _genero == 'profesora';
    final primerNombre = _nombre.text.trim().split(' ').first;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.titulo != null) ...[
            Text(
              widget.titulo!,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitulo ?? '',
              style: const TextStyle(color: KipuColores.gris, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
          // Vista previa: el personaje y el saludo cambian solos.
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _genero == null ? 110 : 62,
                  height: 130,
                  child: _genero == null
                      ? Row(
                          children: [
                            Expanded(
                              child: Image.asset('assets/img/profesora.png'),
                            ),
                            Expanded(
                              child: Image.asset('assets/img/profesor.png'),
                            ),
                          ],
                        )
                      : Image.asset(
                          mujer
                              ? 'assets/img/profesora.png'
                              : 'assets/img/profesor.png',
                          alignment: Alignment.topCenter,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Así te saludará Kipu',
                        style: TextStyle(fontSize: 13, color: KipuColores.gris),
                      ),
                      Text(
                        _genero == null
                            ? '¡Hola${primerNombre.isEmpty ? '' : ', $primerNombre'}!'
                            : '¡Hola, ${mujer ? 'Profesora' : 'Profesor'}'
                                  '${primerNombre.isEmpty ? '' : ' $primerNombre'}!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'El personaje se elige solo según tus datos',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: KipuColores.morado,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _nombre,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Nombres y apellidos',
              hintText: 'Ej. Lucía Ramos Flores',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
          ),
          const SizedBox(height: 16),
          const Text('Sexo', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _OpcionSexo(
                imagen: 'assets/img/profesora.png',
                texto: 'Mujer',
                elegido: _genero == 'profesora',
                onTap: () => setState(() {
                  _genero = 'profesora';
                  _faltaSexo = false;
                }),
              ),
              const SizedBox(width: 10),
              _OpcionSexo(
                imagen: 'assets/img/profesor.png',
                texto: 'Hombre',
                elegido: _genero == 'profesor',
                onTap: () => setState(() {
                  _genero = 'profesor';
                  _faltaSexo = false;
                }),
              ),
            ],
          ),
          if (_faltaSexo)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 12),
              child: Text(
                'Elige una opción',
                style: TextStyle(color: Color(0xFFD0384E), fontSize: 12.5),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _elegirCumple,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Cumpleaños',
                      helperText: 'Opcional',
                    ),
                    child: Text(
                      _cumple == null
                          ? 'Elegir'
                          : DateFormat('dd/MM/yyyy').format(_cumple!),
                      style: TextStyle(
                        color: _cumple == null
                            ? KipuColores.gris
                            : KipuColores.tinta,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _celular,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    helperText: 'Opcional',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _lugar,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ciudad',
              hintText: 'Ej. Huacho, Perú',
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(onPressed: _guardar, child: Text(widget.boton)),
        ],
      ),
    );
  }
}

class _OpcionSexo extends StatelessWidget {
  final String imagen;
  final String texto;
  final bool elegido;
  final VoidCallback onTap;

  const _OpcionSexo({
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: elegido ? KipuColores.moradoClaro : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: elegido ? KipuColores.morado : const Color(0xFFCFCDE0),
              width: elegido ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                clipBehavior: Clip.antiAlias,
                child: Transform.scale(
                  scale: 2.6,
                  alignment: const Alignment(0, -0.82),
                  child: Image.asset(imagen, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                texto,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: elegido ? KipuColores.moradoOscuro : KipuColores.tinta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
