class CharDataDTO {
  final String label;
  final double value;

  CharDataDTO({required this.label, required this.value});

  factory CharDataDTO.fromJson(Map<String, dynamic> json) {
    return CharDataDTO(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}