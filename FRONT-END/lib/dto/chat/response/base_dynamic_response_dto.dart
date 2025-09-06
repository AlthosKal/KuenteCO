import 'chart_data_response_dto.dart';
import 'debt_analysis_response_dto.dart';

abstract class BaseDynamicResponseDTO {
  final String type;
  final String? summary;
  final String? analysis;

  BaseDynamicResponseDTO({
    required this.type,
    this.summary,
    this.analysis,
  });

  Map<String, dynamic> toJson();

  /// Factory method para crear instancias basadas en el tipo
  static BaseDynamicResponseDTO fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'SIMPLE_TEXT':
        return SimpleTextResponseDTO.fromJson(json);
      case 'CHART_DATA':
        return ChartDataResponseDTO.fromJson(json);
      case 'DEBT_ANALYSIS':
        return DebtAnalysisResponseDTO.fromJson(json);
      case 'SPENDING_PATTERNS':
        return SpendingPatternResponseDTO.fromJson(json);
      case 'FINANCIAL_HEALTH':
        return FinancialHealthResponseDTO.fromJson(json);
      case 'EXPENSE_SUGGESTIONS':
        return ExpenseReductionResponseDTO.fromJson(json);
      case 'FINANCIAL_PROJECTION':
        return FinancialProjectionResponseDTO.fromJson(json);
      case 'REPORT_DOWNLOAD':
        return ReportDownloadResponseDTO.fromJson(json);
      default:
        throw ArgumentError('Unknown response type: $type');
    }
  }
}

/// Implementaciones especÃ­ficas que necesitamos crear
class SimpleTextResponseDTO extends BaseDynamicResponseDTO {
  final String message;

  SimpleTextResponseDTO({
    required String summary,
    required String analysis,
    required this.message,
  }) : super(type: 'SIMPLE_TEXT', summary: summary, analysis: analysis);

  factory SimpleTextResponseDTO.fromJson(Map<String, dynamic> json) {
    return SimpleTextResponseDTO(
      summary: json['summary'] ?? '',
      analysis: json['analysis'] ?? '',
      message: json['message'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      'message': message,
    };
  }
}

/// Placeholder para otros DTOs que referenciaremos
class SpendingPatternResponseDTO extends BaseDynamicResponseDTO {
  SpendingPatternResponseDTO() : super(type: 'SPENDING_PATTERNS');
  
  factory SpendingPatternResponseDTO.fromJson(Map<String, dynamic> json) {
    return SpendingPatternResponseDTO();
  }
  
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

class FinancialHealthResponseDTO extends BaseDynamicResponseDTO {
  FinancialHealthResponseDTO() : super(type: 'FINANCIAL_HEALTH');
  
  factory FinancialHealthResponseDTO.fromJson(Map<String, dynamic> json) {
    return FinancialHealthResponseDTO();
  }
  
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

class ExpenseReductionResponseDTO extends BaseDynamicResponseDTO {
  ExpenseReductionResponseDTO() : super(type: 'EXPENSE_SUGGESTIONS');
  
  factory ExpenseReductionResponseDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseReductionResponseDTO();
  }
  
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

class FinancialProjectionResponseDTO extends BaseDynamicResponseDTO {
  FinancialProjectionResponseDTO() : super(type: 'FINANCIAL_PROJECTION');
  
  factory FinancialProjectionResponseDTO.fromJson(Map<String, dynamic> json) {
    return FinancialProjectionResponseDTO();
  }
  
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

class ReportDownloadResponseDTO extends BaseDynamicResponseDTO {
  ReportDownloadResponseDTO() : super(type: 'REPORT_DOWNLOAD');
  
  factory ReportDownloadResponseDTO.fromJson(Map<String, dynamic> json) {
    return ReportDownloadResponseDTO();
  }
  
  @override
  Map<String, dynamic> toJson() => {'type': type};
}