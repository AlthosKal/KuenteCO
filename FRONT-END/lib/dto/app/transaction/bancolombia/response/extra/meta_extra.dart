class Meta {
  final String messageId;
  final String requestDateTime;
  final String applicationId;

  Meta({
    required this.messageId,
    required this.requestDateTime,
    required this.applicationId,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      messageId: json['_messageId'],
      requestDateTime: json['_requestDateTime'],
      applicationId: json['_applicationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_messageId': messageId,
      '_requestDateTime': requestDateTime,
      '_applicationId': applicationId,
    };
  }
}
