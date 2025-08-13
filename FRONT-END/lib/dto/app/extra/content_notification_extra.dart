class ContentNotification {
  final String title;
  final String body;
  final String date;

  ContentNotification({
    required this.title,
    required this.body,
    required this.date,
  });

  factory ContentNotification.fromJson(Map<String, dynamic> json) {
    return ContentNotification(
      title: json['title'],
      body: json['body'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title':title,
      'body': body,
      'date': date,
    };
  }
}
