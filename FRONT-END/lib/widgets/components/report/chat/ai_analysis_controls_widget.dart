import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/chat_controller.dart';

class AIAnalysisControlsWidget extends StatelessWidget {
  final VoidCallback? onAnalyzeGeneral;
  final VoidCallback? onAnalyzeRisk;
  final VoidCallback? onGenerateStrategy;

  const AIAnalysisControlsWidget({
    Key? key,
    this.onAnalyzeGeneral,
    this.onAnalyzeRisk,
    this.onGenerateStrategy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        final isLoading = chatController.isAnalyzingDebts;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Colors.blue[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AnÃ¡lisis Inteligente de Deudas',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Utiliza IA para obtener insights sobre tus deudas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // AnÃ¡lisis General y de Riesgo
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalysisButton(
                        context: context,
                        icon: Icons.analytics,
                        label: 'AnÃ¡lisis\nGeneral',
                        color: Colors.blue,
                        onPressed: isLoading ? null : onAnalyzeGeneral,
                        description: 'EvaluaciÃ³n completa de todas tus deudas',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAnalysisButton(
                        context: context,
                        icon: Icons.warning_amber,
                        label: 'AnÃ¡lisis de\nRiesgo',
                        color: Colors.orange,
                        onPressed: isLoading ? null : onAnalyzeRisk,
                        description: 'EvalÃºa el riesgo financiero de tus deudas',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Estrategia de Pago
                SizedBox(
                  width: double.infinity,
                  child: _buildAnalysisButton(
                    context: context,
                    icon: Icons.psychology,
                    label: 'Generar Estrategia de Pago',
                    color: Colors.green,
                    onPressed: isLoading ? null : onGenerateStrategy,
                    description: 'Plan personalizado para saldar tus deudas',
                    isFullWidth: true,
                  ),
                ),
                
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  _buildLoadingIndicator(chatController),
                ],
                
                if (chatController.lastDebtAnalysisType != null) ...[
                  const SizedBox(height: 16),
                  _buildLastAnalysisInfo(context, chatController),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required String description,
    bool isFullWidth = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isFullWidth 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
    );
  }

  Widget _buildLoadingIndicator(ChatController chatController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analizando tus deudas...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                Text(
                  'La IA estÃ¡ procesando tu informaciÃ³n financiera',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastAnalysisInfo(BuildContext context, ChatController chatController) {
    String analysisTypeText = '';
    IconData analysisIcon = Icons.info;
    Color analysisColor = Colors.blue;
    
    switch (chatController.lastDebtAnalysisType) {
      case 'GENERAL_ANALYSIS':
        analysisTypeText = 'AnÃ¡lisis General';
        analysisIcon = Icons.analytics;
        analysisColor = Colors.blue;
        break;
      case 'RISK_ANALYSIS':
        analysisTypeText = 'AnÃ¡lisis de Riesgo';
        analysisIcon = Icons.warning_amber;
        analysisColor = Colors.orange;
        break;
      case 'PAYMENT_STRATEGY':
        analysisTypeText = 'Estrategia de Pago';
        analysisIcon = Icons.psychology;
        analysisColor = Colors.green;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: analysisColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: analysisColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(analysisIcon, color: analysisColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ãltimo anÃ¡lisis realizado: $analysisTypeText',
              style: TextStyle(
                fontSize: 12,
                color: analysisColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (chatController.hasRiskAnalysis && chatController.currentRiskLevel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRiskColor(chatController.currentRiskLevel!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Riesgo: ${chatController.currentRiskLevel}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'BAJO':
        return Colors.green;
      case 'MEDIO':
        return Colors.orange;
      case 'ALTO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}