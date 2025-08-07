class ImageDTO {
  final String? name;
  final String? imageUrl;
  final String? imageId;

  ImageDTO({
    this.name,
    this.imageUrl,
    this.imageId,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageId: json['imageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'imageId': imageId,
    };
  }
}
