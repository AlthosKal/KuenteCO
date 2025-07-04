import 'analysis_response_dto.dart';

class ChatResponseDTO {
  final String conversationId;
  final AnalysisResponseDTO analysis;

  ChatResponseDTO({required this.conversationId, required this.analysis});

  factory ChatResponseDTO.fromJson(Map<String, dynamic> json) {
    return ChatResponseDTO(
      conversationId: json['conversationId'],
      analysis: AnalysisResponseDTO.fromJson(json['analysis']),
    );
  }
}