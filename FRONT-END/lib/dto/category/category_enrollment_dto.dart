class CategoryEnrollmentDTO {
  final String userEmail;
  final String profileEmail;
  final String categoryName;

  CategoryEnrollmentDTO({
    required this.userEmail,
    required this.profileEmail,
    required this.categoryName,
  });

  factory CategoryEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    return CategoryEnrollmentDTO(
      userEmail: json['userEmail'],
      profileEmail: json['profileEmail'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'profileEmail': profileEmail,
      'categoryName': categoryName,
    };
  }
}
