import '../auth/response/image_dto.dart';

class ProfileDetailDTO {
  final int id;
  final String username;
  final String email;
  final ImageDTO? image;

  ProfileDetailDTO({
    required this.username,
    required this.id,
    required this.email,
    required this.image,
  });

  factory ProfileDetailDTO.fromJson(Map<String, dynamic> json) {
    return ProfileDetailDTO(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] != null ? ImageDTO.fromJson(json['image']) : null,
      );
  }
}