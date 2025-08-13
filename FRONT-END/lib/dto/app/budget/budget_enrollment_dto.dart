class BudgetEnrollmentDTO {
  final String userEmail;
  final String profileEmail;
  final String budgetName;

  BudgetEnrollmentDTO({
    required this.userEmail,
    required this.profileEmail,
    required this.budgetName,
  });

  factory BudgetEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    return BudgetEnrollmentDTO(
      userEmail: json['userEmail'],
      profileEmail: json['profileEmail'],
      budgetName: json['budgetName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'profileEmail': profileEmail,
      'budgetName': budgetName,
    };
  }
}
