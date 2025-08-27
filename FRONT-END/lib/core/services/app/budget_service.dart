import '../../../dto/app/budget/budget_dto.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/budget/budget_summary_dto.dart';
import '../../../dto/app/budget/budget_vs_actual_dto.dart';
import '../../../dto/app/budget/new_budget_dto.dart';
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

  // ✅ Actualizar presupuesto
  Future<BudgetDTO> updateBudget(BudgetDTO dto) async {
    final response = await _apiClient.patchApp('/budget/update', dto.toJson());
    return BudgetDTO.fromJson(response.data);
  }

  // ✅ Actualizar múltiples presupuestos
  Future<void> updateBudgetsBatch(List<BudgetDTO> dtos) async {
    final data = dtos.map((e) => e.toJson()).toList();
    await _apiClient.putApp('/budget/batch/update', data);
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
}
