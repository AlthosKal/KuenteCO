import '../../../dto/app/subscription/request/create_subscription_request_dto.dart';
import '../../../dto/app/subscription/response/create_subscription_response_dto.dart';
import '../../../dto/app/subscription/response/payment_history_response_dto.dart';
import '../../../dto/app/subscription/response/subscription_response_dto.dart';
import '../../../dto/app/subscription/subscription_price_config_dto.dart';
import '../../exceptions/global_exception_handler.dart';
import '../api_client.dart';

class SubscriptionService {
  final ApiClient _apiClient;

  SubscriptionService(this._apiClient);

  /// Crear una nueva suscripción
  Future<CreateSubscriptionResponseDTO> createSubscription(
      CreateSubscriptionRequestDTO request) {
    return GlobalExceptionHandler.run(() async {
      print('ð Creando suscripción: ${request.toJson()}');
      final response = await _apiClient.postApp(
        '/subscription/add',
        request.toJson(),
      );
      print('ð Respuesta de creación: ${response.data}');
      print('ð Tipo de respuesta: ${response.data.runtimeType}');
      
      // El backend envía la respuesta en formato {success, message, data}
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return CreateSubscriptionResponseDTO.fromJson(responseData['data']);
      } else {
        // Fallback si la estructura cambia
        return CreateSubscriptionResponseDTO.fromJson(responseData);
      }
    });
  }

  /// Obtener una suscripción por id
  Future<SubscriptionResponseDTO> getSubscriptionById(int id) {
    return GlobalExceptionHandler.run(() async {
      final response = await _apiClient.getApp('/subscription/$id');
      return SubscriptionResponseDTO.fromJson(response.data);
    });
  }

  /// Obtener las suscripciones del usuario actual
  Future<List<SubscriptionResponseDTO>> getMySubscriptions() {
    return GlobalExceptionHandler.run(() async {
      try {
        print('ð Llamando a /subscription/my-subscriptions');
        final response = await _apiClient.getApp('/subscription');
        print('ð Respuesta recibida: ${response.data}');
        print('ð Tipo de datos: ${response.data.runtimeType}');
        
        // Validar que response.data existe y es del tipo correcto
        if (response.data == null) {
          print('â ï¸ response.data es null');
          return <SubscriptionResponseDTO>[];
        }
        
        // Si es una lista, procesarla normalmente
        if (response.data is List) {
          final data = response.data as List;
          return data.map((e) => SubscriptionResponseDTO.fromJson(e)).toList();
        }
        
        // Si es un objeto con una propiedad que contiene datos
        if (response.data is Map) {
          final dataMap = response.data as Map<String, dynamic>;
          
          // Buscar posibles nombres de claves que contengan la lista
          if (dataMap.containsKey('data')) {
            final listData = dataMap['data'];
            if (listData is List) {
              return listData.map((e) => SubscriptionResponseDTO.fromJson(e)).toList();
            } else if (listData is Map) {
              // El backend devuelve un solo objeto en 'data', no una lista
              print('ð¦ Backend devuelve objeto individual, convirtiéndolo a lista');
              return [SubscriptionResponseDTO.fromJson(listData as Map<String, dynamic>)];
            }
          }
          
          if (dataMap.containsKey('subscriptions')) {
            final listData = dataMap['subscriptions'];
            if (listData is List) {
              return listData.map((e) => SubscriptionResponseDTO.fromJson(e)).toList();
            } else if (listData is Map) {
              return [SubscriptionResponseDTO.fromJson(listData as Map<String, dynamic>)];
            }
          }
          
          if (dataMap.containsKey('content')) {
            final listData = dataMap['content'];
            if (listData is List) {
              return listData.map((e) => SubscriptionResponseDTO.fromJson(e)).toList();
            } else if (listData is Map) {
              return [SubscriptionResponseDTO.fromJson(listData as Map<String, dynamic>)];
            }
          }
        }
        
        // Si llegamos aquí, el formato no es el esperado
        print('â ï¸ Formato inesperado en getMySubscriptions: ${response.data.runtimeType}');
        return <SubscriptionResponseDTO>[];
        
      } catch (e) {
        print('â Error en getMySubscriptions: $e');
        // Si el endpoint no existe o falla, devolver lista vacía
        return <SubscriptionResponseDTO>[];
      }
    });
  }

  /// Obtener historial de pagos de una suscripción
  Future<List<PaymentHistoryResponseDTO>> getPaymentHistory(int id) {
    return GlobalExceptionHandler.run(() async {
      try {
        final response = await _apiClient.getApp('/subscription/$id/payment-history');
        
        // Validar que response.data existe y es del tipo correcto
        if (response.data == null) {
          return <PaymentHistoryResponseDTO>[];
        }
        
        // Si es una lista, procesarla normalmente
        if (response.data is List) {
          final data = response.data as List;
          return data.map((e) => PaymentHistoryResponseDTO.fromJson(e)).toList();
        }
        
        // Si es un objeto con una propiedad que contiene la lista
        if (response.data is Map) {
          final dataMap = response.data as Map<String, dynamic>;
          
          // Buscar posibles nombres de claves que contengan la lista
          if (dataMap.containsKey('data')) {
            final listData = dataMap['data'];
            if (listData is List) {
              return listData.map((e) => PaymentHistoryResponseDTO.fromJson(e)).toList();
            }
          }
          
          if (dataMap.containsKey('payments')) {
            final listData = dataMap['payments'];
            if (listData is List) {
              return listData.map((e) => PaymentHistoryResponseDTO.fromJson(e)).toList();
            }
          }
          
          if (dataMap.containsKey('content')) {
            final listData = dataMap['content'];
            if (listData is List) {
              return listData.map((e) => PaymentHistoryResponseDTO.fromJson(e)).toList();
            }
          }
        }
        
        // Si llegamos aquí, el formato no es el esperado
        print('â ï¸ Formato inesperado en getPaymentHistory: ${response.data.runtimeType}');
        return <PaymentHistoryResponseDTO>[];
        
      } catch (e) {
        print('â Error en getPaymentHistory: $e');
        return <PaymentHistoryResponseDTO>[];
      }
    });
  }

  /// Obtener configuración de precios de suscripciones (datos hardcodeados - no hay endpoint)
  Future<List<SubscriptionPriceConfigDTO>> getSubscriptionPrices() {
    return GlobalExceptionHandler.run(() async {
      // El backend no tiene endpoint de precios, devolver lista vacía para usar fallback
      print('ð¡ No hay endpoint de precios en el backend, usando planes predeterminados');
      return <SubscriptionPriceConfigDTO>[];
    });
  }
}
