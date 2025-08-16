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
    return (response.data as List)
        .map((e) => CategoryEnrollmentDTO.fromJson(e))
        .toList();
  }

  // ✅ GET /category/enroll/user
  Future<List<CategoryEnrollmentDTO>> getEnrollmentsByUser() async {
    final response = await _apiClient.getApp('/category/enroll/user');
    return (response.data as List)
        .map((e) => CategoryEnrollmentDTO.fromJson(e))
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
  Future<List<CategoryDTO>> addCategoriesBatch(List<NewCategoryDTO> dtos) async {
    final response = await _apiClient.postApp(
      '/category/batch/add',
      dtos.map((e) => e.toJson()).toList(),
    );
    return (response.data as List)
        .map((e) => CategoryDTO.fromJson(e))
        .toList();
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
  Future<List<CategoryDTO>> updateCategoriesBatch(List<CategoryDTO> dtos) async {
    final response = await _apiClient.putApp(
      '/category/batch/update',
      dtos.map((e) => e.toJson()).toList(),
    );
    return (response.data as List)
        .map((e) => CategoryDTO.fromJson(e))
        .toList();
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

  // ✅ DELETE /category/enroll/{id}
  Future<void> deleteEnrollment(int id) async {
    await _apiClient.deleteApp('/category/enroll/$id');
  }
}
