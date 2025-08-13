import 'package:decimal/decimal.dart';

class BudgetDTO {
  final int id;
  final String name;
  final Decimal totalBudget;
  final Decimal remainingBudget;

  BudgetDTO({
    required this.id,
    required this.name,
    required this.totalBudget,
    required this.remainingBudget,
  });

  factory BudgetDTO.fromJson(Map<String, dynamic> json) {
    return BudgetDTO(
      id: json['id'],
      name: json['name'],
      totalBudget: Decimal.parse(json['totalBudget'].toString()),
      remainingBudget: Decimal.parse(json['remainingBudget'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalBudget': totalBudget.toString(),
      'remainingBudget': remainingBudget.toString(),
    };
  }
}
