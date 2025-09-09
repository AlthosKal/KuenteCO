class ExpenseReductionSuggestionDTO {
  final String category;
  final double current;
  final double suggested;
  final String recommendation;

  ExpenseReductionSuggestionDTO({
    required this.category,
    required this.current,
    required this.suggested,
    required this.recommendation,
  });

  factory ExpenseReductionSuggestionDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseReductionSuggestionDTO(
      category: json['category'] as String,
      current: (json['current'] as num).toDouble(),
      suggested: (json['suggested'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'current': current,
      'suggested': suggested,
      'recommendation': recommendation,
    };
  }
}