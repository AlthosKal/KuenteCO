import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../core/services/app/excel_service.dart';
import '../dto/app/excel/debt_excel_validation_result_dto.dart';
import 'dart:typed_data';
import 'dart:convert';

// Import condicional para descarga de archivos
import 'excel_download_stub.dart'
    if (dart.library.html) 'excel_download_web.dart'
    if (dart.library.io) 'excel_download_mobile.dart' as download;

class ExcelController extends ChangeNotifier {
  final ExcelService _excelService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  DebtExcelValidationResultDTO? _validationResult;
  String? _lastDownloadedFile;

  ExcelController(this._excelService);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DebtExcelValidationResultDTO? get validationResult => _validationResult;
  DebtExcelValidationResultDTO? get lastValidationResult => _validationResult;
  String? get lastDownloadedFile => _lastDownloadedFile;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Exportar datos financieros a Excel
  Future<void> exportData() async {
    print('🔄 ExcelController: Iniciando exportación...');
    _setLoading(true);
    
    try {
      final response = await _excelService.exportData();
      
      if (response.data != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = 'finanzas_$timestamp.xlsx';
        
        // Con ResponseType.bytes, los datos deberían ser Uint8List
        Uint8List bytes;
        if (response.data is Uint8List) {
          bytes = response.data!;
        } else if (response.data is List<int>) {
          bytes = Uint8List.fromList(response.data!);
        } else {
          throw Exception('Formato de datos no soportado: ${response.data.runtimeType}. Esperado Uint8List o List<int>');
        }
        
        // Usar descarga multiplataforma
        final filePath = await download.downloadFile(bytes, filename);
        
        _lastDownloadedFile = filePath ?? filename;
        _setSuccess('Datos exportados exitosamente a: $filename');
        print('✅ ExcelController: Exportación completada');
      } else {
        throw Exception('No se recibieron datos del servidor');
      }
    } catch (e) {
      print('❌ ExcelController: Error en exportación: $e');
      _setError('Error al exportar datos: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Importar datos financieros desde archivo Excel
  Future<void> importData(dynamic file) async {
    print('🔄 ExcelController: Iniciando importación...');
    _setLoading(true);
    
    try {
      // Primero validar el archivo
      _validationResult = await _excelService.validateExcelFile(file);
      
      if (!_validationResult!.isValid) {
        _setError('Archivo inválido: ${_validationResult!.errors.join(', ')}');
        return;
      }

      // Si hay advertencias, mostrarlas pero continuar
      if (_validationResult!.warnings.isNotEmpty) {
        print('✅ ï¸ ExcelController: Advertencias: ${_validationResult!.warnings.join(', ')}');
      }

      // Proceder con la importación
      await _excelService.importData(file);
      
      final fileName = file.path?.split('/').last ?? 'archivo';
      _setSuccess('Datos importados exitosamente desde $fileName');
      print('✅ ExcelController: Importación completada');
    } catch (e) {
      print('✅ ExcelController: Error en importación: $e');
      _setError('Error al importar datos: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Validar archivo Excel sin importar
  Future<bool> validateFile(dynamic file) async {
    print('🔄 ExcelController: Validando archivo...');
    _setLoading(true);
    
    try {
      _validationResult = await _excelService.validateExcelFile(file);
      
      if (_validationResult!.isValid) {
        _setSuccess(_validationResult!.summaryMessage);
        print('✅ ExcelController: Validación exitosa');
        return true;
      } else {
        _setError(_validationResult!.summaryMessage);
        print('✅ ExcelController: Validación falló');
        return false;
      }
    } catch (e) {
      print('✅ ExcelController: Error en validación: $e');
      _setError('Error al validar archivo: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Descargar plantilla Excel desde assets
  Future<void> downloadTemplateFromAssets() async {
    print('🔄 ExcelController: Descargando plantilla desde assets...');
    _setLoading(true);
    
    try {
      // Cargar el archivo desde assets
      final byteData = await rootBundle.load('assets/templates/Finanzas.xlsx');
      final bytes = byteData.buffer.asUint8List();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'plantilla_finanzas_$timestamp.xlsx';
      
      // Usar la función de descarga específica de la plataforma
      final result = await download.downloadFile(bytes, filename);
      
      _lastDownloadedFile = result ?? filename;
      _setSuccess('Plantilla descargada: $filename');
      print('✅ ExcelController: Plantilla descargada: $filename');
    } catch (e) {
      print('✅ ExcelController: Error descargando plantilla: $e');
      _setError('Error al descargar plantilla: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Descargar plantilla Excel vacía (método original - desde servidor)
  Future<void> downloadTemplate() async {
    print('🔄 ExcelController: Descargando plantilla...');
    _setLoading(true);
    
    try {
      final response = await _excelService.getExcelTemplate();
      
      if (response.data != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = 'plantilla_finanzas_$timestamp.xlsx';
        
        // Con ResponseType.bytes, los datos deberían ser Uint8List
        Uint8List bytes;
        if (response.data is Uint8List) {
          bytes = response.data!;
        } else if (response.data is List<int>) {
          bytes = Uint8List.fromList(response.data!);
        } else {
          throw Exception('Formato de datos no soportado: ${response.data.runtimeType}. Esperado Uint8List o List<int>');
        }
        
        // Usar descarga multiplataforma
        final filePath = await download.downloadFile(bytes, filename);
        
        _lastDownloadedFile = filePath ?? filename;
        _setSuccess('Plantilla descargada: $filename');
        print('✅ ExcelController: Plantilla descargada');
      } else {
        throw Exception('No se pudo obtener la plantilla del servidor');
      }
    } catch (e) {
      print('✅ ExcelController: Error descargando plantilla: $e');
      _setError('Error al descargar plantilla: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Convertir datos de deudas a formato Excel (para preview)
  List<Map<String, dynamic>> previewExcelData(List<dynamic> debts) {
    try {
      print('🔄 ExcelController: Generando preview de ${debts.length} registros');
      final excelData = _excelService.convertDebtsToExcelFormat(debts);
      print('✅ ExcelController: Preview generado');
      return excelData;
    } catch (e) {
      print('✅ ExcelController: Error generando preview: $e');
      _setError('Error al generar preview: ${e.toString()}');
      return [];
    }
  }

  /// Limpiar datos y mensajes
  void clearData() {
    _errorMessage = null;
    _successMessage = null;
    _validationResult = null;
    _lastDownloadedFile = null;
    notifyListeners();
  }

  /// Obtener resumen de la última validación
  String get validationSummary {
    if (_validationResult == null) return 'No hay validación reciente';
    return _validationResult!.summaryMessage;
  }

  /// Verificar si hay un archivo descargado recientemente
  bool get hasRecentDownload => _lastDownloadedFile != null;

  /// Obtener información del último archivo descargado
  String get downloadInfo {
    if (_lastDownloadedFile == null) return 'No hay descargas recientes';
    final filename = _lastDownloadedFile!.split('/').last;
    return 'Ãltimo archivo: $filename';
  }

  /// Verificar si la última validación tuvo advertencias
  bool get hasValidationWarnings {
    return _validationResult != null && 
           _validationResult!.warnings.isNotEmpty;
  }

  /// Obtener lista de advertencias de validación
  List<String> get validationWarnings {
    return _validationResult?.warnings ?? [];
  }

  /// Verificar si la última validación tuvo errores
  bool get hasValidationErrors {
    return _validationResult != null && 
           _validationResult!.errors.isNotEmpty;
  }

  /// Obtener lista de errores de validación
  List<String> get validationErrors {
    return _validationResult?.errors ?? [];
  }

  /// Alias para exportData (para compatibilidad con ReportView)
  Future<void> exportAllData() async {
    await exportData();
  }

  /// Alias para importData (para compatibilidad con ReportView)
  Future<void> importFromExcel(dynamic file) async {
    await importData(file);
  }

  /// Procesar datos validados (después de una validación exitosa)
  Future<void> processValidatedData() async {
    if (_validationResult == null || !_validationResult!.isValid) {
      throw Exception('No hay datos válidos para procesar');
    }
    // El procesamiento ya se hace en importData, esto es solo un wrapper
    _setSuccess('Datos procesados correctamente');
  }
}