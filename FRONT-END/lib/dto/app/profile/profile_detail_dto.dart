import '../image/image_dto.dart';

class ProfileDetailDTO {
  final int id;
  final String username;
  final String email;
  final ImageDTO? image;

  ProfileDetailDTO({
    required this.username,
    required this.id,
    required this.email,
    required this.image,
  });

  factory ProfileDetailDTO.fromJson(Map<String, dynamic> json) {
    return ProfileDetailDTO(
      id: _parseId(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      image: json['image'] != null ? ImageDTO.fromJson(json['image']) : null,
    );
  }

  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      // Si no se puede parsear, intentar convertir desde double
      final doubleValue = double.tryParse(value);
      if (doubleValue != null) return doubleValue.toInt();
    }
    if (value is double) return value.toInt();
    return 0; // Valor por defecto si no se puede convertir
  }
}