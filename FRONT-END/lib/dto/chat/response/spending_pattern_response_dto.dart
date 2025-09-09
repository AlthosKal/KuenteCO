class SpendingPatternResponseDTO {
  final List<String> categoriesWithHighestSpending;
  final double monthlyAverageIncome;
  final double monthlyAverageSpending;
  final List<String> spendingTrends;

  SpendingPatternResponseDTO({
    required this.categoriesWithHighestSpending,
    required this.monthlyAverageIncome,
    required this.monthlyAverageSpending,
    required this.spendingTrends,
  });

  factory SpendingPatternResponseDTO.fromJson(Map<String, dynamic> json) {
    return SpendingPatternResponseDTO(
      categoriesWithHighestSpending: List<String>.from(json['categoriesWithHighestSpending'] as List),
      monthlyAverageIncome: (json['monthlyAverageIncome'] as num).toDouble(),
      monthlyAverageSpending: (json['monthlyAverageSpending'] as num).toDouble(),
      spendingTrends: List<String>.from(json['spendingTrends'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoriesWithHighestSpending': categoriesWithHighestSpending,
      'monthlyAverageIncome': monthlyAverageIncome,
      'monthlyAverageSpending': monthlyAverageSpending,
      'spendingTrends': spendingTrends,
    };
  }
}