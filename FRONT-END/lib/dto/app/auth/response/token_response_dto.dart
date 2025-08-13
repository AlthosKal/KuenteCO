class TokenResponseDTO {
  final String token;
  final String type;

  TokenResponseDTO({required this.token, required this.type});

  factory TokenResponseDTO.fromJson(Map<String, dynamic> json) {
    return TokenResponseDTO(token: json['token'], type: json['type']);
  }
}
