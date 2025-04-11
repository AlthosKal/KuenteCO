class SubscriptionPlan {
  final String title;
  final String description;
  final List<String> features;
  final String price;
  final bool isAcquired;

  const SubscriptionPlan({
    required this.title,
    required this.description,
    required this.features,
    required this.price,
    this.isAcquired = false,
  });
}