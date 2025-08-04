class ExchangeRate {
  final int? id;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime lastUpdated;

  ExchangeRate({
    this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.lastUpdated,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      id: json['id'],
      baseCurrency: json['baseCurrency'],
      targetCurrency: json['targetCurrency'],
      rate: (json['rate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'rate': rate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
