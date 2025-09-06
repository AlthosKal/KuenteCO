/// DTO para anÃ¡lisis de salud financiera relacionada con deudas
class DebtFinancialHealthDTO {
  final double healthScore;
  final String healthLevel;
  final String assessment;
  final List<String> strengths;
  final List<String> concerns;
  final List<FinancialRecommendationDTO> recommendations;
  final DebtHealthMetricsDTO metrics;

  DebtFinancialHealthDTO({
    required this.healthScore,
    required this.healthLevel,
    required this.assessment,
    required this.strengths,
    required this.concerns,
    required this.recommendations,
    required this.metrics,
  });

  factory DebtFinancialHealthDTO.fromJson(Map<String, dynamic> json) {
    return DebtFinancialHealthDTO(
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 0.0,
      healthLevel: json['healthLevel'] ?? 'UNKNOWN',
      assessment: json['assessment'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
      recommendations: (json['recommendations'] as List?)
          ?.map((r) => FinancialRecommendationDTO.fromJson(r))
          .toList() ?? [],
      metrics: DebtHealthMetricsDTO.fromJson(json['metrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthScore': healthScore,
      'healthLevel': healthLevel,
      'assessment': assessment,
      'strengths': strengths,
      'concerns': concerns,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'metrics': metrics.toJson(),
    };
  }

  /// Color del indicador basado en el score
  String get healthColorCode {
    if (healthScore >= 80) return '#4CAF50'; // Verde - Excelente
    if (healthScore >= 60) return '#8BC34A'; // Verde claro - Bueno
    if (healthScore >= 40) return '#FF9800'; // Naranja - Regular
    if (healthScore >= 20) return '#FF5722'; // Rojo naranja - Malo
    return '#F44336'; // Rojo - CrÃ­tico
  }

  /// Icono sugerido basado en el nivel
  String get healthIcon {
    switch (healthLevel.toUpperCase()) {
      case 'EXCELLENT':
        return 'trending_up';
      case 'GOOD':
        return 'thumb_up';
      case 'FAIR':
        return 'warning';
      case 'POOR':
        return 'trending_down';
      case 'CRITICAL':
        return 'error';
      default:
        return 'help';
    }
  }
}

/// DTO para mÃ©tricas especÃ­ficas de salud de deudas
class DebtHealthMetricsDTO {
  final double debtToIncomeRatio;
  final double debtUtilizationRatio;
  final int activeDebtsCount;
  final double averageDebtAge;
  final double totalMonthlyPayments;
  final double projectedPayoffTime;

  DebtHealthMetricsDTO({
    required this.debtToIncomeRatio,
    required this.debtUtilizationRatio,
    required this.activeDebtsCount,
    required this.averageDebtAge,
    required this.totalMonthlyPayments,
    required this.projectedPayoffTime,
  });

  factory DebtHealthMetricsDTO.fromJson(Map<String, dynamic> json) {
    return DebtHealthMetricsDTO(
      debtToIncomeRatio: (json['debtToIncomeRatio'] as num?)?.toDouble() ?? 0.0,
      debtUtilizationRatio: (json['debtUtilizationRatio'] as num?)?.toDouble() ?? 0.0,
      activeDebtsCount: (json['activeDebtsCount'] as num?)?.toInt() ?? 0,
      averageDebtAge: (json['averageDebtAge'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyPayments: (json['totalMonthlyPayments'] as num?)?.toDouble() ?? 0.0,
      projectedPayoffTime: (json['projectedPayoffTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debtToIncomeRatio': debtToIncomeRatio,
      'debtUtilizationRatio': debtUtilizationRatio,
      'activeDebtsCount': activeDebtsCount,
      'averageDebtAge': averageDebtAge,
      'totalMonthlyPayments': totalMonthlyPayments,
      'projectedPayoffTime': projectedPayoffTime,
    };
  }
}

/// DTO para recomendaciones financieras especÃ­ficas
class FinancialRecommendationDTO {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String category;
  final double? potentialSavings;
  final int? timeframeMonths;

  FinancialRecommendationDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    this.potentialSavings,
    this.timeframeMonths,
  });

  factory FinancialRecommendationDTO.fromJson(Map<String, dynamic> json) {
    return FinancialRecommendationDTO(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'MEDIUM',
      category: json['category'] ?? 'GENERAL',
      potentialSavings: (json['potentialSavings'] as num?)?.toDouble(),
      timeframeMonths: (json['timeframeMonths'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      if (potentialSavings != null) 'potentialSavings': potentialSavings,
      if (timeframeMonths != null) 'timeframeMonths': timeframeMonths,
    };
  }
}