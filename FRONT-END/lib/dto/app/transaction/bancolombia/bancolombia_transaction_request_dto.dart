class BancolombiaTransactionRequestDTO {
  final String product;
  final String identificationType;
  final String identificationNumber;
  final String initialDate;
  final String finalDate;
  final String timeSpan;

  BancolombiaTransactionRequestDTO({
    required this.product,
    required this.identificationType,
    required this.identificationNumber,
    required this.initialDate,
    required this.finalDate,
    required this.timeSpan,
  });

  factory BancolombiaTransactionRequestDTO.fromJson(Map<String, dynamic> json) {
    return BancolombiaTransactionRequestDTO(
      product: json['product'],
      identificationType: json['identificationType'],
      identificationNumber: json['identificationNumber'],
      initialDate: json['initialDate'],
      finalDate: json['finalDate'],
      timeSpan: json['timeSpan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'identificationType': identificationType,
      'identificationNumber': identificationNumber,
      'initialDate': initialDate,
      'finalDate': finalDate,
      'timeSpan': timeSpan,
    };
  }
}
