import 'package:flutter/material.dart';

import 'package:decimal/decimal.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';

class EditDebtWidget extends StatefulWidget {
  final DebtDTO debt;
  final Function(DebtDTO) onUpdateDebt;
  final bool isLoading;

  const EditDebtWidget({
    Key? key,
    required this.debt,
    required this.onUpdateDebt,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<EditDebtWidget> createState() => _EditDebtWidgetState();
}

class _EditDebtWidgetState extends State<EditDebtWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _pendingAmountController;
  
  late DateTime _selectedStartDate;
  late DateTime _selectedExpirationDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.debt.name);
    _totalAmountController = TextEditingController(
      text: widget.debt.totalAmount.toString(),
    );
    _pendingAmountController = TextEditingController(
      text: widget.debt.pendingAmount.toString(),
    );
    _selectedStartDate = widget.debt.startDate;
    _selectedExpirationDate = widget.debt.expirationDate;
  }


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
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit,
            color: Colors.blue,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Deuda',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                'Modifica los datos de la deuda',
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
            hintText: 'Ej: PrÃ©stamo bancario, Tarjeta de crÃ©dito...',
            prefixIcon: const Icon(Icons.title, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
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
            prefixIcon: const Icon(Icons.monetization_on, color: Colors.blue),
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el monto total';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null || amount <= 0) {
              return 'Por favor ingresa un monto vÃ¡lido';
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
            prefixIcon: const Icon(Icons.pending_actions, color: Colors.orange),
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el monto pendiente';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null || amount < 0) {
              return 'Por favor ingresa un monto vÃ¡lido';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// FECHA DE INICIO
        InkWell(
          onTap: () => _selectStartDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Fecha de Inicio: ${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// FECHA DE VENCIMIENTO
        InkWell(
          onTap: () => _selectExpirationDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_busy, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  'Fecha de Vencimiento: ${_selectedExpirationDate.day}/${_selectedExpirationDate.month}/${_selectedExpirationDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
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
            onPressed: widget.isLoading ? null : _updateDebt,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
                : const Text('Actualizar'),
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
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpirationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
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

  void _updateDebt() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalAmount = Decimal.parse(_totalAmountController.text.trim());
    final pendingAmount = Decimal.parse(_pendingAmountController.text.trim());
    
    final dto = DebtDTO(
      id: widget.debt.id,
      name: _nameController.text.trim(),
      totalAmount: totalAmount,
      pendingAmount: pendingAmount,
      startDate: _selectedStartDate,
      expirationDate: _selectedExpirationDate,
      state: widget.debt.state,
    );

    widget.onUpdateDebt(dto);
  }
}