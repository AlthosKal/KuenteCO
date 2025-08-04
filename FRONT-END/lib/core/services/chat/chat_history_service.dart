import '../../../dto/chat/response/chat_history_dto.dart';
import '../api_client.dart';

class ChatService {
  final _api = ApiClient();

  Future<List<ChatHistoryDTO>> getHistoryByConversationId(
      String conversationId,
      ) async {
    final response = await _api.getChat('/chat/history/$conversationId');

    final data = response.data;

    if (data is List) {
      return data.map((json) => ChatHistoryDTO.fromJson(json)).toList();
    }
    throw Exception('Respuesta inesperada del servidor.');
  }
}