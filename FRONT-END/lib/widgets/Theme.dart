import 'package:flutter/material.dart';

class AppTheme {
  static ColorScheme get colorScheme {
    return const ColorScheme(
      primary: Color(0xFF890cac),
      secondary: Color(0xFFba68c8),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: colorScheme.copyWith(
        brightness: Brightness.dark,
      ),
    );
  }
}