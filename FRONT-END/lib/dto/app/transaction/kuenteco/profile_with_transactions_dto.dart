import 'package:KuenteCO/dto/app/transaction/kuenteco/transaction_detail_dto.dart';

class ProfileWithTransactionsDTO {
  final String? username;
  final String? email;
  final DateTime? startDate;
  final List<TransactionDetailDTO>? transactions;
  final int? transactionCount;
  final double? totalAmount;

  ProfileWithTransactionsDTO({
    this.username,
    this.email,
    this.startDate,
    this.transactions,
    this.transactionCount,
    this.totalAmount,
  });

  factory ProfileWithTransactionsDTO.fromJson(Map<String, dynamic> json) {
    return ProfileWithTransactionsDTO(
      username: json['username'],
      email: json['email'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List<dynamic>)
              .map((e) => TransactionDetailDTO.fromJson(e))
              .toList()
          : null,
      transactionCount: json['transactionCount'],
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'startDate': startDate?.toIso8601String(),
      'transactions': transactions?.map((e) => e.toJson()).toList(),
      'transactionCount': transactionCount,
      'totalAmount': totalAmount,
    };
  }
}
