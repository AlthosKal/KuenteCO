import 'package:dio/dio.dart';

import 'chat_dto.dart';

class ChatMultipartDTO extends ChatDTO {
  final MultipartFile file;

  ChatMultipartDTO({
    required super.model,
    required super.conversationId,
    required super.prompt,
    required this.file,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(), // incluye model, conversationId, prompt
      'files': file, // añade la lista de archivos
    };
  }
}