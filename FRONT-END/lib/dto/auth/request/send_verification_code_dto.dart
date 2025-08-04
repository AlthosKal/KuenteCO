class SendVerificationCodeDTO {
  final String email;

  SendVerificationCodeDTO({required this.email});

  factory SendVerificationCodeDTO.fromJson(Map<String, dynamic> json) {
    return SendVerificationCodeDTO(email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}