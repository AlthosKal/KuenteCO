import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../dto/app/debt/new_debt_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';

class CreateDebtWidget extends StatefulWidget {
  final Function(NewDebtDTO) onCreateDebt;
  final bool isLoading;

  const CreateDebtWidget({
    Key? key,
    required this.onCreateDebt,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CreateDebtWidget> createState() => _CreateDebtWidgetState();
}

class _CreateDebtWidgetState extends State<CreateDebtWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _pendingAmountController = TextEditingController();
  
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedExpirationDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _pendingAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.red,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva Deuda',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              Text(
                'Registra una nueva deuda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        /// NOMBRE
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nombre de la deuda *',
            hintText: 'Ej: Préstamo bancario, Tarjeta de crédito...',
            prefixIcon: const Icon(Icons.title, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el nombre de la deuda';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),

        /// MONTO TOTAL
        TextFormField(
          controller: _totalAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monto Total *',
            hintText: '0.00',
            prefixIcon: const Icon(Icons.monetization_on, color: Colors.red),
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          onChanged: (value) {
            // Auto-llenar el monto pendiente si está vacío
            if (_pendingAmountController.text.isEmpty) {
              _pendingAmountController.text = value;
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el monto total';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null || amount <= 0) {
              return 'Por favor ingresa un monto válido';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// MONTO PENDIENTE
        TextFormField(
          controller: _pendingAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monto Pendiente *',
            hintText: '0.00',
            prefixIcon: const Icon(Icons.account_balance, color: Colors.red),
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el monto pendiente';
            }
            final pendingAmount = double.tryParse(value.trim());
            if (pendingAmount == null || pendingAmount < 0) {
              return 'Por favor ingresa un monto válido';
            }
            
            final totalAmount = double.tryParse(_totalAmountController.text.trim());
            if (totalAmount != null && pendingAmount > totalAmount) {
              return 'El monto pendiente no puede ser mayor al total';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// FECHA DE INICIO
        GestureDetector(
          onTap: () => _selectStartDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.red),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de Inicio *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// FECHA DE VENCIMIENTO
        GestureDetector(
          onTap: () => _selectExpirationDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.red),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de Vencimiento *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${_selectedExpirationDate.day}/${_selectedExpirationDate.month}/${_selectedExpirationDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _createDebt,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Crear Deuda'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.red,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        // Si la fecha de vencimiento es anterior a la de inicio, ajustarla
        if (_selectedExpirationDate.isBefore(picked)) {
          _selectedExpirationDate = picked.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate,
      firstDate: _selectedStartDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.red,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpirationDate = picked;
      });
    }
  }

  void _createDebt() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalAmount = Decimal.parse(_totalAmountController.text.trim());
    final pendingAmount = Decimal.parse(_pendingAmountController.text.trim());
    
    final dto = NewDebtDTO(
      name: _nameController.text.trim(),
      totalAmount: totalAmount,
      pendingAmount: pendingAmount,
      startDate: _selectedStartDate,
      expirationDate: _selectedExpirationDate,
      state: StateDebt.ACTIVE,
    );

    widget.onCreateDebt(dto);
  }
}