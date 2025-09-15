import '../../../dto/app/category/batch_enrollment_request_dto.dart';
import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';
import '../../../dto/app/category/category_enrollment_summary_dto.dart';
import '../../../dto/app/category/category_report_dto.dart';
import '../../../dto/app/category/new_category_dto.dart';
import '../../../dto/app/category/update_category_dto.dart';
import '../api_client.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  // â GET /category
  Future<List<CategoryDTO>> getAllCategories() async {
    final response = await _apiClient.getApp('/category');
    
    // Manejar diferentes estructuras de respuesta
    final responseData = response.data;
    List dataList;
    
    if (responseData is List) {
      dataList = responseData;
    } else if (responseData is Map && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is String) {
        // Si es un mensaje, retornar lista vacía
        return [];
      } else if (dataValue is List) {
        dataList = dataValue;
      } else {
        return [];
      }
    } else {
      return [];
    }
    
    return dataList
        .map((e) => CategoryDTO.fromJson(e))
        .toList();
  }

  // â GET /category/report/summary
  Future<List<CategoryEnrollmentSummaryDTO>> getCategoryReportSummary() async {
    final response = await _apiClient.getApp('/category/report/summary');
    return (response.data as List)
        .map((e) => CategoryEnrollmentSummaryDTO.fromJson(e))
        .toList();
  }

  // â GET /category/report/{id}
  Future<CategoryReportDTO> getCategoryReportById(int id) async {
    final response = await _apiClient.getApp('/category/report/$id');
    return CategoryReportDTO.fromJson(response.data);
  }

  // â GET /category/enroll
  Future<List<CategoryEnrollmentDTO>> getAllEnrollments() async {
    final response = await _apiClient.getApp('/category/enroll');
    final responseData = response.data;
    
    if (responseData is String) {
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is String) {
        // Si 'data' es un string (mensaje de error), retornar lista vacía
        return [];
      } else if (dataValue is List<dynamic>) {
        // Si 'data' es una lista válida
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
        .map((e) => CategoryEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â GET /category/enroll/user - Returns enrollment summaries for business users
  Future<List<CategoryEnrollmentSummaryDTO>> getEnrollmentSummariesByUser() async {
    final response = await _apiClient.getApp('/category/enroll/user');
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
    
    print('ð CategoryService: /enroll/user data list length: ${dataList.length}');
    
    // PASO 1: Agrupar por categoría ya que el backend envía un elemento por perfil
    final Map<String, List<Map<String, dynamic>>> groupedByCategory = {};
    
    for (final item in dataList) {
      final itemMap = item as Map<String, dynamic>;
      final categoryName = itemMap['categoryName'] as String;
      
      if (!groupedByCategory.containsKey(categoryName)) {
        groupedByCategory[categoryName] = [];
      }
      groupedByCategory[categoryName]!.add(itemMap);
    }
    
    print('ð CategoryService: Grouped into ${groupedByCategory.length} categories');
    
    // PASO 2: Crear CategoryEnrollmentSummaryDTO agrupados
    final List<CategoryEnrollmentSummaryDTO> result = [];
    
    groupedByCategory.forEach((categoryName, categoryItems) {
      print('ð CategoryService: Processing category "$categoryName" with ${categoryItems.length} profiles');
      
      // Combinar todos los enrollmentIds de esta categoría
      final List<int> allEnrollmentIds = [];
      final List<EnrolledProfileSummaryDTO> enrolledProfiles = [];
      
      // Usar el primer item para obtener información base de la categoría
      final firstItem = categoryItems.first;
      
      for (final item in categoryItems) {
        // Agregar enrollmentIds de este item
        if (item['categoryEnrollmentIds'] != null) {
          final ids = (item['categoryEnrollmentIds'] as List<dynamic>)
              .map((e) => e as int)
              .toList();
          allEnrollmentIds.addAll(ids);
        }
        
        // Crear perfil para este item
        if (item['categoryEnrollmentIds'] != null && (item['categoryEnrollmentIds'] as List).isNotEmpty) {
          final enrollmentId = (item['categoryEnrollmentIds'] as List)[0] as int;
          enrolledProfiles.add(EnrolledProfileSummaryDTO(
            enrollmentId: enrollmentId,
            profileEmail: item['profileName'] ?? 'Perfil #$enrollmentId',
            profileName: item['profileName'] ?? 'Perfil #$enrollmentId',
            userEmail: 'Usuario propietario',
            enrollmentDate: item['firstEnrollmentDate'] != null
                ? DateTime.parse(item['firstEnrollmentDate'])
                : null,
          ));
        }
      }
      
      // Crear el DTO agrupado
      final groupedDTO = CategoryEnrollmentSummaryDTO(
        categoryName: categoryName,
        categoryOwnerId: firstItem['ownerUserId']?.toString(),
        ownerUserId: firstItem['ownerUserId']?.toString(),
        enrolledProfilesCount: categoryItems.length,
        totalEnrollments: allEnrollmentIds.length,
        firstEnrollmentDate: _getEarliestDate(categoryItems, 'firstEnrollmentDate'),
        lastEnrollmentDate: _getLatestDate(categoryItems, 'lastEnrollmentDate'),
        categoryStartDate: firstItem['categoryRegisterDate'] != null
            ? DateTime.parse(firstItem['categoryRegisterDate'])
            : null,
        categoryStatus: _mapCategoryState(firstItem['categoryState']),
        categoryEnrollmentIds: allEnrollmentIds,
        enrolledProfiles: enrolledProfiles,
      );
      
      result.add(groupedDTO);
      print('â CategoryService: Created grouped DTO for "$categoryName" with ${enrolledProfiles.length} profiles');
    });
    
    return result;
  }
  
  // Métodos auxiliares para fechas
  DateTime? _getEarliestDate(List<Map<String, dynamic>> items, String dateField) {
    DateTime? earliest;
    for (final item in items) {
      if (item[dateField] != null) {
        final date = DateTime.parse(item[dateField]);
        if (earliest == null || date.isBefore(earliest)) {
          earliest = date;
        }
      }
    }
    return earliest;
  }
  
  DateTime? _getLatestDate(List<Map<String, dynamic>> items, String dateField) {
    DateTime? latest;
    for (final item in items) {
      if (item[dateField] != null) {
        final date = DateTime.parse(item[dateField]);
        if (latest == null || date.isAfter(latest)) {
          latest = date;
        }
      }
    }
    return latest;
  }
  
  // Método auxiliar para mapear el estado de la categoría
  String? _mapCategoryState(dynamic state) {
    if (state == null) return null;
    switch (state.toString().toUpperCase()) {
      case 'ACTIVE':
        return 'ACTIVA';
      case 'INACTIVE':
      case 'CANCELLED':
        return 'FINALIZADA';
      default:
        return state.toString();
    }
  }

  // â POST /category/add
  Future<void> addCategory(NewCategoryDTO dto) async {
    final response = await _apiClient.postApp('/category/add', dto.toJson());
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create category: ${response.statusCode}');
    }
  }

  // â POST /category/batch/add
  Future<void> addCategoriesBatch(List<NewCategoryDTO> dtos) async {
    final response = await _apiClient.postApp(
      '/category/batch/add',
      dtos.map((e) => e.toJson()).toList(),
    );

    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create categories in batch: ${response.statusCode}');
    }
  }

  // ð§ PATCH /category/update (CORREGIDO: Ahora usa UpdateCategoryDTO)
  Future<void> updateCategory(CategoryDTO dto) async {
    // Convertir CategoryDTO a UpdateCategoryDTO
    final updateDto = UpdateCategoryDTO.fromCategoryDTO(dto);
    final payload = updateDto.toJson();
    final response = await _apiClient.patchApp('/category/update', payload);
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update category: ${response.statusCode}');
    }
  }

  // ð§ PUT /category/batch/update (CORREGIDO: Ahora usa UpdateCategoryDTO)
  Future<void> updateCategoriesBatch(List<CategoryDTO> dtos) async {
    // Convertir CategoryDTO a UpdateCategoryDTO
    final updateDtos = dtos.map((dto) => UpdateCategoryDTO.fromCategoryDTO(dto)).toList();
    final response = await _apiClient.putApp(
      '/category/batch/update',
      updateDtos.map((e) => e.toJson()).toList(),
    );
    
    print('ð CategoryService: Batch update response type: ${response.data.runtimeType}');
    print('ð CategoryService: Batch update response data: ${response.data}');
    
    // Verificamos que la petición fue exitosa
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update categories in batch: ${response.statusCode}');
    }
    
    // No necesitamos parsear la respuesta ya que CategoryController
    // recarga todas las categorías después usando getAllCategories()
    print('â CategoryService: Batch update completed successfully');
  }

  // â POST /category/enroll/add?profileId=id&categoryId=id
  Future<void> enrollProfileToCategory(int profileId, int categoryId) async {
    await _apiClient.postApp(
      '/category/enroll/add?profileId=$profileId&categoryId=$categoryId',
      null,
    );
  }

  // â DELETE /category/{id}
  Future<void> deleteCategory(int id) async {
    await _apiClient.deleteApp('/category/$id');
  }

  // â DELETE /category/batch?id=id&id=id
  Future<void> deleteCategoriesBatch(List<int> ids) async {
    final queryParams = ids.map((id) => 'id=$id').join('&');
    await _apiClient.deleteApp('/category/batch?$queryParams');
  }

  // â GET /category/enroll - Get detailed enrollments for business users
  Future<List<CategoryEnrollmentDTO>> getDetailedEnrollments() async {
    final response = await _apiClient.getApp('/category/enroll');
    
    print('ð CategoryService: Raw response data type for detailed enrollments: ${response.data.runtimeType}');
    print('ð CategoryService: Raw response data for detailed enrollments: ${response.data}');
    
    // El backend puede retornar un objeto envuelto con la estructura:
    // { "data": [...] } o directamente la lista
    final responseData = response.data;
    
    if (responseData is String) {
      // Si el backend retorna un mensaje de texto
      print('ð CategoryService: Detailed enrollments response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Si viene envuelto en un objeto con key 'data'
      print('ð CategoryService: Detailed enrollments response has data key, extracting list');
      dataList = responseData['data'] as List<dynamic>;
    } else if (responseData is List<dynamic>) {
      // Si viene directamente como lista
      print('ð CategoryService: Detailed enrollments response is direct list');
      dataList = responseData;
    } else {
      // Si es cualquier otro formato, asumir lista vacía
      print('â CategoryService: Unknown detailed enrollments response format, returning empty list');
      return [];
    }
    
    print('ð CategoryService: Detailed enrollments data list length: ${dataList.length}');
    
    return dataList
        .map((e) => CategoryEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â DELETE /category/enroll/{id}
  Future<void> deleteEnrollment(int id) async {
    print('ð CategoryService: Starting deleteEnrollment request');
    print('ð CategoryService: Enrollment ID to delete: $id');
    print('ð CategoryService: Request URL: /category/enroll/$id');
    
    try {
      final response = await _apiClient.deleteApp('/category/enroll/$id');
      print('â CategoryService: Delete enrollment response status: ${response.statusCode}');
      print('â CategoryService: Delete enrollment response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('â CategoryService: Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to delete enrollment: ${response.statusCode}');
      }
      
      print('â CategoryService: Enrollment deleted successfully');
    } catch (e) {
      print('â CategoryService: Error deleting enrollment: $e');
      rethrow;
    }
  }

  // â DELETE /category/enroll/category/{categoryId} - Delete all enrollments for a specific category
  // Alternative approach: Delete enrollments individually if bulk endpoint fails
  Future<void> deleteAllEnrollmentsByCategory(int categoryId) async {
    print('ð CategoryService: Starting deleteAllEnrollmentsByCategory request');
    print('ð CategoryService: Category ID: $categoryId');
    print('ð CategoryService: Request URL: /category/enroll/category/$categoryId');
    
    try {
      // Try the bulk delete endpoint first
      final response = await _apiClient.deleteApp('/category/enroll/category/$categoryId');
      print('â CategoryService: Delete all enrollments response status: ${response.statusCode}');
      print('â CategoryService: Delete all enrollments response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('â CategoryService: Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to delete all enrollments for category: ${response.statusCode}');
      }
      
      print('â CategoryService: All enrollments for category deleted successfully');
    } catch (e) {
      print('â CategoryService: Bulk delete failed with error: $e');
      print('ð CategoryService: Attempting fallback - individual deletion');
      
      try {
        final allEnrollments = await getDetailedEnrollments();
        final categoryEnrollments = allEnrollments.where((enrollment) => enrollment.id != null).toList();
        
        print('ð CategoryService: Found ${categoryEnrollments.length} total enrollments to filter');
        
        print('â CategoryService: Fallback preparation completed - UI will handle individual deletions');

        rethrow;
        
      } catch (fallbackError) {
        print('â CategoryService: Fallback also failed: $fallbackError');
        rethrow;
      }
    }
  }
  
  // ð POST /category/enroll/add/batch (NUEVO: Asignación masiva de categorías)
  Future<List<CategoryEnrollmentDTO>> enrollProfilesToCategoriesBatch(List<BatchEnrollmentRequestDTO> enrollments) async {
    print('ð CategoryService: Starting batch enrollment request');
    print('ð CategoryService: Enrollments to create: ${enrollments.length}');
    
    final response = await _apiClient.postApp(
      '/category/enroll/add/batch',
      enrollments.map((e) => e.toJson()).toList(),
    );
    
    print('â CategoryService: Batch enrollment response status: ${response.statusCode}');
    print('â CategoryService: Batch enrollment response data: ${response.data}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create batch enrollments: ${response.statusCode}');
    }
    
    // Parsear la respuesta que contiene los CategoryEnrollmentDTO creados
    final responseData = response.data;
    List<dynamic> dataList;
    
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      dataList = responseData['data'] as List<dynamic>;
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      print('â CategoryService: Unexpected response format for batch enrollment');
      return [];
    }
    
    return dataList
        .map((e) => CategoryEnrollmentDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  
  // ð§ DELETE /category/enroll/batch (CORREGIDO: Ahora usa el endpoint correcto del backend)
  Future<void> deleteEnrollmentsBatch(List<int> enrollmentIds) async {
    print('ð CategoryService: Starting batch enrollment deletion request');
    print('ð CategoryService: Enrollment IDs to delete: $enrollmentIds');
    
    if (enrollmentIds.isEmpty) {
      print('ð CategoryService: No enrollment IDs provided, nothing to delete');
      return;
    }
    
    // El backend espera parámetros de query: ?id=1&id=2&id=3
    final queryParams = enrollmentIds.map((id) => 'id=$id').join('&');
    
    try {
      final response = await _apiClient.deleteApp('/category/enroll/batch?$queryParams');
      print('â CategoryService: Batch delete enrollments response status: ${response.statusCode}');
      print('â CategoryService: Batch delete enrollments response data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        print('â CategoryService: Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to delete enrollments in batch: ${response.statusCode}');
      }
      
      print('â CategoryService: Enrollments deleted successfully in batch');
    } catch (e) {
      print('â CategoryService: Error deleting enrollments in batch: $e');
      rethrow;
    }
  }
  
  // â Alternative method: Delete enrollments by IDs (DEPRECATED - usar deleteEnrollmentsBatch)
  @Deprecated('Use deleteEnrollmentsBatch instead')
  Future<void> deleteEnrollmentsByIds(List<int> enrollmentIds) async {
    print('ð CategoryService: Starting deleteEnrollmentsByIds request (DEPRECATED)');
    print('ð CategoryService: Enrollment IDs to delete: $enrollmentIds');
    
    if (enrollmentIds.isEmpty) {
      print('ð CategoryService: No enrollment IDs provided, nothing to delete');
      return;
    }
    
    try {
      final deletePromises = enrollmentIds.map((id) => deleteEnrollment(id)).toList();
      await Future.wait(deletePromises);
      print('â CategoryService: All enrollments deleted successfully via individual calls');
    } catch (e) {
      print('â CategoryService: Error deleting enrollments by IDs: $e');
      rethrow;
    }
  }
}
