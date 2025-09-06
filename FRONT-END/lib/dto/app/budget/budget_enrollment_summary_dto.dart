import '../../../dto/app/budget/budget_enrollment_dto.dart';

class BudgetEnrollmentSummaryDTO {
  final String budgetName;
  final int totalEnrollments;
  final List<BudgetEnrollmentDTO> enrollments;

  BudgetEnrollmentSummaryDTO({
    required this.budgetName,
    required this.totalEnrollments,
    required this.enrollments,
  });

  // Crear un summary agrupando enrollments por presupuesto
  static List<BudgetEnrollmentSummaryDTO> fromEnrollmentList(List<BudgetEnrollmentDTO> enrollments) {
    final Map<String, List<BudgetEnrollmentDTO>> grouped = {};
    
    for (final enrollment in enrollments) {
      if (!grouped.containsKey(enrollment.budgetName)) {
        grouped[enrollment.budgetName] = [];
      }
      grouped[enrollment.budgetName]!.add(enrollment);
    }

    return grouped.entries.map((entry) {
      return BudgetEnrollmentSummaryDTO(
        budgetName: entry.key,
        totalEnrollments: entry.value.length,
        enrollments: entry.value,
      );
    }).toList();
  }

  // Obtener clave para selecciÃ³n (similar a categories)
  String get selectionKey => budgetName;
}

class EnrolledProfileBudgetSummaryDTO {
  final int enrollmentId;
  final String profileEmail;
  final String userEmail;
  final String budgetName;

  EnrolledProfileBudgetSummaryDTO({
    required this.enrollmentId,
    required this.profileEmail,
    required this.userEmail,
    required this.budgetName,
  });

  factory EnrolledProfileBudgetSummaryDTO.fromBudgetEnrollment(BudgetEnrollmentDTO enrollment) {
    return EnrolledProfileBudgetSummaryDTO(
      enrollmentId: enrollment.id,
      profileEmail: enrollment.profileEmail,
      userEmail: enrollment.userEmail,
      budgetName: enrollment.budgetName,
    );
  }

  // Obtener clave para selecciÃ³n individual
  String get selectionKey => '$budgetName-$profileEmail-$userEmail';
}