class CategoryEnrollmentDTO {
  final int? id; // Added for deletion support
  final int? categoryId; // Category ID for creating transactions
  final String userEmail;
  final String profileEmail;
  final String categoryName;
  final int? profileId;
  final String? enrollmentDate;

  CategoryEnrollmentDTO({
    this.id,
    this.categoryId,
    required this.userEmail,
    required this.profileEmail,
    required this.categoryName,
    this.profileId,
    this.enrollmentDate,
  });

  factory CategoryEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    return CategoryEnrollmentDTO(
      id: json['id'],
      categoryId: json['categoryId'],
      userEmail: json['userEmail'],
      profileEmail: json['profileEmail'],
      categoryName: json['categoryName'],
      profileId: json['profileId'],
      enrollmentDate: json['enrollmentDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'userEmail': userEmail,
      'profileEmail': profileEmail,
      'categoryName': categoryName,
      'profileId': profileId,
      'enrollmentDate': enrollmentDate,
    };
  }
}
