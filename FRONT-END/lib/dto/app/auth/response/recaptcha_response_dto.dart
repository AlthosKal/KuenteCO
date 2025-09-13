class RecaptchaResponseDTO {
  final bool success;
  final String? challengeTs;
  final String? hostname;
  final List<String>? errorCodes;

  RecaptchaResponseDTO({
    required this.success,
    this.challengeTs,
    this.hostname,
    this.errorCodes,
  });

  factory RecaptchaResponseDTO.fromJson(Map<String, dynamic> json) {
    return RecaptchaResponseDTO(
      success: json['success'] ?? false,
      challengeTs: json['challenge_ts'],
      hostname: json['hostname'],
      errorCodes: json['error-codes'] != null 
          ? List<String>.from(json['error-codes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'challenge_ts': challengeTs,
      'hostname': hostname,
      'error-codes': errorCodes,
    };
  }
}