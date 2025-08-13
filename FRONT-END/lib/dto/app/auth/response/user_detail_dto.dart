import '../../image/image_dto.dart';

class UserDetailDTO {
  final int? version;
  final ImageDTO? image;
  final String username;
  final String email;
  final String userType;
  final String subscriptionType;
  final String state;

  UserDetailDTO({
    this.version,
    this.image,
    required this.username,
    required this.email,
    required this.userType,
    required this.subscriptionType,
    required this.state,
  });

  factory UserDetailDTO.fromJson(Map<String, dynamic> json) {
    return UserDetailDTO(
      version: json['version'],
      image: json['image'] != null ? ImageDTO.fromJson(json['image']) : null,
      username: json['username'],
      email: json['email'],
      userType: json['userType'],
      subscriptionType: json['subscriptionType'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'image': image?.toJson(),
      'username': username,
      'email': email,
      'userType': userType,
      'subscriptionType': subscriptionType,
      'state': state,
    };
  }
}