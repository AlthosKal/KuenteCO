class CategoryEnrollmentDTO {
  final int? id; // Added for deletion support
  final int? categoryId; // Category ID for creating transactions
  final String userEmail;
  final String profileEmail;
  final String categoryName;

  CategoryEnrollmentDTO({
    this.id,
    this.categoryId,
    required this.userEmail,
    required this.profileEmail,
    required this.categoryName,
  });

  factory CategoryEnrollmentDTO.fromJson(Map<String, dynamic> json) {
    return CategoryEnrollmentDTO(
      id: json['id'],
      categoryId: json['categoryId'],
      userEmail: json['userEmail'],
      profileEmail: json['profileEmail'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'userEmail': userEmail,
      'profileEmail': profileEmail,
      'categoryName': categoryName,
    };
  }
}
