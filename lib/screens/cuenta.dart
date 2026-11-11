import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/cuenta.dart';
import '../data/legal.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'bienvenida.dart' show EditarPerfil;
import 'cursos.dart' show confirmar;
import 'shell.dart' show irASeccion;

const _rojo = Color(0xFFD0384E);

// ------------------------------------------------------------- Foto docente

/// Cara del personaje del docente, recortada en un círculo.
class FotoDocente extends StatelessWidget {
  final double tamano;
  const FotoDocente({super.key, this.tamano = 52});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: db.verAjuste('genero'),
      builder: (context, genero) => Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KipuColores.moradoClaro,
          border: Border.all(color: KipuColores.morado, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale: 2.6,
          alignment: const Alignment(0, -0.82),
          child: Image.asset(
            genero.data == 'profesora'
                ? 'assets/img/profesora.png'
                : 'assets/img/profesor.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------- Menú de la foto docente

/// Menú que se abre al tocar la foto del Dashboard: en PC sale arriba a la
/// derecha y en el celular sube desde abajo.
Future<void> abrirMenuCuenta(BuildContext context) {
  final pantalla = MediaQuery.sizeOf(context);
  if (pantalla.width >= 700) {
    // El menú sale justo debajo de la foto que se tocó.
    final caja = context.findRenderObject() as RenderBox?;
    final pos = caja?.localToGlobal(Offset.zero) ?? Offset.zero;
    final derecha = caja == null
        ? 24.0
        : (pantalla.width - pos.dx - caja.size.width).clamp(8.0, 2000.0);
    final arriba = caja == null ? 90.0 : pos.dy + caja.size.height + 8;
    return showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (ctx) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: arriba, right: derecha),
          child: Material(
            color: Colors.white,
            elevation: 12,
            shadowColor: KipuColores.tinta.withValues(alpha: .25),
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _MenuCuenta(cerrar: () => Navigator.pop(ctx)),
              ),
            ),
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: _MenuCuenta(cerrar: () => Navigator.pop(ctx)),
      ),
    ),
  );
}

class _MenuCuenta extends StatelessWidget {
  final VoidCallback cerrar;
  const _MenuCuenta({required this.cerrar});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    void abrir(Widget w) {
      cerrar();
      nav.push(MaterialPageRoute(builder: (_) => w));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 10),
          child: _Quien(),
        ),
        const Divider(height: 1),
        const SizedBox(height: 6),
        _ItemMenu(
          icono: KipuIcono.estudiantes,
          texto: 'Mi perfil',
          onTap: () => abrir(const MiCuenta()),
        ),
        _ItemMenu(
          icono: KipuIcono.estrella,
          texto: 'Mi plan',
          extra: const _PildoraPlan(),
          onTap: () => abrir(const PantallaPlanes()),
        ),
        _ItemMenu(
          icono: KipuIcono.engranaje,
          texto: 'Configuración',
          onTap: () {
            cerrar();
            nav.popUntil((r) => r.isFirst);
            irASeccion('General');
          },
        ),
        _ItemMenu(
          icono: KipuIcono.ayuda,
          texto: 'Términos y privacidad',
          onTap: () => abrir(const PantallaLegal(politicaPrivacidad)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Divider(height: 1),
        ),
        _ItemMenu(
          icono: KipuIcono.salir,
          texto: 'Cerrar sesión',
          color: _rojo,
          onTap: () async {
            cerrar();
            await pedirCerrarSesion(context);
          },
        ),
      ],
    );
  }
}

Future<void> pedirCerrarSesion(BuildContext context) async {
  if (await confirmar(
    context,
    '¿Cerrar sesión?',
    'Tus datos se quedan guardados en este equipo. Para volver a verlos, '
        'inicia sesión con la misma cuenta.',
    accion: 'Cerrar sesión',
  )) {
    await db.cerrarSesion();
  }
}

class _ItemMenu extends StatelessWidget {
  final KipuIcono icono;
  final String texto;
  final Widget? extra;
  final Color? color;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.extra,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? KipuColores.tinta;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            KipuIcon(icono, size: 21, color: c),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(fontSize: 15.5, color: c),
              ),
            ),
            ?extra,
          ],
        ),
      ),
    );
  }
}

