import 'package:kuenteco/domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required int id,
    required String name,
    required String description,
    String image = '',
  }) : super(
    id: id,
    name: name,
    description: description,
    image: image,
  );

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
    };
  }
}
