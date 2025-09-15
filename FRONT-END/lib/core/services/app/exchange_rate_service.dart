import '../../../dto/app/exchange_rate/convert_currency_request_dto.dart';
import '../../../dto/app/exchange_rate/convert_currency_response_dto.dart';
import '../../../dto/app/exchange_rate/exchange_rate_dto.dart';
import '../../exceptions/api_response.dart';
import '../api_client.dart';

class ExchangeRateService {
  final _api = ApiClient();

  bool get isReady => _api.isInitialized;

  Future<List<ExchangeRateDTO>> getAllExchangeRates() async {
    final response = await _api.getApp('/exchange-rates');
    final json = response.data;

    // Check if response is wrapped in ApiResponse or direct list
    if (json is Map<String, dynamic>) {
      // Wrapped response
      final apiResponse = ApiResponse<List<ExchangeRateDTO>>.fromJson(
        json,
        (data) {
          if (data is! List) {
            throw Exception('Expected List but got ${data.runtimeType}');
          }
          return data
              .map((item) => ExchangeRateDTO.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } else if (json is List) {
      // Direct list response
      return json
          .map((item) => ExchangeRateDTO.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Unexpected response format: ${json.runtimeType}');
    }
  }

  Future<ConvertCurrencyResponseDTO> convertCurrency(
    ConvertCurrencyRequestDTO request,
  ) async {
    final response = await _api.postApp('/exchange-rates/convert', request.toJson());
    final json = response.data;

    // Handle both wrapped ApiResponse and direct response formats
    if (json is Map<String, dynamic>) {
      // Check if it's a wrapped ApiResponse with success field
      if (json.containsKey('success') && json['success'] != null) {
        final apiResponse = ApiResponse<ConvertCurrencyResponseDTO>.fromJson(
          json,
          (data) {
            if (data is! Map<String, dynamic>) {
              throw Exception('Expected Map<String, dynamic> but got ${data.runtimeType}');
            }
            return ConvertCurrencyResponseDTO.fromJson(data);
          },
        );

        if (!apiResponse.success) {
          throw Exception(apiResponse.message);
        }

        return apiResponse.data;
      } else {
        // Handle direct response or error response without success field
        if (json.containsKey('message') && json.containsKey('errors')) {
          // This is an error response
          throw Exception(json['message']);
        } else {
          // This is a direct response
          return ConvertCurrencyResponseDTO.fromJson(json);
        }
      }
    } else {
      throw Exception('Unexpected response format: ${json.runtimeType}');
    }
  }
}