class NewUserDTO {
  final String username;
  final String email;
  final String password;

  NewUserDTO({
    required this.username,
    required this.email,
    required this.password,
  });

  factory NewUserDTO.fromJson(Map<String, dynamic> json) {
    return NewUserDTO(
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'password': password};
  }
}