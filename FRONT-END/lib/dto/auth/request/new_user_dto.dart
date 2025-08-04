

import '../../../utils/enum/user_type_enum.dart';

class NewUserDTO {
  final String username;
  final String email;
  final String password;
  final UserType type;

  NewUserDTO({
    required this.username,
    required this.email,
    required this.password,
    required this.type,
  });

  factory NewUserDTO.fromJson(Map<String, dynamic> json) {
    return NewUserDTO(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      type:json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'password': password, 'type':type.name,};
  }
}