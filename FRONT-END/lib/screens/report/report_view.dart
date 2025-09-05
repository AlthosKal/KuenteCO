import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/excel_controller.dart';
import '../../controllers/business_logic/debt_controller.dart';
import '../../widgets/components/report/chat/ai_analysis_controls_widget.dart';
import '../../widgets/components/report/chat/debt_analysis_results_widget.dart';
import '../../widgets/components/report/excel/excel_controls_widget.dart';
import '../../widgets/components/report/excel/excel_validation_results_widget.dart';

class ReportView extends StatefulWidget {
  const ReportView({Key? key}) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _messageController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Centro de Reportes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology),
              text: 'An�lisis IA',
            ),
            Tab(
              icon: Icon(Icons.table_chart),
              text: 'Excel',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Consumer3<ChatController, ExcelController, DebtController>(
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
    );
  }


  Widget _buildAIAnalysisTab(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) {
    return Row(
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
              // Área de mensajes
              Expanded(
                child: _buildChatArea(context, chatController),
              ),
              // Input de mensaje
              _buildMessageInput(context, chatController, debtController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExcelTab(
    BuildContext context,
    ExcelController excelController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gesti�n de Archivos Excel',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exporta e importa datos financieros en formato Excel para an�lisis externos o respaldo de informaci�n.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          ExcelControlsWidget(
            onExport: () => _exportToExcel(context, excelController),
            onDownloadTemplate: () => _downloadTemplate(context, excelController),
            onImport: (file) => _importFromExcel(context, excelController, file),
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
              Icon(Icons.psychology, color: Colors.blue[600], size: 20),
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
              IconButton(
                onPressed: () => _startNewConversation(chatController),
                icon: const Icon(Icons.add, size: 18),
                tooltip: 'Nueva conversación',
              ),
            ],
          ),
        ),
        // Lista de conversaciones
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: chatController.chatHistory.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildConversationTile(
                  context: context,
                  title: 'Conversación actual',
                  subtitle: 'Análisis financiero',
                  isActive: true,
                  onTap: () {},
                );
              }
              final historyItem = chatController.chatHistory[index - 1];
              return _buildConversationTile(
                context: context,
                title: _truncateText(historyItem.prompt, 30),
                subtitle: _formatDate(historyItem.date),
                isActive: false,
                onTap: () => _loadConversation(chatController, historyItem),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: Colors.blue[200]!) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.blue[800] : Colors.grey[800],
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
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, ChatController chatController) {
    if (chatController.chatHistory.isEmpty && chatController.lastChatResponse == null) {
      return _buildEmptyChat(context);
    }

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _getChatMessageCount(chatController),
        itemBuilder: (context, index) {
          return _buildChatMessage(context, chatController, index);
        },
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
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 48,
              color: Colors.blue[600],
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
      backgroundColor: Colors.blue[50],
      side: BorderSide(color: Colors.blue[200]!),
    );
  }

  Widget _buildChatMessage(BuildContext context, ChatController chatController, int index) {
    // Por ahora mostrar mensajes básicos, se puede expandir después
    final isUser = index % 2 == 0;
    final message = isUser ? "Mensaje del usuario" : "Respuesta de la IA";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[600] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.grey[800],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

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
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta sobre finanzas...',
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
                  borderSide: BorderSide(color: Colors.blue[600]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: chatController.isLoading ? null : _sendMessage,
              icon: chatController.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
              tooltip: 'Enviar mensaje',
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
      _showSuccessMessage(context, 'An�lisis general completado exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error realizando an�lisis general: $e');
    }
  }

  Future<void> _performRiskAnalysis(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) async {
    try {
      await chatController.analyzeDebtsRisk();
      _showSuccessMessage(context, 'An�lisis de riesgo completado exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error realizando an�lisis de riesgo: $e');
    }
  }

  Future<void> _generatePaymentStrategy(
    BuildContext context,
    ChatController chatController,
    DebtController debtController,
  ) async {
    try {
      await chatController.generatePaymentStrategy(
        userId: "dummy_user_id",
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
      _showSuccessMessage(context, 'Exportaci�n a Excel completada exitosamente');
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
    File file,
  ) async {
    try {
      await excelController.importFromExcel(file);
      _showSuccessMessage(context, 'Importaci�n desde Excel completada exitosamente');
    } catch (e) {
      _showErrorMessage(context, 'Error importando desde Excel: $e');
    }
  }

  Future<void> _retryExcelOperation(BuildContext context, ExcelController excelController) async {
    excelController.clearMessages();
    _showInfoMessage(context, 'Operaci�n reiniciada. Intenta nuevamente.');
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
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text('Detalles del An�lisis IA'),
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

  void _showExcelDetails(BuildContext context, ExcelController excelController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.table_chart, color: Colors.green),
            SizedBox(width: 8),
            Text('Detalles de Excel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(excelController.downloadInfo),
            if (excelController.lastDownloadedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                'Archivo: ${excelController.lastDownloadedFile}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
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
            title: const Text('An�lisis Detallado'),
            backgroundColor: Colors.blue[600],
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
    chatController.clearCurrentConversation();
    _messageController.clear();
  }

  void _loadConversation(ChatController chatController, dynamic historyItem) {
    // Implementar carga de conversación específica
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatController = context.read<ChatController>();
    _messageController.clear();
    
    try {
      await chatController.sendMessage(message);
    } catch (e) {
      _showErrorMessage(context, 'Error enviando mensaje: $e');
    }
  }

  void _sendSuggestedMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  int _getChatMessageCount(ChatController chatController) {
    // Por ahora retornar 0, se puede implementar el conteo real después
    return 0;
  }

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
        duration: const Duration(seconds: 4),
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
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}