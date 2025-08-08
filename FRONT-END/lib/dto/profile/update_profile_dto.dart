

import '../image/image_dto.dart';

class UpdateProfileDTO {
  final int id;
  final String username;
  final String email;
  final String? password;
  final ImageDTO? image;

  UpdateProfileDTO({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'image': image?.toJson(),
    };
  }
}