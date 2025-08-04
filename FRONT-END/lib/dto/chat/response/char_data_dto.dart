class CharDataDTO {
  final String label;
  final double value;

  CharDataDTO({required this.label, required this.value});

  factory CharDataDTO.fromJson(Map<String, dynamic> json) {
    return CharDataDTO(label: json['label'], value: json['value']);
  }
}