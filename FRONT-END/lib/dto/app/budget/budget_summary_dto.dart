import 'package:decimal/decimal.dart';

class BudgetSummaryDTO {
  final String userId;
  final String ownerUserId;
  final String username;
  final int totalBudgets;
  final Decimal totalBudgetAmount;
  final Decimal totalRemainingAmount;
  final Decimal totalSpentAmount;
  final Decimal overallPercentageUsed;

  BudgetSummaryDTO({
    required this.userId,
    required this.ownerUserId,
    required this.username,
    required this.totalBudgets,
    required this.totalBudgetAmount,
    required this.totalRemainingAmount,
    required this.totalSpentAmount,
    required this.overallPercentageUsed,
  });

  factory BudgetSummaryDTO.fromJson(Map<String, dynamic> json) {
    return BudgetSummaryDTO(
      userId: json['userId'],
      ownerUserId: json['ownerUserId'],
      username: json['username'],
      totalBudgets: json['totalBudgets'],
      totalBudgetAmount: Decimal.parse(json['totalBudgetAmount'].toString()),
      totalRemainingAmount: Decimal.parse(json['totalRemainingAmount'].toString()),
      totalSpentAmount: Decimal.parse(json['totalSpentAmount'].toString()),
      overallPercentageUsed: Decimal.parse(json['overallPercentageUsed'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ownerUserId': ownerUserId,
      'username': username,
      'totalBudgets': totalBudgets,
      'totalBudgetAmount': totalBudgetAmount.toString(),
      'totalRemainingAmount': totalRemainingAmount.toString(),
      'totalSpentAmount': totalSpentAmount.toString(),
      'overallPercentageUsed': overallPercentageUsed.toString(),
    };
  }
}
