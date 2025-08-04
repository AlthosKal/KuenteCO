class ImageDTO {
  final String name;
  final String imageUrl;
  final String imageId;

  ImageDTO({required this.name, required this.imageUrl, required this.imageId});

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      name: json['name'],
      imageUrl: json['imageUrl'],
      imageId: json['imageId'],
    );
  }
}