class UpdateCategoryDTO {
  final int id;
  final String name;
  final double assignedBudget;
  final String state;
  final int? budgetId;

  UpdateCategoryDTO({
    required this.id,
    required this.name,
    required this.assignedBudget,
    required this.state,
    this.budgetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assignedBudget': assignedBudget,
      'state': state,
      if (budgetId != null) 'budgetId': budgetId,
    };
  }

  factory UpdateCategoryDTO.fromJson(Map<String, dynamic> json) {
    return UpdateCategoryDTO(
      id: json['id'],
      name: json['name'],
      assignedBudget: json['assignedBudget']?.toDouble() ?? 0.0,
      state: json['state'],
      budgetId: json['budgetId'],
    );
  }

  // Método de conveniencia para crear desde CategoryDTO
  factory UpdateCategoryDTO.fromCategoryDTO(dynamic categoryDto) {
    return UpdateCategoryDTO(
      id: categoryDto.id,
      name: categoryDto.name,
      assignedBudget: categoryDto.description.assignedBudget,
      state: categoryDto.description.state.name,
      budgetId: categoryDto.budgetId,
    );
  }
}
