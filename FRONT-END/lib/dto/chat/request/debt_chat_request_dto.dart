/// DTO para solicitar análisis de deudas al chat AI
class DebtChatRequestDTO {
  final String message;
  final String userId;
  final String? analysisType;
  final Map<String, dynamic>? context;
  final List<int>? debtIds;

  DebtChatRequestDTO({
    required this.message,
    required this.userId,
    this.analysisType,
    this.context,
    this.debtIds,
  });

  factory DebtChatRequestDTO.analyzeDebts({
    required String userId,
    List<int>? specificDebtIds,
    String? customMessage,
  }) {
    return DebtChatRequestDTO(
      message: customMessage ?? 'Analiza mis deudas y dame recomendaciones',
      userId: userId,
      analysisType: 'DEBT_ANALYSIS',
      debtIds: specificDebtIds,
      context: {
        'requestType': 'DEBT_ANALYSIS',
        'includeRiskAnalysis': true,
        'includeRecommendations': true,
      },
    );
  }

  factory DebtChatRequestDTO.riskAnalysis({
    required String userId,
    required double monthlyIncome,
    List<int>? debtIds,
  }) {
    return DebtChatRequestDTO(
      message: 'Realiza un análisis de riesgo de mis deudas',
      userId: userId,
      analysisType: 'RISK_ANALYSIS',
      debtIds: debtIds,
      context: {
        'requestType': 'RISK_ANALYSIS',
        'monthlyIncome': monthlyIncome,
        'includeDebtToIncomeRatio': true,
      },
    );
  }

  factory DebtChatRequestDTO.paymentStrategy({
    required String userId,
    required double availableBudget,
    List<int>? priorityDebtIds,
  }) {
    return DebtChatRequestDTO(
      message: 'Sugiere una estrategia de pago para mis deudas',
      userId: userId,
      analysisType: 'PAYMENT_STRATEGY',
      debtIds: priorityDebtIds,
      context: {
        'requestType': 'PAYMENT_STRATEGY',
        'availableBudget': availableBudget,
        'prioritizeHighInterest': true,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'userId': userId,
      if (analysisType != null) 'analysisType': analysisType,
      if (context != null) 'context': context,
      if (debtIds != null) 'debtIds': debtIds,
    };
  }
}