import '../../../dto/chat/request/chat_dto.dart';
import '../../../dto/chat/request/chat_files_dto.dart';
import '../../../dto/chat/request/chat_multipart_dto.dart';
import '../../../dto/chat/response/chat_response_dto.dart';
import '../../../dto/chat/response/string_chat_response_dto.dart';
import '../api_client.dart';

class ChatService {
  final _api = ApiClient();

  Future<ChatResponseDTO> askAi(ChatDTO dto) async {
    final response = await _api.postChat('/chat', dto.toJson());
    return ChatResponseDTO.fromJson(response.data);
  }

  Future<StringChatResponseDTO> askAiWithUrl(ChatFilesDTO dto) async {
    final response = await _api.postChat('/chat-with-url', dto.toJson());
    return StringChatResponseDTO.fromJson(response.data);
  }

  Future<StringChatResponseDTO> askAiWithFile(ChatMultipartDTO dto) async {
    final response = await _api.postChat('/chat-with-file', dto.toJson());

    return StringChatResponseDTO.fromJson(response.data);
  }
}