/// Foto, nombre y correo del docente.
class _Quien extends StatelessWidget {
  const _Quien();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Cuenta?>(
      stream: db.verCuenta(),
      builder: (context, cuenta) => StreamBuilder<String?>(
        stream: db.verAjuste('nombre'),
        builder: (context, nombre) => StreamBuilder<String?>(
          stream: db.verAjuste('genero'),
          builder: (context, genero) {
            final n = (nombre.data?.isNotEmpty ?? false)
                ? nombre.data!
                : (cuenta.data?.nombre ?? '');
            return Row(
              children: [
                const FotoDocente(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.isEmpty ? 'Docente' : 'Prof. $n',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (cuenta.data != null)
                        Text(
                          cuenta.data!.correo,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: KipuColores.gris,
                          ),
                        ),
                    ],
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

class _PildoraPlan extends StatelessWidget {
  const _PildoraPlan();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Plan?>(
      stream: db.verPlan(),
      builder: (context, snap) {
        final p = snap.data;
        if (p == null) return const SizedBox.shrink();
        final dias = p.diasRestantes();
        final (texto, fondo, tinta) = p.vencido()
            ? (
                p.esPrueba ? 'Prueba terminada' : 'Plan vencido',
                const Color(0xFFFCE4E8),
                _rojo,
              )
            : p.esPrueba
            ? (
                'Prueba · $dias ${dias == 1 ? 'día' : 'días'}',
                const Color(0xFFFDE9DB),
                const Color(0xFFC25A16),
              )
            : (p.nombre, const Color(0xFFD9F4EC), const Color(0xFF16A37F));
        return _Pildora(texto, fondo, tinta);
      },
    );
  }
}

class _Pildora extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color tinta;
  const _Pildora(this.texto, this.fondo, this.tinta);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: tinta,
      ),
    ),
  );
}

// ---------------------------------------------------------------- Mi cuenta

class MiCuenta extends StatelessWidget {
  const MiCuenta({super.key});

