import '../../../utils/enum/model.dart';

class ChatDTO {
  final Model model;
  final String? conversationId;
  final String prompt;

  ChatDTO({
    required this.model,
    required this.conversationId,
    required this.prompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model.name,
      if (conversationId != null) 'conversationId': conversationId,
      'prompt': prompt,
    };
  }
}