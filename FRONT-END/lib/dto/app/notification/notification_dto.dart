import '../extra/content_notification_extra.dart';

class NotificationDTO {
  final int id;
  final ContentNotification content;
  final DateTime dateSend;

  NotificationDTO({
    required this.id,
    required this.content,
    required this.dateSend,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      id: json['id'],
      content: ContentNotification.fromJson(json['content']),
      dateSend: DateTime.parse(json['dateSend']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content.toJson(),
      'dateSend': dateSend.toIso8601String(),
    };
  }
}
