import 'chart_data_response_dto.dart';

class StringChatResponseDTO {
  final String conversationId;
  final String response;
  final ChartDataResponseDTO? chartData;

  StringChatResponseDTO({
    required this.conversationId,
    required this.response,
    this.chartData,
  });

  factory StringChatResponseDTO.fromJson(Map<String, dynamic> json) {
    return StringChatResponseDTO(
      conversationId: json['conversationId'] ?? '',
      response: json['response'] ?? '',
      chartData: json['chartData'] != null 
          ? ChartDataResponseDTO.fromJson(json['chartData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'response': response,
      if (chartData != null) 'chartData': chartData!.toJson(),
    };
  }
}