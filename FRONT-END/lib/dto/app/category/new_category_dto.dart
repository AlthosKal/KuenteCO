import '../extra/description_category_extra.dart';

class NewCategoryDTO {
  final int? budgetId;
  final String name;
  final DescriptionCategory description;

  NewCategoryDTO({
    this.budgetId,
    required this.name,
    required this.description,
  });

  factory NewCategoryDTO.fromJson(Map<String, dynamic> json) {
    return NewCategoryDTO(
      budgetId: json['budgetId'],
      name: json['name'],
      description: DescriptionCategory.fromJson(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetId': budgetId,
      'name': name,
      'description': description.toJson(),
    };
  }
}
