import 'package:decimal/decimal.dart';

class ConvertCurrencyResponseDTO {
  final Decimal convertedAmount;
  final String baseCurrency;
  final String targetCurrency;
  final Decimal rate;

  ConvertCurrencyResponseDTO({
    required this.convertedAmount,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
  });

  factory ConvertCurrencyResponseDTO.fromJson(Map<String, dynamic> json) {
    return ConvertCurrencyResponseDTO(
      convertedAmount: Decimal.parse(json['convertedAmount'].toString()),
      baseCurrency: json['baseCurrency'],
      targetCurrency: json['targetCurrency'],
      rate: Decimal.parse(json['rate'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'convertedAmount': convertedAmount.toString(),
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'rate': rate.toString(),
    };
  }
}
