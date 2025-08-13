class TransactionSummaryDTO {
  final String ownerUserId;
  final String transactionOwnerType;
  final int profileId;
  final String transactionName;
  final String categoryName;
  final String budgetName;
  final String debtName;
  final int transactionCount;
  final int incomeCount;
  final int expenseCount;
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final DateTime firstTransactionDate;
  final DateTime lastTransactionDate;

  TransactionSummaryDTO({
    required this.ownerUserId,
    required this.transactionOwnerType,
    required this.profileId,
    required this.transactionName,
    required this.categoryName,
    required this.budgetName,
    required this.debtName,
    required this.transactionCount,
    required this.incomeCount,
    required this.expenseCount,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.firstTransactionDate,
    required this.lastTransactionDate,
  });

  factory TransactionSummaryDTO.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryDTO(
      ownerUserId: json['ownerUserId'],
      transactionOwnerType: json['transactionOwnerType'],
      profileId: json['profileId'],
      transactionName: json['transactionName'],
      categoryName: json['categoryName'],
      budgetName: json['budgetName'],
      debtName: json['debtName'],
      transactionCount: json['transactionCount'],
      incomeCount: json['incomeCount'],
      expenseCount: json['expenseCount'],
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      firstTransactionDate: DateTime.parse(json['firstTransactionDate']),
      lastTransactionDate: DateTime.parse(json['lastTransactionDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'transactionOwnerType': transactionOwnerType,
      'profileId': profileId,
      'transactionName': transactionName,
      'categoryName': categoryName,
      'budgetName': budgetName,
      'debtName': debtName,
      'transactionCount': transactionCount,
      'incomeCount': incomeCount,
      'expenseCount': expenseCount,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netAmount': netAmount,
      'firstTransactionDate': firstTransactionDate.toIso8601String(),
      'lastTransactionDate': lastTransactionDate.toIso8601String(),
    };
  }
}
