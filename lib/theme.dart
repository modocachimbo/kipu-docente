import 'package:flutter/material.dart';

/// Paleta de color que el docente puede elegir. El morado es la predeterminada.
class KipuEstilo {
  final String id;
  final String nombre;
  final Color principal;
  final Color oscuro;
  final Color claro;
  final Color fondo;

  const KipuEstilo(
    this.id,
    this.nombre,
    this.principal,
    this.oscuro,
    this.claro,
    this.fondo,
  );
}

const estilosKipu = [
  KipuEstilo(
    'morado',
    'Morado',
    Color(0xFF7C6CF2),
    Color(0xFF5B4BD6),
    Color(0xFFE9E6FD),
    Color(0xFFF4F3FB),
  ),
  KipuEstilo(
    'azul',
    'Azul',
    Color(0xFF3D7BF0),
    Color(0xFF2557C7),
    Color(0xFFE2ECFD),
    Color(0xFFF2F6FD),
  ),
  KipuEstilo(
    'verde',
    'Verde',
    Color(0xFF16A37F),
    Color(0xFF0E7A5F),
    Color(0xFFD9F4EC),
    Color(0xFFF1F8F5),
  ),
  KipuEstilo(
    'rosa',
    'Rosa',
    Color(0xFFE5508E),
    Color(0xFFB8336C),
    Color(0xFFFCE3EE),
    Color(0xFFFBF2F6),
  ),
  KipuEstilo(
    'naranja',
    'Naranja',
    Color(0xFFF07A2D),
    Color(0xFFC25A16),
    Color(0xFFFDE9DB),
    Color(0xFFFBF5F0),
  ),
];

/// Estilo en uso. Se guarda en el ajuste 'estilo' y se carga al abrir la app.
final estiloActual = ValueNotifier<KipuEstilo>(estilosKipu.first);

KipuEstilo estiloPorId(String? id) =>
    estilosKipu.firstWhere((e) => e.id == id, orElse: () => estilosKipu.first);

class KipuColores {
  // Los nombres "morado*" se mantienen, pero siguen al estilo elegido.
  static Color get morado => estiloActual.value.principal;
  static Color get moradoOscuro => estiloActual.value.oscuro;
  static Color get moradoClaro => estiloActual.value.claro;
  static Color get fondo => estiloActual.value.fondo;
  static const tinta = Color(0xFF1F1B2E);
  static const gris = Color(0xFF6E6A80);

  static List<List<Color>> get tarjetas => [
    [
      Color.lerp(morado, Colors.white, .12)!,
      Color.lerp(morado, Colors.white, .45)!,
    ],
    [Color(0xFF4F7CF5), Color(0xFF79A6FA)],
    [Color(0xFF3FB8E8), Color(0xFF8AD8F5)],
    [Color(0xFF2FCB9C), Color(0xFF6FE3BE)],
  ];

  // Escala MINEDU
  static const ad = Color(0xFF7C6CF2);
  static const a = Color(0xFF4F7CF5);
  static const b = Color(0xFF3FB8E8);
  static const c = Color(0xFF2FCB9C);
}

ThemeData kipuTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: KipuColores.morado,
    primary: KipuColores.morado,
    surface: Colors.white,
  );
  final redondo = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  return ThemeData(
    colorScheme: esquema,
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: KipuColores.fondo,
    appBarTheme: AppBarTheme(
      backgroundColor: KipuColores.fondo,
      foregroundColor: KipuColores.tinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: KipuColores.tinta,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: KipuColores.morado.withValues(alpha: .45),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: KipuColores.morado.withValues(alpha: .45),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: KipuColores.morado, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: redondo,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: redondo,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: KipuColores.moradoClaro,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontFamily: 'Outfit', fontSize: 12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: KipuColores.morado,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
  );
}
