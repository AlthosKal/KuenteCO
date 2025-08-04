class TransactionsByCategoryDTO {
  final int categoryId;
  final String categoryName;
  final String ownerUserId;
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final int transactionCount;
  final int incomeCount;
  final int expenseCount;

  TransactionsByCategoryDTO({
    required this.categoryId,
    required this.categoryName,
    required this.ownerUserId,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.transactionCount,
    required this.incomeCount,
    required this.expenseCount,
  });

  factory TransactionsByCategoryDTO.fromJson(Map<String, dynamic> json) {
    return TransactionsByCategoryDTO(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      ownerUserId: json['ownerUserId'],
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] ?? 0,
      incomeCount: json['incomeCount'] ?? 0,
      expenseCount: json['expenseCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'ownerUserId': ownerUserId,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netAmount': netAmount,
      'transactionCount': transactionCount,
      'incomeCount': incomeCount,
      'expenseCount': expenseCount,
    };
  }
}
