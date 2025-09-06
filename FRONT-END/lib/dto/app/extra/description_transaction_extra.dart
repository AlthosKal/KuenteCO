import '../../../utils/enum/transaction_type_enum.dart';

class DescriptionTransaction {
  final String description;
  final TransactionType type;

  DescriptionTransaction({
    required this.description,
    required this.type,
  });

  factory DescriptionTransaction.fromJson(Map<String, dynamic> json) {
    final typeString = json['type']?.toString();
    final parsedType = TransactionType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => TransactionType.EXPENSE, // o cualquier valor por defecto
    );
    
    return DescriptionTransaction(
      description: json['description'],
      type: parsedType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'type': type.name,
    };
  }

  @override
  String toString() {
    return description; // Solo devolver el texto de la descripciÃ³n, no toda la estructura
  }
}
