import 'package:decimal/decimal.dart';

class DebtSummaryDTO {
  final String userId;
  final String ownerUserId;
  final String username;
  final int totalDebts;
  final int activeDebts;
  final int paidDebts;
  final int overdueDebts;
  final int refinancedDebts;
  final int inMoratiumDebts;
  final int cancelledDebts;
  final Decimal totalDebtAmount;
  final Decimal totalPendingAmount;
  final Decimal activePendingAmount;
  final DateTime? nextDueDate;
  final int expiredActiveDebts;

  DebtSummaryDTO({
    required this.userId,
    required this.ownerUserId,
    required this.username,
    required this.totalDebts,
    required this.activeDebts,
    required this.paidDebts,
    required this.overdueDebts,
    required this.refinancedDebts,
    required this.inMoratiumDebts,
    required this.cancelledDebts,
    required this.totalDebtAmount,
    required this.totalPendingAmount,
    required this.activePendingAmount,
    this.nextDueDate,
    required this.expiredActiveDebts,
  });

  factory DebtSummaryDTO.fromJson(Map<String, dynamic> json) {
    return DebtSummaryDTO(
      userId: json['userId'],
      ownerUserId: json['ownerUserId'],
      username: json['username'],
      totalDebts: json['totalDebts'],
      activeDebts: json['activeDebts'],
      paidDebts: json['paidDebts'],
      overdueDebts: json['overdueDebts'],
      refinancedDebts: json['refinancedDebts'],
      inMoratiumDebts: json['inMoratiumDebts'],
      cancelledDebts: json['cancelledDebts'],
      totalDebtAmount: Decimal.parse(json['totalDebtAmount'].toString()),
      totalPendingAmount: Decimal.parse(json['totalPendingAmount'].toString()),
      activePendingAmount: Decimal.parse(json['activePendingAmount'].toString()),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      expiredActiveDebts: json['expiredActiveDebts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ownerUserId': ownerUserId,
      'username': username,
      'totalDebts': totalDebts,
      'activeDebts': activeDebts,
      'paidDebts': paidDebts,
      'overdueDebts': overdueDebts,
      'refinancedDebts': refinancedDebts,
      'inMoratiumDebts': inMoratiumDebts,
      'cancelledDebts': cancelledDebts,
      'totalDebtAmount': totalDebtAmount.toString(),
      'totalPendingAmount': totalPendingAmount.toString(),
      'activePendingAmount': activePendingAmount.toString(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'expiredActiveDebts': expiredActiveDebts,
    };
  }
}
