import 'base_dynamic_response_dto.dart';
import 'string_chat_response_dto.dart';

/// DTO para respuestas de análisis dinámico que combina respuesta de texto y análisis AI
class DynamicAnalysisResponseDTO {
  final StringChatResponseDTO body;
  final BaseDynamicResponseDTO response;

  DynamicAnalysisResponseDTO({
    required this.body,
    required this.response,
  });

  factory DynamicAnalysisResponseDTO.fromJson(Map<String, dynamic> json) {
    print('🔍 DynamicAnalysisResponseDTO: Parsing JSON: $json');
    
    final bodyData = json['body'] ?? {};
    final responseData = json['response'] ?? {};
    
    print('🔍 DynamicAnalysisResponseDTO: Body data: $bodyData');
    print('🔍 DynamicAnalysisResponseDTO: Response data: $responseData');
    
    return DynamicAnalysisResponseDTO(
      body: StringChatResponseDTO.fromJson(bodyData),
      response: BaseDynamicResponseDTO.fromJson(responseData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body.toJson(),
      'response': response.toJson(),
    };
  }

  /// Getter para obtener el tipo de análisis
  String get analysisType => response.type;

  /// Getter para verificar si incluye datos de gráfico
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