  @override
  Widget build(BuildContext context) {
    void ir(Widget w) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: _Centrado(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const FotoDocente(tamano: 76),
                  const SizedBox(height: 8),
                  StreamBuilder<String?>(
                    stream: db.verAjuste('nombre'),
                    builder: (context, n) => Text(
                      'Prof. ${n.data ?? ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StreamBuilder<Cuenta?>(
                    stream: db.verCuenta(),
                    builder: (context, c) => Text(
                      c.data == null
                          ? ''
                          : '${c.data!.correo} · entraste con '
                                '${c.data!.nombreProveedor}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KipuColores.gris,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _Titulo('MIS DATOS'),
          const _MisDatos(),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => ir(const EditarPerfil()),
            child: const Text('Editar mis datos'),
          ),
          const _Titulo('MI PLAN'),
          const _TarjetaMiPlan(),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                _Fila(
                  'Términos de uso',
                  onTap: () => ir(const PantallaLegal(terminosUso)),
                ),
                const Divider(height: 1),
                _Fila(
                  'Política de privacidad',
                  onTap: () => ir(const PantallaLegal(politicaPrivacidad)),
                ),
                const Divider(height: 1),
                _Fila(
                  'Cerrar sesión',
                  onTap: () async {
                    await pedirCerrarSesion(context);
                    if (context.mounted) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    }
                  },
                ),
                const Divider(height: 1),
                _Fila(
                  'Borrar mi cuenta',
                  color: _rojo,
                  sub: 'Borra tu cuenta y todos tus datos',
                  onTap: () => _borrarCuenta(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _borrarCuenta(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _DialogoBorrar(),
    );
    if (ok != true) return;
    await db.borrarCuenta();
    if (context.mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }
}

/// Para borrar hay que escribir BORRAR, así no pasa por accidente.
class _DialogoBorrar extends StatefulWidget {
  const _DialogoBorrar();

  @override
  State<_DialogoBorrar> createState() => _DialogoBorrarState();
}

class _DialogoBorrarState extends State<_DialogoBorrar> {
  final _texto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final listo = _texto.text.trim().toUpperCase() == 'BORRAR';
    return AlertDialog(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4E8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            '!',
            style: TextStyle(
              color: _rojo,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      title: const Text('¿Borrar tu cuenta?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text.rich(
              TextSpan(
                style: TextStyle(height: 1.45),
                children: [
                  TextSpan(text: 'Se borrarán tu cuenta y '),
                  TextSpan(
                    text: 'todos tus datos',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ': colegios, cursos, estudiantes, notas, asistencia y '
                        'configuración. ',
                  ),
                  TextSpan(
                    text: 'No hay forma de recuperarlos después.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Borrar la cuenta no cancela tu suscripción. Cancélala en '
                'Google Play › Pagos y suscripciones para que no te cobren.',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A4B12)),
              ),
            ),
            const SizedBox(height: 14),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Escribe '),
                  TextSpan(
                    text: 'BORRAR',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' para confirmar'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _texto,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'BORRAR'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _rojo),
          onPressed: listo ? () => Navigator.pop(context, true) : null,
          child: const Text('Borrar todo'),
        ),
      ],
    );
  }
}

class _MisDatos extends StatelessWidget {
  const _MisDatos();

  @override
  Widget build(BuildContext context) {
    Widget dato(String clave, String titulo, String Function(String) mostrar) =>
        StreamBuilder<String?>(
          stream: db.verAjuste(clave),
          builder: (context, v) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                Text(titulo, style: const TextStyle(color: KipuColores.gris)),
                const Spacer(),
                Text(
                  (v.data ?? '').isEmpty ? '—' : mostrar(v.data!),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          children: [
            dato('genero', 'Sexo', (g) => g == 'profesora' ? 'Mujer' : 'Hombre'),
            const Divider(height: 1),
            dato('cumple', 'Cumpleaños', (c) {
              final d = DateTime.tryParse(c);
              return d == null ? '—' : DateFormat("d 'de' MMMM", 'es').format(d);
            }),
            const Divider(height: 1),
            dato('celular', 'Celular', (c) => c),
            const Divider(height: 1),
            dato('lugar', 'Ciudad', (c) => c),
          ],
        ),
      ),
    );
  }
}

/// Abre la página de suscripciones de Google Play.
Future<void> abrirSuscripcionesPlay() => launchUrl(
  Uri.parse('https://play.google.com/store/account/subscriptions'),
  mode: LaunchMode.externalApplication,
);

class _TarjetaMiPlan extends StatelessWidget {
  const _TarjetaMiPlan();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Plan?>(
      stream: db.verPlan(),
      builder: (context, snap) {
        final p = snap.data;
        if (p == null) return const SizedBox.shrink();
        final dias = p.diasRestantes();
        final fin = DateFormat("d 'de' MMMM", 'es').format(p.fin);
        final sub = p.vencido()
            ? (p.esPrueba
                  ? 'Tu prueba terminó el $fin. Elige un plan para seguir.'
                  : 'Tu plan venció el $fin.')
            : p.esPrueba
            ? 'Te quedan $dias de ${p.diasTotales} días · termina el $fin'
            : 'Activo hasta el $fin';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: KipuColores.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _PildoraPlan(),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: dias / p.diasTotales,
                    minHeight: 7,
                    backgroundColor: KipuColores.moradoClaro,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaPlanes()),
                  ),
                  child: Text(p.esPrueba ? 'Ver planes' : 'Cambiar de plan'),
                ),
                if (!p.esPrueba) ...[
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gestionar o cancelar suscripción'),
                    subtitle: const Text(
                      'Se hace en Google Play › Pagos y suscripciones',
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: abrirSuscripcionesPlay,
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Cuando compres un plan podrás cancelarlo cuando quieras '
                      'en Google Play › Pagos y suscripciones.',
                      style: TextStyle(fontSize: 12.5, color: KipuColores.gris),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------ Planes

class PantallaPlanes extends StatelessWidget {
  const PantallaPlanes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planes Kipu')),
      body: const _Centrado(
        children: [
          Text(
            'Todo Kipu: cursos, asistencia, notas, horario, planificación y '
            'reportes.',
            style: TextStyle(color: KipuColores.gris, fontSize: 15),
          ),
          SizedBox(height: 16),
          SelectorPlanes(),
        ],
      ),
    );
  }
}

/// Tarjetas anual y mensual con el botón de comprar. Se usa en la pantalla de
/// planes y justo después de crear la cuenta.
class SelectorPlanes extends StatefulWidget {
  const SelectorPlanes({super.key});

  @override
  State<SelectorPlanes> createState() => _SelectorPlanesState();
}

class _SelectorPlanesState extends State<SelectorPlanes> {
  String _elegido = 'anual';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarjetaPlan(
          titulo: 'Anual',
          precio: 'S/ $precioAnual',
          periodo: 'al año · S/ ${precioAnual ~/ 12} al mes',
          etiqueta: 'Ahorra 33%',
          elegido: _elegido == 'anual',
          onTap: () => setState(() => _elegido = 'anual'),
        ),
        const SizedBox(height: 10),
        _TarjetaPlan(
          titulo: 'Mensual',
          precio: 'S/ $precioMensual',
          periodo: 'al mes',
          elegido: _elegido == 'mensual',
          onTap: () => setState(() => _elegido = 'mensual'),
        ),
        const SizedBox(height: 14),
        for (final t in const [
          'Úsalo en tu celular y en tu PC',
          'Copia de tus datos en Google Drive (próximamente)',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const KipuIcon(
                  KipuIcono.check,
                  size: 18,
                  color: Color(0xFF16A37F),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(t, style: const TextStyle(fontSize: 14.5))),
              ],
            ),
          ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () => avisarPagosPronto(context),
          child: Text(
            _elegido == 'anual' ? 'Comprar plan anual' : 'Comprar plan mensual',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, height: 1.45),
              children: [
                TextSpan(
                  text: 'Sobre tu suscripción: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      'el pago se hace con Google Play y se renueva solo cada '
                      'mes o cada año. Puedes cancelarla cuando quieras en ',
                ),
                TextSpan(
                  text: 'Google Play › Pagos y suscripciones',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: '; sigues usando Kipu hasta el final del periodo pagado.',
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => avisarPagosPronto(context),
          child: const Text('¿Ya pagaste en otro equipo? Restaurar compra'),
        ),
      ],
    );
  }
}

/// Los cobros con Google Play se conectan cuando la app esté publicada.
Future<void> avisarPagosPronto(BuildContext context) => showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Pagos muy pronto'),
    content: const Text(
      'Los pagos con Google Play se activarán cuando Kipu esté publicado en '
      'Play Store. Mientras tanto puedes usar tu prueba gratis.',
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Entendido'),
      ),
    ],
  ),
);

