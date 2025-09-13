class RecaptchaRequestDTO {
  final String token;

  RecaptchaRequestDTO({required this.token});

  factory RecaptchaRequestDTO.fromJson(Map<String, dynamic> json) {
    return RecaptchaRequestDTO(
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}