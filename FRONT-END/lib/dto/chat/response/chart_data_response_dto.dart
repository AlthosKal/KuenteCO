import 'base_dynamic_response_dto.dart';
import 'char_data_dto.dart';

/// DTO para respuestas de grÃ¡ficos del chat AI
class ChartDataResponseDTO extends BaseDynamicResponseDTO {
  final String chartType;
  final List<CharDataDTO> data;
  final String? xAxisLabel;
  final String? yAxisLabel;

  ChartDataResponseDTO({
    required String summary,
    required String analysis,
    required this.chartType,
    required this.data,
    this.xAxisLabel,
    this.yAxisLabel,
  }) : super(type: 'CHART_DATA', summary: summary, analysis: analysis);

  factory ChartDataResponseDTO.fromJson(Map<String, dynamic> json) {
    return ChartDataResponseDTO(
      summary: json['summary'] ?? '',
      analysis: json['analysis'] ?? '',
      chartType: json['chartType'] ?? 'bar',
      data: (json['data'] as List?)
          ?.map((item) => CharDataDTO.fromJson(item))
          .toList() ?? [],
      xAxisLabel: json['xAxisLabel'],
      yAxisLabel: json['yAxisLabel'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      'chartType': chartType,
      'data': data.map((item) => item.toJson()).toList(),
      if (xAxisLabel != null) 'xAxisLabel': xAxisLabel,
      if (yAxisLabel != null) 'yAxisLabel': yAxisLabel,
    };
  }

  /// Getter para tipos de grÃ¡ficos soportados
  static List<String> get supportedChartTypes => [
    'line',
    'bar', 
    'pie',
    'area',
    'scatter',
    'donut'
  ];

  /// Verificar si el tipo de grÃ¡fico es vÃ¡lido
  bool get isValidChartType => supportedChartTypes.contains(chartType);
}