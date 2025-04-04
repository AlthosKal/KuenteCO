// lib/models/account_model.dart
class Account {
  final int id;
  final String name;
  final String description;
  final String image;

  Account({
    required this.id,
    required this.name,
    required this.description,
    this.image = '',
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'] ?? '',
    );
  }
}