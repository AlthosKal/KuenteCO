import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../../../dto/app/excel/debt_excel_export_dto.dart';
import '../../../dto/app/excel/debt_excel_import_dto.dart';
import '../../../dto/app/excel/debt_excel_validation_result_dto.dart';
import '../api_client.dart';

class ExcelService {
  final ApiClient _apiClient;

  ExcelService(this._apiClient);

  /// Exportar datos financieros a Excel
  Future<Response> exportData() async {
    print('🔄 ExcelService: Iniciando exportación de datos a Excel...');
    
    try {
      // Configurar para recibir datos binarios
      final response = await _apiClient.getApp(
        '/excel/export',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          },
        ),
      );
      
      print('✅ ExcelService: Exportación completada exitosamente');
      return response;
    } catch (e) {
      print('✅ ExcelService: Error en exportación: $e');
      rethrow;
    }
  }

  /// Importar datos financieros desde archivo Excel
  Future<void> importData(dynamic file) async {
    print('🔄 ExcelService: Iniciando importación desde archivo: ${file is XFile ? file.name : file.path}');
    
    try {
      FormData formData;
      
      if (file is XFile) {
        // Manejar XFile (multiplataforma)
        final bytes = await file.readAsBytes();
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: file.name,
          ),
        });
      } else {
        // Manejar File (legacy)
        String fileName = file.path.split('/').last;
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        });
      }

      final response = await _apiClient.postApp('/excel/import', formData);

      print('✅ ExcelService: Importación completada: ${response.data}');
    } catch (e) {
      print('✅ ExcelService: Error en importación: $e');
      rethrow;
    }
  }

  /// Validar archivo Excel antes de importar
  Future<DebtExcelValidationResultDTO> validateExcelFile(dynamic file) async {
    print('🔄 ExcelService: Validando archivo Excel: ${file is XFile ? file.name : file.path}');
    
    try {
      // Aquí implementaríamos validación local del archivo
      // Por ahora, simulamos una validación básica
      
      String fileName;
      int fileSize;
      
      if (file is XFile) {
        fileName = file.name.toLowerCase();
        fileSize = await file.length();
      } else {
        fileName = file.path.split('/').last.toLowerCase();
        fileSize = await file.length();
      }
      
      List<String> errors = [];
      List<String> warnings = [];
      
      // Validaciones básicas
      if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
        errors.add('El archivo debe ser un Excel (.xlsx o .xls)');
      }
      
      if (fileSize > 10 * 1024 * 1024) { // 10MB
        errors.add('El archivo no puede ser mayor a 10MB');
      }
      
      if (fileSize == 0) {
        errors.add('El archivo está vacío');
      }
      
      if (errors.isNotEmpty) {
        print('✅ ExcelService: Validación falló con ${errors.length} errores');
        return DebtExcelValidationResultDTO.failure(
          errors: errors,
          totalRows: 0,
          validRows: 0,
          warnings: warnings,
        );
      }
      
      print('✅ ExcelService: Validación completada exitosamente');
      return DebtExcelValidationResultDTO.success(
        totalRows: 1, // Placeholder hasta implementar parseo real
        warnings: warnings,
      );
      
    } catch (e) {
      print('✅ ExcelService: Error en validación: $e');
      return DebtExcelValidationResultDTO.failure(
        errors: ['Error al validar archivo: $e'],
        totalRows: 0,
        validRows: 0,
      );
    }
  }

  /// Convertir datos de deudas a formato Excel
  List<Map<String, dynamic>> convertDebtsToExcelFormat(List<dynamic> debts) {
    print('🔄 ExcelService: Convirtiendo ${debts.length} deudas a formato Excel');
    
    try {
      final excelData = debts.map((debt) {
        final excelDebt = DebtExcelExportDTO.fromDebtDTO(debt);
        return excelDebt.toExcelJson();
      }).toList();
      
      print('✅ ExcelService: Conversión completada');
      return excelData;
    } catch (e) {
      print('✅ ExcelService: Error en conversión: $e');
      rethrow;
    }
  }

  /// Convertir datos Excel a DTOs de deudas
  List<DebtExcelImportDTO> convertExcelDataToDebts(List<Map<String, dynamic>> excelData) {
    print('🔄 ExcelService: Convirtiendo ${excelData.length} filas Excel a DTOs');
    
    try {
      final debts = excelData.map((row) {
        return DebtExcelImportDTO.fromExcelRow(row);
      }).toList();
      
      print('✅ ExcelService: Conversión Excel a DTOs completada');
      return debts;
    } catch (e) {
      print('✅ ExcelService: Error en conversión Excel a DTOs: $e');
      rethrow;
    }
  }

  /// Descargar archivo Excel al dispositivo
  Future<String> downloadExcelFile(Uint8List bytes, String filename) async {
    print('🔄 ExcelService: Descargando archivo: $filename');
    
    try {
      // Obtener directorio de descargas usando path_provider
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
      
      print('✅ ExcelService: Archivo descargado en: $filePath');
      return filePath;
    } catch (e) {
      print('✅ ExcelService: Error en descarga: $e');
      rethrow;
    }
  }

  /// Obtener plantilla Excel vacía para importación
  Future<Response> getExcelTemplate() async {
    print('🔄 ExcelService: Obteniendo plantilla Excel...');
    
    try {
      // Por ahora, usamos el mismo endpoint de exportación como plantilla
      // En el futuro, podría haber un endpoint específico para plantillas
      return await exportData();
    } catch (e) {
      print('✅ ExcelService: Error obteniendo plantilla: $e');
      rethrow;
    }
  }
}