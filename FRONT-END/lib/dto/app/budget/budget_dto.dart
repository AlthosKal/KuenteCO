import 'package:decimal/decimal.dart';

class BudgetDTO {
  final int id;
  final String name;
  final Decimal totalBudget;
  final Decimal remainingBudget;
  final String status;
  final DateTime? creationDate;

  BudgetDTO({
    required this.id,
    required this.name,
    required this.totalBudget,
    required this.remainingBudget,
    required this.status,
    this.creationDate,
  });

  // Getter for backward compatibility
  Decimal get totalAmount => totalBudget;

  factory BudgetDTO.fromJson(Map<String, dynamic> json) {
    return BudgetDTO(
      id: json['id'] ?? 0, // Manejar id nulo
      name: json['name'] ?? '',
      totalBudget: json['totalBudget'] != null 
          ? Decimal.parse(json['totalBudget'].toString())
          : Decimal.zero,
      remainingBudget: json['remainingBudget'] != null 
          ? Decimal.parse(json['remainingBudget'].toString())
          : Decimal.zero,
      status: json['status'] ?? 'ACTIVE',
      creationDate: json['creationDate'] != null 
          ? DateTime.parse(json['creationDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalBudget': totalBudget.toString(),
      'remainingBudget': remainingBudget.toString(),
      'status': status,
      'creationDate': creationDate?.toIso8601String(),
    };
  }
}
