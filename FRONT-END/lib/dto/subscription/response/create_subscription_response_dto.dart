enum SubscriptionType {
  FREE,
  BASIC,
  PREMIUM,
}

enum PreapprovalStatus {
  PENDING,
  ACTIVE,
  CANCELLED,
}

class CreateSubscriptionResponseDTO {
  final int subscriptionId;
  final String preapprovalId;
  final String initPoint;
  final String externalReference;
  final SubscriptionType subscriptionType;
  final double monthlyAmount;
  final PreapprovalStatus status;
  final DateTime createdAt;
  final DateTime nextPaymentDate;

  CreateSubscriptionResponseDTO({
    required this.subscriptionId,
    required this.preapprovalId,
    required this.initPoint,
    required this.externalReference,
    required this.subscriptionType,
    required this.monthlyAmount,
    required this.status,
    required this.createdAt,
    required this.nextPaymentDate,
  });

  factory CreateSubscriptionResponseDTO.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionResponseDTO(
      subscriptionId: json['subscriptionId'],
      preapprovalId: json['preapprovalId'],
      initPoint: json['initPoint'],
      externalReference: json['externalReference'],
      subscriptionType: SubscriptionType.values.firstWhere(
            (e) => e.name == json['subscriptionType'],
      ),
      monthlyAmount: (json['monthlyAmount'] as num).toDouble(),
      status: PreapprovalStatus.values.firstWhere(
            (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'preapprovalId': preapprovalId,
      'initPoint': initPoint,
      'externalReference': externalReference,
      'subscriptionType': subscriptionType.name,
      'monthlyAmount': monthlyAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
    };
  }
}
