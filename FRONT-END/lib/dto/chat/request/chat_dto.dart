import '../../../utils/enum/model_enum.dart';

class ChatDTO {
  final Model model;
  final String? conversationId;
  final String prompt;

  ChatDTO({
    required this.model,
    this.conversationId,
    required this.prompt,
  });

  bool needsConversationId() {
    return conversationId == null || conversationId!.trim().isEmpty;
  }

  Map<String, dynamic> toJson() {
    final json = {
      'model': model.name,
      if (conversationId != null) 'conversationId': conversationId,
      'prompt': prompt,
    };
    print('📤 ChatDTO: Enviando al backend: $json');
    return json;
  }
}