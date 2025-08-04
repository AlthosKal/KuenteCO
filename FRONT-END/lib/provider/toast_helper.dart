import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showSuccess(
      BuildContext context, {
        required String title,
        String? description,
      }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      primaryColor: const Color(0xFF890cac),
      backgroundColor: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12.0),
      showProgressBar: true,
    );
  }

  static void showError(
      BuildContext context, {
        required String title,
        String? description,
      }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      primaryColor: const Color(0xFFFF0000),
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFFFF0000),
      borderRadius: BorderRadius.circular(12.0),
      showProgressBar: true,
    );
  }

}