import 'data_response_dto.dart';

class AnalysisResponseDTO {
  final String response;
  final String analysis;
  final DataResponseDTO data;

  AnalysisResponseDTO({
    required this.response,
    required this.analysis,
    required this.data,
  });

  factory AnalysisResponseDTO.fromJson(Map<String, dynamic> json) {
    return AnalysisResponseDTO(
      response: json['response'],
      analysis: json['analysis'],
      data: DataResponseDTO.fromJson(json['data']),
    );
  }
}