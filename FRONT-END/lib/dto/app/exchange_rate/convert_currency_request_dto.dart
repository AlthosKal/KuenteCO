import 'package:decimal/decimal.dart';

class ConvertCurrencyRequestDTO {
  final Decimal amount;
  final String baseCurrency;
  final String targetCurrency;

  ConvertCurrencyRequestDTO({
    required this.amount,
    required this.baseCurrency,
    required this.targetCurrency,
  });

  factory ConvertCurrencyRequestDTO.fromJson(Map<String, dynamic> json) {
    return ConvertCurrencyRequestDTO(
      amount: Decimal.parse(json['amount'].toString()),
      baseCurrency: json['baseCurrency'],
      targetCurrency: json['targetCurrency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount.toString(),
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
    };
  }
}
