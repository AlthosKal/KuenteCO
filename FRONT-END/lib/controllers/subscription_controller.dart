import 'package:flutter/material.dart';

import '../core/services/app/subscription_service.dart';
import '../dto/subscription/request/create_subscription_request_dto.dart';
import '../dto/subscription/response/create_subscription_response_dto.dart';
import '../dto/subscription/response/payment_history_response_dto.dart';
import '../dto/subscription/response/subscription_response_dto.dart';
import '../dto/subscription/subscription_price_config_dto.dart';


class SubscriptionController extends ChangeNotifier {
  final SubscriptionService _subscriptionService;

  SubscriptionController(this._subscriptionService);

  bool isLoading = false;
  String? errorMessage;

  List<SubscriptionResponseDTO> mySubscriptions = [];
  SubscriptionResponseDTO? currentSubscription;
  CreateSubscriptionResponseDTO? lastCreatedSubscription;
  List<PaymentHistoryResponseDTO> paymentHistory = [];
  List<SubscriptionPriceConfigDTO> subscriptionPrices = [];

  /// Crear una nueva suscripción
  Future<CreateSubscriptionResponseDTO?> createSubscription(CreateSubscriptionRequestDTO request) async {
    _setLoading(true);
    try {
      final response = await _subscriptionService.createSubscription(request);
      lastCreatedSubscription = response;
      errorMessage = null;
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Los precios son estéticos, no se cargan del backend
  Future<void> loadSubscriptionPrices() async {
    // Los precios están hardcodeados, MercadoPago maneja los precios reales
    subscriptionPrices = <SubscriptionPriceConfigDTO>[];
    print('💰 Usando precios estéticos - MercadoPago maneja los precios reales');
  }

  Future<void> loadSubscriptionById(int id) async {
    _setLoading(true);
    try {
      currentSubscription = await _subscriptionService.getSubscriptionById(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadMySubscriptions() async {
    _setLoading(true);
    try {
      mySubscriptions = await _subscriptionService.getMySubscriptions();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadPaymentHistory(int subscriptionId) async {
    _setLoading(true);
    try {
      paymentHistory =
      await _subscriptionService.getPaymentHistory(subscriptionId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
