import 'analysis_response_dto.dart';
import 'data_response_dto.dart';

class ChatResponseDTO {
  final String conversationId;
  final AnalysisResponseDTO analysis;

  ChatResponseDTO({required this.conversationId, required this.analysis});

  factory ChatResponseDTO.fromJson(Map<String, dynamic> json) {
    // El backend devuelve la estructura dentro de 'data'
    final data = json['data'];
    if (data == null) {
      return ChatResponseDTO(
        conversationId: '',
        analysis: AnalysisResponseDTO.empty(),
      );
    }

    final body = data['body'] ?? {};
    final response = data['response'] ?? {};
    
    return ChatResponseDTO(
      conversationId: body['conversationId'] ?? '',
      analysis: AnalysisResponseDTO(
        response: body['response'] ?? '',
        analysis: response['analysis'] ?? response['summary'] ?? '',
        data: DataResponseDTO.empty(), // chartData puede ser null
      ),
    );
  }
}