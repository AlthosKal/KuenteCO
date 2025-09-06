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

  /// Chat bÃ¡sico con AI
  Future<ChatResponseDTO> askAi(ChatDTO dto) async {
    print('ð ChatService: Enviando consulta bÃ¡sica al chat AI');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: Respuesta recibida del chat bÃ¡sico');
      return ChatResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en chat bÃ¡sico: $e');
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

  /// AnÃ¡lisis especÃ­fico de deudas
  Future<DebtAnalysisResponseDTO> analyzeDebts(DebtChatRequestDTO dto) async {
    print('ð ChatService: Iniciando anÃ¡lisis de deudas');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: AnÃ¡lisis de deudas completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en anÃ¡lisis de deudas: $e');
      rethrow;
    }
  }

  /// AnÃ¡lisis dinÃ¡mico (respuesta flexible basada en tipo)
  Future<DynamicAnalysisResponseDTO> getDynamicAnalysis(ChatDTO dto) async {
    print('ð ChatService: Solicitando anÃ¡lisis dinÃ¡mico');
    try {
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: AnÃ¡lisis dinÃ¡mico recibido');
      return DynamicAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en anÃ¡lisis dinÃ¡mico: $e');
      rethrow;
    }
  }

  /// AnÃ¡lisis de riesgo de deudas
  Future<DebtAnalysisResponseDTO> getDebtRiskAnalysis({
    required String userId,
    required double monthlyIncome,
    List<int>? debtIds,
  }) async {
    print('ð ChatService: Iniciando anÃ¡lisis de riesgo de deudas');
    try {
      final dto = DebtChatRequestDTO.riskAnalysis(
        userId: userId,
        monthlyIncome: monthlyIncome,
        debtIds: debtIds,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: AnÃ¡lisis de riesgo completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en anÃ¡lisis de riesgo: $e');
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

  /// AnÃ¡lisis general de deudas
  Future<DebtAnalysisResponseDTO> getGeneralDebtAnalysis({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) async {
    print('ð ChatService: Iniciando anÃ¡lisis general de deudas');
    try {
      final dto = DebtChatRequestDTO.analyzeDebts(
        userId: userId,
        specificDebtIds: specificDebtIds,
        customMessage: customMessage,
      );
      
      final response = await _api.postChat('/chat', dto.toJson());
      print('â ChatService: AnÃ¡lisis general completado');
      return DebtAnalysisResponseDTO.fromJson(response.data);
    } catch (e) {
      print('â ChatService: Error en anÃ¡lisis general: $e');
      rethrow;
    }
  }

  /// Procesar respuesta dinÃ¡mica basada en tipo
  Future<BaseDynamicResponseDTO> processResponse(Map<String, dynamic> responseData) async {
    print('ð ChatService: Procesando respuesta dinÃ¡mica');
    try {
      final dynamicResponse = BaseDynamicResponseDTO.fromJson(responseData);
      print('â ChatService: Respuesta dinÃ¡mica procesada: ${dynamicResponse.type}');
      return dynamicResponse;
    } catch (e) {
      print('â ChatService: Error procesando respuesta dinÃ¡mica: $e');
      rethrow;
    }
  }
}