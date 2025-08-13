import '../image/image_dto.dart';

class UpdateProfileDTO {
  final int id;
  final String username;
  final String email;
  final ImageDTO? image;
  final bool removeImage;

  UpdateProfileDTO({
    required this.id,
    required this.username,
    required this.email,
    this.image,
    required this.removeImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'removeImage': removeImage,
    };
  }
}