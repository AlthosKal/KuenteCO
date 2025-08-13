class TokenResponseDTO {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String scope;
  final String refreshToken;

  TokenResponseDTO({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.scope,
    required this.refreshToken,
  });

  factory TokenResponseDTO.fromJson(Map<String, dynamic> json) {
    return TokenResponseDTO(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      scope: json['scope'] ?? '',
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'scope': scope,
      'refresh_token': refreshToken,
    };
  }
}
