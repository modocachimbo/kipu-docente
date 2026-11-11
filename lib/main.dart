import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/colores_notas.dart';
import 'data/cuenta.dart';
import 'data/database.dart';
import 'data/recordatorios.dart';
import 'screens/bienvenida.dart';
import 'screens/entrada.dart';
import 'screens/shell.dart';
import 'theme.dart';

final db = KipuDb();

/// Para mostrar los avisos de Mi diario sobre cualquier pantalla.
final mensajero = GlobalKey<ScaffoldMessengerState>();

void _mostrarAviso() {
  final a = recordatorios.enApp.value;
  if (a == null) return;
  mensajero.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 12),
        behavior: SnackBarBehavior.floating,
        content: Text('${a.titulo}\n${a.cuerpo}'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_PE');
  estiloActual.value = estiloPorId(await db.leerAjuste('estilo'));
  coloresNotas.value = ColoresNotas.deTexto(
    await db.leerAjuste(claveColoresNotas),
  );
  // Los avisos no deben impedir que abra la app.
  recordatorios.enApp.addListener(_mostrarAviso);
  unawaited(recordatorios.iniciar(db).catchError((_) {}));
  runApp(const KipuApp());
}

class KipuApp extends StatelessWidget {
  const KipuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KipuEstilo>(
      valueListenable: estiloActual,
      builder: (context, estilo, _) => MaterialApp(
        key: ValueKey(estilo.id), // reconstruye todo al cambiar de color
        title: 'Kipu Docente',
        scaffoldMessengerKey: mensajero,
        debugShowCheckedModeBanner: false,
        theme: kipuTema(),
        locale: const Locale('es', 'PE'),
        supportedLocales: const [Locale('es', 'PE'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const _Puerta(),
      ),
    );
  }
}

/// Orden de entrada: cuenta → prueba o plan → perfil → Kipu.
class _Puerta extends StatelessWidget {
  const _Puerta();

  static const _cargando = Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: db.verSesion(),
      builder: (context, sesion) {
        if (!sesion.hasData) return _cargando;
        if (!sesion.data!) return const Entrada();
        return StreamBuilder<Plan?>(
          stream: db.verPlan(),
          builder: (context, plan) {
            if (plan.connectionState == ConnectionState.waiting) {
              return _cargando;
            }
            if (plan.data == null) return const ElegirPlan();
            return StreamBuilder<String?>(
              stream: db.verAjuste('nombre'),
              builder: (context, nombre) {
                if (nombre.connectionState == ConnectionState.waiting) {
                  return _cargando;
                }
                return (nombre.data ?? '').isEmpty
                    ? const CompletarPerfil()
                    : const Shell();
              },
            );
          },
        );
      },
    );
  }
}
