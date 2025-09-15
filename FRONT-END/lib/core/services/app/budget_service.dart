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
    final response = await _apiClient.getApp('/budget');
    
    // Manejar diferentes estructuras de respuesta
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto
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
        return [];
      }
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacía
      return [];
    }
        
    return dataList.map((json) => BudgetDTO.fromJson(json)).toList();
  }

  // â Reporte comparación presupuesto vs real
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
        return [];
      }
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacía
      return [];
    }
    
    
    return dataList
        .map((e) => BudgetEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â Agregar un presupuesto
  Future<BudgetDTO> addBudget(NewBudgetDTO dto) async {
    final response = await _apiClient.postApp('/budget/add', dto.toJson());
    
    // Manejar diferentes estructuras de respuesta
    final data = response.data is Map<String, dynamic> 
        ? response.data 
        : response.data['data'] ?? response.data;
    
    return BudgetDTO.fromJson(data);
  }

  // â Agregar múltiples presupuestos
  Future<void> addBudgetsBatch(List<NewBudgetDTO> dtos) async {
    final data = dtos.map((e) => e.toJson()).toList();
    await _apiClient.postApp('/budget/batch/add', data);
  }

  // â Actualizar presupuesto individual
  Future<BudgetDTO> updateBudget(UpdateBudgetDTO dto) async {
    final jsonData = dto.toJson();
    final response = await _apiClient.patchApp('/budget/update', jsonData);
    
    // Manejar la estructura de respuesta del backend
    final data = response.data['data'] ?? response.data;
    return BudgetDTO.fromJson(data);
  }

  // â Actualizar múltiples presupuestos
  Future<void> updateBudgetsBatch(List<UpdateBudgetDTO> dtos) async {
    final data = dtos.map((e) => e.toJson()).toList();
    final response = await _apiClient.putApp('/budget/batch/update', data);
  }

  // â Enrolar perfil a presupuesto
  Future<void> enrollProfileToBudget(int profileId, int budgetId) async {
    await _apiClient.postApp('/budget/enroll/add?profileId=$profileId&budgetId=$budgetId', null);
  }

  // â Eliminar un presupuesto por id
  Future<void> deleteBudget(int id) async {
    await _apiClient.deleteApp('/budget/$id');
  }

  // â Eliminar múltiples presupuestos
  Future<void> deleteBudgetsBatch(List<int> ids) async {
    final queryParams = ids.map((id) => 'id=$id').join('&');
    await _apiClient.deleteApp('/budget/batch?$queryParams');
  }

  // â Eliminar enrollment
  Future<void> deleteEnrollment(int id) async {
    await _apiClient.deleteApp('/budget/enroll/$id');
  }

  // â Eliminar múltiples enrollments
  Future<void> deleteEnrollmentsBatch(List<int> ids) async {
    
    if (ids.isEmpty) {
      return;
    }
    
    // Filter out invalid IDs
    final validIds = ids.where((id) => id > 0).toList();
    
    if (validIds.isEmpty) {
      throw Exception('No se encontraron IDs válidos para eliminar');
    }
    
    final queryParams = validIds.map((id) => 'id=$id').join('&');
    final url = '/budget/enroll/batch?$queryParams';
    
    try {
      final response = await _apiClient.deleteApp(url);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
      
    } catch (e) {
      rethrow;
    }
  }

  // â Enrolar múltiples perfiles a presupuestos
  Future<void> enrollProfileToBudgetBatch(List<Map<String, int>> enrollments) async {
    await _apiClient.postApp('/budget/enroll/add/batch', enrollments);
  }

  // â Obtener enrollments por usuario
  Future<List<BudgetEnrollmentDTO>> getEnrollmentsByUser() async {
    final response = await _apiClient.getApp('/budget/enroll/user');
    
    
    // El backend puede retornar un objeto envuelto o directamente la lista
    final responseData = response.data;
    
    if (responseData is String) {
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
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      return [];
    }
    
    
    // Log each item structure to understand backend data
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i] is Map<String, dynamic>) {
        final itemMap = dataList[i] as Map<String, dynamic>;
        
        // Log specific fields we care about
      }
    }
    
    // Convert grouped backend response to individual DTOs
    final List<BudgetEnrollmentDTO> result = [];
    for (final item in dataList) {
      final itemDtos = BudgetEnrollmentDTO.fromBackendGroupedResponse(item as Map<String, dynamic>);
      result.addAll(itemDtos);
    }
    
    return result;
  }
}
