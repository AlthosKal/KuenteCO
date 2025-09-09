class FinancialHealthScoreDTO {
  final int score; // 0-100
  final String grade;
  final List<String> suggestions;

  FinancialHealthScoreDTO({
    required this.score,
    required this.grade,
    required this.suggestions,
  });

  factory FinancialHealthScoreDTO.fromJson(Map<String, dynamic> json) {
    return FinancialHealthScoreDTO(
      score: json['score'] as int,
      grade: json['grade'] as String,
      suggestions: List<String>.from(json['suggestions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'grade': grade,
      'suggestions': suggestions,
    };
  }
}