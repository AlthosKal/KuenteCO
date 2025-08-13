class CategoryEnrollmentSummaryDTO {
  final int? categoryId;
  final String? categoryName;
  final int? categoryOwnerId;
  final int? ownerUserId;
  final int? enrolledUsersCount;
  final int? enrolledProfilesCount;
  final int? totalEnrollments;
  final DateTime? firstEnrollmentDate;
  final DateTime? lastEnrollmentDate;
  final DateTime? categoryStartDate;
  final DateTime? categoryFinishDate;
  final String? categoryStatus;

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
  });

  factory CategoryEnrollmentSummaryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryEnrollmentSummaryDTO(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      categoryOwnerId: json['categoryOwnerId'],
      ownerUserId: json['ownerUserId'],
      enrolledUsersCount: json['enrolledUsersCount'],
      enrolledProfilesCount: json['enrolledProfilesCount'],
      totalEnrollments: json['totalEnrollments'],
      firstEnrollmentDate: json['firstEnrollmentDate'] != null
          ? DateTime.parse(json['firstEnrollmentDate'])
          : null,
      lastEnrollmentDate: json['lastEnrollmentDate'] != null
          ? DateTime.parse(json['lastEnrollmentDate'])
          : null,
      categoryStartDate: json['categoryStartDate'] != null
          ? DateTime.parse(json['categoryStartDate'])
          : null,
      categoryFinishDate: json['categoryFinishDate'] != null
          ? DateTime.parse(json['categoryFinishDate'])
          : null,
      categoryStatus: json['categoryStatus'],
    );
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
    };
  }
}
