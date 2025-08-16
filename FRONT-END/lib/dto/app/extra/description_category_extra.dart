import '../../../utils/enum/state_enum.dart';

class DescriptionCategory {
  final double assignedBudget;
  final State state;

  DescriptionCategory({
    required this.assignedBudget,
    required this.state,
  });

  factory DescriptionCategory.fromJson(Map<String, dynamic> json) {
    return DescriptionCategory(
      assignedBudget: (json['assignedBudget'] as num).toDouble(),
      state: State.values.firstWhere(
            (e) => e.name == json['state'],
        orElse: () => State.PENDING,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignedBudget': assignedBudget,
      'state': state.name,
    };
  }
}
