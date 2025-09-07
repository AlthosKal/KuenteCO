/// DTO para el resultado de validación al importar deudas desde Excel
class DebtExcelValidationResultDTO {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int totalRows;
  final int validRows;
  final int invalidRows;

  DebtExcelValidationResultDTO({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
  });

  factory DebtExcelValidationResultDTO.success({
    required int totalRows,
    List<String>? warnings,
  }) {
    return DebtExcelValidationResultDTO(
      isValid: true,
      errors: [],
      warnings: warnings ?? [],
      totalRows: totalRows,
      validRows: totalRows,
      invalidRows: 0,
    );
  }

  factory DebtExcelValidationResultDTO.failure({
    required List<String> errors,
    required int totalRows,
    required int validRows,
    List<String>? warnings,
  }) {
    return DebtExcelValidationResultDTO(
      isValid: false,
      errors: errors,
      warnings: warnings ?? [],
      totalRows: totalRows,
      validRows: validRows,
      invalidRows: totalRows - validRows,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'errors': errors,
      'warnings': warnings,
      'totalRows': totalRows,
      'validRows': validRows,
      'invalidRows': invalidRows,
    };
  }

  String get summaryMessage {
    if (isValid) {
      return 'Validación exitosa: $validRows de $totalRows filas válidas${warnings.isNotEmpty ? ' con ${warnings.length} advertencia(s)' : ''}';
    } else {
      return 'Validación falló: $validRows válidas, $invalidRows inválidas de $totalRows filas totales';
    }
  }
}