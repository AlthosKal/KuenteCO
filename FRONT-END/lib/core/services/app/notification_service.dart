import '../../../dto/app/notification/notification_dto.dart';
import '../api_client.dart';

class NotificationService {
  final _api = ApiClient();

  bool get isReady => _api.isInitialized;

  Future<List<NotificationDTO>> getAllNotifications() async {
    final response = await _api.getApp('/notification');
    final responseData = response.data;

    // Manejar diferentes estructuras de respuesta
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
        .map((item) => NotificationDTO.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotificationDTO>> getNotificationsByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final queryParams = {
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
    };

    final response = await _api.getApp(
        '/notification/range', queryParameters: queryParams);
    final responseData = response.data;

    // Manejar diferentes estructuras de respuesta
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
        .map((item) => NotificationDTO.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}