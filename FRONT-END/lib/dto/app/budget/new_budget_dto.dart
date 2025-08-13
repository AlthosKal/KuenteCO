import 'package:decimal/decimal.dart';

class NewBudgetDTO {
  final String name;
  final Decimal totalBudget;
  final Decimal remainingBudget;

  NewBudgetDTO({
    required this.name,
    required this.totalBudget,
    required this.remainingBudget,
  });

  factory NewBudgetDTO.fromJson(Map<String, dynamic> json) {
    return NewBudgetDTO(
      name: json['name'],
      totalBudget: Decimal.parse(json['totalBudget'].toString()),
      remainingBudget: Decimal.parse(json['remainingBudget'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalBudget': totalBudget.toString(),
      'remainingBudget': remainingBudget.toString(),
    };
  }
}
