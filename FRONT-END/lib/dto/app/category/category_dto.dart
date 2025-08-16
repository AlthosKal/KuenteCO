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
    try {
      final id = json['id'];
      if (id == null) {
        throw Exception('CategoryDTO: id field is null in JSON: $json');
      }
      
      return CategoryDTO(
        id: id is int ? id : int.parse(id.toString()),
        budgetId: json['budgetId'] != null 
            ? (json['budgetId'] is int 
                ? json['budgetId'] as int 
                : int.parse(json['budgetId'].toString()))
            : null,
        name: json['name']?.toString() ?? '',
        description: DescriptionCategory.fromJson(json['description'] ?? {}),
        registerDate: DateTime.parse(json['registerDate']?.toString() ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      throw Exception('Error parsing CategoryDTO from JSON: $json. Error: $e');
    }
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
