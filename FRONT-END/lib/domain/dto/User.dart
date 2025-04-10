class User {
  final String id;
  final String email;
  final String fullName;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.token,
  });

  // Método para crear un User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['fullName'],
      token: json['token'],


    );
  }
}
