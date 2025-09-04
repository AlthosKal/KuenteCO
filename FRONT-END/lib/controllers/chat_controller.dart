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
  
  // Estado de análisis de deudas
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

  /// Chat básico con AI
  Future<void> sendMessage(String message, {Model? model}) async {
    print('🔄 ChatController: Enviando mensaje básico');
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
      print('✅ ChatController: Mensaje enviado y respuesta recibida');
    } catch (e) {
      print('❌ ChatController: Error enviando mensaje: $e');
      _setError('Error al enviar mensaje: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Análisis específico de deudas
  Future<void> analyzeDebts({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) async {
    print('🔄 ChatController: Iniciando análisis de deudas');
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
        _lastDebtAnalysis!.analysis ?? 'Análisis de deudas completado',
      );
      
      print('✅ ChatController: Análisis de deudas completado');
    } catch (e) {
      print('❌ ChatController: Error en análisis de deudas: $e');
      _setError('Error al analizar deudas: ${e.toString()}');
    } finally {
      _setDebtAnalyzing(false);
    }
  }

  /// Análisis de riesgo de deudas
  Future<void> analyzeDebtRisk({
    required String userId,
    required double monthlyIncome,
    List<int>? debtIds,
  }) async {
    print('🔄 ChatController: Iniciando análisis de riesgo');
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
        'Análisis de riesgo de deudas',
        _lastDebtAnalysis!.analysis ?? 'Análisis de riesgo completado',
      );
      
      print('✅ ChatController: Análisis de riesgo completado');
    } catch (e) {
      print('❌ ChatController: Error en análisis de riesgo: $e');
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
    print('🔄 ChatController: Generando estrategia de pago');
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
      
      print('✅ ChatController: Estrategia de pago generada');
    } catch (e) {
      print('❌ ChatController: Error generando estrategia: $e');
      _setError('Error al generar estrategia: ${e.toString()}');
    } finally {
      _setDebtAnalyzing(false);
    }
  }

  /// Análisis dinámico
  Future<void> getDynamicAnalysis(String message, {Model? model}) async {
    print('🔄 ChatController: Solicitando análisis dinámico');
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
      print('✅ ChatController: Análisis dinámico completado');
    } catch (e) {
      print('❌ ChatController: Error en análisis dinámico: $e');
      _setError('Error en análisis dinámico: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar historial de chat
  Future<void> loadChatHistory() async {
    print('🔄 ChatController: Cargando historial de chat');
    _setLoading(true);

    try {
      // _chatHistory = await _historyService.getChatHistory();
      // Por ahora usar historial local
      print('✅ ChatController: Historial cargado: ${_chatHistory.length} mensajes');
    } catch (e) {
      print('❌ ChatController: Error cargando historial: $e');
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
        print('📝 ChatController: Historial guardado localmente');
      } catch (e) {
        print('⚠️ ChatController: Error guardando en historial: $e');
      }
    }
  }

  /// Limpiar conversación actual
  void clearCurrentConversation() {
    _currentConversationId = null;
    _lastChatResponse = null;
    _lastStringResponse = null;
    _lastDynamicAnalysis = null;
    _lastDebtAnalysis = null;
    _lastDebtAnalysisType = null;
    _setError(null);
    notifyListeners();
    print('🧹 ChatController: Conversación actual limpiada');
  }

  /// Limpiar todo el historial
  Future<void> clearAllHistory() async {
    print('🔄 ChatController: Limpiando todo el historial');
    try {
      // await _historyService.clearAllHistory();
      _chatHistory.clear();
      clearCurrentConversation();
      print('✅ ChatController: Historial limpiado completamente');
    } catch (e) {
      print('❌ ChatController: Error limpiando historial: $e');
      _setError('Error al limpiar historial: ${e.toString()}');
    }
  }

  /// Obtener resumen del último análisis de deudas
  String? get lastDebtAnalysisSummary {
    return _lastDebtAnalysis?.summary;
  }

  /// Obtener recomendaciones del último análisis
  List<String> get lastDebtRecommendations {
    return _lastDebtAnalysis?.recommendations ?? [];
  }

  /// Verificar si hay análisis de riesgo disponible
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

  /// Verificar si hay datos de gráfico en la última respuesta
  bool get hasChartData {
    return _lastDynamicAnalysis?.hasChartData == true;
  }

  /// Obtener tipo de análisis dinámico
  String? get dynamicAnalysisType {
    return _lastDynamicAnalysis?.analysisType;
  }

  /// Métodos simplificados para ReportView
  Future<void> analyzeDebtsGeneral() async {
    // Por ahora usar datos dummy, después se puede conectar con userId real
    await analyzeDebts(
      userId: "dummy_user_id",
      customMessage: "Analizar todas mis deudas de forma general",
    );
  }

  Future<void> analyzeDebtsRisk() async {
    // Por ahora usar datos dummy, después se puede conectar con userId real
    await analyzeDebtRisk(
      userId: "dummy_user_id", 
      monthlyIncome: 50000.0, // Valor dummy
    );
  }
}