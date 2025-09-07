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

// Modelo para mensajes de chat
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });
}

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
  
  // Control de mensajes en tiempo real
  final List<ChatMessage> _messages = [];
  String? _currentTypingMessage;
  bool _isTyping = false;

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
  
  // Getters para mensajes en tiempo real
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  String? get currentTypingMessage => _currentTypingMessage;

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

  void _setTyping(bool typing, {String? message}) {
    _isTyping = typing;
    _currentTypingMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Chat básico con AI
  Future<void> sendMessage(String message, {Model? model}) async {
    print('ð ChatController: Enviando mensaje básico');
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

  /// Análisis específico de deudas
  Future<void> analyzeDebts({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) async {
    print('ð ChatController: Iniciando análisis de deudas');
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
      
      print('â ChatController: Análisis de deudas completado');
    } catch (e) {
      print('â ChatController: Error en análisis de deudas: $e');
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
    print('ð ChatController: Iniciando análisis de riesgo');
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
      
      print('â ChatController: Análisis de riesgo completado');
    } catch (e) {
      print('â ChatController: Error en análisis de riesgo: $e');
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

  /// Análisis dinámico
  Future<void> getDynamicAnalysis(String message, {Model? model}) async {
    print('ð ChatController: Solicitando análisis dinámico');
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
      print('â ChatController: Análisis dinámico completado');
    } catch (e) {
      print('â ChatController: Error en análisis dinámico: $e');
      _setError('Error en análisis dinámico: ${e.toString()}');
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
    print('ð§¹ ChatController: Conversación actual limpiada');
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

  /// Agregar mensaje del usuario
  void _addUserMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }

  /// Agregar mensaje de la IA
  void _addAIMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }

  /// Limpiar todos los mensajes
  void clearMessages() {
    _messages.clear();
    _setTyping(false);
    notifyListeners();
  }

  /// Actualizar método sendMessage para incluir manejo de mensajes
  Future<void> sendMessageWithTypewriter(String message, {Model? model}) async {
    print('🤖 ChatController: Enviando mensaje con efecto typewriter');
    _setLoading(true);
    _setError(null);
    
    // Agregar mensaje del usuario inmediatamente
    _addUserMessage(message);

    try {
      final dto = ChatDTO(
        model: model ?? Model.OPENAI,
        conversationId: _currentConversationId,
        prompt: message,
      );

      // Mostrar indicador de que la IA está escribiendo
      _setTyping(true, message: 'La IA está analizando tu consulta...');

      _lastChatResponse = await _chatService.askAi(dto);
      
      // Detener indicador de escritura
      _setTyping(false);
      
      // Manejo seguro de la respuesta
      if (_lastChatResponse != null) {
        _currentConversationId = _lastChatResponse!.conversationId;
        
        // Validar que la respuesta tenga contenido antes de agregarlo
        final responseText = _lastChatResponse!.analysis.response;
        if (responseText.isNotEmpty) {
          _addAIMessage(responseText);
          await _addToHistory(message, responseText);
        } else {
          final fallbackMessage = 'La IA ha procesado tu consulta, pero no se pudo obtener una respuesta de texto.';
          _addAIMessage(fallbackMessage);
          await _addToHistory(message, fallbackMessage);
        }
      } else {
        final errorMessage = 'No se pudo obtener respuesta del servidor.';
        _addAIMessage(errorMessage);
      }
      
      print('✅ ChatController: Mensaje enviado y respuesta recibida');
    } catch (e, stackTrace) {
      print('❌ ChatController: Error enviando mensaje: $e');
      print('❌ StackTrace: $stackTrace');
      _setTyping(false);
      
      // Agregar mensaje de error visible al usuario
      final errorMessage = 'Lo siento, ocurrió un error al procesar tu mensaje. Por favor, intenta nuevamente.';
      _addAIMessage(errorMessage);
      _setError('Error al enviar mensaje: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}