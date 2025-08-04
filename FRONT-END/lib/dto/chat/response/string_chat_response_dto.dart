class StringChatResponseDTO {
  final String conversationId;
  final String response;

  StringChatResponseDTO({required this.conversationId, required this.response});

  factory StringChatResponseDTO.fromJson(Map<String, dynamic> json) {
    return StringChatResponseDTO(
      conversationId: json['conversationId'],
      response: json['response'],
    );
  }
}