import 'package:flutter/material.dart';

import '../data/cuenta.dart';
import '../data/demo.dart';
import '../data/diario_db.dart';
import '../data/legal.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/kipu_icono.dart';
import 'bienvenida.dart' show EditarPerfil;
import 'cuenta.dart';
import 'cursos.dart' show confirmar;
import 'diario.dart' show ajustesAvisos;

/// Configuración › General: cómo se ve y se comporta Kipu. Los datos del
/// docente y su plan están en Mi perfil (la foto del Dashboard).
class Configuracion extends StatelessWidget {
  const Configuracion({super.key});

  @override
  Widget build(BuildContext context) {
    void ir(Widget w) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración general')),
      body: LayoutBuilder(
        builder: (context, c) {
          final dos = c.maxWidth >= 760;
          Widget grupo(String titulo, List<Widget> tarjetas) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: KipuColores.gris,
                  ),
                ),
              ),
              if (dos)
                for (var i = 0; i < tarjetas.length; i += 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: tarjetas[i]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: i + 1 < tarjetas.length
                                ? tarjetas[i + 1]
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  )
              else
                for (final t in tarjetas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: t,
                  ),
            ],
          );
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  const _AvisoPlan(),
                  grupo('APARIENCIA', [
                    _Tarjeta(
                      icono: KipuIcono.paleta,
                      titulo: 'Color de la app',
                      texto: estiloActual.value.nombre,
                      onTap: () => elegirEstilo(context),
                    ),
                    _Tarjeta(
                      icono: KipuIcono.estudiantes,
                      titulo: 'Mi perfil y mi plan',
                      texto: 'Tus datos, tu personaje y tu suscripción',
                      onTap: () => ir(const MiCuenta()),
                    ),
                  ]),
                  grupo('USO DE LA APP', [
                    StreamBuilder<String?>(
                      stream: db.verAjuste(claveAvisos),
                      builder: (context, v) {
                        final a = AjustesAvisos.deTexto(v.data);
                        final activos = [
                          if (a.clases) 'clase ${a.minutosClase} min antes',
                          if (a.cumples) 'cumpleaños',
                          if (a.cierre) 'cierre de periodo',
                          if (a.pendientes) 'pendientes',
                        ];
                        return _Tarjeta(
                          icono: KipuIcono.campana,
                          titulo: 'Avisos',
                          texto: activos.isEmpty
                              ? 'Ninguno activo'
                              : activos.join(' · '),
                          etiqueta: '${activos.length} activos',
                          onTap: () => ajustesAvisos(context),
                        );
                      },
                    ),
                    _Tarjeta(
                      icono: KipuIcono.ajustes,
                      titulo: 'Más ajustes',
                      texto:
                          'Modo oscuro, tamaño de letra, PIN, registro de notas '
                          'y asistente IA',
                      etiqueta: 'Próximamente',
                      gris: true,
                    ),
                  ]),
                  grupo('TUS DATOS', [
                    _Tarjeta(
                      icono: KipuIcono.estudiantes,
                      titulo: 'Cargar datos de ejemplo',
                      texto:
                          'Colegios, alumnos y notas inventados para probar Kipu',
                      onTap: () async {
                        if (await confirmar(
                          context,
                          '¿Cargar datos de ejemplo?',
                          'Se reemplazarán los colegios, cursos y alumnos que '
                              'tengas ahora.',
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
                    _Tarjeta(
                      icono: KipuIcono.borrar,
                      titulo: 'Borrar todos mis datos',
                      texto:
                          'Colegios, cursos, alumnos, asistencia, notas y '
                          'calendario. Tu cuenta se queda.',
                      rojo: true,
                      onTap: () async {
                        if (await confirmar(
                          context,
                          '¿Borrar todo?',
                          'No hay forma de recuperar estos datos después.',
                        )) {
                          await db.borrarTodo();
                        }
                      },
                    ),
                  ]),
                  grupo('ACERCA DE KIPU', [
                    _Tarjeta(
                      icono: KipuIcono.ayuda,
                      titulo: 'Términos de uso',
                      texto: 'Actualizado el $actualizacionLegal',
                      onTap: () => ir(const PantallaLegal(terminosUso)),
                    ),
                    _Tarjeta(
                      icono: KipuIcono.ayuda,
                      titulo: 'Política de privacidad',
                      texto: 'Qué datos usa Kipu y cómo los cuida',
                      onTap: () => ir(const PantallaLegal(politicaPrivacidad)),
                    ),
                  ]),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Kipu Docente 1.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KipuColores.gris, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Aviso de la prueba gratis arriba de la configuración.
class _AvisoPlan extends StatelessWidget {
  const _AvisoPlan();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Plan?>(
      stream: db.verPlan(),
      builder: (context, snap) {
        final p = snap.data;
        if (p == null || !p.esPrueba) return const SizedBox.shrink();
        final dias = p.diasRestantes();
        return Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                KipuColores.morado,
                Color.lerp(KipuColores.morado, Colors.white, .2)!,
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.vencido()
                          ? 'Tu prueba gratis terminó'
                          : 'Prueba gratis · te quedan $dias de '
                                '${p.diasTotales} días',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: dias / p.diasTotales,
                        minHeight: 6,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: KipuColores.morado,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaPlanes()),
                ),
                child: const Text('Ver planes'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final KipuIcono icono;
  final String titulo;
  final String texto;
  final String? etiqueta;
  final bool rojo;
  final bool gris;
  final VoidCallback? onTap;

  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.texto,
    this.etiqueta,
    this.rojo = false,
    this.gris = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = rojo ? const Color(0xFFD0384E) : KipuColores.morado;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Opacity(
          opacity: gris ? .6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: rojo ? const Color(0xFFFCE4E8) : KipuColores.moradoClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: KipuIcon(icono, size: 22, color: color)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: rojo ? color : KipuColores.tinta,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        texto,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: KipuColores.gris,
                          height: 1.35,
                        ),
                      ),
                      if (etiqueta != null) ...[
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: gris
                                ? const Color(0xFFEEEDF3)
                                : const Color(0xFFD9F4EC),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            etiqueta!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: gris
                                  ? KipuColores.gris
                                  : const Color(0xFF16A37F),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  const KipuIcon(
                    KipuIcono.flecha,
                    size: 18,
                    color: KipuColores.gris,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> editarPerfil(BuildContext context) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EditarPerfil()),
);

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
                          ? const KipuIcon(KipuIcono.check, color: Colors.white)
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
