// Capturas de pantalla de «Copias de seguridad» (no es una prueba normal).
// Se generan con: flutter test tool/capturas --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kipu/data/copias.dart';
import 'package:kipu/screens/copias.dart';
import 'package:kipu/theme.dart';

Future<void> _fuentes() async {
  final f = FontLoader('Outfit');
  for (final n in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    f.addFont(rootBundle.load('assets/fonts/Outfit-$n.ttf'));
  }
  await f.load();
}

Widget _app(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: kipuTema(),
  locale: const Locale('es', 'PE'),
  supportedLocales: const [Locale('es', 'PE')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

Future<void> _tam(WidgetTester t, Size s, double dpr) async {
  t.view.physicalSize = s * dpr;
  t.view.devicePixelRatio = dpr;
  addTearDown(t.view.reset);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_PE');
    await _fuentes();
  });

  final ahora = DateTime.now();

  testWidgets('celular sin copias', (t) async {
    await _tam(t, const Size(412, 1000), 2);
    copias.estado.value = const EstadoCopias();
    copias.ajustes.value = const AjustesCopias();
    await t.pumpWidget(_app(const PantallaCopias()));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('1-celular-sin-copias.png'));
  });

  testWidgets('celular con copia', (t) async {
    await _tam(t, const Size(412, 1000), 2);
    copias.estado.value = EstadoCopias(ultima: ahora.subtract(const Duration(minutes: 12)));
    copias.ajustes.value = const AjustesCopias(frecuencia: Frecuencia.diaria, conservar: 10);
    await t.pumpWidget(_app(const PantallaCopias()));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('2-celular-con-copia.png'));
  });

  testWidgets('ajustes de las copias', (t) async {
    await _tam(t, const Size(412, 1000), 2);
    copias.estado.value = EstadoCopias(ultima: ahora.subtract(const Duration(hours: 3)));
    copias.ajustes.value = const AjustesCopias();
    await t.pumpWidget(_app(const PantallaCopias()));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Ajustes de las copias'));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('3-ajustes.png'));
  });

  testWidgets('computadora', (t) async {
    await _tam(t, const Size(1280, 900), 1.5);
    copias.estado.value = EstadoCopias(ultima: ahora.subtract(const Duration(days: 1, hours: 2)));
    copias.ajustes.value = const AjustesCopias();
    await t.pumpWidget(_app(const PantallaCopias()));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('4-computadora.png'));
  });
}
