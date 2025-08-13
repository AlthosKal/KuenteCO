import '../../extra/description_transaction_extra.dart';

class NewTransactionDTO {
  final int? categoryId;
  final int? budgetId;
  final int? debtId;
  final String? name;
  final DescriptionTransaction description;
  final double amount;

  NewTransactionDTO({
    this.categoryId,
    this.budgetId,
    this.debtId,
    this.name,
    required this.description,
    required this.amount,
  });

  factory NewTransactionDTO.fromJson(Map<String, dynamic> json) {
    return NewTransactionDTO(
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      debtId: json['debtId'],
      name: json['name'],
      description: DescriptionTransaction.fromJson(json['description']),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'budgetId': budgetId,
      'debtId': debtId,
      'name': name,
      'description': description.toJson(),
      'amount': amount,
    };
  }
}
