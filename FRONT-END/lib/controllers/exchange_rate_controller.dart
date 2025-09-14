import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../core/exceptions/global_exception_handler.dart';
import '../core/services/app/exchange_rate_service.dart';
import '../dto/app/exchange_rate/convert_currency_request_dto.dart';
import '../dto/app/exchange_rate/convert_currency_response_dto.dart';
import '../dto/app/exchange_rate/exchange_rate_dto.dart';
import '../provider/toast_helper.dart';

class ExchangeRateController {
  final ExchangeRateService _exchangeRateService;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isConverting = ValueNotifier(false);
  final ValueNotifier<List<ExchangeRateDTO>> exchangeRates = ValueNotifier([]);
  final ValueNotifier<ConvertCurrencyResponseDTO?> conversionResult = ValueNotifier(null);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  ExchangeRateController({ExchangeRateService? exchangeRateService})
      : _exchangeRateService = exchangeRateService ?? ExchangeRateService();

  Future<void> getAllExchangeRates({BuildContext? context}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await GlobalExceptionHandler.run(
        () async {
          final result = await _exchangeRateService.getAllExchangeRates();
          exchangeRates.value = result;
        },
        onError: (error) {
          errorMessage.value = error.toString();
          if (context != null && context.mounted) {
            ToastHelper.showError(
              context,
              title: 'Error al cargar tipos de cambio',
              description: error.toString(),
            );
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> convertCurrency({
    required Decimal amount,
    required String baseCurrency,
    required String targetCurrency,
    BuildContext? context,
  }) async {
    // Validate amount range
    if (amount <= Decimal.zero || amount > Decimal.parse('999999999.99')) {
      final error = 'El valor debe estar entre 0.01 y 999999999.99';
      errorMessage.value = error;
      if (context != null && context.mounted) {
        ToastHelper.showError(
          context,
          title: 'Monto inválido',
          description: error,
        );
      }
      return;
    }

    isConverting.value = true;
    errorMessage.value = null;
    conversionResult.value = null;

    final request = ConvertCurrencyRequestDTO(
      amount: amount,
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
    );

    try {
      await GlobalExceptionHandler.run(
        () async {
          final result = await _exchangeRateService.convertCurrency(request);
          conversionResult.value = result;
          
          if (context != null && context.mounted) {
            ToastHelper.showSuccess(
              context,
              title: 'Conversión exitosa',
              description: '${amount.toString()} $baseCurrency = ${result.convertedAmount.toString()} $targetCurrency',
            );
          }
        },
        onError: (error) {
          errorMessage.value = error.toString();
          if (context != null && context.mounted) {
            ToastHelper.showError(
              context,
              title: 'Error en la conversión',
              description: error.toString(),
            );
          }
        },
      );
    } finally {
      isConverting.value = false;
    }
  }

  ExchangeRateDTO? findExchangeRate(String baseCurrency, String targetCurrency) {
    try {
      return exchangeRates.value.firstWhere(
        (rate) =>
            rate.baseCurrency == baseCurrency && rate.targetCurrency == targetCurrency,
      );
    } catch (e) {
      return null;
    }
  }

  List<String> getAvailableCurrencies() {
    final currencies = <String>{};
    for (final rate in exchangeRates.value) {
      currencies.add(rate.baseCurrency);
      currencies.add(rate.targetCurrency);
    }
    return currencies.toList()..sort();
  }

  void clearConversionResult() {
    conversionResult.value = null;
    errorMessage.value = null;
  }

  void dispose() {
    isLoading.dispose();
    isConverting.dispose();
    exchangeRates.dispose();
    conversionResult.dispose();
    errorMessage.dispose();
  }
}