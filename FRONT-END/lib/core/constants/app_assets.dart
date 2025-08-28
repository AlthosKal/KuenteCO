abstract final class AppAssets {
  // Prevent instantiation
  const AppAssets._();

  // Image paths
  static const String _imagePath = 'assets/img';
  
  static const String background = '$_imagePath/Background.png';
  static const String brand = '$_imagePath/Brand.jpeg';
  static const String logo = '$_imagePath/Logo.png';
  static const String logo1 = '$_imagePath/Logo 1.png';
  static const String logo2 = '$_imagePath/Logo 2.png';

  // All image assets list for preloading
  static const List<String> allImages = [
    background,
    brand,
    logo,
    logo1,
    logo2,
  ];
}