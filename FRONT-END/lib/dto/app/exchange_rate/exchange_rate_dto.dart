import 'package:decimal/decimal.dart';

class ExchangeRateDTO {
  final String baseCurrency;
  final String targetCurrency;
  final Decimal rate;
  final DateTime lastUpdated;

  ExchangeRateDTO({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.lastUpdated,
  });

  factory ExchangeRateDTO.fromJson(Map<String, dynamic> json) {
    return ExchangeRateDTO(
      baseCurrency: json['baseCurrency'],
      targetCurrency: json['targetCurrency'],
      rate: Decimal.parse(json['rate'].toString()),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'rate': rate.toString(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
