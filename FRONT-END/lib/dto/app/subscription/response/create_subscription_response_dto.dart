import '../../../../utils/enum/preapproval_status_enum.dart';
import '../../../../utils/enum/subscription_type_enum.dart';

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
      subscriptionId: json['subscriptionId'] != null ? int.tryParse(json['subscriptionId'].toString()) ?? 0 : 0,
      preapprovalId: json['preapprovalId']?.toString() ?? '',
      initPoint: json['initPoint']?.toString() ?? '',
      externalReference: json['externalReference']?.toString() ?? '',
      subscriptionType: SubscriptionType.values.firstWhere(
            (e) => e.name == json['subscriptionType']?.toString(),
        orElse: () => SubscriptionType.BASIC,
      ),
      monthlyAmount: json['monthlyAmount'] != null ? double.tryParse(json['monthlyAmount'].toString()) ?? 0.0 : 0.0,
      status: PreapprovalStatus.values.firstWhere(
            (e) => e.name == json['status']?.toString(),
        orElse: () => PreapprovalStatus.PENDING,
      ),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      nextPaymentDate: json['nextPaymentDate'] != null ? DateTime.tryParse(json['nextPaymentDate'].toString()) ?? DateTime.now() : DateTime.now(),
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
