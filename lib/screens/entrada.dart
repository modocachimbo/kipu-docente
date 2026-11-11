import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/cuenta.dart';
import '../data/demo.dart';
import '../data/legal.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'cuenta.dart';
import 'cursos.dart' show confirmar;

/// Primera pantalla al abrir Kipu: crear cuenta o iniciar sesión. Sin cuenta
/// no se ve nada de la app.
class Entrada extends StatelessWidget {
  const Entrada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth >= 900) {
            return Row(
              children: [
                const SizedBox(width: 440, child: _PanelMorado()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: const _Formulario(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Logo(centrado: true),
                      const SizedBox(height: 8),
                      const SizedBox(height: 150, child: _Personajes()),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu enseñanza, bien organizada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _Formulario(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PanelMorado extends StatelessWidget {
  const _PanelMorado();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KipuColores.morado,
            Color.lerp(KipuColores.morado, Colors.white, .25)!,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(36, 36, 36, 0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Logo(claro: true),
          SizedBox(height: 40),
          Text(
            'Tu enseñanza,\nbien organizada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Cursos, asistencia, notas, horario y planificación.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Spacer(),
          SizedBox(height: 330, child: _Personajes()),
        ],
      ),
    );
  }
}

/// La profesora y el profesor juntos.
class _Personajes extends StatelessWidget {
  const _Personajes();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: FractionallySizedBox(
            heightFactor: .96,
            child: Image.asset('assets/img/profesora.png'),
          ),
        ),
        Flexible(child: Image.asset('assets/img/profesor.png')),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final bool claro;
  final bool centrado;
  const _Logo({this.claro = false, this.centrado = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centrado
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: claro ? Colors.white : KipuColores.morado,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: KipuIcon(
              KipuIcono.cursos,
              size: 24,
              color: claro ? KipuColores.morado : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Kipu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: claro ? Colors.white : KipuColores.tinta,
          ),
        ),
      ],
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario();

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  bool _crear = true;
  bool _acepto = false;
  bool _verClave = false;
  bool _ocupado = false;
  String? _error;
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();

  Future<void> _enviar() async {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    if (_crear && !_acepto) {
      setState(
        () => _error =
            'Para crear tu cuenta acepta los Términos de uso y la '
            'Política de privacidad.',
      );
      return;
    }
    setState(() => _ocupado = true);
    final error = _crear
        ? await db.crearCuentaCorreo(correo: _correo.text, clave: _clave.text)
        : await db.iniciarSesionCorreo(_correo.text, _clave.text);
    if (mounted) {
      setState(() {
        _ocupado = false;
        _error = error;
      });
    }
  }

  Future<void> _social(String nombre) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Entrar con $nombre'),
      content: Text(
        'Muy pronto podrás entrar con tu cuenta de $nombre. Mientras tanto, '
        '${_crear ? 'crea tu cuenta' : 'inicia sesión'} con tu correo o usa '
        'la cuenta de prueba.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );

  Future<void> _prueba() async {
    // La cuenta de prueba reemplaza los datos de este equipo: si ya hay una
    // cuenta real aquí, se pide confirmar.
    final actual = await db.leerCuenta();
    if (!mounted) return;
    if (actual != null && actual.proveedor != 'demo') {
      final ok = await confirmar(
        context,
        '¿Entrar con la cuenta de prueba?',
        'En este equipo está la cuenta ${actual.correo}. La cuenta de prueba '
            'reemplazará sus colegios, cursos y notas por datos de ejemplo, y '
            'no hay forma de recuperarlos.',
        accion: 'Reemplazar',
      );
      if (!ok || !mounted) return;
    }
    setState(() => _ocupado = true);
    await db.entrarConCuentaDePrueba(() => cargarDatosDeEjemplo(db));
  }

  void _abrirLegal(DocumentoLegal d) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PantallaLegal(d)),
  );

  @override
  Widget build(BuildContext context) {
    final enlace = TextStyle(
      color: KipuColores.morado,
      fontWeight: FontWeight.w600,
    );
    final legal = <InlineSpan>[
      TextSpan(
        text: 'Términos de uso',
        style: enlace,
        recognizer: TapGestureRecognizer()
          ..onTap = () => _abrirLegal(terminosUso),
      ),
      const TextSpan(text: ' y la '),
      TextSpan(
        text: 'Política de privacidad',
        style: enlace,
        recognizer: TapGestureRecognizer()
          ..onTap = () => _abrirLegal(politicaPrivacidad),
      ),
    ];
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, label: Text('Crear cuenta')),
              ButtonSegment(value: false, label: Text('Iniciar sesión')),
            ],
            selected: {_crear},
            onSelectionChanged: (s) => setState(() {
              _crear = s.first;
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          _BotonSocial(
            letra: 'G',
            color: const Color(0xFF4285F4),
            texto: 'Continuar con Google',
            onTap: () => _social('Google'),
          ),
          const SizedBox(height: 8),
          _BotonSocial(
            letra: 'f',
            color: const Color(0xFF1877F2),
            texto: 'Continuar con Facebook',
            onTap: () => _social('Facebook'),
          ),
          const _Separador('o con tu correo'),
          TextFormField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Correo'),
            validator: (v) =>
                correoValido(v ?? '') ? null : 'Escribe un correo válido',
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _clave,
            obscureText: !_verClave,
            autofillHints: [
              _crear ? AutofillHints.newPassword : AutofillHints.password,
            ],
            onFieldSubmitted: (_) => _enviar(),
            decoration: InputDecoration(
              labelText: _crear ? 'Contraseña (mínimo 6)' : 'Contraseña',
              suffixIcon: IconButton(
                tooltip: _verClave ? 'Ocultar' : 'Mostrar',
                icon: Icon(
                  _verClave ? Icons.visibility_off : Icons.visibility,
                  color: KipuColores.gris,
                ),
                onPressed: () => setState(() => _verClave = !_verClave),
              ),
            ),
            validator: (v) => (v ?? '').length < 6
                ? 'La contraseña debe tener al menos 6 caracteres'
                : null,
          ),
          if (_crear) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _acepto = !_acepto),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acepto,
                    onChanged: (v) => setState(() => _acepto = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 13.5, height: 1.4),
                          children: [
                            const TextSpan(text: 'Acepto los '),
                            ...legal,
                            const TextSpan(text: ' de Kipu'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Olvidaste tu contraseña?'),
                    content: const Text(
                      'Por ahora tu cuenta se guarda solo en este equipo, así '
                      'que la contraseña no se puede recuperar por correo. '
                      'Cuando se active el inicio con Google podrás entrar sin '
                      'contraseña.',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                ),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFD0384E), fontSize: 13.5),
              ),
            ),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: _ocupado ? null : _enviar,
            child: Text(_crear ? 'Crear cuenta' : 'Iniciar sesión'),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 12.5, color: KipuColores.gris),
              children: _crear
                  ? const [
                      TextSpan(
                        text:
                            'Después eliges: probar 7 días gratis o comprar '
                            'tu plan.',
                      ),
                    ]
                  : [
                      const TextSpan(
                        text: 'Al continuar con Google o Facebook aceptas los ',
                      ),
                      ...legal,
                      const TextSpan(text: '.'),
                    ],
            ),
            textAlign: TextAlign.center,
          ),
          const _Separador('¿Solo quieres mirar?'),
          OutlinedButton(
            onPressed: _ocupado ? null : _prueba,
            child: const Text('Entrar con la cuenta de prueba'),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ya viene con colegios, cursos y notas de ejemplo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
          ),
        ],
      ),
    );
  }
}

