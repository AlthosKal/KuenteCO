import 'package:decimal/decimal.dart';

class NewBudgetDTO {
  final String name;
  final double totalBudget;
  final double remainingBudget;

  NewBudgetDTO({
    required this.name,
    required this.totalBudget,
    required this.remainingBudget,
  });

  factory NewBudgetDTO.fromJson(Map<String, dynamic> json) {
    return NewBudgetDTO(
      name: json['name'],
      totalBudget: (json['totalBudget'] as num).toDouble(),
      remainingBudget: (json['remainingBudget'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalBudget': totalBudget,
      'remainingBudget': remainingBudget,
    };
  }
}
