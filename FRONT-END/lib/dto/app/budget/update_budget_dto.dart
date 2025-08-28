import 'package:decimal/decimal.dart';

class UpdateBudgetDTO {
  final int id;
  final String name;
  final double totalBudget;
  final double remainingBudget;

  UpdateBudgetDTO({
    required this.id,
    required this.name,
    required this.totalBudget,
    required this.remainingBudget,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalBudget': totalBudget,
      'remainingBudget': remainingBudget,
    };
  }

  factory UpdateBudgetDTO.fromBudgetDTO(
    int id,
    String name,
    Decimal totalBudget,
    Decimal remainingBudget,
  ) {
    return UpdateBudgetDTO(
      id: id,
      name: name,
      totalBudget: totalBudget.toDouble(),
      remainingBudget: remainingBudget.toDouble(),
    );
  }
}