class _TarjetaPlan extends StatelessWidget {
  final String titulo;
  final String precio;
  final String periodo;
  final String? etiqueta;
  final bool elegido;
  final VoidCallback onTap;

  const _TarjetaPlan({
    required this.titulo,
    required this.precio,
    required this.periodo,
    required this.elegido,
    required this.onTap,
    this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: elegido ? KipuColores.morado : const Color(0xFFE3E2EE),
            width: elegido ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (etiqueta != null)
                  _Pildora(
                    etiqueta!,
                    const Color(0xFFD9F4EC),
                    const Color(0xFF16A37F),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: precio,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '  $periodo',
                    style: const TextStyle(
                      fontSize: 14,
                      color: KipuColores.gris,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- Legal

class PantallaLegal extends StatelessWidget {
  final DocumentoLegal documento;
  const PantallaLegal(this.documento, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(documento.titulo)),
      body: _Centrado(
        children: [
          Text(
            'Última actualización: $actualizacionLegal',
            style: const TextStyle(color: KipuColores.gris, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(documento.intro, style: const TextStyle(height: 1.5)),
                  for (final s in documento.secciones) ...[
                    const SizedBox(height: 18),
                    Text(
                      s.titulo,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    for (final p in s.parrafos)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(p, style: const TextStyle(height: 1.5)),
                      ),
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

// ----------------------------------------------------------------- Comunes

class _Centrado extends StatelessWidget {
  final List<Widget> children;
  const _Centrado({required this.children});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: children,
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: KipuColores.gris,
      ),
    ),
  );
}

class _Fila extends StatelessWidget {
  final String texto;
  final String? sub;
  final Color? color;
  final VoidCallback onTap;
  const _Fila(this.texto, {required this.onTap, this.sub, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(texto, style: TextStyle(color: color)),
    subtitle: sub == null ? null : Text(sub!),
    trailing: const KipuIcon(KipuIcono.flecha, size: 18, color: KipuColores.gris),
    onTap: onTap,
  );
}
