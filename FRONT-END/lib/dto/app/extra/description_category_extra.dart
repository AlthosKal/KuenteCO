import '../../../utils/enum/state_enum.dart' as state_enum;

class DescriptionCategory {
  final double assignedBudget;
  final state_enum.State state;

  DescriptionCategory({
    required this.assignedBudget,
    required this.state,
  });

  factory DescriptionCategory.fromJson(Map<String, dynamic> json) {
    try {
      final assignedBudget = json['assignedBudget'];
      final state = json['state'];
      
      return DescriptionCategory(
        assignedBudget: assignedBudget != null 
            ? (assignedBudget is num 
                ? assignedBudget.toDouble() 
                : double.parse(assignedBudget.toString()))
            : 0.0,
        state: state != null 
            ? state_enum.State.values.firstWhere(
                (e) => e.name.toString() == state.toString(),
                orElse: () => state_enum.State.PENDING,
              )
            : state_enum.State.PENDING,
      );
    } catch (e) {
      throw Exception('Error parsing DescriptionCategory from JSON: $json. Error: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'assignedBudget': assignedBudget,
      'state': state.name,
    };
  }
}
