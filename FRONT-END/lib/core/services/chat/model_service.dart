import '../../../utils/enum/model_enum.dart';
import '../api_client.dart';

class ModelService {
  final _api = ApiClient();

  Future<List<Model>> getAllModels() async {
    final response = await _api.getChat('/model');

    final data = response.data;
    if (data is List) {
      return data.map((e) => Model.values.byName(e)).toList();
    }
    throw Exception('Respuesta inesperada del servidor');
  }
}