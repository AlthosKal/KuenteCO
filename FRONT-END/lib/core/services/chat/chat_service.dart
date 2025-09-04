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
    print('🔄 ChatService: Enviando consulta básica al chat AI');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('✅ ChatService: Respuesta recibida del chat básico');
      return ChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en chat básico: $e');
      rethrow;
    }
  }

  /// Chat con URLs/archivos
  Future<StringChatResponseDTO> askAiWithUrl(ChatFilesDTO dto) async {
    print('🔄 ChatService: Enviando consulta con URLs al chat AI');
    try {
      final response = await _api.postChat('/chat-with-url', dto.toJson());
      print('✅ ChatService: Respuesta recibida del chat con URLs');
      return StringChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en chat con URLs: $e');
      rethrow;
    }
  }

  /// Chat con archivo
  Future<StringChatResponseDTO> askAiWithFile(ChatMultipartDTO dto) async {
    print('🔄 ChatService: Enviando consulta con archivo al chat AI');
    try {
      final response = await _api.postChat('/chat-with-file', dto.toJson());
      print('✅ ChatService: Respuesta recibida del chat con archivo');
      return StringChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en chat con archivo: $e');
      rethrow;
    }
  }

  /// Análisis específico de deudas
  Future<DebtAnalysisResponseDTO> analyzeDebts(DebtChatRequestDTO dto) async {
    print('🔄 ChatService: Iniciando análisis de deudas');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('✅ ChatService: Análisis de deudas completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en análisis de deudas: $e');
      rethrow;
    }
  }

  /// Análisis dinámico (respuesta flexible basada en tipo)
  Future<DynamicAnalysisResponseDTO> getDynamicAnalysis(ChatDTO dto) async {
    print('🔄 ChatService: Solicitando análisis dinámico');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('✅ ChatService: Análisis dinámico recibido');
      return DynamicAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en análisis dinámico: $e');
      rethrow;
    }
  }

  /// Análisis de riesgo de deudas
  Future<DebtAnalysisResponseDTO> getDebtRiskAnalysis({
    required String userId,
    required double monthlyIncome,
    List<int>? debtIds,
  }) async {
    print('🔄 ChatService: Iniciando análisis de riesgo de deudas');
    try {
      final dto = DebtChatRequestDTO.riskAnalysis(
        userId: userId,
        monthlyIncome: monthlyIncome,
        debtIds: debtIds,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('✅ ChatService: Análisis de riesgo completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en análisis de riesgo: $e');
      rethrow;
    }
  }

  /// Estrategia de pago de deudas
  Future<DebtAnalysisResponseDTO> getPaymentStrategy({
    required String userId,
    required double availableBudget,
    List<int>? priorityDebtIds,
  }) async {
    print('🔄 ChatService: Generando estrategia de pago');
    try {
      final dto = DebtChatRequestDTO.paymentStrategy(
        userId: userId,
        availableBudget: availableBudget,
        priorityDebtIds: priorityDebtIds,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('✅ ChatService: Estrategia de pago generada');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error generando estrategia de pago: $e');
      rethrow;
    }
  }

  /// Análisis general de deudas
  Future<DebtAnalysisResponseDTO> getGeneralDebtAnalysis({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) async {
    print('🔄 ChatService: Iniciando análisis general de deudas');
    try {
      final dto = DebtChatRequestDTO.analyzeDebts(
        userId: userId,
        specificDebtIds: specificDebtIds,
        customMessage: customMessage,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('✅ ChatService: Análisis general completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('❌ ChatService: Error en análisis general: $e');
      rethrow;
    }
  }

  /// Procesar respuesta dinámica basada en tipo
  Future<BaseDynamicResponseDTO> processResponse(Map<String, dynamic> responseData) async {
    print('🔄 ChatService: Procesando respuesta dinámica');
    try {
      final dynamicResponse = BaseDynamicResponseDTO.fromJson(responseData);
      print('✅ ChatService: Respuesta dinámica procesada: ${dynamicResponse.type}');
      return dynamicResponse;
    } catch (e) {
      print('❌ ChatService: Error procesando respuesta dinámica: $e');
      rethrow;
    }
  }
}