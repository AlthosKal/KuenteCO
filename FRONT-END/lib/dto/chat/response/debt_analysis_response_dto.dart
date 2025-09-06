import 'base_dynamic_response_dto.dart';

/// DTO para la respuesta de anÃ¡lisis AI de deudas desde KuentecoChat
class DebtAnalysisResponseDTO extends BaseDynamicResponseDTO {
  final DebtRiskAnalysisDTO? debtAnalysis;
  final List<String> recommendations;

  DebtAnalysisResponseDTO({
    required String summary,
    required String analysis,
    this.debtAnalysis,
    required this.recommendations,
  }) : super(type: 'DEBT_ANALYSIS', summary: summary, analysis: analysis);

  factory DebtAnalysisResponseDTO.fromJson(Map<String, dynamic> json) {
    return DebtAnalysisResponseDTO(
      summary: json['summary'] ?? '',
      analysis: json['analysis'] ?? '',
      debtAnalysis: json['debtAnalysis'] != null 
          ? DebtRiskAnalysisDTO.fromJson(json['debtAnalysis'])
          : null,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      if (debtAnalysis != null) 'debtAnalysis': debtAnalysis!.toJson(),
      'recommendations': recommendations,
    };
  }
}

/// DTO para anÃ¡lisis de riesgo de deudas
class DebtRiskAnalysisDTO {
  final double totalDebt;
  final double monthlyDebtPayment;
  final String debtToIncomeRatio;
  final String riskLevel;
  final List<String> actionPlan;

  DebtRiskAnalysisDTO({
    required this.totalDebt,
    required this.monthlyDebtPayment,
    required this.debtToIncomeRatio,
    required this.riskLevel,
    required this.actionPlan,
  });

  factory DebtRiskAnalysisDTO.fromJson(Map<String, dynamic> json) {
    return DebtRiskAnalysisDTO(
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      monthlyDebtPayment: (json['monthlyDebtPayment'] as num?)?.toDouble() ?? 0.0,
      debtToIncomeRatio: json['debtToIncomeRatio'] ?? '0%',
      riskLevel: json['riskLevel'] ?? 'BAJO',
      actionPlan: List<String>.from(json['actionPlan'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDebt': totalDebt,
      'monthlyDebtPayment': monthlyDebtPayment,
      'debtToIncomeRatio': debtToIncomeRatio,
      'riskLevel': riskLevel,
      'actionPlan': actionPlan,
    };
  }

  /// Getter para obtener el color basado en el nivel de riesgo
  String get riskColorCode {
    switch (riskLevel.toUpperCase()) {
      case 'BAJO':
        return '#4CAF50'; // Verde
      case 'MEDIO':
        return '#FF9800'; // Naranja
      case 'ALTO':
        return '#F44336'; // Rojo
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Getter para obtener recomendaciÃ³n principal
  String get primaryRecommendation {
    return actionPlan.isNotEmpty ? actionPlan.first : 'Sin recomendaciones disponibles';
  }
}