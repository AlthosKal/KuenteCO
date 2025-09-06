import '../../../dto/app/budget/budget_dto.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/budget/budget_summary_dto.dart';
import '../../../dto/app/budget/budget_vs_actual_dto.dart';
import '../../../dto/app/budget/new_budget_dto.dart';
import '../../../dto/app/budget/update_budget_dto.dart';
import '../api_client.dart';

class BudgetService {
  final ApiClient _apiClient;

  BudgetService(this._apiClient);

  // â Obtener todos los presupuestos
  Future<List<BudgetDTO>> getBudgets() async {
    print('BudgetService: Sending GET to /budget');
    final response = await _apiClient.getApp('/budget');
    print('BudgetService: Response received: ${response.data}');
    print('BudgetService: Response status: ${response.statusCode}');
    
    // Manejar diferentes estructuras de respuesta
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto
      print('BudgetService: Response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Si viene envuelto en un objeto con key 'data'
      final dataValue = responseData['data'];
      
      if (dataValue is String) {
        // Si el campo 'data' contiene un mensaje de texto
        return [];
      } else if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        print('BudgetService: Data field has unknown format, returning empty list');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      print('BudgetService: Response is direct list');
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacÃ­a
      print('BudgetService: Unknown response format, returning empty list');
      return [];
    }
        
    print('BudgetService: Parsed data type: ${dataList.runtimeType}');
    print('BudgetService: Processing ${dataList.length} budget items');
    return dataList.map((json) => BudgetDTO.fromJson(json)).toList();
  }

  // â Reporte comparaciÃ³n presupuesto vs real
  Future<List<BudgetVsActualDTO>> getBudgetComparison() async {
    final response = await _apiClient.getApp('/budget/report/comparison');
    return (response.data as List)
        .map((json) => BudgetVsActualDTO.fromJson(json))
        .toList();
  }

  // â Reporte resumen presupuestos
  Future<BudgetSummaryDTO> getBudgetSummary() async {
    final response = await _apiClient.getApp('/budget/report/summary');
    return BudgetSummaryDTO.fromJson(response.data);
  }

