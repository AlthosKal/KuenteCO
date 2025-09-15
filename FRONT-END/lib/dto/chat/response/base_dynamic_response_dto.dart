import 'chart_data_response_dto.dart';
import 'debt_analysis_response_dto.dart';
import 'expense_reduction_suggestion_dto.dart';
import 'financial_health_score_dto.dart';
import 'financial_projection_dto.dart';
import 'report_download_response_dto.dart';
import 'spending_pattern_response_dto.dart';

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
    print('🔍 BaseDynamicResponseDTO: Parsing JSON: $json');
    final type = json['type'] as String? ?? 'SIMPLE_TEXT';
    print('🔍 BaseDynamicResponseDTO: Detected type: "$type"');
    
    switch (type) {
      case 'SIMPLE_TEXT':
        return SimpleTextResponseDTO.fromJson(json);
      case 'CHART_DATA':
        return ChartDataResponseDTO.fromJson(json);
      case 'DEBT_ANALYSIS':
        return DebtAnalysisResponseDTO.fromJson(json);
      case 'SPENDING_PATTERNS':
        return SpendingPatternResponseWrapperDTO.fromJson(json);
      case 'FINANCIAL_HEALTH':
        return FinancialHealthResponseWrapperDTO.fromJson(json);
      case 'EXPENSE_SUGGESTIONS':
        return ExpenseReductionResponseWrapperDTO.fromJson(json);
      case 'FINANCIAL_PROJECTION':
        return FinancialProjectionResponseWrapperDTO.fromJson(json);
      case 'REPORT_DOWNLOAD':
        return ReportDownloadResponseWrapperDTO.fromJson(json);
      case 'BUDGET_COMPARISON':
        return BudgetComparisonResponseDTO.fromJson(json);
      default:
        print('⚠️ BaseDynamicResponseDTO: Tipo desconocido "$type", usando SIMPLE_TEXT por defecto');
        return SimpleTextResponseDTO.fromJson(json);
    }
  }
}

/// Implementaciones específicas que necesitamos crear
class SimpleTextResponseDTO extends BaseDynamicResponseDTO {
  final String message;

  SimpleTextResponseDTO({
    super.summary,
    super.analysis,
    required this.message,
  }) : super(type: 'SIMPLE_TEXT');

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

/// Wrapper DTOs que extienden BaseDynamicResponseDTO
class SpendingPatternResponseWrapperDTO extends BaseDynamicResponseDTO {
  final SpendingPatternResponseDTO spendingPatterns;

  SpendingPatternResponseWrapperDTO({
    required super.summary,
    required super.analysis,
    required this.spendingPatterns,
  }) : super(type: 'SPENDING_PATTERNS');
  
  factory SpendingPatternResponseWrapperDTO.fromJson(Map<String, dynamic> json) {
    return SpendingPatternResponseWrapperDTO(
      summary: json['summary'],
      analysis: json['analysis'],
      spendingPatterns: SpendingPatternResponseDTO.fromJson(json),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      ...spendingPatterns.toJson(),
    };
  }
}

class FinancialHealthResponseWrapperDTO extends BaseDynamicResponseDTO {
  final FinancialHealthScoreDTO healthScore;

  FinancialHealthResponseWrapperDTO({
    required super.summary,
    required super.analysis,
    required this.healthScore,
  }) : super(type: 'FINANCIAL_HEALTH');
  
  factory FinancialHealthResponseWrapperDTO.fromJson(Map<String, dynamic> json) {
    return FinancialHealthResponseWrapperDTO(
      summary: json['summary'],
      analysis: json['analysis'],
      healthScore: FinancialHealthScoreDTO.fromJson(json['healthScore'] ?? json),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      'healthScore': healthScore.toJson(),
    };
  }
}

class ExpenseReductionResponseWrapperDTO extends BaseDynamicResponseDTO {
  final List<ExpenseReductionSuggestionDTO> suggestions;
  final double totalPotentialSavings;

  ExpenseReductionResponseWrapperDTO({
    required super.summary,
    required super.analysis,
    required this.suggestions,
    required this.totalPotentialSavings,
  }) : super(type: 'EXPENSE_SUGGESTIONS');
  
  factory ExpenseReductionResponseWrapperDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseReductionResponseWrapperDTO(
      summary: json['summary'],
      analysis: json['analysis'],
      suggestions: (json['suggestions'] as List?)
          ?.map((e) => ExpenseReductionSuggestionDTO.fromJson(e))
          .toList() ?? [],
      totalPotentialSavings: (json['totalPotentialSavings'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      'suggestions': suggestions.map((e) => e.toJson()).toList(),
      'totalPotentialSavings': totalPotentialSavings,
    };
  }
}

class FinancialProjectionResponseWrapperDTO extends BaseDynamicResponseDTO {
  final FinancialProjectionDTO projection;

  FinancialProjectionResponseWrapperDTO({
    required super.summary,
    required super.analysis,
    required this.projection,
  }) : super(type: 'FINANCIAL_PROJECTION');
  
  factory FinancialProjectionResponseWrapperDTO.fromJson(Map<String, dynamic> json) {
    return FinancialProjectionResponseWrapperDTO(
      summary: json['summary'],
      analysis: json['analysis'],
      projection: FinancialProjectionDTO.fromJson(json['projection'] ?? json),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      'projection': projection.toJson(),
    };
  }
}

class ReportDownloadResponseWrapperDTO extends BaseDynamicResponseDTO {
  final ReportDownloadResponseDTO reportDownload;

  ReportDownloadResponseWrapperDTO({
    required super.summary,
    required super.analysis,
    required this.reportDownload,
  }) : super(type: 'REPORT_DOWNLOAD');
  
  factory ReportDownloadResponseWrapperDTO.fromJson(Map<String, dynamic> json) {
    return ReportDownloadResponseWrapperDTO(
      summary: json['summary'],
      analysis: json['analysis'],
      reportDownload: ReportDownloadResponseDTO.fromJson(json),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      ...reportDownload.toJson(),
    };
  }
}

class BudgetComparisonResponseDTO extends BaseDynamicResponseDTO {
  final Map<String, dynamic> comparisonData;

  BudgetComparisonResponseDTO({
    required super.summary,
    required super.analysis,
    required this.comparisonData,
  }) : super(type: 'BUDGET_COMPARISON');
  
  factory BudgetComparisonResponseDTO.fromJson(Map<String, dynamic> json) {
    return BudgetComparisonResponseDTO(
      summary: json['summary'],
      analysis: json['analysis'],
      comparisonData: Map<String, dynamic>.from(json['comparisonData'] ?? {}),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'summary': summary,
      'analysis': analysis,
      'comparisonData': comparisonData,
    };
  }
}