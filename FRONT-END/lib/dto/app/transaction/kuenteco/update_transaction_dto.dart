import '../../extra/description_transaction_extra.dart';

class UpdateTransactionDTO {
  final int id;
  final int? categoryId;
  final int? budgetId; // Requerido por el endpoint de actualizaciÃ³n del backend
  final int? debtId; // Opcional como en el backend
  final String name; // Requerido como en el backend
  final DescriptionTransaction description;
  final double amount;

  UpdateTransactionDTO({
    required this.id,
    this.categoryId, // Optional - can be null
    this.budgetId, // Optional - can be null  
    this.debtId, // Optional - can be null
    required this.name,
    required this.description,
    required this.amount,
  });

  factory UpdateTransactionDTO.fromJson(Map<String, dynamic> json) {
    return UpdateTransactionDTO(
      id: json['id'],
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
      'id': id,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'debtId': debtId,
      'name': name,
      'description': description.toJson(),
      'amount': amount,
    };
  }
}