  // â Obtener enrollments
  Future<List<BudgetEnrollmentDTO>> getEnrollments() async {
    final response = await _apiClient.getApp('/budget/enroll');
    
    // El backend puede retornar un objeto envuelto con la estructura:
    // { "data": [...] } o directamente la lista, o un mensaje
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto (ej: "No tienes presupuestos asignados")
      print('BudgetService: Response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Si viene envuelto en un objeto con key 'data'
      final dataValue = responseData['data'];
      
      if (dataValue is String) {
        // Si el campo 'data' contiene un mensaje de texto
        return [];
      } else if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        print('BudgetService: Data field has unknown format, returning empty list');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      print('BudgetService: Response is direct list');
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacÃ­a
      print('BudgetService: Unknown response format, returning empty list');
      return [];
    }
    
    
    return dataList
        .map((e) => BudgetEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â Agregar un presupuesto
  Future<BudgetDTO> addBudget(NewBudgetDTO dto) async {
    print('BudgetService: Sending POST to /budget/add with data: ${dto.toJson()}');
    final response = await _apiClient.postApp('/budget/add', dto.toJson());
    print('BudgetService: Response received: ${response.data}');
    print('BudgetService: Response status: ${response.statusCode}');
    
    // Manejar diferentes estructuras de respuesta
    final data = response.data is Map<String, dynamic> 
        ? response.data 
        : response.data['data'] ?? response.data;
    
    print('BudgetService: Parsed data for BudgetDTO: $data');
    return BudgetDTO.fromJson(data);
  }

  // â Agregar mÃºltiples presupuestos
  Future<void> addBudgetsBatch(List<NewBudgetDTO> dtos) async {
    final data = dtos.map((e) => e.toJson()).toList();
    await _apiClient.postApp('/budget/batch/add', data);
  }

  // â Actualizar presupuesto individual
  Future<BudgetDTO> updateBudget(UpdateBudgetDTO dto) async {
    print('BudgetService: Updating budget with data: ${dto.toJson()}');
    final jsonData = dto.toJson();
    print('BudgetService: Serialized JSON: $jsonData');
    print('BudgetService: About to call patchApp...');
    final response = await _apiClient.patchApp('/budget/update', jsonData);
    print('BudgetService: patchApp completed, processing response...');
    print('BudgetService: Update response: ${response.data}');
    
    // Manejar la estructura de respuesta del backend
    final data = response.data['data'] ?? response.data;
    print('BudgetService: Extracted data for BudgetDTO: $data');
    return BudgetDTO.fromJson(data);
  }

  // â Actualizar mÃºltiples presupuestos
  Future<void> updateBudgetsBatch(List<UpdateBudgetDTO> dtos) async {
    print('BudgetService: Batch updating ${dtos.length} budgets');
    final data = dtos.map((e) => e.toJson()).toList();
    print('BudgetService: Batch update data: $data');
    final response = await _apiClient.putApp('/budget/batch/update', data);
    print('BudgetService: Batch update response: ${response.data}');
    print('BudgetService: Batch update completed successfully');
  }

  // â Enrolar perfil a presupuesto
  Future<void> enrollProfileToBudget(int profileId, int budgetId) async {
    await _apiClient.postApp('/budget/enroll/add?profileId=$profileId&budgetId=$budgetId', null);
  }

  // â Eliminar un presupuesto por id
  Future<void> deleteBudget(int id) async {
    await _apiClient.deleteApp('/budget/$id');
  }

  // â Eliminar mÃºltiples presupuestos
  Future<void> deleteBudgetsBatch(List<int> ids) async {
    final queryParams = ids.map((id) => 'id=$id').join('&');
    await _apiClient.deleteApp('/budget/batch?$queryParams');
  }

  // â Eliminar enrollment
  Future<void> deleteEnrollment(int id) async {
    await _apiClient.deleteApp('/budget/enroll/$id');
  }

  // â Eliminar mÃºltiples enrollments
  Future<void> deleteEnrollmentsBatch(List<int> ids) async {
    print('BudgetService: deleteEnrollmentsBatch called with IDs: $ids');
    
    if (ids.isEmpty) {
      print('BudgetService: No IDs provided for deletion');
      return;
    }
    
    // Filter out invalid IDs
    final validIds = ids.where((id) => id > 0).toList();
    print('BudgetService: Valid IDs after filtering: $validIds');
    
    if (validIds.isEmpty) {
      print('BudgetService: No valid IDs found after filtering');
      throw Exception('No se encontraron IDs vÃ¡lidos para eliminar');
    }
    
    final queryParams = validIds.map((id) => 'id=$id').join('&');
    final url = '/budget/enroll/batch?$queryParams';
    print('BudgetService: Making DELETE request to: $url');
    
    try {
      final response = await _apiClient.deleteApp(url);
      print('BudgetService: Delete response status: ${response.statusCode}');
      print('BudgetService: Delete response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
      
      print('BudgetService: Batch deletion completed successfully');
    } catch (e) {
      print('BudgetService: Error during batch deletion: $e');
      rethrow;
    }
  }

  // â Enrolar mÃºltiples perfiles a presupuestos
  Future<void> enrollProfileToBudgetBatch(List<Map<String, int>> enrollments) async {
    await _apiClient.postApp('/budget/enroll/add/batch', enrollments);
  }

  // â Obtener enrollments por usuario
  Future<List<BudgetEnrollmentDTO>> getEnrollmentsByUser() async {
    print('BudgetService: Sending GET to /budget/enroll/user');
    final response = await _apiClient.getApp('/budget/enroll/user');
    
    print('BudgetService: Raw response data type: ${response.data.runtimeType}');
    print('BudgetService: Raw response data: ${response.data}');
    
    // El backend puede retornar un objeto envuelto o directamente la lista
    final responseData = response.data;
    
    if (responseData is String) {
      print('BudgetService: Response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      
      if (dataValue is String) {
        return [];
      } else if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        print('BudgetService: Data field has unknown format, returning empty list');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      print('BudgetService: Response is direct list');
      dataList = responseData;
    } else {
      print('BudgetService: Unknown response format, returning empty list');
      return [];
    }
    
    
    // Log each item structure to understand backend data
    for (int i = 0; i < dataList.length; i++) {
      print('BudgetService: Processing item $i: ${dataList[i]}');
      if (dataList[i] is Map<String, dynamic>) {
        final itemMap = dataList[i] as Map<String, dynamic>;
        print('BudgetService: Item $i keys: ${itemMap.keys.toList()}');
        
        // Log specific fields we care about
        print('BudgetService: Item $i id field: ${itemMap['id']} (${itemMap['id'].runtimeType})');
        print('BudgetService: Item $i profileEmail field: ${itemMap['profileEmail']} (${itemMap['profileEmail'].runtimeType})');
        print('BudgetService: Item $i userEmail field: ${itemMap['userEmail']} (${itemMap['userEmail'].runtimeType})');
        print('BudgetService: Item $i budgetName field: ${itemMap['budgetName']} (${itemMap['budgetName'].runtimeType})');
      }
    }
    
    // Convert grouped backend response to individual DTOs
    List<BudgetEnrollmentDTO> result = [];
    for (final item in dataList) {
      final itemDtos = BudgetEnrollmentDTO.fromBackendGroupedResponse(item as Map<String, dynamic>);
      result.addAll(itemDtos);
    }
    
    print('BudgetService: Converted to ${result.length} individual DTOs');
    return result;
  }
}
