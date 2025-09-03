import 'package:decimal/decimal.dart';
import '../../../utils/enum/state_debt_enum.dart';

class NewDebtDTO {
  final int transactionId;
  final String name;
  final Decimal totalAmount;
  final Decimal pendingAmount;
  final DateTime startDate;
  final DateTime expirationDate;
  final StateDebt? state;

  NewDebtDTO({
    required this.transactionId,
    required this.name,
    required this.totalAmount,
    required this.pendingAmount,
    required this.startDate,
    required this.expirationDate,
    this.state,
  });

  factory NewDebtDTO.fromJson(Map<String, dynamic> json) {
    return NewDebtDTO(
      transactionId: json['transactionId'],
      name: json['name'],
      totalAmount: Decimal.parse(json['totalAmount'].toString()),
      pendingAmount: Decimal.parse(json['pendingAmount'].toString()),
      startDate: DateTime.parse(json['startDate']),
      expirationDate: DateTime.parse(json['expirationDate']),
      state: json['state'] != null ? StateDebt.fromString(json['state']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'name': name,
      'totalAmount': totalAmount.toString(),
      'pendingAmount': pendingAmount.toString(),
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      if (state != null) 'state': state!.toJson(),
    };
  }
}
