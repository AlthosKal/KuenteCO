import 'package:flutter/material.dart';

import '../components/transaction/transaction_statistics_widget.dart';

class StatisticsTabWidget extends StatelessWidget {
  final String? userRole;

  const StatisticsTabWidget({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SingleChildScrollView(
          child: TransactionStatisticsWidget(),
        ),
      ),
    );
  }
}