import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../controllers/exchange_rate_controller.dart';
import '../../../dto/app/exchange_rate/exchange_rate_dto.dart';
import '../../../dto/app/exchange_rate/convert_currency_response_dto.dart';

class CurrencyConverterWidget extends StatefulWidget {
  const CurrencyConverterWidget({super.key});

  @override
  State<CurrencyConverterWidget> createState() => _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  late ExchangeRateController _exchangeRateController;
  final TextEditingController _amountController = TextEditingController();

  String? _selectedBaseCurrency;
  String? _selectedTargetCurrency;
  List<String> _availableCurrencies = [];

  @override
  void initState() {
    super.initState();
    _exchangeRateController = ExchangeRateController();
    _loadExchangeRates();
  }

  @override
  void dispose() {
    _exchangeRateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadExchangeRates() async {
    await _exchangeRateController.getAllExchangeRates(context: context);
    setState(() {
      _availableCurrencies = _exchangeRateController.getAvailableCurrencies();
      if (_availableCurrencies.isNotEmpty) {
        _selectedBaseCurrency = _availableCurrencies.contains('USD') ? 'USD' : _availableCurrencies.first;
        _selectedTargetCurrency = _availableCurrencies.contains('COP') ? 'COP' : 
            (_availableCurrencies.length > 1 ? _availableCurrencies[1] : _availableCurrencies.first);
      }
    });
  }

  void _convertCurrency() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || _selectedBaseCurrency == null || _selectedTargetCurrency == null) {
      return;
    }

    try {
      final amount = Decimal.parse(amountText);
      _exchangeRateController.convertCurrency(
        amount: amount,
        baseCurrency: _selectedBaseCurrency!,
        targetCurrency: _selectedTargetCurrency!,
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Monto inválido: $e')),
      );
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _selectedBaseCurrency;
      _selectedBaseCurrency = _selectedTargetCurrency;
      _selectedTargetCurrency = temp;
    });
    _exchangeRateController.clearConversionResult();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        borderRadius: 16,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAmountInput(),
                      const SizedBox(height: 20),
                      _buildCurrencySelectors(),
                      const SizedBox(height: 20),
                      _buildConvertButton(),
                      const SizedBox(height: 20),
                      _buildResult(),
                      const SizedBox(height: 20),
                      _buildExchangeRatesList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.currency_exchange,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Conversor de Monedas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _amountController,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        cursorColor: Colors.white,
        cursorWidth: 2.0,
        showCursor: true,
        decoration: InputDecoration(
          hintText: 'Ingresa el monto a convertir',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(
            Icons.attach_money,
            color: Colors.white.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelectors() {
    return Row(
      children: [
        Expanded(child: _buildCurrencyDropdown('De', _selectedBaseCurrency, (value) {
          setState(() => _selectedBaseCurrency = value);
          _exchangeRateController.clearConversionResult();
        })),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GestureDetector(
            onTap: _swapCurrencies,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        Expanded(child: _buildCurrencyDropdown('A', _selectedTargetCurrency, (value) {
          setState(() => _selectedTargetCurrency = value);
          _exchangeRateController.clearConversionResult();
        })),
      ],
    );
  }

  Widget _buildCurrencyDropdown(String label, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                'Seleccionar',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white),
              items: _availableCurrencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConvertButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _exchangeRateController.isConverting,
      builder: (context, isConverting, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isConverting ? null : _convertCurrency,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isConverting 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Convertir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildResult() {
    return ValueListenableBuilder<ConvertCurrencyResponseDTO?>(
      valueListenable: _exchangeRateController.conversionResult,
      builder: (context, result, _) {
        if (result == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resultado:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '1 ${result.baseCurrency} = ${result.rate.toString()} ${result.targetCurrency}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${result.convertedAmount.toString()} ${result.targetCurrency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExchangeRatesList() {
    return ValueListenableBuilder<List<ExchangeRateDTO>>(
      valueListenable: _exchangeRateController.exchangeRates,
      builder: (context, rates, _) {
        if (rates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipos de Cambio Disponibles:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...rates.map((rate) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${rate.baseCurrency} → ${rate.targetCurrency}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    rate.rate.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        );
      },
    );
  }
}