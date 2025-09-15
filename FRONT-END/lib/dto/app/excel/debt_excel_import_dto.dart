import 'package:decimal/decimal.dart';
import '../../../utils/enum/state_debt_enum.dart';

/// DTO para importar deudas desde Excel
class DebtExcelImportDTO {
  final String name;
  final Decimal totalAmount;
  final Decimal pendingAmount;
  final DateTime startDate;
  final DateTime expirationDate;
  final StateDebt state;

  DebtExcelImportDTO({
    required this.name,
    required this.totalAmount,
    required this.pendingAmount,
    required this.startDate,
    required this.expirationDate,
    required this.state,
  });

  factory DebtExcelImportDTO.fromExcelRow(Map<String, dynamic> excelRow) {
    return DebtExcelImportDTO(
      name: excelRow['Nombre'] ?? '',
      totalAmount: Decimal.parse(excelRow['Total']?.toString() ?? '0'),
      pendingAmount: Decimal.parse(excelRow['Pendiente']?.toString() ?? '0'),
      startDate: _parseExcelDate(excelRow['Fecha de Inicio']),
      expirationDate: _parseExcelDate(excelRow['Fecha de Vencimiento']),
      state: StateDebt.fromString(excelRow['Estado'] ?? 'ACTIVE'),
    );
  }

  static DateTime _parseExcelDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    final String dateStr = dateValue.toString();
    
    // Formato esperado: dd/MM/yyyy
    if (dateStr.contains('/')) {
      final List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        final int day = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    }
    
    // Fallback: intentar parsear como ISO string
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toNewDebtJson() {
    return {
      'name': name,
      'totalAmount': totalAmount.toString(),
      'pendingAmount': pendingAmount.toString(),
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'state': state.toJson(),
    };
  }
}