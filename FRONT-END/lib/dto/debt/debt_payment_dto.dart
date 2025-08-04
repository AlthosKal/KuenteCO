import 'package:decimal/decimal.dart';

class DebtPaymentDTO {
  final int debtId;
  final Decimal paymentAmount;
  final String? description;
  final DateTime? paymentDate;

  DebtPaymentDTO({
    required this.debtId,
    required this.paymentAmount,
    this.description,
    this.paymentDate,
  });

  factory DebtPaymentDTO.fromJson(Map<String, dynamic> json) {
    return DebtPaymentDTO(
      debtId: json['debtId'],
      paymentAmount: Decimal.parse(json['paymentAmount'].toString()),
      description: json['description'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debtId': debtId,
      'paymentAmount': paymentAmount.toString(),
      'description': description,
      'paymentDate': paymentDate?.toIso8601String(),
    };
  }
}
