import '../../../utils/enum/transaction_type_enum.dart';
import '../../extra/description_transaction_extra.dart';

class TransactionDetailDTO {
  final int id;
  final int categoryId;
  final int budgetId;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final DescriptionTransaction description;

  TransactionDetailDTO({
    required this.id,
    required this.categoryId,
    required this.budgetId,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
  });

  factory TransactionDetailDTO.fromJson(Map<String, dynamic> json) {
    return TransactionDetailDTO(
      id: json['id'],
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      type: TransactionType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => TransactionType.INCOME, // valor por defecto
      ),
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      description: DescriptionTransaction.fromJson(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'type': type.name,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'description': description.toJson(),
    };
  }
}
