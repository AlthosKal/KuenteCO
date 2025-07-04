import 'package:kuenteco/utils/enum/user_type_enum.dart';

class UserDetailDTO {
  final String username;
  final String email;
  final String? imageUrl;
  final UserType type;

  UserDetailDTO({
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.type,
  });

  factory UserDetailDTO.fromJson(Map<String, dynamic> json) {
    return UserDetailDTO(
      username: json['username'],
      email: json['email'],
      imageUrl: json['image']?['imageUrl'],
      type: json['type'],

    );
  }
}