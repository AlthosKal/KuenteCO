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
    
    DescriptionTransaction? descriptionExtra;
    
    // First try to get it from descriptionExtra field
    if (json['descriptionExtra'] != null) {
      descriptionExtra = DescriptionTransaction.fromJson(json['descriptionExtra']);
    } 
    // If not found, try to get it from description field (which sometimes contains the DescriptionTransaction object)
    else if (json['description'] != null && json['description'] is Map<String, dynamic>) {
      try {
        descriptionExtra = DescriptionTransaction.fromJson(json['description'] as Map<String, dynamic>);
      } catch (e) {
        // If parsing fails, descriptionExtra remains null
      }
    }
    
    return TransactionDetailDTO(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'],
      budgetId: json['budgetId'],
      name: json['name'] ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      timestamp: timestampValue,
      descriptionExtra: descriptionExtra,
      description: _parseDescription(json['description']),
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

  static String? _parseDescription(dynamic descriptionJson) {
    if (descriptionJson == null) return null;
    
    // Si es un string, devolverlo directamente
    if (descriptionJson is String) {
      return descriptionJson;
    }
    
    // Si es un Map (objeto DescriptionTransaction), extraer el campo description
    if (descriptionJson is Map<String, dynamic>) {
      return descriptionJson['description']?.toString();
    }
    
    // Fallback: convertir a string
    return descriptionJson.toString();
  }
}
