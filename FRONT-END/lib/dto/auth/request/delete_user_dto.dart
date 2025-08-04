class DeleteUserDTO {
  final String id;

  DeleteUserDTO({required this.id});

  factory DeleteUserDTO.fromJson(Map<String, dynamic> json) {
    return DeleteUserDTO(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
