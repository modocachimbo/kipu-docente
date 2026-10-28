import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/database.dart';
import 'screens/bienvenida.dart';
import 'screens/shell.dart';
import 'theme.dart';

final db = KipuDb();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_PE');
  estiloActual.value = estiloPorId(await db.leerAjuste('estilo'));
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
        debugShowCheckedModeBanner: false,
        theme: kipuTema(),
        locale: const Locale('es', 'PE'),
        supportedLocales: const [Locale('es', 'PE'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: StreamBuilder<String?>(
          stream: db.verAjuste('nombre'),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snap.data == null ? const Bienvenida() : const Shell();
          },
        ),
      ),
    );
  }
}
