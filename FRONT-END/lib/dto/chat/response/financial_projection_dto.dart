class FinancialProjectionDTO {
  final double projectedBalanceIn3Months;
  final bool riskOfDeficit;
  final String? monthWithNegativeBalance;
  final String recommendation;

  FinancialProjectionDTO({
    required this.projectedBalanceIn3Months,
    required this.riskOfDeficit,
    this.monthWithNegativeBalance,
    required this.recommendation,
  });

  factory FinancialProjectionDTO.fromJson(Map<String, dynamic> json) {
    return FinancialProjectionDTO(
      projectedBalanceIn3Months: (json['projectedBalanceIn3Months'] as num).toDouble(),
      riskOfDeficit: json['riskOfDeficit'] as bool,
      monthWithNegativeBalance: json['monthWithNegativeBalance'] as String?,
      recommendation: json['recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectedBalanceIn3Months': projectedBalanceIn3Months,
      'riskOfDeficit': riskOfDeficit,
      'monthWithNegativeBalance': monthWithNegativeBalance,
      'recommendation': recommendation,
    };
  }
}