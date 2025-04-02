import 'package:flutter/material.dart';
import 'dart:ui' as ui; // Add this import for ImageFilter

import '../constants/auth_constants.dart';

class AuthUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AuthConstants.errorColor : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void navigateAndClearStack(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
          (route) => false,
    );
  }

  static Widget buildBlurredContainer({
    required Widget child,
    required double width,
    bool withPadding = true,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Add 'ui.' prefix
        child: Container(
          width: width,
          padding: withPadding ? const EdgeInsets.all(20.0) : null,
          decoration: BoxDecoration(
            color: AuthConstants.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: AuthConstants.primaryColor.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}