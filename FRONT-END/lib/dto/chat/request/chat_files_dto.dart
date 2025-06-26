import 'chat_dto.dart';

class ChatFilesDTO extends ChatDTO {
  final List<String> files;

  ChatFilesDTO({
    required super.model,
    required super.conversationId,
    required super.prompt,
    required this.files,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(), // incluye model, conversationId, prompt
      'files': files, // añade la lista de archivos
    };
  }
}