class _BotonSocial extends StatelessWidget {
  final String letra;
  final Color color;
  final String texto;
  final VoidCallback onTap;

  const _BotonSocial({
    required this.letra,
    required this.color,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: KipuColores.tinta,
        side: const BorderSide(color: Color(0xFFDAD9E6), width: 1.4),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letra,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  final String texto;
  const _Separador(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            texto,
            style: const TextStyle(fontSize: 13, color: KipuColores.gris),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );
}

// ------------------------------------------------------- Elegir cómo empezar

/// Justo después de crear la cuenta: probar 7 días gratis o comprar un plan.
class ElegirPlan extends StatelessWidget {
  const ElegirPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '¡Bienvenido a Kipu!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Prueba Kipu completo o elige tu plan.',
                    style: TextStyle(color: KipuColores.gris, fontSize: 15),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          KipuColores.morado,
                          Color.lerp(KipuColores.morado, Colors.white, .2)!,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '$diasPrueba días gratis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Todo Kipu, sin tarjeta. Tus datos no se borran '
                          'cuando termina.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: KipuColores.morado,
                          ),
                          onPressed: () => db.empezarPlan('prueba'),
                          child: const Text('Probar 7 días gratis'),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 22, 0, 12),
                    child: Text(
                      'O COMPRA TU PLAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                  const SelectorPlanes(),
                  TextButton(
                    onPressed: () => pedirCerrarSesion(context),
                    child: const Text('Salir y usar otra cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
