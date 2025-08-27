enum State {
  PENDING,
  ACTIVE,
  INACTIVE,
  SUSPENDED,
  CANCELLED
}

extension StateExtension on State {
  String get name {
    return toString().split('.').last;
  }
}