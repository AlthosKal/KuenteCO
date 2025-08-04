import '../extra/description_category_extra.dart';

class CategoryDTO {
  final int id;
  final int budgetId;
  final DescriptionCategory description;
  final DateTime? startDate;
  final DateTime? finishDate;

  CategoryDTO({
    required this.id,
    required this.budgetId,
    required this.description,
    this.startDate,
    this.finishDate,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'],
      budgetId: json['budgetId'],
      description: DescriptionCategory.fromJson(json['description']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      finishDate: json['finishDate'] != null ? DateTime.parse(json['finishDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'description': description.toJson(),
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
    };
  }
}
