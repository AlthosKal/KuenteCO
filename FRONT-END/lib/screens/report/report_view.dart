import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/business_logic/debt_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/excel/excel_controller.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/report/chat/animated_typing_dots.dart';
import '../../widgets/components/report/chat/chat_message_widget.dart';
import '../../widgets/components/report/chat/debt_analysis_results_widget.dart';
import '../../widgets/components/report/excel/excel_controls_widget.dart';
import '../../widgets/components/report/excel/excel_validation_results_widget.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _messageController;
  late ScrollController _chatScrollController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messageController = TextEditingController();
    _chatScrollController = ScrollController();
    
    // El historial se carga automáticamente desde el constructor del ChatController
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              /// NAVBAR
              KuentecoLoggedNavbar(
                currentRoute: '/reports',
                onLogout: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),

              /// HEADER CON TABS
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportes',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.black54,
                        indicator: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.psychology, size: 20),
                            text: 'Análisis IA',
                          ),
                          Tab(
                            icon: Icon(Icons.table_chart, size: 20),
                            text: 'Excel',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// CONTENIDO DE TABS
              Expanded(
                child: Consumer3<ChatController, ExcelController, DebtController>(
                  builder: (context, chatController, excelController, debtController, child) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAIAnalysisTab(context, chatController, debtController),
                        _buildExcelTab(context, excelController),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAIAnalysisTab(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
      children: [
        // Panel lateral de conversaciones
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              right: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: _buildConversationPanel(context, chatController),
        ),
        // Panel principal del chat
        Expanded(
          child: Column(
            children: [
              // Ãrea de mensajes
              Expanded(
                child: _buildChatArea(context, chatController),
              ),
              // Input de mensaje
              _buildMessageInput(context, chatController, debtController),
            ],
          ),
        ),
      ],
        ),
      ),
    );
  }

  Widget _buildExcelTab(
    BuildContext context,
    ExcelController excelController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ExcelControlsWidget(
              onExport: () => _exportToExcel(context, excelController),
              onDownloadTemplate: () => _downloadTemplate(context, excelController),
              onImport: (file) => _importFromExcel(context, excelController, file),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (excelController.lastValidationResult != null)
            ExcelValidationResultsWidget(
              validationResult: excelController.lastValidationResult!,
              onRetry: () => _retryExcelOperation(context, excelController),
              onProceed: excelController.lastValidationResult!.isValid
                ? () => _proceedWithValidData(context, excelController)
                : null,
            ),
        ],
      ),
    );
  }

  // Chat Interface Methods
  Widget _buildConversationPanel(BuildContext context, ChatController chatController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conversaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      print('🔄 Refrescando historial manualmente');
                      await chatController.refreshChatHistory();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    tooltip: 'Refrescar conversaciones',
                  ),
                  IconButton(
                    onPressed: () => _startNewConversation(chatController),
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'Nueva conversación',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Lista de conversaciones
        Expanded(
          child: chatController.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Cargando conversaciones...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: chatController.chatHistory.length,
                itemBuilder: (context, index) {
                  final historyItem = chatController.chatHistory[index];
                  final isCurrentConversation = chatController.currentConversationId == historyItem.conversationId;
                  return FutureBuilder<String>(
                    future: chatController.getConversationSubtitle(historyItem),
                    builder: (context, subtitleSnapshot) {
                      final subtitle = subtitleSnapshot.data ?? _formatDate(historyItem.date);
                      return _buildConversationTile(
                        context: context,
                        title: _truncateText(historyItem.prompt, 30),
                        subtitle: subtitle,
                        isActive: isCurrentConversation,
                        onTap: () => _loadConversation(chatController, historyItem),
                        onDelete: () => _deleteConversation(chatController, historyItem.conversationId),
                      );
                    },
                  );
                },
              ),
        ),
        
      ],
    );
  }

  Widget _buildConversationTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? Colors.purple[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: Colors.purple[300]!, width: 2) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? Colors.purple[800] : Colors.grey[800],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null && !isActive) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    onDelete();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, ChatController chatController) {
    if (chatController.messages.isEmpty && !chatController.isTyping) {
      return _buildEmptyChat(context);
    }

    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatController.messages.length + (chatController.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Mostrar indicador de escritura al final
                if (index == chatController.messages.length && chatController.isTyping) {
                  return _buildTypingIndicator(context, chatController);
                }
                
                final message = chatController.messages[index];
                return ChatMessageWidget(
                  message: message.content,
                  type: message.isUser ? MessageType.user : MessageType.ai,
                  timestamp: message.timestamp,
                  enableTypewriter: !message.isUser && message.isNew && index == chatController.messages.length - 1, // Solo para mensajes nuevos de IA
                  reportId: message.reportId,
                  fileName: message.fileName,
                  showChart: message.showChart,
                  onTypewriterComplete: () {
                    // Cuando termina el typewriter del último mensaje, desactivar isTyping
                    if (!message.isUser && message.isNew && index == chatController.messages.length - 1) {
                      final chatController = context.read<ChatController>();
                      chatController.clearTyping();
                    }
                    // Scroll automático cuando termina la animación
                    _scrollToBottom();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 48,
              color: Colors.purple[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analiza tus finanzas con IA',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haz preguntas sobre tus deudas, obtén recomendaciones\npersonalizadas y analiza tu situación financiera',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Analizar mis deudas'),
              _buildSuggestionChip('Calcular riesgo financiero'),
              _buildSuggestionChip('Estrategia de pago'),
              _buildSuggestionChip('Recomendaciones personalizadas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _sendSuggestedMessage(text),
      backgroundColor: Colors.purple[50],
      side: BorderSide(color: Colors.purple[200]!),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, ChatController chatController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.purple[600],
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  AnimatedTypingDots(
                    color: Colors.purple[400],
                    size: 6,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chatController.currentTypingMessage ?? 'La IA está escribiendo...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método removido, ahora se usa AnimatedTypingDots widget

  Widget _buildMessageInput(BuildContext context, ChatController chatController, DebtController debtController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                  if (HardwareKeyboard.instance.isShiftPressed) {
                    // Shift+Enter: permite nueva línea (comportamiento por defecto)
                    return KeyEventResult.ignored;
                  } else {
                    // Solo Enter: enviar mensaje
                    if (!chatController.isLoading && !chatController.isTyping) {
                      _sendMessage();
                    }
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _messageController,
                enabled: !chatController.isLoading && !chatController.isTyping,
                decoration: InputDecoration(
                  hintText: (chatController.isLoading || chatController.isTyping)
                    ? 'Generando respuesta...' 
                    : 'Escribe tu pregunta sobre finanzas (Enter para enviar, Shift+Enter para nueva línea)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.purple[600]!),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: (chatController.isLoading || chatController.isTyping) ? Colors.red[600] : Colors.purple[600],
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: (chatController.isLoading || chatController.isTyping) ? _cancelMessage : _sendMessage,
              icon: (chatController.isLoading || chatController.isTyping)
                ? const Icon(Icons.stop, color: Colors.white)
                : const Icon(Icons.send, color: Colors.white),
              tooltip: (chatController.isLoading || chatController.isTyping) ? 'Cancelar respuesta' : 'Enviar mensaje',
            ),
          ),
        ],
      ),
    );
  }

  // AI Analysis Methods
  Future<void> _performGeneralAnalysis(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) async {
    try {
      await chatController.analyzeDebtsGeneral();
      _showSuccessMessage(context, 'Análisis general completado exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error realizando análisis general: $e');
    }
  }

  Future<void> _performRiskAnalysis(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) async {
    try {
      await chatController.analyzeDebtsRisk();
      _showSuccessMessage(context, 'Análisis de riesgo completado exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error realizando análisis de riesgo: $e');
    }
  }

  Future<void> _generatePaymentStrategy(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) async {
    try {
      await chatController.generatePaymentStrategy(
        userId: 'dummy_user_id',
        availableBudget: 100000.0, // Presupuesto dummy
      );
      _showSuccessMessage(context, 'Estrategia de pago generada exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error generando estrategia de pago: $e');
    }
  }

  // Excel Methods
  Future<void> _exportToExcel(BuildContext context, ExcelController excelController) async {
    try {
      await excelController.exportAllData();
      _showSuccessMessage(context, 'Exportación a Excel completada exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error exportando a Excel: $e');
    }
  }

  Future<void> _downloadTemplate(BuildContext context, ExcelController excelController) async {
    try {
      await excelController.downloadTemplateFromAssets();
      _showSuccessMessage(context, 'Plantilla descargada exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error descargando plantilla: $e');
    }
  }

  Future<void> _importFromExcel(
    BuildContext context,
    ExcelController excelController,
    dynamic file,
  ) async {
    try {
      await excelController.importFromExcel(file);
      _showSuccessMessage(context, 'Importación desde Excel completada exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error importando desde Excel: $e');
    }
  }

  Future<void> _retryExcelOperation(BuildContext context, ExcelController excelController) async {
    excelController.clearMessages();
    _showInfoMessage(context, 'Operación reiniciada. Intenta nuevamente.');
  }

  Future<void> _proceedWithValidData(BuildContext context, ExcelController excelController) async {
    try {
      await excelController.processValidatedData();
      _showSuccessMessage(context, 'Datos procesados exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error procesando datos validados: $e');
    }
  }


  void _showAIReportDetails(BuildContext context, ChatController chatController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple),
            SizedBox(width: 8),
            Text('Detalles del Análisis IA'),
          ],
        ),
        content: SingleChildScrollView(
          child: DebtAnalysisResultsWidget(
            analysis: chatController.lastDebtAnalysis!,
            onViewDetails: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }



  void _showFullAnalysisDetails(BuildContext context, ChatController chatController) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Análisis Detallado'),
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: DebtAnalysisResultsWidget(
              analysis: chatController.lastDebtAnalysis!,
            ),
          ),
        ),
      ),
    );
  }

  // Chat Helper Methods
  void _startNewConversation(ChatController chatController) {
    chatController.startNewConversation();
    chatController.clearMessages();
    _messageController.clear();
  }

  void _loadConversation(ChatController chatController, dynamic historyItem) {
    // Debug: Verificar qué conversación se está cargando
    print('🔍 DEBUG: Cargando conversación desde lista');
    print('   - Title mostrado: "${historyItem.prompt}"');
    print('   - Conversation ID: ${historyItem.conversationId}');
    print('   - Fecha: ${historyItem.date}');
    
    // Cargar la conversación específica
    chatController.loadConversation(historyItem.conversationId);
  }

  void _deleteConversation(ChatController chatController, String conversationId) async {
    // Mostrar confirmación antes de eliminar
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar conversación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta conversación? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await chatController.deleteConversation(conversationId);
        if (mounted) {
          _showSuccessMessage(context, 'Conversación eliminada correctamente');
        }
      } catch (e) {
        if (mounted) {
          _showErrorMessage(context, 'Error al eliminar conversación: $e');
        }
      }
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatController = context.read<ChatController>();
    _messageController.clear();
    
    try {
      await chatController.sendMessageWithTypewriter(message);
    } catch (e) {
      _showErrorMessage(context, 'Error enviando mensaje: $e');
    }
  }

  void _cancelMessage() {
    final chatController = context.read<ChatController>();
    chatController.cancelCurrentResponse();
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendSuggestedMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  // Método ya no necesario, se usa chatController.messages.length

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper Methods

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}