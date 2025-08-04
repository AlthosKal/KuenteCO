import 'package:decimal/decimal.dart';

enum StateDebt {
  PENDING,
  PAID,
  OVERDUE;

  static StateDebt fromString(String value) {
    return StateDebt.values.firstWhere((e) => e.name == value.toUpperCase());
  }

  String toJson() => name;
}

class DebtDTO {
  final int id;
  final String name;
  final Decimal totalAmount;
  final Decimal pendingAmount;
  final DateTime startDate;
  final DateTime expirationDate;
  final StateDebt state;

  DebtDTO({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.pendingAmount,
    required this.startDate,
    required this.expirationDate,
    required this.state,
  });

  factory DebtDTO.fromJson(Map<String, dynamic> json) {
    return DebtDTO(
      id: json['id'],
      name: json['name'],
      totalAmount: Decimal.parse(json['totalAmount'].toString()),
      pendingAmount: Decimal.parse(json['pendingAmount'].toString()),
      startDate: DateTime.parse(json['startDate']),
      expirationDate: DateTime.parse(json['expirationDate']),
      state: StateDebt.fromString(json['state']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount.toString(),
      'pendingAmount': pendingAmount.toString(),
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'state': state.toJson(),
    };
  }
}
