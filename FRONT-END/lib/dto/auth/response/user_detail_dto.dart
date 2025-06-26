class UserDetailDTO {
  final String id;
  final String username;
  final String email;

  UserDetailDTO({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserDetailDTO.fromJson(Map<String, dynamic> json) {
    return UserDetailDTO(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}