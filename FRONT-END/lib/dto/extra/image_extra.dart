class ImageModel {
  final int? id;
  final String name;
  final String imageUrl;
  final String imageId;

  ImageModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.imageId,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? json['url_image'],
      imageId: json['imageId'] ?? json['id_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url_image': imageUrl,
      'id_image': imageId,
    };
  }
}
