import 'package:KuenteCO/dto/app/transaction/kuenteco/transaction_detail_dto.dart';

class ProfileWithTransactionsDTO {
  final String username;
  final String email;
  final DateTime startDate;
  final List<TransactionDetailDTO> transactions;
  final int transactionCount;
  final double totalAmount;

  ProfileWithTransactionsDTO({
    required this.username,
    required this.email,
    required this.startDate,
    required this.transactions,
    required this.transactionCount,
    required this.totalAmount,
  });

  factory ProfileWithTransactionsDTO.fromJson(Map<String, dynamic> json) {
    return ProfileWithTransactionsDTO(
      username: json['username'],
      email: json['email'],
      startDate: DateTime.parse(json['startDate']),
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TransactionDetailDTO.fromJson(e))
          .toList(),
      transactionCount: json['transactionCount'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'startDate': startDate.toIso8601String(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'transactionCount': transactionCount,
      'totalAmount': totalAmount,
    };
  }
}
