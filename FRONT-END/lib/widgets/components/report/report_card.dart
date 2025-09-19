import 'package:flutter/material.dart';
import '../../../screens/report/report_view.dart';
import '../../common/hover_card.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      title: 'Reporte',
      icon: Icons.assessment_outlined,
      onTap: () => _navigateToReportView(context),
      baseColor: const Color(0xFF890cac).withOpacity(0.3),
      hoverColor: const Color(0xFF890cac).withOpacity(0.5),
    );
  }

  void _navigateToReportView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportView(),
      ),
    );
  }
}