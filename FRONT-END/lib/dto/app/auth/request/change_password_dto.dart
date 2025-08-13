class ChangePasswordDTO {
  final String email;
  final String code;
  final String newPassword;

  ChangePasswordDTO({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  factory ChangePasswordDTO.fromJson(Map<String, dynamic> json) {
    return ChangePasswordDTO(
      email: json['email'],
      code: json['code'],
      newPassword: json['newPassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'code': code, 'newPassword': newPassword};
  }
}