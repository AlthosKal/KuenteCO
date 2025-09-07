class DebtEnrollmentDTO {
  final int? enrollmentId; // ID del enrollment para eliminación
  final String userEmail;
  final String profileEmail;
  final int? debtId;
  final String debtName;

  const DebtEnrollmentDTO({
    this.enrollmentId,
    required this.userEmail,
    required this.profileEmail,
    this.debtId,
    required this.debtName,
  });

  Map<String, dynamic> toJson() => {
        'enrollmentId': enrollmentId,
        'userEmail': userEmail,
        'profileEmail': profileEmail,
        'debtId': debtId,
        'debtName': debtName,
      };

  factory DebtEnrollmentDTO.fromJson(Map<String, dynamic> json) =>
      DebtEnrollmentDTO(
        enrollmentId: json['enrollmentId'] as int? ?? json['id'] as int?, // Backend puede enviar como 'id'
        userEmail: json['userEmail'] as String,
        profileEmail: json['profileEmail'] as String,
        debtId: json['debtId'] as int?,
        debtName: json['debtName'] as String,
      );

  DebtEnrollmentDTO copyWith({
    int? enrollmentId,
    String? userEmail,
    String? profileEmail,
    int? debtId,
    String? debtName,
  }) =>
      DebtEnrollmentDTO(
        enrollmentId: enrollmentId ?? this.enrollmentId,
        userEmail: userEmail ?? this.userEmail,
        profileEmail: profileEmail ?? this.profileEmail,
        debtId: debtId ?? this.debtId,
        debtName: debtName ?? this.debtName,
      );

  @override
  String toString() => 'DebtEnrollmentDTO(enrollmentId: $enrollmentId, userEmail: $userEmail, profileEmail: $profileEmail, debtId: $debtId, debtName: $debtName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DebtEnrollmentDTO &&
        other.enrollmentId == enrollmentId &&
        other.userEmail == userEmail &&
        other.profileEmail == profileEmail &&
        other.debtId == debtId &&
        other.debtName == debtName;
  }

  @override
  int get hashCode => enrollmentId.hashCode ^ userEmail.hashCode ^ profileEmail.hashCode ^ debtId.hashCode ^ debtName.hashCode;
}