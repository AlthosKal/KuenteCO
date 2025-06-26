class ValidateVerificationCodeDTO {
  final String email;
  final String code;

  ValidateVerificationCodeDTO({required this.email, required this.code});

  factory ValidateVerificationCodeDTO.fromJson(Map<String, dynamic> json) {
    return ValidateVerificationCodeDTO(
      email: json['email'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'code': code};
  }
}