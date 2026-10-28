import 'package:flutter/material.dart';

class KipuColores {
  static const morado = Color(0xFF7C6CF2);
  static const moradoOscuro = Color(0xFF5B4BD6);
  static const moradoClaro = Color(0xFFE9E6FD);
  static const fondo = Color(0xFFF4F3FB);
  static const tinta = Color(0xFF1F1B2E);
  static const gris = Color(0xFF6E6A80);

  static const tarjetas = [
    [Color(0xFF8F7CF5), Color(0xFFB7A9FA)],
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
  final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  return ThemeData(
    colorScheme: esquema,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: KipuColores.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: KipuColores.fondo,
      foregroundColor: KipuColores.tinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
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
        borderSide: const BorderSide(color: Color(0xFFB9B0F8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB9B0F8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: KipuColores.morado, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: redondo,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w600),
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
        const TextStyle(fontFamily: 'Poppins', fontSize: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: KipuColores.morado,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
  );
}
