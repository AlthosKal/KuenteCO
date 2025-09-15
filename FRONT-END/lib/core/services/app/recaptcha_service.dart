import 'dart:async';
import 'dart:convert';
// Importación condicional para web
import 'dart:html' as html;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../dto/app/auth/request/recaptcha_request_dto.dart';
import '../../../dto/app/auth/response/recaptcha_response_dto.dart';
import '../api_client.dart';

class RecaptchaService {
  final _api = ApiClient();

  bool get isReady => _api.isInitialized;

  /// Obtener la site key desde .env
  String get siteKey => dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';

  /// Verificar token de reCAPTCHA con el backend usando endpoint público
  Future<bool> verifyRecaptcha(String token) async {
    if (kIsWeb) {
      return _verifyRecaptchaWeb(token);
    } else {
      return _verifyRecaptchaMobile(token);
    }
  }

  /// Verificación usando dart:html para web
  Future<bool> _verifyRecaptchaWeb(String token) async {
    try {
      final dto = RecaptchaRequestDTO(token: token);
      final jsonData = json.encode(dto.toJson());
      
      // Usar la misma base URL que el ApiClient
      final baseUrl = kIsWeb ? dotenv.env['APP_URL_WEB'] ?? '' : dotenv.env['APP_URL_ANDROID'] ?? '';
      final url = '$baseUrl/recaptcha/verify';
      
      final request = html.HttpRequest();
      request.open('POST', url);
      request.setRequestHeader('Content-Type', 'application/json');
      
      final completer = Completer<bool>();
      
      request.onLoad.listen((event) {
        if (request.status == 200) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      });
      
      request.onError.listen((event) {
        completer.complete(false);
      });
      
      request.send(jsonData);
      return await completer.future;
      
    } catch (e) {
      return false;
    }
  }

  /// Verificación usando Dio para móvil
  Future<bool> _verifyRecaptchaMobile(String token) async {
    try {
      final dto = RecaptchaRequestDTO(token: token);
      final response = await _api.postPublic('/recaptcha/verify', dto.toJson());
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Verificar token y obtener respuesta completa del backend
  Future<RecaptchaResponseDTO?> verifyRecaptchaDetailed(String token) async {
    try {
      final dto = RecaptchaRequestDTO(token: token);
      final response = await _api.postPublic('/recaptcha/verify', dto.toJson());
      
      if (response.statusCode == 200) {
        return RecaptchaResponseDTO(success: true);
      } else {
        final errorData = response.data;
        if (errorData is Map<String, dynamic>) {
          return RecaptchaResponseDTO.fromJson(errorData);
        }
        return RecaptchaResponseDTO(success: false);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        return RecaptchaResponseDTO(success: false, errorCodes: ['invalid-recaptcha']);
      } else {
        return RecaptchaResponseDTO(success: false, errorCodes: ['network-error']);
      }
    } catch (e) {
      return RecaptchaResponseDTO(
        success: false, 
        errorCodes: ['unknown-error']
      );
    }
  }

  /// Validar que la site key esté configurada
  bool get isSiteKeyConfigured => siteKey.isNotEmpty;
}