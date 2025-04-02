import 'package:flutter/material.dart';

class AppTheme {
  // Light Color Scheme
  static final ColorScheme _lightColorScheme = ColorScheme.light(
    primary: const Color(0xFF890cac),
    secondary: const Color(0xFFba68c8),
    surface: Colors.white,
    error: const Color(0xFFd32f2f),
  );

  // Dark Color Scheme
  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFFba68c8),
    secondary: const Color(0xFF890cac),
    surface: const Color(0xFF1E1E1E),
  );

  // Text Styles
  static TextStyle get headlineMedium => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headlineMedium.copyWith(
        color: _lightColorScheme.onPrimary,
        fontSize: 20,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: headlineMedium.copyWith(color: _lightColorScheme.onSurface),
      bodyLarge: bodyLarge.copyWith(color: _lightColorScheme.onSurface),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.secondary,
      foregroundColor: _lightColorScheme.onSecondary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headlineMedium.copyWith(
        color: _darkColorScheme.onPrimary,
        fontSize: 20,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: headlineMedium.copyWith(color: _darkColorScheme.onSurface),
      bodyLarge: bodyLarge.copyWith(color: _darkColorScheme.onSurface),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _darkColorScheme.surface,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.secondary,
      foregroundColor: _darkColorScheme.onSecondary,
    ),
  );
}