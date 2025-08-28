import 'package:flutter/material.dart';

abstract final class AppColors {
  // Prevent instantiation
  const AppColors._();

  // Primary colors
  static const Color primaryPurple = Color(0xFF890cac);
  static const Color lightPurple = Color(0xFFEDE7F6);

  // Status colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningYellow = Color(0xFFF57C00);
  static const Color infoBlue = Color(0xFF1976D2);

  // Text colors
  static const Color textWhite = Colors.white;
  static const Color textBlack = Colors.black;
  static const Color textGrey = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF303030);
  static const Color surfaceWhite = Colors.white;

  // Border colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x3A000000);
}