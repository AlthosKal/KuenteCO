class CategoryEnrollmentSummaryDTO {
  final int? categoryId;
  final String? categoryName;
  final String? categoryOwnerId; // Changed from int? to String? for UUID
  final String? ownerUserId; // Changed from int? to String? for UUID
  final int? enrolledUsersCount;
  final int? enrolledProfilesCount;
  final int? totalEnrollments;
  final DateTime? firstEnrollmentDate;
  final DateTime? lastEnrollmentDate;
  final DateTime? categoryStartDate;
  final DateTime? categoryFinishDate;
  final String? categoryStatus;
  final List<int>? categoryEnrollmentIds; // IDs de los enrollments individuales
  final List<EnrolledProfileSummaryDTO>? enrolledProfiles; // Información detallada de cada perfil

  CategoryEnrollmentSummaryDTO({
    this.categoryId,
    this.categoryName,
    this.categoryOwnerId,
    this.ownerUserId,
    this.enrolledUsersCount,
    this.enrolledProfilesCount,
    this.totalEnrollments,
    this.firstEnrollmentDate,
    this.lastEnrollmentDate,
    this.categoryStartDate,
    this.categoryFinishDate,
    this.categoryStatus,
    this.categoryEnrollmentIds,
    this.enrolledProfiles,
  });

  factory CategoryEnrollmentSummaryDTO.fromJson(Map<String, dynamic> json) {
    // Parsear categoryEnrollmentIds que viene como array del backend
    List<int>? enrollmentIds;
    if (json['categoryEnrollmentIds'] != null) {
      enrollmentIds = (json['categoryEnrollmentIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList();
    }
    
    // Crear perfiles básicos usando los IDs disponibles
    List<EnrolledProfileSummaryDTO>? profiles;
    if (enrollmentIds != null && enrollmentIds.isNotEmpty) {
      profiles = enrollmentIds.map((id) {
        return EnrolledProfileSummaryDTO(
          enrollmentId: id,
          profileEmail: 'Perfil #$id',
          profileName: 'Perfil asignado #$id',
          userEmail: 'Usuario propietario',
          enrollmentDate: json['firstEnrollmentDate'] != null
              ? DateTime.parse(json['firstEnrollmentDate'])
              : null,
        );
      }).toList();
    }
    
    return CategoryEnrollmentSummaryDTO(
      categoryName: json['categoryName'],
      categoryOwnerId: json['ownerUserId']?.toString(),
      ownerUserId: json['ownerUserId']?.toString(),
      enrolledProfilesCount: json['totalEnrollments']?.toInt(),
      totalEnrollments: json['totalEnrollments']?.toInt(),
      firstEnrollmentDate: json['firstEnrollmentDate'] != null
          ? DateTime.parse(json['firstEnrollmentDate'])
          : null,
      lastEnrollmentDate: json['lastEnrollmentDate'] != null
          ? DateTime.parse(json['lastEnrollmentDate'])
          : null,
      categoryStartDate: json['categoryRegisterDate'] != null
          ? DateTime.parse(json['categoryRegisterDate'])
          : null,
      categoryStatus: _mapCategoryState(json['categoryState']),
      categoryEnrollmentIds: enrollmentIds,
      enrolledProfiles: profiles,
    );
  }
  
  // Método auxiliar para mapear el estado de la categoría
  static String? _mapCategoryState(dynamic state) {
    if (state == null) return null;
    switch (state.toString().toUpperCase()) {
      case 'ACTIVE':
        return 'ACTIVA';
      case 'INACTIVE':
      case 'CANCELLED':
        return 'FINALIZADA';
      default:
        return state.toString();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryOwnerId': categoryOwnerId,
      'ownerUserId': ownerUserId,
      'enrolledUsersCount': enrolledUsersCount,
      'enrolledProfilesCount': enrolledProfilesCount,
      'totalEnrollments': totalEnrollments,
      'firstEnrollmentDate': firstEnrollmentDate?.toIso8601String(),
      'lastEnrollmentDate': lastEnrollmentDate?.toIso8601String(),
      'categoryStartDate': categoryStartDate?.toIso8601String(),
      'categoryFinishDate': categoryFinishDate?.toIso8601String(),
      'categoryStatus': categoryStatus,
      'categoryEnrollmentIds': categoryEnrollmentIds,
      'enrolledProfiles': enrolledProfiles?.map((e) => e.toJson()).toList(),
    };
  }

  // Método auxiliar para crear desde enrollments existentes
  factory CategoryEnrollmentSummaryDTO.fromSummaryAndEnrollments(
    Map<String, dynamic> summaryJson,
    List<Map<String, dynamic>> enrollmentsJson,
  ) {
    // Filtrar enrollments por categoría
    final categoryName = summaryJson['categoryName'];
    final relevantEnrollments = enrollmentsJson
        .where((e) => e['categoryName'] == categoryName)
        .toList();

    // Crear perfiles basados en los enrollments individuales
    final List<EnrolledProfileSummaryDTO> profiles = relevantEnrollments
        .map((e) => EnrolledProfileSummaryDTO.fromEnrollmentJson(e))
        .toList();

    // Obtener IDs de enrollments
    final List<int> enrollmentIds = relevantEnrollments
        .map((e) => e['id'] as int)
        .toList();

    return CategoryEnrollmentSummaryDTO(
      categoryId: summaryJson['categoryId'],
      categoryName: summaryJson['categoryName'],
      categoryOwnerId: summaryJson['categoryOwnerId'],
      ownerUserId: summaryJson['ownerUserId'],
      enrolledUsersCount: summaryJson['enrolledUsersCount'],
      enrolledProfilesCount: summaryJson['enrolledProfilesCount'],
      totalEnrollments: summaryJson['totalEnrollments'],
      firstEnrollmentDate: summaryJson['firstEnrollmentDate'] != null
          ? DateTime.parse(summaryJson['firstEnrollmentDate'])
          : null,
      lastEnrollmentDate: summaryJson['lastEnrollmentDate'] != null
          ? DateTime.parse(summaryJson['lastEnrollmentDate'])
          : null,
      categoryStartDate: summaryJson['categoryStartDate'] != null
          ? DateTime.parse(summaryJson['categoryStartDate'])
          : null,
      categoryFinishDate: summaryJson['categoryFinishDate'] != null
          ? DateTime.parse(summaryJson['categoryFinishDate'])
          : null,
      categoryStatus: summaryJson['categoryStatus'],
      categoryEnrollmentIds: enrollmentIds,
      enrolledProfiles: profiles,
    );
  }
}

class EnrolledProfileSummaryDTO {
  final int enrollmentId;
  final String profileEmail;
  final String? profileName;
  final String userEmail;
  final DateTime? enrollmentDate;

  EnrolledProfileSummaryDTO({
    required this.enrollmentId,
    required this.profileEmail,
    this.profileName,
    required this.userEmail,
    this.enrollmentDate,
  });

  factory EnrolledProfileSummaryDTO.fromJson(Map<String, dynamic> json) {
    return EnrolledProfileSummaryDTO(
      enrollmentId: json['enrollmentId'],
      profileEmail: json['profileEmail'],
      profileName: json['profileName'],
      userEmail: json['userEmail'],
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'])
          : null,
    );
  }

  factory EnrolledProfileSummaryDTO.fromEnrollmentJson(Map<String, dynamic> json) {
    return EnrolledProfileSummaryDTO(
      enrollmentId: json['id'],
      profileEmail: json['profileEmail'],
      profileName: json['profileName'],
      userEmail: json['userEmail'],
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'profileEmail': profileEmail,
      'profileName': profileName,
      'userEmail': userEmail,
      'enrollmentDate': enrollmentDate?.toIso8601String(),
    };
  }
}
