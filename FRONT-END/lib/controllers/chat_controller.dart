import 'package:flutter/material.dart';
import '../core/services/chat/chat_service.dart';
import '../core/services/chat/chat_history_service.dart' as history;
import '../dto/chat/request/chat_dto.dart';
import '../dto/chat/response/chat_response_dto.dart';
import '../dto/chat/response/string_chat_response_dto.dart';
import '../dto/chat/response/dynamic_analysis_response_dto.dart';
import '../dto/chat/response/debt_analysis_response_dto.dart';
import '../dto/chat/response/chat_history_dto.dart';
import '../utils/enum/model_enum.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService;
  final history.ChatService _historyService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentConversationId;
  
  // Respuestas del chat
  ChatResponseDTO? _lastChatResponse;
  StringChatResponseDTO? _lastStringResponse;
  DynamicAnalysisResponseDTO? _lastDynamicAnalysis;
  DebtAnalysisResponseDTO? _lastDebtAnalysis;
  
  // Historial
  List<ChatHistoryDTO> _chatHistory = [];
  
  // Estado de anÃ¡lisis de deudas
  bool _isAnalyzingDebts = false;
  String? _lastDebtAnalysisType;

  ChatController(this._chatService, this._historyService);

  // Getters
  bool get isLoading => _isLoading;
  bool get isAnalyzingDebts => _isAnalyzingDebts;
  String? get errorMessage => _errorMessage;
  String? get currentConversationId => _currentConversationId;
  ChatResponseDTO? get lastChatResponse => _lastChatResponse;
  StringChatResponseDTO? get lastStringResponse => _lastStringResponse;
  DynamicAnalysisResponseDTO? get lastDynamicAnalysis => _lastDynamicAnalysis;
  DebtAnalysisResponseDTO? get lastDebtAnalysis => _lastDebtAnalysis;
  List<ChatHistoryDTO> get chatHistory => List.unmodifiable(_chatHistory);
  String? get lastDebtAnalysisType => _lastDebtAnalysisType;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setDebtAnalyzing(bool analyzing) {
    _isAnalyzingDebts = analyzing;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Chat bÃ¡sico con AI
  Future<void> sendMessage(String message, {Model? model}) async {
    print('ð ChatController: Enviando mensaje bÃ¡sico');
    _setLoading(true);
    _setError(null);

    try {
      final dto = ChatDTO(
        model: model ?? Model.OPENAI,
        conversationId: _currentConversationId,
        prompt: message,
      );

      _lastChatResponse = await _chatService.askAi(dto);
      _currentConversationId = _lastChatResponse!.conversationId;
      
      await _addToHistory(message, _lastChatResponse!.analysis.response);
      print('â ChatController: Mensaje enviado y respuesta recibida');
    } catch (e) {
      print('â ChatController: Error enviando mensaje: $e');
      _setError('Error al enviar mensaje: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// AnÃ¡lisis especÃ­fico de deudas
  Future<void> analyzeDebts({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) async {
    print('ð ChatController: Iniciando anÃ¡lisis de deudas');
    _setDebtAnalyzing(true);
    _setError(null);
    _lastDebtAnalysisType = 'GENERAL_ANALYSIS';

    try {
      _lastDebtAnalysis = await _chatService.getGeneralDebtAnalysis(
        userId: userId,
        specificDebtIds: specificDebtIds,
        customMessage: customMessage,
      );
      
      await _addToHistory(
        customMessage ?? 'Analizar mis deudas',
        _lastDebtAnalysis!.analysis ?? 'AnÃ¡lisis de deudas completado',
      );
      
      print('â ChatController: AnÃ¡lisis de deudas completado');
    } catch (e) {
      print('â ChatController: Error en anÃ¡lisis de deudas: $e');
      _setError('Error al analizar deudas: ${e.toString()}');
    } finally {
      _setDebtAnalyzing(false);
    }
  }

  /// AnÃ¡lisis de riesgo de deudas
  Future<void> analyzeDebtRisk({
    required String userId,
    required double monthlyIncome,
    List<int>? debtIds,
  }) async {
    print('ð ChatController: Iniciando anÃ¡lisis de riesgo');
    _setDebtAnalyzing(true);
    _setError(null);
    _lastDebtAnalysisType = 'RISK_ANALYSIS';

    try {
      _lastDebtAnalysis = await _chatService.getDebtRiskAnalysis(
        userId: userId,
        monthlyIncome: monthlyIncome,
        debtIds: debtIds,
      );
      
      await _addToHistory(
        'AnÃ¡lisis de riesgo de deudas',
        _lastDebtAnalysis!.analysis ?? 'AnÃ¡lisis de riesgo completado',
      );
      
      print('â ChatController: AnÃ¡lisis de riesgo completado');
    } catch (e) {
      print('â ChatController: Error en anÃ¡lisis de riesgo: $e');
      _setError('Error al analizar riesgo: ${e.toString()}');
    } finally {
      _setDebtAnalyzing(false);
    }
  }

  /// Estrategia de pago
  Future<void> generatePaymentStrategy({
    required String userId,
    required double availableBudget,
    List<int>? priorityDebtIds,
  }) async {
    print('ð ChatController: Generando estrategia de pago');
    _setDebtAnalyzing(true);
    _setError(null);
    _lastDebtAnalysisType = 'PAYMENT_STRATEGY';

    try {
      _lastDebtAnalysis = await _chatService.getPaymentStrategy(
        userId: userId,
        availableBudget: availableBudget,
        priorityDebtIds: priorityDebtIds,
      );
      
      await _addToHistory(
        'Estrategia de pago para deudas',
        _lastDebtAnalysis!.analysis ?? 'Estrategia generada',
      );
      
      print('â ChatController: Estrategia de pago generada');
    } catch (e) {
      print('â ChatController: Error generando estrategia: $e');
      _setError('Error al generar estrategia: ${e.toString()}');
    } finally {
      _setDebtAnalyzing(false);
    }
  }

  /// AnÃ¡lisis dinÃ¡mico
  Future<void> getDynamicAnalysis(String message, {Model? model}) async {
    print('ð ChatController: Solicitando anÃ¡lisis dinÃ¡mico');
    _setLoading(true);
    _setError(null);

    try {
      final dto = ChatDTO(
        model: model ?? Model.OPENAI,
        conversationId: _currentConversationId,
        prompt: message,
      );

      _lastDynamicAnalysis = await _chatService.getDynamicAnalysis(dto);
      _currentConversationId = _lastDynamicAnalysis!.body.conversationId;
      
      await _addToHistory(message, _lastDynamicAnalysis!.body.response);
      print('â ChatController: AnÃ¡lisis dinÃ¡mico completado');
    } catch (e) {
      print('â ChatController: Error en anÃ¡lisis dinÃ¡mico: $e');
      _setError('Error en anÃ¡lisis dinÃ¡mico: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar historial de chat
  Future<void> loadChatHistory() async {
    print('ð ChatController: Cargando historial de chat');
    _setLoading(true);

    try {
      // _chatHistory = await _historyService.getChatHistory();
      // Por ahora usar historial local
      print('â ChatController: Historial cargado: ${_chatHistory.length} mensajes');
    } catch (e) {
      print('â ChatController: Error cargando historial: $e');
      _setError('Error al cargar historial: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Agregar mensaje al historial
  Future<void> _addToHistory(String prompt, String response) async {
    if (_currentConversationId != null) {
      final historyItem = ChatHistoryDTO(
        conversationId: _currentConversationId!,
        prompt: prompt,
        response: response,
        date: DateTime.now(),
      );
      
      _chatHistory.insert(0, historyItem);
      notifyListeners();
      
      // Guardar en el servicio de historial (por implementar)
      try {
        // await _historyService.saveChatHistory(historyItem);
        print('ð ChatController: Historial guardado localmente');
      } catch (e) {
        print('â ï¸ ChatController: Error guardando en historial: $e');
      }
    }
  }

  /// Limpiar conversaciÃ³n actual
  void clearCurrentConversation() {
    _currentConversationId = null;
    _lastChatResponse = null;
    _lastStringResponse = null;
    _lastDynamicAnalysis = null;
    _lastDebtAnalysis = null;
    _lastDebtAnalysisType = null;
    _setError(null);
    notifyListeners();
    print('ð§¹ ChatController: ConversaciÃ³n actual limpiada');
  }

  /// Limpiar todo el historial
  Future<void> clearAllHistory() async {
    print('ð ChatController: Limpiando todo el historial');
    try {
      // await _historyService.clearAllHistory();
      _chatHistory.clear();
      clearCurrentConversation();
      print('â ChatController: Historial limpiado completamente');
    } catch (e) {
      print('â ChatController: Error limpiando historial: $e');
      _setError('Error al limpiar historial: ${e.toString()}');
    }
  }

  /// Obtener resumen del Ãºltimo anÃ¡lisis de deudas
  String? get lastDebtAnalysisSummary {
    return _lastDebtAnalysis?.summary;
  }

  /// Obtener recomendaciones del Ãºltimo anÃ¡lisis
  List<String> get lastDebtRecommendations {
    return _lastDebtAnalysis?.recommendations ?? [];
  }

  /// Verificar si hay anÃ¡lisis de riesgo disponible
  bool get hasRiskAnalysis {
    return _lastDebtAnalysis?.debtAnalysis != null;
  }

  /// Obtener nivel de riesgo actual
  String? get currentRiskLevel {
    return _lastDebtAnalysis?.debtAnalysis?.riskLevel;
  }

  /// Obtener ratio deuda-ingreso
  String? get debtToIncomeRatio {
    return _lastDebtAnalysis?.debtAnalysis?.debtToIncomeRatio;
  }

  /// Verificar si hay datos de grÃ¡fico en la Ãºltima respuesta
  bool get hasChartData {
    return _lastDynamicAnalysis?.hasChartData == true;
  }

  /// Obtener tipo de anÃ¡lisis dinÃ¡mico
  String? get dynamicAnalysisType {
    return _lastDynamicAnalysis?.analysisType;
  }

  /// MÃ©todos simplificados para ReportView
  Future<void> analyzeDebtsGeneral() async {
    // Por ahora usar datos dummy, despuÃ©s se puede conectar con userId real
    await analyzeDebts(
      userId: "dummy_user_id",
      customMessage: "Analizar todas mis deudas de forma general",
    );
  }

  Future<void> analyzeDebtsRisk() async {
    // Por ahora usar datos dummy, despuÃ©s se puede conectar con userId real
    await analyzeDebtRisk(
      userId: "dummy_user_id", 
      monthlyIncome: 50000.0, // Valor dummy
    );
  }
}