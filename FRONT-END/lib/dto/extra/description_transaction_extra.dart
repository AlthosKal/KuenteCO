import '../../utils/enum/transaction_type_enum.dart';

class DescriptionTransaction {
  final String description;
  final TransactionType type;

  DescriptionTransaction({
    required this.description,
    required this.type,
  });

  factory DescriptionTransaction.fromJson(Map<String, dynamic> json) {
    return DescriptionTransaction(
      description: json['description'],
      type: TransactionType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => TransactionType.EXPENSE, // o cualquier valor por defecto
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'type': type.name,
    };
  }
}
