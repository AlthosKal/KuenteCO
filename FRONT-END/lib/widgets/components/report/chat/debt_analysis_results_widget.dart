import 'package:flutter/material.dart';
import '../../../../dto/chat/response/debt_analysis_response_dto.dart';

class DebtAnalysisResultsWidget extends StatelessWidget {
  final DebtAnalysisResponseDTO analysis;
  final VoidCallback? onViewDetails;

  const DebtAnalysisResultsWidget({
    Key? key,
    required this.analysis,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            
            if (analysis.summary != null && analysis.summary!.isNotEmpty) 
              _buildSummarySection(context),
            
            if (analysis.debtAnalysis != null) 
              _buildRiskAnalysisSection(context),
            
            if (analysis.recommendations.isNotEmpty) 
              _buildRecommendationsSection(context),
            
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insights,
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
                'Resultados del Análisis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Análisis generado por Inteligencia Artificial',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (analysis.debtAnalysis?.riskLevel != null)
          _buildRiskBadge(analysis.debtAnalysis!.riskLevel),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.summarize, color: Colors.blue[600], size: 18),
            const SizedBox(width: 8),
            Text(
              'Resumen Ejecutivo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Text(
            analysis.summary!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRiskAnalysisSection(BuildContext context) {
    final riskAnalysis = analysis.debtAnalysis!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[600], size: 18),
            const SizedBox(width: 8),
            Text(
              'Análisis de Riesgo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Métricas de riesgo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[100]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Deuda Total',
                      '\$${_formatCurrency(riskAnalysis.totalDebt)}',
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Pago Mensual',
                      '\$${_formatCurrency(riskAnalysis.monthlyDebtPayment)}',
                      Icons.payment,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Ratio Deuda/Ingreso',
                      riskAnalysis.debtToIncomeRatio,
                      Icons.percent,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Nivel de Riesgo',
                      riskAnalysis.riskLevel,
                      Icons.trending_up,
                      _getRiskColor(riskAnalysis.riskLevel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.green[600], size: 18),
            const SizedBox(width: 8),
            Text(
              'Recomendaciones (${analysis.recommendations.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[100]!),
          ),
          child: Column(
            children: analysis.recommendations
                .asMap()
                .entries
                .map((entry) => _buildRecommendationItem(
                      entry.key + 1, 
                      entry.value,
                      context,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(int index, String recommendation, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String riskLevel) {
    final color = _getRiskColor(riskLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRiskIcon(riskLevel),
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Riesgo $riskLevel',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareAnalysis(context),
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Compartir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[300]!),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Ver Detalles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
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

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'BAJO':
        return Icons.trending_down;
      case 'MEDIO':
        return Icons.trending_flat;
      case 'ALTO':
        return Icons.trending_up;
      default:
        return Icons.help;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  void _shareAnalysis(BuildContext context) {
    // Implementar funcionalidad de compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente disponible'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}