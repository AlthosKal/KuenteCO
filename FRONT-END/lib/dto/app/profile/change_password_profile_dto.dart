class ChangePasswordProfileDto {
  final String newPassword;
  final String confirmPassword;

  ChangePasswordProfileDto({
    required this.newPassword,
    required this.confirmPassword,
  }) {
    if (newPassword.isEmpty) {
      throw ArgumentError('La nueva contraseña no puede estar vacía');
    }
    if (confirmPassword.isEmpty) {
      throw ArgumentError('La confirmación de contraseña no puede estar vacía');
    }
    if (newPassword.length < 8) {
      throw ArgumentError('La contraseña debe tener mínimo 8 caracteres');
    }
    if (confirmPassword.length < 8) {
      throw ArgumentError('La confirmación debe tener mínimo 8 caracteres');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  factory ChangePasswordProfileDto.fromJson(Map<String, dynamic> json) {
    return ChangePasswordProfileDto(
      newPassword: json['newPassword'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
    );
  }
}