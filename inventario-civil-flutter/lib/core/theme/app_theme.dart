import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema principal de la aplicación InventarioPro.
/// Paleta basada en el diseño de los wireframes aprobados.
class AppTheme {
  AppTheme._();

  // Colores primarios
  static const Color primary        = Color(0xFF1B3A6B); // Azul marino UCB
  static const Color primaryLight   = Color(0xFF2C5282);
  static const Color accent         = Color(0xFFF6C90E); // Amarillo
  static const Color background     = Color(0xFFF5F7FA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color error          = Color(0xFFE53E3E);
  static const Color success        = Color(0xFF38A169);
  static const Color warning        = Color(0xFFDD6B20);
  static const Color textPrimary    = Color(0xFF1A202C);
  static const Color textSecondary  = Color(0xFF718096);

  // Stock status colors
  static const Color stockNormal    = Color(0xFF38A169);
  static const Color stockBajo      = Color(0xFFDD6B20);
  static const Color stockCritico   = Color(0xFFE53E3E);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: surface,
    ),
  );
}
