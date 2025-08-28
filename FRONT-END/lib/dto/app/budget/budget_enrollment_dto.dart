class BudgetEnrollmentDTO {
  final int id;
  final String userEmail;
  final String profileEmail;
  final String budgetName;

  BudgetEnrollmentDTO({
    required this.id,
    required this.userEmail,
    required this.profileEmail,
    required this.budgetName,
  });

  factory BudgetEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    print('BudgetEnrollmentDTO.fromJson: Raw JSON: $json');
    final id = _parseId(json['id']);
    final userEmail = json['userEmail'] ?? '';
    final profileEmail = json['profileEmail'] ?? '';
    final budgetName = json['budgetName'] ?? '';
    print('BudgetEnrollmentDTO.fromJson: Parsed values - ID: $id, UserEmail: $userEmail, ProfileEmail: $profileEmail, BudgetName: $budgetName');
    return BudgetEnrollmentDTO(
      id: id,
      userEmail: userEmail,
      profileEmail: profileEmail,
      budgetName: budgetName,
    );
  }

  static int _parseId(dynamic value) {
    print('BudgetEnrollmentDTO._parseId: Input value: $value (type: ${value.runtimeType})');
    if (value == null) {
      print('BudgetEnrollmentDTO._parseId: Value is null, returning 0');
      return 0;
    }
    if (value is int) {
      print('BudgetEnrollmentDTO._parseId: Value is int: $value');
      return value;
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        print('BudgetEnrollmentDTO._parseId: Parsed from string: $parsed');
        return parsed;
      }
      final doubleValue = double.tryParse(value);
      if (doubleValue != null) {
        print('BudgetEnrollmentDTO._parseId: Parsed from double string: ${doubleValue.toInt()}');
        return doubleValue.toInt();
      }
    }
    if (value is double) {
      print('BudgetEnrollmentDTO._parseId: Value is double: ${value.toInt()}');
      return value.toInt();
    }
    print('BudgetEnrollmentDTO._parseId: Could not parse, returning 0');
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'profileEmail': profileEmail,
      'budgetName': budgetName,
    };
  }
}
