class TokenResponseDTO {
  final String token;
  final String role;

  TokenResponseDTO({required this.token, required this.role});

  factory TokenResponseDTO.fromJson(Map<String, dynamic> json) {
    return TokenResponseDTO(token: json['token'], role: json['role']);
  }
}
