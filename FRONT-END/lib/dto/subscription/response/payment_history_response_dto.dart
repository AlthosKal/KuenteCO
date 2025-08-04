enum PaymentStatus {
  APPROVED,
  PENDING,
  REJECTED,
  CANCELLED,
}

class PaymentHistoryResponseDTO {
  final String paymentId;
  final double amount;
  final String currencyId;
  final PaymentStatus status;
  final String statusDetail;
  final String paymentMethodId;
  final DateTime dateCreated;
  final DateTime? dateApproved;
  final String description;

  PaymentHistoryResponseDTO({
    required this.paymentId,
    required this.amount,
    required this.currencyId,
    required this.status,
    required this.statusDetail,
    required this.paymentMethodId,
    required this.dateCreated,
    this.dateApproved,
    required this.description,
  });

  factory PaymentHistoryResponseDTO.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryResponseDTO(
      paymentId: json['paymentId'],
      amount: (json['amount'] as num).toDouble(),
      currencyId: json['currencyId'],
      status: PaymentStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => PaymentStatus.PENDING, // fallback
      ),
      statusDetail: json['statusDetail'],
      paymentMethodId: json['paymentMethodId'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateApproved: json['dateApproved'] != null
          ? DateTime.parse(json['dateApproved'])
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'amount': amount,
      'currencyId': currencyId,
      'status': status.name,
      'statusDetail': statusDetail,
      'paymentMethodId': paymentMethodId,
      'dateCreated': dateCreated.toIso8601String(),
      'dateApproved': dateApproved?.toIso8601String(),
      'description': description,
    };
  }
}
