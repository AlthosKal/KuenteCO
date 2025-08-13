import '../extra/description_category_extra.dart';

class NewCategoryDTO {
  final int? budgetId;
  final DescriptionCategory description;
  final DateTime startDate;
  final DateTime finishDate;

  NewCategoryDTO({
    this.budgetId,
    required this.description,
    required this.startDate,
    required this.finishDate,
  });

  factory NewCategoryDTO.fromJson(Map<String, dynamic> json) {
    return NewCategoryDTO(
      budgetId: json['budgetId'],
      description: DescriptionCategory.fromJson(json['description']),
      startDate: DateTime.parse(json['startDate']),
      finishDate: DateTime.parse(json['finishDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetId': budgetId,
      'description': description.toJson(),
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
    };
  }
}
