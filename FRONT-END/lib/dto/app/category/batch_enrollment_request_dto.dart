class BatchEnrollmentRequestDTO {
  final int profileId;
  final int categoryId;

  BatchEnrollmentRequestDTO({
    required this.profileId,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'categoryId': categoryId,
    };
  }

  factory BatchEnrollmentRequestDTO.fromJson(Map<String, dynamic> json) {
    return BatchEnrollmentRequestDTO(
      profileId: json['profileId'],
      categoryId: json['categoryId'],
    );
  }
}
