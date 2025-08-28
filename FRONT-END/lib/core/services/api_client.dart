import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../routes/app_routes.dart';

class ApiClient {
  // Singleton
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  final _storage = const FlutterSecureStorage();

  late final Dio _dioApp;
  late final Dio _dioChat;

  late final String baseUrlApp;
  late final String baseUrlChat;

  bool _isInitialized = false;

  ApiClient._internal() {
    _initializeUrls();
    _dioApp = _createDio(baseUrlApp);
    _dioChat = _createDio(baseUrlChat);
    _isInitialized = true;
  }

  void _initializeUrls() {
    if (kIsWeb) {
      baseUrlApp = dotenv.get('APP_URL_WEB');
      baseUrlChat = dotenv.get('CHAT_URL_WEB');
    } else if (Platform.isAndroid) {
      baseUrlApp = dotenv.get('APP_URL_ANDROID');
      baseUrlChat = dotenv.get('CHAT_URL_ANDROID');
    } else {
      // Default fallback for other platforms
      baseUrlApp = dotenv.get('APP_URL_WEB');
      baseUrlChat = dotenv.get('CHAT_URL_WEB');
    }
  }

  Dio _createDio(String baseUrl) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'Authorization');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kIsWeb) {
            options.headers['X-Requested-With'] = 'XMLHttpRequest';
          }
          return handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          if (e.response?.statusCode == 401) {
            // TODO: Implement proper navigation to login
            if (kDebugMode) {
              print('🔐 Unauthorized access - redirect to ${AppRoutes.login}');
            }
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  bool get isInitialized => _isInitialized;

  // Métodos API con manejo de errores
  Future<Response> getApp(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dioApp.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al obtener datos.';
      throw Exception(mensaje);
    }
  }

  Future<Response<dynamic>> postApp(String path, dynamic data) async {
    try {
      final Options? options = data is FormData 
          ? Options(headers: <String, String>{'Accept': 'application/json'}) 
          : null;
      return await _dioApp.post(path, data: data, options: options);
    } on DioException catch (e) {
      final String mensaje = e.response?.data?['message'] ?? 
                            e.message ?? 
                            'Error al enviar datos.';
      throw Exception(mensaje);
    }
  }

  Future<Response> putApp(String path, dynamic data) async {
    try {
      return await _dioApp.put(path, data: data);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al actualizar datos.';
      throw Exception(mensaje);
    }
  }

  Future<Response> patchApp(String path, [dynamic data]) async {
    try {
      // Si es FormData, permitir que Dio maneje el Content-Type automáticamente
      final options = data is FormData 
          ? Options(headers: {'Accept': 'application/json'}) 
          : null;
      return await _dioApp.patch(path, data: data, options: options);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al modificar datos.';
      throw Exception(mensaje);
    }
  }

  Future<Response> deleteApp(String path) async {
    try {
      return await _dioApp.delete(path);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al eliminar datos.';
      throw Exception(mensaje);
    }
  }

  Future<Response> downloadFile(String path, String savePath) async {
    try {
      return await _dioApp.download(
        path,
        savePath,
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al descargar archivo.';
      throw Exception(mensaje);
    }
  }

  // Métodos para la API del chat
  Future<Response> getChat(String path) async {
    try {
      return await _dioChat.get(path);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al obtener datos del chat.';
      throw Exception(mensaje);
    }
  }

  Future<Response> postChat(String path, dynamic data) async {
    try {
      return await _dioChat.post(path, data: data);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al enviar datos al chat.';
      throw Exception(mensaje);
    }
  }

  Future<Response> putChat(String path, dynamic data) async {
    try {
      return await _dioChat.put(path, data: data);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al actualizar chat.';
      throw Exception(mensaje);
    }
  }

  Future<Response> deleteChat(String path) async {
    try {
      return await _dioChat.delete(path);
    } on DioException catch (e) {
      final mensaje = e.response?.data?['message'] ?? e.message ?? 'Error al eliminar del chat.';
      throw Exception(mensaje);
    }
  }
}
