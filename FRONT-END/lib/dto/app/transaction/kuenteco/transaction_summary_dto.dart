class TransactionSummaryDTO {
  final String? ownerUserId;
  final int? profileId;
  final int? transactionId;
  final String? transactionOwnerType;
  final String? transactionName;
  final String? categoryName;
  final String? budgetName;
  final String? debtName;
  final int? transactionCount;
  final int? incomeCount;
  final int? expenseCount;
  final double? totalIncome;
  final double? totalExpenses;
  final double? netAmount;
  final DateTime? firstTransactionDate;
  final DateTime? lastTransactionDate;

  TransactionSummaryDTO({
    this.ownerUserId,
    this.profileId,
    this.transactionId,
    this.transactionOwnerType,
    this.transactionName,
    this.categoryName,
    this.budgetName,
    this.debtName,
    this.transactionCount,
    this.incomeCount,
    this.expenseCount,
    this.totalIncome,
    this.totalExpenses,
    this.netAmount,
    this.firstTransactionDate,
    this.lastTransactionDate,
  });

  factory TransactionSummaryDTO.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryDTO(
      ownerUserId: json['ownerUserId'],
      profileId: json['profileId'],
      transactionId: json['transactionId'],
      transactionOwnerType: json['transactionOwnerType'],
      transactionName: json['transactionName'],
      categoryName: json['categoryName'],
      budgetName: json['budgetName'],
      debtName: json['debtName'],
      transactionCount: json['transactionCount'],
      incomeCount: json['incomeCount'],
      expenseCount: json['expenseCount'],
      totalIncome: (json['totalIncome'] as num?)?.toDouble(),
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble(),
      netAmount: (json['netAmount'] as num?)?.toDouble(),
      firstTransactionDate: json['firstTransactionDate'] != null 
          ? DateTime.parse(json['firstTransactionDate']) 
          : null,
      lastTransactionDate: json['lastTransactionDate'] != null 
          ? DateTime.parse(json['lastTransactionDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'profileId': profileId,
      'transactionId': transactionId,
      'transactionOwnerType': transactionOwnerType,
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
      'firstTransactionDate': firstTransactionDate?.toIso8601String(),
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }
}
