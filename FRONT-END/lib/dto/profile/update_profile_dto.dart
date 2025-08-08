import '../image/image_dto.dart';

class UpdateProfileDTO {
  final int id;
  final String username;
  final String email;
  final ImageDTO? image;

  UpdateProfileDTO({
    required this.id,
    required this.username,
    required this.email,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'image': image?.toJson(),
    };
  }
}