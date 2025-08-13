import '../../../utils/enum/subscription_type_enum.dart';
import '../../../utils/enum/state_enum.dart';
import '../../../utils/enum/preapproval_status_enum.dart';

class SubscriptionResponseDTO {
  final int subscriptionId;
  final String preapprovalId;
  final SubscriptionType subscriptionType;
  final double monthlyAmount;
  final State subscriptionState;
  final PreapprovalStatus preapprovalStatus;
  final DateTime startDate;
  final DateTime expirationDate;
  final DateTime nextPaymentDate;
  final bool isAutoRenewable;
  final String? paymentMethodId;
  final String? cardLastFourDigits;
  final String? cardBrand;

  SubscriptionResponseDTO({
    required this.subscriptionId,
    required this.preapprovalId,
    required this.subscriptionType,
    required this.monthlyAmount,
    required this.subscriptionState,
    required this.preapprovalStatus,
    required this.startDate,
    required this.expirationDate,
    required this.nextPaymentDate,
    required this.isAutoRenewable,
    this.paymentMethodId,
    this.cardLastFourDigits,
    this.cardBrand,
  });

  factory SubscriptionResponseDTO.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseDTO(
      subscriptionId: json['subscriptionId'],
      preapprovalId: json['preapprovalId'],
      subscriptionType: SubscriptionType.values.firstWhere(
            (e) => e.name == json['subscriptionType'],
        orElse: () => SubscriptionType.BASIC,
      ),
      monthlyAmount: (json['monthlyAmount'] as num).toDouble(),
      subscriptionState: State.values.firstWhere(
            (e) => e.name == json['subscriptionState'],
        orElse: () => State.INACTIVE,
      ),
      preapprovalStatus: PreapprovalStatus.values.firstWhere(
            (e) => e.name == json['preapprovalStatus'],
        orElse: () => PreapprovalStatus.PENDING,
      ),
      startDate: DateTime.parse(json['startDate']),
      expirationDate: DateTime.parse(json['expirationDate']),
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
      isAutoRenewable: json['isAutoRenewable'] ?? false,
      paymentMethodId: json['paymentMethodId'] as String?,
      cardLastFourDigits: json['cardLastFourDigits'] as String?,
      cardBrand: json['cardBrand'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'preapprovalId': preapprovalId,
      'subscriptionType': subscriptionType.name,
      'monthlyAmount': monthlyAmount,
      'subscriptionState': subscriptionState.name,
      'preapprovalStatus': preapprovalStatus.name,
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'isAutoRenewable': isAutoRenewable,
      'paymentMethodId': paymentMethodId,
      'cardLastFourDigits': cardLastFourDigits,
      'cardBrand': cardBrand,
    };
  }
}
