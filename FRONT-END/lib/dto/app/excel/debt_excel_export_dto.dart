import 'package:decimal/decimal.dart';
import '../../../utils/enum/state_debt_enum.dart';

/// DTO para exportar deudas a Excel
class DebtExcelExportDTO {
  final String name;
  final Decimal totalAmount;
  final Decimal pendingAmount;
  final DateTime startDate;
  final DateTime expirationDate;
  final StateDebt state;

  DebtExcelExportDTO({
    required this.name,
    required this.totalAmount,
    required this.pendingAmount,
    required this.startDate,
    required this.expirationDate,
    required this.state,
  });

  factory DebtExcelExportDTO.fromDebtDTO(dynamic debtDTO) {
    return DebtExcelExportDTO(
      name: debtDTO.name,
      totalAmount: debtDTO.totalAmount,
      pendingAmount: debtDTO.pendingAmount,
      startDate: debtDTO.startDate,
      expirationDate: debtDTO.expirationDate,
      state: debtDTO.state,
    );
  }

  Map<String, dynamic> toExcelJson() {
    return {
      'Nombre': name,
      'Total': totalAmount.toString(),
      'Pendiente': pendingAmount.toString(),
      'Fecha de Inicio': '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}',
      'Fecha de Vencimiento': '${expirationDate.day.toString().padLeft(2, '0')}/${expirationDate.month.toString().padLeft(2, '0')}/${expirationDate.year}',
      'Estado': state.name,
    };
  }
}