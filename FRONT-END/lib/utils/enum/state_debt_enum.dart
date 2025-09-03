enum StateDebt {
  ACTIVE,
  PAID,
  DEFEATED,
  REFINANCED,
  IN_MORATIUM,
  CANCELLED;

  static StateDebt fromString(String value) {
    return StateDebt.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => StateDebt.ACTIVE,
    );
  }

  String toJson() => name;
  
  @override
  String toString() => name;
}