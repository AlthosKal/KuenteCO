import '../extra/description_category_extra.dart';

class CategoryDTO {
  final int id;
  final int? budgetId;
  final String name;
  final DescriptionCategory description;
  final DateTime registerDate;

  CategoryDTO({
    required this.id,
    this.budgetId,
    required this.name,
    required this.description,
    required this.registerDate,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'],
      budgetId: json['budgetId'],
      name: json['name'],
      description: DescriptionCategory.fromJson(json['description']),
      registerDate: DateTime.parse(json['registerDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'name': name,
      'description': description.toJson(),
    };
  }
}
