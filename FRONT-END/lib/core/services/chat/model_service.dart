import '../../../utils/enum/model_enum.dart';
import '../api_client.dart';

class ModelService {
  final _api = ApiClient();

  /// Obtener todos los modelos disponibles
  Future<List<Model>> getAllModels() async {
    print('🤖 ModelService: Obteniendo todos los modelos');
    try {
      final response = await _api.getChat('/model');
      final data = response.data;
      
      if (data is List) {
        final models = data.map((e) => Model.values.byName(e)).toList();
        print('✅ ModelService: ${models.length} modelos obtenidos');
        return models;
      }
      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      print('❌ ModelService: Error obteniendo modelos: $e');
      rethrow;
    }
  }

  /// Obtener nombres de modelos como strings
  Future<List<String>> getModelNames() async {
    print('🤖 ModelService: Obteniendo nombres de modelos');
    try {
      final response = await _api.getChat('/model');
      final data = response.data;
      
      if (data is List) {
        final modelNames = data.cast<String>();
        print('✅ ModelService: ${modelNames.length} nombres de modelos obtenidos');
        return modelNames;
      }
      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      print('❌ ModelService: Error obteniendo nombres de modelos: $e');
      rethrow;
    }
  }
}