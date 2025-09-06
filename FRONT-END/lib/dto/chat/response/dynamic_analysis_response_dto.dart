import 'base_dynamic_response_dto.dart';
import 'string_chat_response_dto.dart';

/// DTO para respuestas de anÃ¡lisis dinÃ¡mico que combina respuesta de texto y anÃ¡lisis AI
class DynamicAnalysisResponseDTO {
  final StringChatResponseDTO body;
  final BaseDynamicResponseDTO response;

  DynamicAnalysisResponseDTO({
    required this.body,
    required this.response,
  });

  factory DynamicAnalysisResponseDTO.fromJson(Map<String, dynamic> json) {
    return DynamicAnalysisResponseDTO(
      body: StringChatResponseDTO.fromJson(json['body'] ?? {}),
      response: BaseDynamicResponseDTO.fromJson(json['response'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body.toJson(),
      'response': response.toJson(),
    };
  }

  /// Getter para obtener el tipo de anÃ¡lisis
  String get analysisType => response.type;

  /// Getter para verificar si incluye datos de grÃ¡fico
  bool get hasChartData => body.chartData != null;

  /// Getter para obtener resumen combinado
  String get combinedSummary {
    final bodySummary = body.response;
    final analysisSummary = response.summary;
    
    if (analysisSummary != null && analysisSummary.isNotEmpty) {
      return '$bodySummary\n\n$analysisSummary';
    }
    return bodySummary;
  }
}