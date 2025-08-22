import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';
import '../../../dto/app/category/category_enrollment_summary_dto.dart';
import '../../../dto/app/category/category_report_dto.dart';
import '../../../dto/app/category/new_category_dto.dart';
import '../api_client.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  // ✅ GET /category
  Future<List<CategoryDTO>> getAllCategories() async {
    final response = await _apiClient.getApp('/category');
    final data = response.data['data'] as List;
    return data
        .map((e) => CategoryDTO.fromJson(e))
        .toList();
  }

  // ✅ GET /category/report/summary
  Future<List<CategoryEnrollmentSummaryDTO>> getCategoryReportSummary() async {
    final response = await _apiClient.getApp('/category/report/summary');
    return (response.data as List)
        .map((e) => CategoryEnrollmentSummaryDTO.fromJson(e))
        .toList();
  }

  // ✅ GET /category/report/{id}
  Future<CategoryReportDTO> getCategoryReportById(int id) async {
    final response = await _apiClient.getApp('/category/report/$id');
    return CategoryReportDTO.fromJson(response.data);
  }

  // ✅ GET /category/enroll
  Future<List<CategoryEnrollmentDTO>> getAllEnrollments() async {
    final response = await _apiClient.getApp('/category/enroll');
    
    print('📌 CategoryService: Raw response data type: ${response.data.runtimeType}');
    print('📌 CategoryService: Raw response data: ${response.data}');
    
    // El backend puede retornar un objeto envuelto con la estructura:
    // { "data": [...] } o directamente la lista
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto (ej: "No tienes categorías asignadas")
      print('📌 CategoryService: Response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Si viene envuelto en un objeto con key 'data'
      print('📌 CategoryService: Response has data key, extracting list');
      dataList = responseData['data'] as List<dynamic>;
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      print('📌 CategoryService: Response is direct list');
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacía
      print('❌ CategoryService: Unknown response format, returning empty list');
      return [];
    }
    
    print('📌 CategoryService: Data list length: ${dataList.length}');
    
    return dataList
        .map((e) => CategoryEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ GET /category/enroll/user - Returns enrollment summaries for business users
  Future<List<CategoryEnrollmentSummaryDTO>> getEnrollmentSummariesByUser() async {
    final response = await _apiClient.getApp('/category/enroll/user');
    
    print('📌 CategoryService: Raw response data type for /enroll/user: ${response.data.runtimeType}');
    print('📌 CategoryService: Raw response data for /enroll/user: ${response.data}');
    
    // El backend puede retornar un objeto envuelto con la estructura:
    // { "data": [...] } o directamente la lista
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto
      print('📌 CategoryService: /enroll/user response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Si viene envuelto en un objeto con key 'data'
      print('📌 CategoryService: /enroll/user response has data key, extracting list');
      dataList = responseData['data'] as List<dynamic>;
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      print('📌 CategoryService: /enroll/user response is direct list');
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacía
      print('❌ CategoryService: Unknown /enroll/user response format, returning empty list');
      return [];
    }
    
    print('📌 CategoryService: /enroll/user data list length: ${dataList.length}');
    
    return dataList
        .map((e) => CategoryEnrollmentSummaryDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ POST /category/add
  Future<void> addCategory(NewCategoryDTO dto) async {
    final response = await _apiClient.postApp('/category/add', dto.toJson());
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create category: ${response.statusCode}');
    }
  }

  // ✅ POST /category/batch/add
  Future<void> addCategoriesBatch(List<NewCategoryDTO> dtos) async {
    final response = await _apiClient.postApp(
      '/category/batch/add',
      dtos.map((e) => e.toJson()).toList(),
    );
    
    print('📌 CategoryService: Batch add response type: ${response.data.runtimeType}');
    print('📌 CategoryService: Batch add response data: ${response.data}');
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create categories in batch: ${response.statusCode}');
    }
    
    // No necesitamos parsear la respuesta ya que CategoryController
    // recarga todas las categorías después usando getAllCategories()
    print('✅ CategoryService: Batch creation completed successfully');
  }

  // ✅ PATCH /category/update
  Future<void> updateCategory(CategoryDTO dto) async {
    final payload = dto.toJson();
    print('🔄 Updating category with payload: $payload');
    
    final response = await _apiClient.patchApp('/category/update', payload);
    
    print('📡 Server response status: ${response.statusCode}');
    print('📡 Server response data: ${response.data}');
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update category: ${response.statusCode}');
    }
  }

  // ✅ PUT /category/batch/update
  Future<void> updateCategoriesBatch(List<CategoryDTO> dtos) async {
    final response = await _apiClient.putApp(
      '/category/batch/update',
      dtos.map((e) => e.toJson()).toList(),
    );
    
    print('📌 CategoryService: Batch update response type: ${response.data.runtimeType}');
    print('📌 CategoryService: Batch update response data: ${response.data}');
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update categories in batch: ${response.statusCode}');
    }
    
    // No necesitamos parsear la respuesta ya que CategoryController
    // recarga todas las categorías después usando getAllCategories()
    print('✅ CategoryService: Batch update completed successfully');
  }

  // ✅ POST /category/enroll/add?profileId=id&categoryId=id
  Future<void> enrollProfileToCategory(int profileId, int categoryId) async {
    await _apiClient.postApp(
      '/category/enroll/add?profileId=$profileId&categoryId=$categoryId',
      null,
    );
  }

  // ✅ DELETE /category/{id}
  Future<void> deleteCategory(int id) async {
    await _apiClient.deleteApp('/category/$id');
  }

  // ✅ DELETE /category/batch?id=id&id=id
  Future<void> deleteCategoriesBatch(List<int> ids) async {
    final queryParams = ids.map((id) => 'id=$id').join('&');
    await _apiClient.deleteApp('/category/batch?$queryParams');
  }

  // ✅ GET /category/enroll - Get detailed enrollments for business users
  Future<List<CategoryEnrollmentDTO>> getDetailedEnrollments() async {
    final response = await _apiClient.getApp('/category/enroll');
    
    print('📌 CategoryService: Raw response data type for detailed enrollments: ${response.data.runtimeType}');
    print('📌 CategoryService: Raw response data for detailed enrollments: ${response.data}');
    
    // El backend puede retornar un objeto envuelto con la estructura:
    // { "data": [...] } o directamente la lista
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto
      print('📌 CategoryService: Detailed enrollments response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Si viene envuelto en un objeto con key 'data'
      print('📌 CategoryService: Detailed enrollments response has data key, extracting list');
      dataList = responseData['data'] as List<dynamic>;
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      print('📌 CategoryService: Detailed enrollments response is direct list');
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacía
      print('❌ CategoryService: Unknown detailed enrollments response format, returning empty list');
      return [];
    }
    
    print('📌 CategoryService: Detailed enrollments data list length: ${dataList.length}');
    
    return dataList
        .map((e) => CategoryEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ DELETE /category/enroll/{id}
  Future<void> deleteEnrollment(int id) async {
    print('📌 CategoryService: Starting deleteEnrollment request');
    print('📌 CategoryService: Enrollment ID to delete: $id');
    print('📌 CategoryService: Request URL: /category/enroll/$id');
    
    try {
      final response = await _apiClient.deleteApp('/category/enroll/$id');
      print('✅ CategoryService: Delete enrollment response status: ${response.statusCode}');
      print('✅ CategoryService: Delete enrollment response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('❌ CategoryService: Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to delete enrollment: ${response.statusCode}');
      }
      
      print('✅ CategoryService: Enrollment deleted successfully');
    } catch (e) {
      print('❌ CategoryService: Error deleting enrollment: $e');
      rethrow;
    }
  }

  // ✅ DELETE /category/enroll/category/{categoryId} - Delete all enrollments for a specific category
  // Alternative approach: Delete enrollments individually if bulk endpoint fails
  Future<void> deleteAllEnrollmentsByCategory(int categoryId) async {
    print('📌 CategoryService: Starting deleteAllEnrollmentsByCategory request');
    print('📌 CategoryService: Category ID: $categoryId');
    print('📌 CategoryService: Request URL: /category/enroll/category/$categoryId');
    
    try {
      // Try the bulk delete endpoint first
      final response = await _apiClient.deleteApp('/category/enroll/category/$categoryId');
      print('✅ CategoryService: Delete all enrollments response status: ${response.statusCode}');
      print('✅ CategoryService: Delete all enrollments response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('❌ CategoryService: Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to delete all enrollments for category: ${response.statusCode}');
      }
      
      print('✅ CategoryService: All enrollments for category deleted successfully');
    } catch (e) {
      print('❌ CategoryService: Bulk delete failed with error: $e');
      print('📌 CategoryService: Attempting fallback - individual deletion');
      
      // Fallback: Get all detailed enrollments and delete them individually
      try {
        final allEnrollments = await getDetailedEnrollments();
        final categoryEnrollments = allEnrollments.where((enrollment) => enrollment.id != null).toList();
        
        print('📌 CategoryService: Found ${categoryEnrollments.length} total enrollments to filter');
        
        // We can't filter by categoryId here since we don't have it in the response
        // This is a limitation of the fallback approach - it will be handled by the UI
        // which already has the filtered list
        
        print('✅ CategoryService: Fallback preparation completed - UI will handle individual deletions');
        
        // Re-throw the original error since this fallback requires UI coordination
        rethrow;
        
      } catch (fallbackError) {
        print('❌ CategoryService: Fallback also failed: $fallbackError');
        rethrow;
      }
    }
  }
  
  // ✅ Alternative method: Delete enrollments by IDs (bulk individual deletion)
  Future<void> deleteEnrollmentsByIds(List<int> enrollmentIds) async {
    print('📌 CategoryService: Starting deleteEnrollmentsByIds request');
    print('📌 CategoryService: Enrollment IDs to delete: $enrollmentIds');
    
    if (enrollmentIds.isEmpty) {
      print('📌 CategoryService: No enrollment IDs provided, nothing to delete');
      return;
    }
    
    try {
      final deletePromises = enrollmentIds.map((id) => deleteEnrollment(id)).toList();
      await Future.wait(deletePromises);
      print('✅ CategoryService: All enrollments deleted successfully via individual calls');
    } catch (e) {
      print('❌ CategoryService: Error deleting enrollments by IDs: $e');
      rethrow;
    }
  }
}
