import 'package:flutter/material.dart';

import '../data/cuenta.dart';
import '../data/preferencias.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';

/// Configuración › General › Más ajustes: tamaño de letra y PIN.
class MasAjustes extends StatelessWidget {
  const MasAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Más ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Titulo('TAMAÑO DE LETRA'),
                  _Caja(
                    child: ValueListenableBuilder<double>(
                      valueListenable: escalaLetra,
                      builder: (context, escala, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final (nombre, e) in tamanosLetra)
                                ChoiceChip(
                                  label: Text(nombre),
                                  selected: (escala - e).abs() < .01,
                                  onSelected: (_) => db.guardarEscalaLetra(e),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Así se verán los textos de Kipu.',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _Titulo('BLOQUEO CON PIN'),
                  StreamBuilder<bool>(
                    stream: db.verHayPin(),
                    builder: (context, snap) {
                      final hay = snap.data ?? false;
                      return _Caja(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                KipuIcon(
                                  KipuIcono.candado,
                                  size: 26,
                                  color: KipuColores.morado,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    hay
                                        ? 'Kipu pide tu PIN al abrirse'
                                        : 'Pide un PIN de 4 números al abrir '
                                              'Kipu, para que nadie más vea '
                                              'las notas de tus estudiantes.',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (!hay)
                              FilledButton(
                                onPressed: () => _ponerPin(context),
                                child: const Text('Poner PIN'),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _ponerPin(context),
                                      child: const Text('Cambiar PIN'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _quitarPin(context),
                                      child: const Text('Quitar PIN'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const _Titulo('MUY PRONTO'),
                  const _Caja(
                    child: Text(
                      'Modo oscuro y asistente con inteligencia artificial.',
                      style: TextStyle(color: KipuColores.gris),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ponerPin(BuildContext context) async {
    final hay = await db.hayPin();
    if (!context.mounted) return;
    if (hay) {
      final ok = await pedirPin(context, 'Escribe tu PIN actual');
      if (ok != true || !context.mounted) return;
    }
    final pin = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _NuevoPin()),
    );
    if (pin == null) return;
    await db.guardarPin(pin);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN guardado')));
    }
  }

  Future<void> _quitarPin(BuildContext context) async {
    final ok = await pedirPin(context, 'Escribe tu PIN para quitarlo');
    if (ok == true) await db.quitarPin();
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 1,
        fontWeight: FontWeight.w600,
        color: KipuColores.gris,
      ),
    ),
  );
}

class _Caja extends StatelessWidget {
  final Widget child;
  const _Caja({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

/// Pide el PIN en una pantalla aparte; true si es correcto.
Future<bool?> pedirPin(BuildContext context, String titulo) =>
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: TecladoPin(
            titulo: titulo,
            onCompleto: (pin) async {
              final ok = await db.pinCorrecto(pin);
              if (ok && context.mounted) Navigator.pop(context, true);
              return ok ? null : 'PIN incorrecto';
            },
          ),
        ),
      ),
    );

/// Escribir el PIN nuevo dos veces.
class _NuevoPin extends StatefulWidget {
  const _NuevoPin();

  @override
  State<_NuevoPin> createState() => _NuevoPinState();
}

class _NuevoPinState extends State<_NuevoPin> {
  String? _primero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TecladoPin(
        key: ValueKey(_primero == null),
        titulo: _primero == null ? 'Elige un PIN de 4 números' : 'Repite tu PIN',
        onCompleto: (pin) async {
          if (_primero == null) {
            setState(() => _primero = pin);
            return null;
          }
          if (pin != _primero) {
            setState(() => _primero = null);
            return 'No coinciden. Empieza de nuevo';
          }
          Navigator.pop(context, pin);
          return null;
        },
      ),
    );
  }
}

/// Pantalla que tapa Kipu hasta escribir el PIN. Está encima del Navigator
/// de la app, así que no abre ventanas: la confirmación va en la misma
/// pantalla.
class PantallaBloqueo extends StatefulWidget {
  const PantallaBloqueo({super.key});

  @override
  State<PantallaBloqueo> createState() => _PantallaBloqueoState();
}

class _PantallaBloqueoState extends State<PantallaBloqueo> {
  bool _olvido = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _olvido
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '¿Olvidaste tu PIN?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Se cerrará tu sesión y se quitará el PIN. Para '
                          'volver a entrar necesitas el correo y la contraseña '
                          'de tu cuenta. Tus datos se quedan en este equipo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: KipuColores.gris),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () async {
                            await db.quitarPin();
                            await db.cerrarSesion();
                          },
                          child: const Text('Cerrar sesión'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => setState(() => _olvido = false),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: TecladoPin(
                      titulo: 'Escribe tu PIN',
                      onCompleto: (pin) async {
                        if (await db.pinCorrecto(pin)) {
                          appBloqueada.value = false;
                          return null;
                        }
                        return 'PIN incorrecto';
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _olvido = true),
                    child: const Text('¿Olvidaste tu PIN?'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }
}

/// Puntos y teclado numérico. [onCompleto] devuelve un error para mostrar o
/// null si el PIN se aceptó.
class TecladoPin extends StatefulWidget {
  final String titulo;
  final Future<String?> Function(String pin) onCompleto;
  const TecladoPin({super.key, required this.titulo, required this.onCompleto});

  @override
  State<TecladoPin> createState() => _TecladoPinState();
}

class _TecladoPinState extends State<TecladoPin> {
  static const _largo = 4;
  String _pin = '';
  String? _error;
  bool _ocupado = false;

  Future<void> _tecla(String t) async {
    if (_ocupado) return;
    setState(() {
      _error = null;
      if (t == '<') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < _largo) {
        _pin += t;
      }
    });
    if (_pin.length < _largo) return;
    _ocupado = true;
    final error = await widget.onCompleto(_pin);
    if (!mounted) return;
    setState(() {
      _ocupado = false;
      _pin = '';
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget tecla(String t) => Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Material(
          color: t.isEmpty ? Colors.transparent : Colors.white,
          shape: const CircleBorder(),
          child: t.isEmpty
              ? null
              : InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _tecla(t),
                  child: Center(
                    child: t == '<'
                        ? const KipuIcon(
                            KipuIcono.izquierda,
                            color: KipuColores.tinta,
                          )
                        : Text(
                            t,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
        ),
      ),
    );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KipuIcon(KipuIcono.candado, size: 44, color: KipuColores.morado),
            const SizedBox(height: 14),
            Text(
              widget.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _largo; i++)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? KipuColores.morado
                          : Colors.transparent,
                      border: Border.all(color: KipuColores.morado, width: 2),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  _error ?? '',
                  style: const TextStyle(color: Color(0xFFD0384E)),
                ),
              ),
            ),
            for (final fila in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['', '0', '<'],
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (final t in fila) tecla(t)],
              ),
          ],
        ),
      ),
    );
  }
}
