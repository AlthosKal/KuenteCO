import '../../../utils/enum/state_enum.dart';

class DescriptionCategory {
  final String name;
  final double assignedBudget;
  final State state;

  DescriptionCategory({
    required this.name,
    required this.assignedBudget,
    required this.state,
  });

  factory DescriptionCategory.fromJson(Map<String, dynamic> json) {
    return DescriptionCategory(
      name: json['name'],
      assignedBudget: (json['assignedBudget'] as num).toDouble(),
      state: State.values.firstWhere(
            (e) => e.name == json['state'],
        orElse: () => State.PENDING,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'assignedBudget': assignedBudget,
      'state': state.name,
    };
  }
}
