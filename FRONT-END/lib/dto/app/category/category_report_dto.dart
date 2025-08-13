import '../budget/budget_dto.dart';
import '../transaction/kuenteco/transaction_detail_dto.dart';
import 'category_dto.dart';

class CategoryReportDTO {
  final CategoryDTO? category;
  final BudgetDTO? budget;
  final double? totalSpent;
  final double? totalIncome;
  final double? categoryRemainingBudget;
  final int? transactionCount;
  final List<TransactionDetailDTO>? transactions;
  final DateTime? reportGeneratedAt;

  CategoryReportDTO({
    this.category,
    this.budget,
    this.totalSpent,
    this.totalIncome,
    this.categoryRemainingBudget,
    this.transactionCount,
    this.transactions,
    this.reportGeneratedAt,
  });

  factory CategoryReportDTO.fromJson(Map<String, dynamic> json) {
    return CategoryReportDTO(
      category: json['category'] != null
          ? CategoryDTO.fromJson(json['category'])
          : null,
      budget: json['budget'] != null
          ? BudgetDTO.fromJson(json['budget'])
          : null,
      totalSpent: (json['totalSpent'] as num?)?.toDouble(),
      totalIncome: (json['totalIncome'] as num?)?.toDouble(),
      categoryRemainingBudget:
      (json['categoryRemainingBudget'] as num?)?.toDouble(),
      transactionCount: json['transactionCount'],
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
          .map((e) => TransactionDetailDTO.fromJson(e))
          .toList()
          : null,
      reportGeneratedAt: json['reportGeneratedAt'] != null
          ? DateTime.parse(json['reportGeneratedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category?.toJson(),
      'budget': budget?.toJson(),
      'totalSpent': totalSpent,
      'totalIncome': totalIncome,
      'categoryRemainingBudget': categoryRemainingBudget,
      'transactionCount': transactionCount,
      'transactions': transactions?.map((e) => e.toJson()).toList(),
      'reportGeneratedAt': reportGeneratedAt?.toIso8601String(),
    };
  }
}
