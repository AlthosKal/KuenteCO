import 'char_data_dto.dart';

class DataResponseDTO {
  final String name;
  final String description;
  final List<CharDataDTO> values;

  DataResponseDTO({
    required this.name,
    required this.description,
    required this.values,
  });

  factory DataResponseDTO.fromJson(Map<String, dynamic> json) {
    return DataResponseDTO(
      name: json['name'],
      description: json['description'],
      values:
      (json['values'] as List).map((e) => CharDataDTO.fromJson(e)).toList(),
    );
  }
}