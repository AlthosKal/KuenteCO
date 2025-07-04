class ChatHistoryDTO {
  final String conversationId;
  final String prompt;
  final String response;
  final DateTime date;

  ChatHistoryDTO({
    required this.conversationId,
    required this.prompt,
    required this.response,
    required this.date,
  });

  factory ChatHistoryDTO.fromJson(Map<String, dynamic> json) {
    return ChatHistoryDTO(
      conversationId: json['conversationId'],
      prompt: json['prompt'],
      response: json['response'],
      date: DateTime.parse(json['date']),
    );
  }
}