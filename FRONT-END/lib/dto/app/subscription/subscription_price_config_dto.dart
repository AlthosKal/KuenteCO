import 'package:decimal/decimal.dart';
import '../../../utils/enum/subscription_type_enum.dart';

class SubscriptionPriceConfigDTO {
  final SubscriptionType type;
  final Decimal monthlyPrice;
  final String description;
  final String currencyId;

  SubscriptionPriceConfigDTO({
    required this.type,
    required this.monthlyPrice,
    required this.description,
    required this.currencyId,
  });

  factory SubscriptionPriceConfigDTO.fromJson(Map<String, dynamic> json) {
    return SubscriptionPriceConfigDTO(
      type: SubscriptionTypeExtension.fromString(json['type']),
      monthlyPrice: Decimal.parse(json['monthlyPrice'].toString()),
      description: json['description'],
      currencyId: json['currencyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'monthlyPrice': monthlyPrice.toString(),
      'description': description,
      'currencyId': currencyId,
    };
  }
}

extension SubscriptionTypeExtension on SubscriptionType {
  static SubscriptionType fromString(String value) {
    return SubscriptionType.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SubscriptionType.BASIC,
    );
  }
}
