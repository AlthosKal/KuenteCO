class Account {
  final int id;
  final String name;
  final String description;
  final String image;

  const Account({
    required this.id,
    required this.name,
    required this.description,
    this.image = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Account &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              description == other.description &&
              image == other.image;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ image.hashCode;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, description: $description, image: $image)';
  }
}
