import 'package:decimal/decimal.dart';

class BudgetVsActualDTO {
  final int categoryId;
  final String categoryName;
  final int budgetId;
  final String budgetName;
  final Decimal assignedAmount;
  final Decimal remainingBudget;
  final int ownerUserId;
  final Decimal actualSpent;
  final Decimal calculatedRemaining;
  final Decimal percentageUsed;
  final String budgetStatus;

  BudgetVsActualDTO({
    required this.categoryId,
    required this.categoryName,
    required this.budgetId,
    required this.budgetName,
    required this.assignedAmount,
    required this.remainingBudget,
    required this.ownerUserId,
    required this.actualSpent,
    required this.calculatedRemaining,
    required this.percentageUsed,
    required this.budgetStatus,
  });

  factory BudgetVsActualDTO.fromJson(Map<String, dynamic> json) {
    return BudgetVsActualDTO(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      budgetId: json['budgetId'],
      budgetName: json['budgetName'],
      assignedAmount: Decimal.parse(json['assignedAmount'].toString()),
      remainingBudget: Decimal.parse(json['remainingBudget'].toString()),
      ownerUserId: json['ownerUserId'],
      actualSpent: Decimal.parse(json['actualSpent'].toString()),
      calculatedRemaining: Decimal.parse(json['calculatedRemaining'].toString()),
      percentageUsed: Decimal.parse(json['percentageUsed'].toString()),
      budgetStatus: json['budgetStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'budgetId': budgetId,
      'budgetName': budgetName,
      'assignedAmount': assignedAmount.toString(),
      'remainingBudget': remainingBudget.toString(),
      'ownerUserId': ownerUserId,
      'actualSpent': actualSpent.toString(),
      'calculatedRemaining': calculatedRemaining.toString(),
      'percentageUsed': percentageUsed.toString(),
      'budgetStatus': budgetStatus,
    };
  }
}
