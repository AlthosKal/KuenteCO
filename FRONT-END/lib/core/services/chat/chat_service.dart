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
      return DynamicAnalysisResponseDTO.fromJson(response.data);
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

  // ENDPOINT DE MODELOS

  /// Obtener todos los modelos disponibles
  Future<List<String>> getAllModels() async {
    print('🤖 ChatService: Obteniendo todos los modelos');
    try {
      final response = await _api.getChat('/model');
      final data = response.data;
      
      print('📊 ChatService: Tipo de respuesta modelos: ${data.runtimeType}');
      print('📊 ChatService: Contenido de respuesta modelos: $data');
      
      if (data is Map<String, dynamic>) {
        // El servidor devuelve: {success: true, data: [...]}
        if (data['success'] == true && data['data'] is List) {
          final models = (data['data'] as List).cast<String>();
          print('✅ ChatService: ${models.length} modelos obtenidos');
          return models;
        } else {
          throw Exception('Error del servidor: ${data['message'] ?? 'Sin mensaje'}');
        }
      } else if (data is List) {
        // Soporte para respuesta directa como lista (por compatibilidad)
        final models = data.cast<String>();
        print('✅ ChatService: ${models.length} modelos obtenidos');
        return models;
      } else if (data == null) {
        print('ℹ️ ChatService: Sin modelos (respuesta nula)');
        return [];
      }
      throw Exception('Respuesta inesperada del servidor. Tipo: ${data.runtimeType}, Contenido: $data');
    } catch (e) {
      print('❌ ChatService: Error obteniendo modelos: $e');
      rethrow;
    }
  }

  // ENDPOINT DE REPORTES

  /// Descargar reporte por ID
  Future<Map<String, dynamic>> downloadReport(String reportId) async {
    print('📥 ChatService: Descargando reporte: $reportId');
    try {
      final response = await _api.getChat('/reports/download/$reportId');
      print('✅ ChatService: Reporte descargado');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ ChatService: Error descargando reporte: $e');
      rethrow;
    }
  }
}