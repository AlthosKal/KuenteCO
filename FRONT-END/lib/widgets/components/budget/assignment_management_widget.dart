import 'package:flutter/material.dart';

import 'assignment_list_widget.dart';

class AssignmentManagementWidget extends StatelessWidget {
  const AssignmentManagementWidget({super.key});

  static Future<bool?> showAssignmentManagement(BuildContext context) {
    return AssignmentListWidget.showAssignmentList(context);
  }

  @override
  Widget build(BuildContext context) {
    // Este widget ya no se usa directamente, solo sirve como proxy
    return const AssignmentListWidget();
  }
}