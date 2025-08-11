import '../../../utils/enum/subscription_type_enum.dart';

class CreateSubscriptionRequestDTO {
  final SubscriptionType subscriptionType;
  String backUrl = "https://github.com/AlthosKal/KuenteCO";

  CreateSubscriptionRequestDTO({
    required this.subscriptionType,
    required this.backUrl,
  });

  factory CreateSubscriptionRequestDTO.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionRequestDTO(
      subscriptionType: SubscriptionType.values.firstWhere(
            (e) => e.name == json['subscriptionType'],
        orElse: () => SubscriptionType.BASIC,
      ),
      backUrl: json['backUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionType': subscriptionType.name,
      'backUrl': backUrl,
    };
  }
}
