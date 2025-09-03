import 'package:dio/dio.dart';

import '../../utils/parser/api_error_parse.dart';

typedef AsyncTask<T> = Future<T> Function();
typedef ErrorHandler = void Function(dynamic error);

class GlobalExceptionHandler {
  static Future<T> run<T>(AsyncTask<T> task, {ErrorHandler? onError}) async {
    try {
      return await task();
    } catch (e, stack) {
      print('🛑 Error global: $e');
      print('📍 Stack trace: $stack');

      // Resuelve mensaje amigable
      String userMessage = _resolveMessage(e);

      if (onError != null) {
        onError(Exception(userMessage));
      }

      throw Exception(userMessage);
    }
  }

  static String _resolveMessage(dynamic error) {
    if (error is DioException) {
      return ApiErrorParser.extractMessage(error.response?.data);
    }

    // Si es una excepción personalizada con mensaje, respétalo
    if (error is Exception) {
      final message = error.toString();
      if (message.isNotEmpty &&
          message != 'Exception' &&
          !message.contains('Ocurrió un error inesperado')) {
        return message.replaceFirst('Exception: ', '');
      }
    }

    // Otros errores comunes
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Sesión expirada. Inicia sesión nuevamente.';
    }
    if (errorString.contains('403')) {
      return 'No tienes permisos para esta acción.';
    }
    if (errorString.contains('404')) {
      return 'Recurso no encontrado.';
    }

    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
