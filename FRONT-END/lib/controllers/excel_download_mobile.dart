import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Implementación de descarga para móvil/desktop
Future<String?> downloadFile(Uint8List bytes, String filename) async {
  // Solicitar permisos de almacenamiento en Android
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Se requiere permiso de almacenamiento para descargar archivos');
    }
  }

  // Obtener directorio de descargas
  Directory directory;
  
  if (Platform.isAndroid) {
    // En Android, intentar usar el directorio de descargas público
    directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      // Si no existe, usar el directorio de la aplicación
      directory = await getApplicationDocumentsDirectory();
    }
  } else {
    // En otras plataformas, usar el directorio de descargas del usuario
    directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }
  
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  
  final filePath = '${directory.path}/$filename';
  final file = File(filePath);
  await file.writeAsBytes(bytes);
  
  return filePath;
}