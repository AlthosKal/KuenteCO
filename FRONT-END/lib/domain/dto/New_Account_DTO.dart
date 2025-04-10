enum AccountType {
  PERSONAL,
  BUSINESS,
  SAVINGS,
  // Agrega más si están en el enum de backend
}

class NewAccountDTO {
  final String name;
  final AccountType type;

  NewAccountDTO({
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name, // Enviamos como String
    };
  }
}
