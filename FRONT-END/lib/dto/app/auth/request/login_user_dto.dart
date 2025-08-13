class LoginUserDTO {
  final String nameOrEmail;
  final String password;

  LoginUserDTO({required this.nameOrEmail, required this.password});

  factory LoginUserDTO.fromJson(Map<String, dynamic> json) {
    return LoginUserDTO(
      nameOrEmail: json['nameOrEmail'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nameOrEmail': nameOrEmail, 'password': password};
  }
}