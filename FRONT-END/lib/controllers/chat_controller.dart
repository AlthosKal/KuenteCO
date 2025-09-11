import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/services/chat/chat_service.dart';
import '../core/services/chat/chat_history_service.dart' as history;
import '../dto/chat/request/chat_dto.dart';
import '../dto/chat/response/chat_response_dto.dart';
import '../dto/chat/response/string_chat_response_dto.dart';
import '../dto/chat/response/dynamic_analysis_response_dto.dart';
import '../dto/chat/response/debt_analysis_response_dto.dart';
import '../dto/chat/response/chat_history_dto.dart';
import '../dto/chat/response/base_dynamic_response_dto.dart';
import '../dto/chat/response/report_download_response_dto.dart';

// Modelo para mensajes de chat
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;
  final bool isNew; // Para distinguir mensajes nuevos de históricos
  final String? reportId; // ID del reporte para descarga
  final String? fileName; // Nombre del archivo del reporte

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
    this.isNew = true, // Por defecto es nuevo
    this.reportId,
    this.fileName,
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
  bool _isCancelled = false;


  ChatController(this._chatService, this._historyService) {
    print('🏗️ ChatController: Constructor ejecutado, _currentConversationId: $_currentConversationId');
    // Inicializar con una conversación nueva y limpia
    startNewConversation();
    // Cargar historial automáticamente sin await para no bloquear el constructor
    _loadHistoryAsync();
  }
  
  /// Cargar historial de forma asíncrona
  void _loadHistoryAsync() async {
    print('🚀 ChatController: Cargando historial automáticamente');
    
    final originalErrorMessage = _errorMessage;
    await loadChatHistory();
    
    // Verificar si hubo un error después de cargar
    if (_errorMessage != null && _errorMessage != originalErrorMessage) {
      print('❌ ChatController: Error al cargar historial automáticamente');
    } else {
      print('✅ ChatController: Historial cargado automáticamente exitosamente');
      
      // Ya no seleccionamos automáticamente la conversación más reciente
      // El usuario debe seleccionar explícitamente una conversación del historial
      print('📚 ChatController: Historial cargado. Esperando selección manual de conversación.');
    }
  }

  /// Convertir markdown a texto plano
  String _markdownToPlainText(String markdown) {
    if (markdown.isEmpty) return markdown;
    
    String plainText = markdown;
    
    // Remover encabezados (### ## #) - capturar y mantener solo el texto
    plainText = plainText.replaceAllMapped(
      RegExp(r'^#{1,6}\s*(.*)$', multiLine: true), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover negritas (**texto** o __texto__)
    plainText = plainText.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'), 
      (match) => match.group(1) ?? ''
    );
    plainText = plainText.replaceAllMapped(
      RegExp(r'__(.*?)__'), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover cursivas (*texto* o _texto_)
    plainText = plainText.replaceAllMapped(
      RegExp(r'\*([^*]+)\*'), 
      (match) => match.group(1) ?? ''
    );
    plainText = plainText.replaceAllMapped(
      RegExp(r'_([^_]+)_'), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover código inline (`código`)
    plainText = plainText.replaceAllMapped(
      RegExp(r'`([^`]*)`'), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover bloques de código (```código```)
    plainText = plainText.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Remover enlaces normales [texto](url) - mantener solo el texto, pero preservar enlaces de descarga
    plainText = plainText.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\((?!#download:)([^)]*)\)'), 
      (match) => match.group(1) ?? ''
    );
    
    // Los enlaces de descarga [texto](#download:id) se mantienen intactos
    
    // Remover listas con bullets (- * +) - mantener solo el contenido
    plainText = plainText.replaceAllMapped(
      RegExp(r'^[\s]*[-\*\+]\s*(.*)$', multiLine: true), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover numeración de listas (1. 2. 3.) - mantener solo el contenido
    plainText = plainText.replaceAllMapped(
      RegExp(r'^\s*\d+\.\s*(.*)$', multiLine: true), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover citas (> texto) - mantener solo el contenido
    plainText = plainText.replaceAllMapped(
      RegExp(r'^>\s*(.*)$', multiLine: true), 
      (match) => match.group(1) ?? ''
    );
    
    // Remover líneas de separación (---)
    plainText = plainText.replaceAll(RegExp(r'^---+$', multiLine: true), '');
    
    // Remover tablas (|columna|columna|)
    plainText = plainText.replaceAll(RegExp(r'^\|.*\|$', multiLine: true), '');
    
    // Limpiar múltiples saltos de línea consecutivos
    plainText = plainText.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    
    // Limpiar espacios extra al inicio y final de líneas
    plainText = plainText.replaceAll(RegExp(r'^[ \t]+|[ \t]+$', multiLine: true), '');
    
    // Limpiar cualquier $1, $2, etc. que pueda haber quedado
    plainText = plainText.replaceAll(RegExp(r'\$\d+'), '');
    
    // Limpiar espacios extra
    plainText = plainText.trim();
    
    return plainText;
  }

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

  /// Limpiar estado de escritura
  void clearTyping() {
    print('✏️ ChatController: Limpiando estado de escritura');
    _setTyping(false);
  }

  /// Cancelar respuesta en progreso
  void cancelCurrentResponse() {
    print('🛑 ChatController: Cancelando respuesta en progreso');
    _isCancelled = true;
    _setLoading(false);
    _setTyping(false);
    
    // Agregar mensaje de cancelación solo si estábamos realmente generando algo nuevo
    if (_messages.isNotEmpty && _isLoading) {
      final cancelMessage = 'Respuesta cancelada por el usuario.';
      // Agregar directamente sin activar typewriter para cancelación
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: cancelMessage,
        isUser: false,
        timestamp: DateTime.now(),
        isNew: false, // Mensaje de cancelación no es nuevo
      );
      _messages.add(message);
    }
    
    notifyListeners();
    print('✅ ChatController: Respuesta cancelada');
  }

  /// Chat básico con AI
  Future<void> sendMessage(String message) async {
    print('ð ChatController: Enviando mensaje básico');
    _setLoading(true);
    _setError(null);

    try {
      final dto = ChatDTO(
        conversationId: _currentConversationId,
        prompt: message,
      );

      _lastChatResponse = await _chatService.askAi(dto);
      
      // Solo actualizar conversationId si no tenemos uno ya (primera vez)
      if (_currentConversationId == null) {
        _currentConversationId = _lastChatResponse!.conversationId;
        print('ChatController: Nueva conversación iniciada con ID: $_currentConversationId');
      } else {
        print('ChatController: Continuando conversación con ID: $_currentConversationId');
      }
      
      final plainTextResponse = _markdownToPlainText(_lastChatResponse!.analysis.response);
      await _addToHistory(message, plainTextResponse);
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
      
      final plainTextAnalysis = _markdownToPlainText(_lastDebtAnalysis!.analysis ?? 'Análisis de deudas completado');
      await _addToHistory(
        customMessage ?? 'Analizar mis deudas',
        plainTextAnalysis,
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
      
      final plainTextAnalysis = _markdownToPlainText(_lastDebtAnalysis!.analysis ?? 'Análisis de riesgo completado');
      await _addToHistory(
        'Análisis de riesgo de deudas',
        plainTextAnalysis,
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
      
      final plainTextAnalysis = _markdownToPlainText(_lastDebtAnalysis!.analysis ?? 'Estrategia generada');
      await _addToHistory(
        'Estrategia de pago para deudas',
        plainTextAnalysis,
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
  Future<void> getDynamicAnalysis(String message) async {
    print('ð ChatController: Solicitando análisis dinámico');
    _setLoading(true);
    _setError(null);

    try {
      final dto = ChatDTO(
        conversationId: _currentConversationId,
        prompt: message,
      );

      _lastDynamicAnalysis = await _chatService.getDynamicAnalysis(dto);
      
      // Solo actualizar conversationId si no tenemos uno ya (primera vez)
      if (_currentConversationId == null) {
        _currentConversationId = _lastDynamicAnalysis!.body.conversationId;
        print('ChatController: Nueva conversación dinámica iniciada con ID: $_currentConversationId');
      } else {
        print('ChatController: Continuando conversación dinámica con ID: $_currentConversationId');
      }
      
      final plainTextResponse = _markdownToPlainText(_lastDynamicAnalysis!.body.response);
      await _addToHistory(message, plainTextResponse);
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
      final allMessages = await _historyService.getAllConversations();
      print('ChatController: Obtenidos ${allMessages.length} mensajes del servidor');

      // AGRUPAR POR CONVERSATION ID - MANTENER EL PRIMER MENSAJE DE CADA CONVERSACION
      final Map<String, ChatHistoryDTO> conversationRepresentatives = {};
      final Map<String, List<ChatHistoryDTO>> allMessagesByConversation = {};

      print('📊 ChatController: Analizando ${allMessages.length} mensajes para agrupación:');
      
      for (final message in allMessages) {
        final id = message.conversationId;
        print('   - ID: $id, Prompt: "${message.prompt.substring(0, math.min(20, message.prompt.length))}..."');
        
        // Agrupar TODOS los mensajes por conversation ID
        if (!allMessagesByConversation.containsKey(id)) {
          allMessagesByConversation[id] = [];
        }
        allMessagesByConversation[id]!.add(message);

        // Si no existe esta conversación, o si este mensaje es más antiguo (primer prompt histórico)
        if (!conversationRepresentatives.containsKey(id) ||
            message.date.isBefore(conversationRepresentatives[id]!.date)) {
          conversationRepresentatives[id] = message;
        }
      }
      
      print('📊 ChatController: Resumen de agrupación:');
      allMessagesByConversation.forEach((id, messages) {
        print('   - Conversación $id: ${messages.length} mensajes');
        print('     Primer mensaje: "${messages.first.prompt.substring(0, math.min(20, messages.first.prompt.length))}..."');
      });

      // Convertir a lista ordenada por fecha del último mensaje de cada conversación
      _chatHistory = conversationRepresentatives.values.toList();
      
      // Ordenar por la fecha más reciente de cada conversación
      for (int i = 0; i < _chatHistory.length; i++) {
        final conversationId = _chatHistory[i].conversationId;
        // Encontrar el mensaje más reciente de esta conversación para el ordenamiento
        final latestMessageInConversation = allMessages
            .where((msg) => msg.conversationId == conversationId)
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
        
        // Encontrar el primer mensaje (más antiguo) para conservar como título
        final firstMessageInConversation = allMessages
            .where((msg) => msg.conversationId == conversationId)
            .reduce((a, b) => a.date.isBefore(b.date) ? a : b);
        
        // Actualizar manteniendo el primer prompt como título pero con fecha más reciente para ordenamiento
        _chatHistory[i] = ChatHistoryDTO(
          conversationId: _chatHistory[i].conversationId,
          prompt: firstMessageInConversation.prompt, // SIEMPRE usar el primer prompt como título
          date: latestMessageInConversation.date, // Fecha más reciente para ordenamiento
        );
      }
      
      // Ordenar por fecha más reciente
      _chatHistory.sort((a, b) => b.date.compareTo(a.date));

      print('ChatController: AGRUPAMIENTO COMPLETO - ${_chatHistory.length} conversaciones únicas de ${allMessages.length} mensajes totales');
      
      // Debug: Mostrar las primeras 3 conversaciones de la lista final
      print('📝 DEBUG: Lista final de conversaciones (primeras 3):');
      for (int i = 0; i < math.min(3, _chatHistory.length); i++) {
        final conv = _chatHistory[i];
        print('   ${i+1}. ID: ${conv.conversationId}');
        print('      Title: "${conv.prompt.substring(0, math.min(30, conv.prompt.length))}..."');
        print('      Fecha: ${conv.date}');
      }

      // FORZAR ACTUALIZACION DE UI
      notifyListeners();
    } catch (e) {
      print('ChatController: Error cargando historial: $e');
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
        date: DateTime.now(),
      );
      
      // Buscar si ya existe una entrada para esta conversación en el historial
      final existingIndex = _chatHistory.indexWhere(
        (item) => item.conversationId == _currentConversationId,
      );
      
      if (existingIndex != -1) {
        // Actualizar la conversación existente con el último mensaje y fecha más reciente
        _chatHistory[existingIndex] = ChatHistoryDTO(
          conversationId: _currentConversationId!,
          prompt: _chatHistory[existingIndex].prompt, // Mantener el primer mensaje como título
          date: DateTime.now(), // Fecha más reciente para ordenamiento
        );
        
        // Mover al inicio de la lista (conversación más reciente)
        final updatedItem = _chatHistory.removeAt(existingIndex);
        _chatHistory.insert(0, updatedItem);
      } else {
        // Si es una conversación nueva, agregar al inicio
        _chatHistory.insert(0, historyItem);
      }
      notifyListeners();
      
      // Guardar en el servicio de historial (por implementar)
      try {
        // El servidor guarda automáticamente - no POST necesario
        print('ð ChatController: Historial guardado localmente');
      } catch (e) {
        print('â ï¸ ChatController: Error guardando en historial: $e');
      }
    }
  }

  /// Limpiar conversación actual (mantiene compatibilidad)
  void clearCurrentConversation() {
    startNewConversation();
    print('ð§¹ ChatController: Conversación actual limpiada');
  }

  /// Limpiar todo el historial
  Future<void> clearAllHistory() async {
    print('ð ChatController: Limpiando todo el historial');
    try {
      await _historyService.clearAllHistory();
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
  void _addUserMessage(String content, {bool isNew = true}) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      isNew: isNew,
    );
    _messages.add(message);
    notifyListeners();
  }

  /// Agregar mensaje de la IA
  void _addAIMessage(String content, {bool isNew = true}) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      isNew: isNew,
    );
    _messages.add(message);
    // Solo activar estado de escritura para mensajes nuevos
    if (isNew) {
      _setTyping(true, message: 'Mostrando respuesta...');
    }
    notifyListeners();
  }

  /// Limpiar todos los mensajes
  void clearMessages() {
    _messages.clear();
    _setTyping(false);
    notifyListeners();
  }

  /// Actualizar método sendMessage para incluir manejo de mensajes
  Future<void> sendMessageWithTypewriter(String message) async {
    print('🤖 ChatController: Enviando mensaje con efecto typewriter');
    print('🔍 ChatController: _currentConversationId actual: $_currentConversationId');
    _isCancelled = false; // Resetear estado de cancelación
    _setLoading(true);
    _setError(null);
    
    // Agregar mensaje del usuario inmediatamente
    _addUserMessage(message);

    try {
      final dto = ChatDTO(
        conversationId: _currentConversationId,
        prompt: message,
      );
      
      print('📤 ChatController: Enviando DTO - conversationId: ${dto.conversationId}');

      // Mostrar indicador de que la IA está escribiendo
      _setTyping(true, message: 'La IA está analizando tu consulta...');

      // Usar análisis dinámico que puede manejar todos los tipos de respuesta
      _lastDynamicAnalysis = await _chatService.getDynamicAnalysis(dto);
      
      print('📥 ChatController: Respuesta dinámica recibida - conversationId: ${_lastDynamicAnalysis?.body.conversationId}');
      
      // Verificar si fue cancelado antes de procesar la respuesta
      if (_isCancelled) {
        print('⚠️ ChatController: Respuesta cancelada, no procesando resultado');
        return;
      }
      
      // Detener indicador de escritura
      _setTyping(false);
      
      // Manejo seguro de la respuesta dinámica
      if (_lastDynamicAnalysis != null) {
        // IMPORTANTE: El backend ignora nuestro conversationId y devuelve uno nuevo
        // Debemos usar el ID real que devuelve el backend
        final realConversationId = _lastDynamicAnalysis!.body.conversationId;
        
        print('🔍 ChatController: Analizando conversationId...');
        print('   ConversationId actual: $_currentConversationId');
        print('   ConversationId del backend: "$realConversationId"');
        print('   ConversationId está vacío: ${realConversationId.isEmpty}');
        
        // Solo actualizar si no está vacío
        if (realConversationId.isNotEmpty) {
          if (_currentConversationId != realConversationId) {
            print('⚠️ ChatController: Backend devolvió un ID diferente!');
            print('   Enviado: $_currentConversationId');
            print('   Recibido: $realConversationId');
            _currentConversationId = realConversationId;
          }
        } else {
          print('⚠️ ChatController: Backend devolvió conversationId vacío, manteniendo el actual');
        }
        
        if (_currentConversationId == null) {
          print('ChatController: Nueva conversación typewriter iniciada con ID: $_currentConversationId');
        } else {
          print('ChatController: Usando conversación real con ID: $_currentConversationId');
        }
        
        // Procesar respuesta según su tipo
        await _processAnalysisResponse(_lastDynamicAnalysis!, message);
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

  /// Procesar respuesta de análisis dinámico según su tipo
  Future<void> _processAnalysisResponse(DynamicAnalysisResponseDTO analysis, String originalMessage) async {
    print('🔍 ChatController: Procesando respuesta tipo: ${analysis.analysisType}');
    print('🔍 ChatController: ConversationId: "${analysis.body.conversationId}"');
    print('🔍 ChatController: Response text length: ${analysis.body.response.length}');
    print('🔍 ChatController: Response text: "${analysis.body.response}"');
    
    // Para REPORT_DOWNLOAD, el manejo se hace en _handleReportDownload
    // Para otros tipos, agregar mensaje de texto normal
    if (analysis.analysisType != 'REPORT_DOWNLOAD') {
      final responseText = analysis.body.response;
      if (responseText.isNotEmpty) {
        final plainTextResponse = _markdownToPlainText(responseText);
        _addAIMessage(plainTextResponse);
        await _addToHistory(originalMessage, plainTextResponse);
      } else {
        // Fallback cuando la respuesta está vacía
        print('⚠️ ChatController: Respuesta vacía del backend, mostrando mensaje de fallback');
        final fallbackMessage = 'He procesado tu solicitud pero no se pudo obtener la respuesta completa del servidor. Por favor, intenta nuevamente.';
        _addAIMessage(fallbackMessage);
        await _addToHistory(originalMessage, fallbackMessage);
      }
    }
    
    // Manejar tipos específicos de respuesta
    switch (analysis.analysisType) {
      case 'REPORT_DOWNLOAD':
        await _handleReportDownload(analysis, originalMessage);
        break;
      case 'CHART_DATA':
        _handleChartData(analysis);
        break;
      case 'DEBT_ANALYSIS':
        _handleDebtAnalysis(analysis);
        break;
      case 'SPENDING_PATTERNS':
        _handleSpendingPatterns(analysis);
        break;
      case 'FINANCIAL_HEALTH':
        _handleFinancialHealth(analysis);
        break;
      case 'EXPENSE_SUGGESTIONS':
        _handleExpenseSuggestions(analysis);
        break;
      case 'FINANCIAL_PROJECTION':
        _handleFinancialProjection(analysis);
        break;
      case 'BUDGET_COMPARISON':
        _handleBudgetComparison(analysis);
        break;
      case 'SIMPLE_TEXT':
      default:
        // Ya se manejó el texto arriba
        print('📝 ChatController: Respuesta de texto simple procesada');
        break;
    }
  }

  /// Manejar descarga de reportes (PDFs)
  Future<void> _handleReportDownload(DynamicAnalysisResponseDTO analysis, String originalMessage) async {
    print('📄 ChatController: Iniciando _handleReportDownload');
    print('📄 ChatController: analysis.response type: ${analysis.response.runtimeType}');
    print('📄 ChatController: analysis.response is ReportDownloadResponseWrapperDTO: ${analysis.response is ReportDownloadResponseWrapperDTO}');
    
    if (analysis.response is ReportDownloadResponseWrapperDTO) {
      final reportWrapper = analysis.response as ReportDownloadResponseWrapperDTO;
      final reportData = reportWrapper.reportDownload;
      
      print('📄 ChatController: Reporte disponible para descarga:');
      print('   - ID: ${reportData.reportId}');
      print('   - Archivo: ${reportData.fileName}');
      print('   - Tipo: ${reportData.reportType}');
      print('   - Tamaño: ${reportData.fileSizeBytes} bytes');
      
      // Usar respuesta del servidor directamente, sin enlaces
      final serverResponse = analysis.body.response.isNotEmpty 
          ? analysis.body.response 
          : 'Tu reporte ha sido generado exitosamente.';
      
      final plainTextMessage = _markdownToPlainText(serverResponse);
      
      // Crear mensaje con información del reporte para descarga
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: plainTextMessage,
        isUser: false,
        timestamp: DateTime.now(),
        isNew: true,
        reportId: reportData.reportId,
        fileName: reportData.fileName,
      );
      
      print('📄 ChatController: Creando mensaje con reportId: ${message.reportId}');
      print('📄 ChatController: Creando mensaje con fileName: ${message.fileName}');
      print('📄 ChatController: Total de mensajes antes de agregar: ${_messages.length}');
      
      _messages.add(message);
      print('📄 ChatController: Total de mensajes después de agregar: ${_messages.length}');
      print('📄 ChatController: Último mensaje reportId: ${_messages.last.reportId}');
      notifyListeners();
      
      await _addToHistory(originalMessage, plainTextMessage);
    } else {
      print('❌ ChatController: analysis.response NO es ReportDownloadResponseWrapperDTO');
      print('❌ ChatController: Tipo real: ${analysis.response.runtimeType}');
      
      // Agregar mensaje normal como fallback
      final serverResponse = analysis.body.response.isNotEmpty 
          ? analysis.body.response 
          : 'Error procesando reporte.';
      final plainTextMessage = _markdownToPlainText(serverResponse);
      _addAIMessage(plainTextMessage);
      await _addToHistory(originalMessage, plainTextMessage);
    }
  }

  /// Manejar datos de gráficos
  void _handleChartData(DynamicAnalysisResponseDTO analysis) {
    print('📊 ChatController: Datos de gráfico disponibles');
    // Aquí puedes agregar lógica para mostrar gráficos
    // Por ejemplo, notificar a widgets que muestren gráficos
  }

  /// Manejar análisis de deudas
  void _handleDebtAnalysis(DynamicAnalysisResponseDTO analysis) {
    print('💳 ChatController: Análisis de deudas disponible');
    // Lógica específica para análisis de deudas
  }

  /// Manejar patrones de gasto
  void _handleSpendingPatterns(DynamicAnalysisResponseDTO analysis) {
    print('💰 ChatController: Patrones de gasto analizados');
    // Lógica específica para patrones de gasto
  }

  /// Manejar salud financiera
  void _handleFinancialHealth(DynamicAnalysisResponseDTO analysis) {
    print('🏥 ChatController: Análisis de salud financiera disponible');
    // Lógica específica para salud financiera
  }

  /// Manejar sugerencias de reducción de gastos
  void _handleExpenseSuggestions(DynamicAnalysisResponseDTO analysis) {
    print('💡 ChatController: Sugerencias de reducción de gastos disponibles');
    // Lógica específica para sugerencias
  }

  /// Manejar proyecciones financieras
  void _handleFinancialProjection(DynamicAnalysisResponseDTO analysis) {
    print('🔮 ChatController: Proyecciones financieras disponibles');
    // Lógica específica para proyecciones
  }

  /// Manejar comparación de presupuestos
  void _handleBudgetComparison(DynamicAnalysisResponseDTO analysis) {
    print('📈 ChatController: Comparación de presupuestos disponible');
    // Lógica específica para comparación de presupuestos
  }

  /// Descargar reporte por ID
  Future<void> downloadReport(String reportId) async {
    print('📥 ChatController: Iniciando descarga de reporte: $reportId');
    _setLoading(true);
    
    try {
      // Pequeño delay para asegurar que el reporte esté completamente procesado
      print('⏱️ ChatController: Esperando a que el reporte esté listo...');
      await Future.delayed(const Duration(milliseconds: 1500));
      
      await _chatService.downloadReport(reportId);
      print('✅ ChatController: Reporte descargado exitosamente');
      
      // Mostrar mensaje de éxito
      _addAIMessage('✅ Descarga iniciada. El archivo se descargará automáticamente.');
      
    } catch (e) {
      print('❌ ChatController: Error descargando reporte: $e');
      _setError('Error al descargar reporte: ${e.toString()}');
      _addAIMessage('❌ Error al descargar el reporte. Por favor, intenta nuevamente.');
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar si hay un reporte disponible para descarga en la última respuesta
  bool get hasReportToDownload {
    return _lastDynamicAnalysis?.analysisType == 'REPORT_DOWNLOAD';
  }

  /// Obtener información del reporte disponible para descarga
  ReportDownloadResponseDTO? get availableReport {
    if (_lastDynamicAnalysis?.analysisType == 'REPORT_DOWNLOAD' &&
        _lastDynamicAnalysis?.response is ReportDownloadResponseWrapperDTO) {
      final wrapper = _lastDynamicAnalysis!.response as ReportDownloadResponseWrapperDTO;
      return wrapper.reportDownload;
    }
    return null;
  }

  /// Iniciar nueva conversación (limpia completamente el estado)
  void startNewConversation() {
    print('ChatController: Iniciando nueva conversación');
    _currentConversationId = null;
    _lastChatResponse = null;
    _lastStringResponse = null;
    _lastDynamicAnalysis = null;
    _lastDebtAnalysis = null;
    _lastDebtAnalysisType = null;
    _messages.clear();
    _setError(null);
    _setTyping(false);
    notifyListeners();
    print('ChatController: Nueva conversación iniciada');
  }

  /// Cargar conversación existente por ID
  Future<void> loadConversation(String conversationId) async {
    print('💬 ChatController: Cargando conversación completa: $conversationId');
    
    // Validar que el conversationId no esté vacío o sea nulo
    if (conversationId.trim().isEmpty) {
      print('❌ ChatController: ConversationId vacío, cancelando carga');
      _setError('ID de conversación inválido');
      return;
    }
    
    _setLoading(true);
    _setError(null);

    try {
      // Limpiar estado actual
      _messages.clear();
      _setTyping(false); // Asegurar que no esté en modo escritura
      _currentConversationId = conversationId;
      
      // Cargar historial de la conversación desde el servidor
      final history = await _historyService.getHistoryByConversationId(conversationId);
      
      print('📚 ChatController: Obtenidos ${history.length} mensajes para conversación $conversationId:');
      
      // Verificar si la conversación realmente existe
      if (history.isEmpty) {
        print('⚠️ ChatController: ADVERTENCIA - Conversación vacía o eliminada: $conversationId');
        _setError('Esta conversación ya no existe o fue eliminada');
        return;
      }
      
      // Convertir historial a mensajes para mostrar en la UI (ordenados cronológicamente)
      final sortedHistory = history..sort((a, b) => a.date.compareTo(b.date));
      
      for (final item in sortedHistory) {
        print('   - ${item.date}: "${item.prompt.substring(0, math.min(30, item.prompt.length))}..."');
        print('     ConversationID: ${item.conversationId}');
        
        // Validación adicional: asegurar que el mensaje pertenece a la conversación correcta
        if (item.conversationId != conversationId) {
          print('⚠️ ChatController: ADVERTENCIA - Mensaje con ID incorrecto!');
          print('     Esperado: $conversationId, Recibido: ${item.conversationId}');
          continue; // Saltar este mensaje
        }
        
        _addUserMessage(item.prompt, isNew: false); // Marcar como histórico
        if (item.response != null) {
          final plainTextResponse = _markdownToPlainText(item.response!);
          _addAIMessage(plainTextResponse, isNew: false); // Marcar como histórico
        }
      }
      
      print('✅ ChatController: Conversación cargada exitosamente con ${history.length} mensajes');
      notifyListeners();
    } catch (e) {
      print('❌ ChatController: Error cargando conversación: $e');
      _setError('Error al cargar conversación: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener lista de conversaciones disponibles (desde el caché local)
  List<ChatHistoryDTO> getAvailableConversations() {
    print('ChatController: Devolviendo ${_chatHistory.length} conversaciones del caché local');
    return List.unmodifiable(_chatHistory);
  }

  /// Refrescar historial de conversaciones desde el servidor
  Future<void> refreshChatHistory() async {
    print('ChatController: Refrescando historial desde el servidor');
    await loadChatHistory();
  }

  /// Método público para inicializar manualmente (útil para debugging)
  Future<void> initializeManually() async {
    print('ChatController: Inicialización manual solicitada');
    await loadChatHistory();
  }

  /// Verificar si hay conversaciones en el historial
  bool get hasConversations => _chatHistory.isNotEmpty;

  /// Obtener el número total de conversaciones
  int get conversationsCount => _chatHistory.length;

  /// Eliminar conversación específica
  Future<void> deleteConversation(String conversationId) async {
    print('ChatController: Eliminando conversación: $conversationId');
    _setLoading(true);
    _setError(null);
    
    try {
      // Eliminar del servidor
      await _historyService.deleteConversation(conversationId);
      
      // Si es la conversación actual, limpiarla
      if (_currentConversationId == conversationId) {
        startNewConversation();
      }
      
      // Forzar recarga completa desde el servidor para evitar inconsistencias
      print('ChatController: Conversación eliminada, recargando historial desde servidor');
      await loadChatHistory();
      
      print('ChatController: Conversación eliminada exitosamente');
      
    } catch (e) {
      print('ChatController: Error eliminando conversación: $e');
      _setError('Error al eliminar conversación: ${e.toString()}');
      
      // En caso de error, recargar el historial para sincronizar
      try {
        await loadChatHistory();
      } catch (reloadError) {
        print('ChatController: Error recargando historial después de fallo: $reloadError');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener título de conversación basado en el primer mensaje
  String getConversationTitle(ChatHistoryDTO conversation) {
    // Usar el prompt como título, truncado si es muy largo
    String title = conversation.prompt.trim();
    if (title.length > 50) {
      title = '${title.substring(0, 50)}...';
    }
    return title.isNotEmpty ? title : 'Conversación sin título';
  }
  
  /// Obtener subtítulo con información de la conversación (fecha + número de mensajes)
  Future<String> getConversationSubtitle(ChatHistoryDTO conversation) async {
    try {
      // Obtener el número real de mensajes en esta conversación
      final messages = await _historyService.getHistoryByConversationId(conversation.conversationId);
      final messageCount = messages.length;
      final dateStr = '${conversation.date.day}/${conversation.date.month}/${conversation.date.year}';
      
      if (messageCount > 1) {
        return '$dateStr • $messageCount mensajes';
      } else {
        return dateStr;
      }
    } catch (e) {
      // Si falla, mostrar solo la fecha
      return '${conversation.date.day}/${conversation.date.month}/${conversation.date.year}';
    }
  }

  /// Obtener resumen de una conversación específica
  Future<String> getConversationSummary(String conversationId) async {
    try {
      final messages = await _historyService.getHistoryByConversationId(conversationId);
      if (messages.isEmpty) return 'Conversación vacía';
      
      // Usar el primer mensaje como resumen
      final firstMessage = messages.first;
      String summary = firstMessage.prompt.trim();
      if (summary.length > 100) {
        summary = '${summary.substring(0, 100)}...';
      }
      return summary.isNotEmpty ? summary : 'Sin descripción';
    } catch (e) {
      print('ChatController: Error obteniendo resumen de conversación: $e');
      return 'Error cargando resumen';
    }
  }
}