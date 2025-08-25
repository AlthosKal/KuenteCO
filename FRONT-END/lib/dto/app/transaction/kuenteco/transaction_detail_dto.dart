import '../../extra/description_transaction_extra.dart';

class TransactionDetailDTO {
  final int id;
  final int? categoryId;
  final int? budgetId;
  final String name;
  final double amount;
  final DateTime? timestamp;
  final DescriptionTransaction? descriptionExtra;
  final String? description; // String description for simple text
  final String date; // ISO 8601 string for easier formatting

  TransactionDetailDTO({
    required this.id,
    this.categoryId,
    this.budgetId,
    required this.name,
    required this.amount,
    this.timestamp,
    this.descriptionExtra,
    this.description,
    required this.date,
  });

  factory TransactionDetailDTO.fromJson(Map<String, dynamic> json) {
    final timestampValue = json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now();
    
    return TransactionDetailDTO(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      name: json['name'] ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      timestamp: timestampValue,
      descriptionExtra: json['descriptionExtra'] != null 
          ? DescriptionTransaction.fromJson(json['descriptionExtra']) 
          : null,
      description: json['description']?.toString(),
      date: json['date'] ?? timestampValue.toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'name': name,
      'amount': amount,
      'timestamp': timestamp?.toIso8601String(),
      'descriptionExtra': descriptionExtra?.toJson(),
      'description': description,
      'date': date,
    };
  }
}
