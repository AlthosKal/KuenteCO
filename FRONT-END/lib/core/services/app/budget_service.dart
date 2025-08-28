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

  // ✅ Obtener todos los presupuestos
  Future<List<BudgetDTO>> getBudgets() async {
    print('BudgetService: Sending GET to /budget');
    final response = await _apiClient.getApp('/budget');
    print('BudgetService: Response received: ${response.data}');
    print('BudgetService: Response status: ${response.statusCode}');
    
    // Manejar diferentes estructuras de respuesta
    final data = response.data is List 
        ? response.data 
        : response.data['data'] ?? response.data;
        
    print('BudgetService: Parsed data type: ${data.runtimeType}');
    if (data is List) {
      print('BudgetService: Processing ${data.length} budget items');
      return data.map((json) => BudgetDTO.fromJson(json)).toList();
    } else {
      print('BudgetService: Unexpected data format, returning empty list');
      return [];
    }
  }

  // ✅ Reporte comparación presupuesto vs real
  Future<List<BudgetVsActualDTO>> getBudgetComparison() async {
    final response = await _apiClient.getApp('/budget/report/comparison');
    return (response.data as List)
        .map((json) => BudgetVsActualDTO.fromJson(json))
        .toList();
  }

  // ✅ Reporte resumen presupuestos
  Future<BudgetSummaryDTO> getBudgetSummary() async {
    final response = await _apiClient.getApp('/budget/report/summary');
    return BudgetSummaryDTO.fromJson(response.data);
  }

  // ✅ Obtener enrollments
  Future<List<BudgetEnrollmentDTO>> getEnrollments() async {
    final response = await _apiClient.getApp('/budget/enroll');
    return (response.data as List)
        .map((json) => BudgetEnrollmentDTO.fromJson(json))
        .toList();
  }

  // ✅ Agregar un presupuesto
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

  // ✅ Agregar múltiples presupuestos
  Future<void> addBudgetsBatch(List<NewBudgetDTO> dtos) async {
    final data = dtos.map((e) => e.toJson()).toList();
    await _apiClient.postApp('/budget/batch/add', data);
  }

  // ✅ Actualizar presupuesto individual
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

  // ✅ Actualizar múltiples presupuestos
  Future<void> updateBudgetsBatch(List<UpdateBudgetDTO> dtos) async {
    print('BudgetService: Batch updating ${dtos.length} budgets');
    final data = dtos.map((e) => e.toJson()).toList();
    print('BudgetService: Batch update data: $data');
    final response = await _apiClient.putApp('/budget/batch/update', data);
    print('BudgetService: Batch update response: ${response.data}');
    print('BudgetService: Batch update completed successfully');
  }

  // ✅ Enrolar perfil a presupuesto
  Future<void> enrollProfileToBudget(int profileId, int budgetId) async {
    await _apiClient.postApp('/budget/enroll/add?profileId=$profileId&budgetId=$budgetId', null);
  }

  // ✅ Eliminar un presupuesto por id
  Future<void> deleteBudget(int id) async {
    await _apiClient.deleteApp('/budget/$id');
  }

  // ✅ Eliminar múltiples presupuestos
  Future<void> deleteBudgetsBatch(List<int> ids) async {
    final queryParams = ids.map((id) => 'id=$id').join('&');
    await _apiClient.deleteApp('/budget/batch?$queryParams');
  }

  // ✅ Eliminar enrollment
  Future<void> deleteEnrollment(int id) async {
    await _apiClient.deleteApp('/budget/enroll/$id');
  }

  // ✅ Eliminar múltiples enrollments
  Future<void> deleteEnrollmentsBatch(List<int> ids) async {
    final queryParams = ids.map((id) => 'id=$id').join('&');
    await _apiClient.deleteApp('/budget/enroll/batch?$queryParams');
  }

  // ✅ Enrolar múltiples perfiles a presupuestos
  Future<void> enrollProfileToBudgetBatch(List<Map<String, int>> enrollments) async {
    await _apiClient.postApp('/budget/enroll/add/batch', enrollments);
  }

  // ✅ Obtener enrollments por usuario
  Future<List<BudgetEnrollmentDTO>> getEnrollmentsByUser() async {
    print('BudgetService: Sending GET to /budget/enroll/user');
    final response = await _apiClient.getApp('/budget/enroll/user');
    
    // Log complete response details
    print('BudgetService: === RAW RESPONSE DEBUG ===');
    print('BudgetService: Status Code: ${response.statusCode}');
    print('BudgetService: Headers: ${response.headers}');
    print('BudgetService: Response data: ${response.data}');
    print('BudgetService: Response data type: ${response.data.runtimeType}');
    
    // Check if response.data is Map and log all keys
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      print('BudgetService: Response is Map with keys: ${map.keys.toList()}');
      for (final key in map.keys) {
        print('BudgetService: Map[$key] = ${map[key]} (${map[key].runtimeType})');
      }
    }
    
    // Manejar diferentes estructuras de respuesta del backend
    final data = response.data is Map<String, dynamic> 
        ? response.data['data'] ?? response.data
        : response.data;
        
    print('BudgetService: Extracted data: $data');
    print('BudgetService: Extracted data type: ${data.runtimeType}');
    
    if (data is List) {
      print('BudgetService: Processing ${data.length} user enrollment items');
      // Log each individual item before processing
      for (int i = 0; i < data.length; i++) {
        print('BudgetService: Item[$i] = ${data[i]} (${data[i].runtimeType})');
        if (data[i] is Map<String, dynamic>) {
          final itemMap = data[i] as Map<String, dynamic>;
          print('BudgetService: Item[$i] keys: ${itemMap.keys.toList()}');
          for (final key in itemMap.keys) {
            print('BudgetService: Item[$i][$key] = ${itemMap[key]} (${itemMap[key].runtimeType})');
          }
        }
      }
      return data.map((json) => BudgetEnrollmentDTO.fromJson(json)).toList();
    } else if (data is String) {
      print('BudgetService: Received string response: $data');
      return [];
    } else {
      print('BudgetService: Unexpected data format, returning empty list');
      return [];
    }
  }
}
