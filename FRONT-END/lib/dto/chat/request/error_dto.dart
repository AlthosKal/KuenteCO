/// DTO para manejo de errores en el chat
class ErrorDTO {
  final String description;
  final List<String> reasons;

  ErrorDTO({
    required this.description,
    required this.reasons,
  });

  factory ErrorDTO.fromJson(Map<String, dynamic> json) {
    return ErrorDTO(
      description: json['description'] ?? '',
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'reasons': reasons,
    };
  }

  factory ErrorDTO.single({
    required String description,
    required String reason,
  }) {
    return ErrorDTO(
      description: description,
      reasons: [reason],
    );
  }

  factory ErrorDTO.validation({
    required String field,
    required List<String> validationErrors,
  }) {
    return ErrorDTO(
      description: 'Error de validación en el campo: $field',
      reasons: validationErrors,
    );
  }
}