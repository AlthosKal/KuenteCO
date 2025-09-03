import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:decimal/decimal.dart';
import '../../../controllers/category_controller.dart';
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
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  
  int? _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.debt.name);
    _descriptionController = TextEditingController(
      text: _getDebtDescription(),
    );
    _amountController = TextEditingController(
      text: widget.debt.totalAmount.toString(),
    );
    _selectedCategoryId = null; // DebtDTO no tiene categoryId
    _selectedDate = widget.debt.startDate;
  }

  String _getDebtDescription() {
    // DebtDTO no tiene campos de descripción como TransactionDetailDTO
    // Por ahora devolvemos string vacío
    return '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
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
            hintText: 'Ej: Préstamo bancario, Tarjeta de crédito...',
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

        /// MONTO
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Monto *',
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
              return 'Por favor ingresa el monto';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null || amount <= 0) {
              return 'Por favor ingresa un monto válido';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// DESCRIPCIÓN
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descripción (opcional)',
            hintText: 'Detalles adicionales sobre la deuda...',
            prefixIcon: const Icon(Icons.description, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// FECHA
        InkWell(
          onTap: () => _selectDate(context),
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
                  'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// CATEGORÍA
        Consumer<CategoryController>(
          builder: (context, categoryController, child) {
            final categories = categoryController.categories;
            
            if (categories.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No hay categorías disponibles',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Categoría (opcional)',
                prefixIcon: const Icon(Icons.category, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Sin categoría'),
                ),
                ...categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            );
          },
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
        _selectedDate = picked;
      });
    }
  }

  void _updateDebt() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newAmount = Decimal.parse(_amountController.text.trim());
    
    final dto = DebtDTO(
      id: widget.debt.id,
      name: _nameController.text.trim(),
      totalAmount: newAmount,
      pendingAmount: widget.debt.pendingAmount, // Mantener el monto pendiente actual
      startDate: widget.debt.startDate,
      expirationDate: widget.debt.expirationDate,
      state: widget.debt.state,
    );

    widget.onUpdateDebt(dto);
  }
}