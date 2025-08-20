class CategoryEnrollmentDTO {
  final int? id; // Added for deletion support
  final String userEmail;
  final String profileEmail;
  final String categoryName;

  CategoryEnrollmentDTO({
    this.id,
    required this.userEmail,
    required this.profileEmail,
    required this.categoryName,
  });

  factory CategoryEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    return CategoryEnrollmentDTO(
      id: json['id'],
      userEmail: json['userEmail'],
      profileEmail: json['profileEmail'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'profileEmail': profileEmail,
      'categoryName': categoryName,
    };
  }
}
