import 'package:flutter/material.dart';

import '../core/exceptions/global_exception_handler.dart';
import '../core/services/app/notification_service.dart';
import '../dto/app/notification/notification_dto.dart';
import '../provider/toast_helper.dart';

class NotificationController {
  final NotificationService _notificationService;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<NotificationDTO>> notifications = ValueNotifier([]);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  NotificationController({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  Future<void> getAllNotifications({BuildContext? context}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await GlobalExceptionHandler.run(
        () async {
          final result = await _notificationService.getAllNotifications();
          notifications.value = result;
        },
        onError: (error) {
          errorMessage.value = error.toString();
          if (context != null && context.mounted) {
            ToastHelper.showError(
              context,
              title: 'Error al cargar notificaciones',
              description: error.toString(),
            );
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getNotificationsByDateRange({
    required DateTime fromDate,
    required DateTime toDate,
    BuildContext? context,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await GlobalExceptionHandler.run(
        () async {
          final result = await _notificationService.getNotificationsByDateRange(
            fromDate: fromDate,
            toDate: toDate,
          );
          notifications.value = result;
        },
        onError: (error) {
          errorMessage.value = error.toString();
          if (context != null && context.mounted) {
            ToastHelper.showError(
              context,
              title: 'Error al filtrar notificaciones',
              description: error.toString(),
            );
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearNotifications() {
    notifications.value = [];
    errorMessage.value = null;
  }

  void dispose() {
    isLoading.dispose();
    notifications.dispose();
    errorMessage.dispose();
  }
}