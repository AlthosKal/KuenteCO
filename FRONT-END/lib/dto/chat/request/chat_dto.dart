class ChatDTO {
  final String? conversationId;
  final String prompt;

  ChatDTO({
    this.conversationId,
    required this.prompt,
  });

  bool needsConversationId() {
    return conversationId == null || conversationId!.trim().isEmpty;
  }

  Map<String, dynamic> toJson() {
    final json = {
      if (conversationId != null) 'conversationId': conversationId,
      'prompt': prompt,
    };
    print('📤 ChatDTO: Enviando al backend: $json');
    return json;
  }
}