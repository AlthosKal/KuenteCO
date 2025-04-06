import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:kuenteco/core/constants/App_colors.dart';

class AuthUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Future<void> navigateAndClearStack({
    required BuildContext context,
    required Widget page,
  }) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
          (route) => false,
    );
  }

  static Widget buildBlurredContainer({
    required Widget child,
    required double width,
    bool withPadding = true,
    double blurIntensity = 5.0,
    double borderRadius = 15.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: blurIntensity,
          sigmaY: blurIntensity,
        ),
        child: Container(
          width: width,
          padding: withPadding ? const EdgeInsets.all(20.0) : null,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static bool validateEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    ).hasMatch(email);
  }

  static bool validatePassword(String password) {
    return password.length >= 6;
  }
}