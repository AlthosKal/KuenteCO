import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../dto/chat/request/chat_dto.dart';
import '../../../dto/chat/request/chat_files_dto.dart';
import '../../../dto/chat/request/chat_multipart_dto.dart';
import '../../../dto/chat/request/debt_chat_request_dto.dart';
import '../../../dto/chat/response/chat_response_dto.dart';
import '../../../dto/chat/response/string_chat_response_dto.dart';
import '../../../dto/chat/response/dynamic_analysis_response_dto.dart';
import '../../../dto/chat/response/debt_analysis_response_dto.dart';
import '../../../dto/chat/response/base_dynamic_response_dto.dart';
import '../api_client.dart';

class ChatService {
  final _api = ApiClient();

  /// Chat básico con AI
  Future<ChatResponseDTO> askAi(ChatDTO dto) async {
    print('ð ChatService: Enviando consulta básica al chat AI');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Respuesta recibida del chat básico');
      return ChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en chat básico: $e');
      rethrow;
    }
  }

  /// Chat con URLs/archivos
  Future<StringChatResponseDTO> askAiWithUrl(ChatFilesDTO dto) async {
    print('ð ChatService: Enviando consulta con URLs al chat AI');
    try {
      final response = await _api.postChat('/chat-with-url', dto.toJson());
      print('â ChatService: Respuesta recibida del chat con URLs');
      return StringChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en chat con URLs: $e');
      rethrow;
    }
  }

  /// Chat con archivo
  Future<StringChatResponseDTO> askAiWithFile(ChatMultipartDTO dto) async {
    print('ð ChatService: Enviando consulta con archivo al chat AI');
    try {
      final response = await _api.postChat('/chat-with-file', dto.toJson());
      print('â ChatService: Respuesta recibida del chat con archivo');
      return StringChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en chat con archivo: $e');
      rethrow;
    }
  }

  /// Análisis específico de deudas
  Future<DebtAnalysisResponseDTO> analyzeDebts(DebtChatRequestDTO dto) async {
    print('ð ChatService: Iniciando análisis de deudas');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Análisis de deudas completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en análisis de deudas: $e');
      rethrow;
    }
  }

  /// Análisis dinámico (respuesta flexible basada en tipo)
  Future<DynamicAnalysisResponseDTO> getDynamicAnalysis(ChatDTO dto) async {
    print('ð ChatService: Solicitando análisis dinámico');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Análisis dinámico recibido');
      // Log de la estructura completa para debugging
      print('📊 ChatService: Estructura completa de respuesta: ${response.data}');
      
      // La respuesta real está en response.data['data']
      final actualData = response.data['data'];
      if (actualData == null) {
        throw Exception('No se encontraron datos en la respuesta del backend');
      }
      
      print('📊 ChatService: Datos reales: $actualData');
      return DynamicAnalysisResponseDTO.fromJson(actualData);
    } catch (e) {
      print('â ChatService: Error en análisis dinámico: $e');
      rethrow;
    }
  }

  /// Análisis de riesgo de deudas
  Future<DebtAnalysisResponseDTO> getDebtRiskAnalysis({
    required String userId,
    required double monthlyIncome,
    List<int>? debtIds,
  }) async {
    print('ð ChatService: Iniciando análisis de riesgo de deudas');
    try {
      final dto = DebtChatRequestDTO.riskAnalysis(
        userId: userId,
        monthlyIncome: monthlyIncome,
        debtIds: debtIds,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Análisis de riesgo completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en análisis de riesgo: $e');
      rethrow;
    }
  }

  /// Estrategia de pago de deudas
  Future<DebtAnalysisResponseDTO> getPaymentStrategy({
    required String userId,
    required double availableBudget,
    List<int>? priorityDebtIds,
  }) async {
    print('ð ChatService: Generando estrategia de pago');
    try {
      final dto = DebtChatRequestDTO.paymentStrategy(
        userId: userId,
        availableBudget: availableBudget,
        priorityDebtIds: priorityDebtIds,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Estrategia de pago generada');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error generando estrategia de pago: $e');
      rethrow;
    }
  }

  /// Análisis general de deudas
  Future<DebtAnalysisResponseDTO> getGeneralDebtAnalysis({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) async {
    print('ð ChatService: Iniciando análisis general de deudas');
    try {
      final dto = DebtChatRequestDTO.analyzeDebts(
        userId: userId,
        specificDebtIds: specificDebtIds,
        customMessage: customMessage,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Análisis general completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en análisis general: $e');
      rethrow;
    }
  }

  /// Procesar respuesta dinámica basada en tipo
  Future<BaseDynamicResponseDTO> processResponse(Map<String, dynamic> responseData) async {
    print('ð ChatService: Procesando respuesta dinámica');
    try {
      final dynamicResponse = BaseDynamicResponseDTO.fromJson(responseData);
      print('â ChatService: Respuesta dinámica procesada: ${dynamicResponse.type}');
      return dynamicResponse;
    } catch (e) {
      print('â ChatService: Error procesando respuesta dinámica: $e');
      rethrow;
    }
  }


  // ENDPOINT DE REPORTES

  /// Descargar reporte por ID
  Future<void> downloadReport(String reportId) async {
    try {
      // Hacer la request directamente con configuración para PDF binario
      final token = await const FlutterSecureStorage().read(key: 'Authorization');
      final headers = {
        'Accept': 'application/pdf',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await Dio().get(
        '${_api.baseUrlChat}/reports/download/$reportId',
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
      );
      
      if (response.statusCode == 200) {
        final pdfData = response.data;
        print('📊 PDF DEBUG: Response data type: ${pdfData.runtimeType}');
        print('📊 PDF DEBUG: Data length: ${pdfData is List ? pdfData.length : 'N/A'}');
        
        if (pdfData == null) {
          throw Exception('Los datos del PDF están vacíos');
        }
        
        // Convertir a Uint8List siguiendo el patrón de Excel
        Uint8List bytes;
        if (pdfData is String) {
          // El servidor está devolviendo un string binario directo
          bytes = Uint8List.fromList(pdfData.codeUnits);
        } else if (pdfData is Uint8List) {
          bytes = pdfData;
        } else if (pdfData is List<int>) {
          bytes = Uint8List.fromList(pdfData);
        } else {
          throw Exception('Formato de datos no soportado: ${pdfData.runtimeType}. Esperado String, Uint8List o List<int>');
        }
        
        // Usar el mismo patrón de descarga que Excel
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'reporte_$reportId.pdf')
          ..click();
        
        html.Url.revokeObjectUrl(url);
      } else {
        throw Exception('Error en respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar si los datos parecen ser un PDF válido
  bool _isPdfData(List<int> bytes) {
    if (bytes.length < 4) return false;
    
    // Los PDFs empiezan con "%PDF"
    final pdfHeader = [37, 80, 68, 70]; // "%PDF" en ASCII
    for (int i = 0; i < 4; i++) {
      if (bytes[i] != pdfHeader[i]) {
        return false;
      }
    }
    return true;
  }
}