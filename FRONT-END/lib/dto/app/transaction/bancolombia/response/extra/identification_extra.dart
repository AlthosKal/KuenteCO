class Identification {
  final String type;
  final String number;

  Identification({
    required this.type,
    required this.number,
  });

  factory Identification.fromJson(Map<String, dynamic> json) {
    return Identification(
      type: json['type'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'number': number,
    };
  }
}
