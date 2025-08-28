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

  // Factory para crear desde la estructura individual del backend
  factory BudgetEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    final id = _parseId(json['id']);
    final userEmail = json['userEmail'] ?? json['email'] ?? '';
    final profileEmail = json['profileEmail'] ?? json['profileName'] ?? '';
    final budgetName = json['budgetName'] ?? json['budget_name'] ?? '';
                      
    print('BudgetEnrollmentDTO.fromJson: FINAL RESULT - ID: $id, ProfileEmail: "$profileEmail", BudgetName: "$budgetName"');
    return BudgetEnrollmentDTO(
      id: id,
      userEmail: userEmail,
      profileEmail: profileEmail,
      budgetName: budgetName,
    );
  }

  // Factory para crear desde la estructura agrupada del backend (/budget/enroll/user)
  static List<BudgetEnrollmentDTO> fromBackendGroupedResponse(Map<String, dynamic> json) {
    print('BudgetEnrollmentDTO.fromBackendGroupedResponse: Processing: $json');
    
    final budgetName = json['budgetName'] ?? '';
    final profileName = json['profileName'] ?? '';
    final enrollmentIds = json['budgetEnrollmentIds'] as List<dynamic>? ?? [];
    
    // Crear un DTO por cada ID de enrollment
    return enrollmentIds.map((idValue) {
      final id = _parseId(idValue);
      print('BudgetEnrollmentDTO: Created from grouped - ID: $id, Profile: "$profileName", Budget: "$budgetName"');
      return BudgetEnrollmentDTO(
        id: id,
        userEmail: '', // No disponible en la respuesta agrupada
        profileEmail: profileName,
        budgetName: budgetName,
      );
    }).toList();
  }

  static int _parseId(dynamic value) {
    if (value == null) return 0;
    
    if (value is int) {
      print('BudgetEnrollmentDTO._parseId: Int ID found: $value');
      return value > 0 ? value : 0;
    }
    
    if (value is double) {
      final intValue = value.toInt();
      print('BudgetEnrollmentDTO._parseId: Double ID converted: $intValue');
      return intValue > 0 ? intValue : 0;
    }
    
    if (value is String && value.isNotEmpty) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) {
        print('BudgetEnrollmentDTO._parseId: String ID parsed: $parsed');
        return parsed;
      }
    }
    
    print('BudgetEnrollmentDTO._parseId: WARNING - Could not parse ID from: $value (${value.runtimeType})');
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
