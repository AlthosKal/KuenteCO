import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';
import '../../../utils/formatters.dart';

class TransactionFormWidget extends StatefulWidget {
  final TransactionDetailDTO? transaction; // Si es null, es para crear nueva transacciÃ³n
  final Function(NewTransactionDTO) onCreateTransaction;
  final Function(UpdateTransactionDTO)? onUpdateTransaction;
  final List<String> categories; // Lista de categorÃ­as disponibles
  final String? selectedTransactionType; // 'income', 'expense', 'debt'
  final bool isLoading;

  const TransactionFormWidget({
    Key? key,
    this.transaction,
    required this.onCreateTransaction,
    this.onUpdateTransaction,
    this.categories = const [],
    this.selectedTransactionType,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<TransactionFormWidget> createState() => _TransactionFormWidgetState();
}

class _TransactionFormWidgetState extends State<TransactionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCategoryId;
  int? _selectedBudgetId;
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'expense';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.transaction != null) {
      // Modo ediciÃ³n
      _nameController.text = widget.transaction!.name;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedBudgetId = widget.transaction!.budgetId;
      _selectedDate = widget.transaction!.transactionDate ?? DateTime.now();
      _transactionType = _determineTransactionType(widget.transaction!.name);
    } else {
      // Modo creaciÃ³n
      _transactionType = widget.selectedTransactionType ?? 'expense';
    }
  }

  String _determineTransactionType(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ingreso') || lowerName.contains('income')) {
      return 'income';
    } else if (lowerName.contains('deuda') || lowerName.contains('debt')) {
      return 'debt';
    } else {
      return 'expense';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.transaction != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            isEditing ? 'Editar TransacciÃ³n' : 'Nueva TransacciÃ³n',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Tipo de transacciÃ³n (solo en modo creaciÃ³n)
          if (!isEditing) ...[
            Text(
              'Tipo de TransacciÃ³n',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionTypeSelector(),
            const SizedBox(height: 20),
          ],

          // Campo de nombre
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre *',
              hintText: 'Ej: Salario, Compras supermercado, PrÃ©stamo',
              prefixIcon: Icon(_getTransactionIcon()),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo de monto
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Monto *',
              hintText: '0',
              prefixIcon: const Icon(Icons.attach_money),
              border: const OutlineInputBorder(),
              suffixText: 'COP',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CurrencyInputFormatter(),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El monto es requerido';
              }
              final amount = double.tryParse(value.replaceAll(',', ''));
              if (amount == null || amount <= 0) {
                return 'Ingresa un monto vÃ¡lido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo de descripciÃ³n
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'DescripciÃ³n (opcional)',
              hintText: 'Agrega detalles adicionales...',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
          const SizedBox(height: 16),

          // Selector de fecha
          _buildDateSelector(),
          const SizedBox(height: 16),

          // Selector de categorÃ­a
          if (widget.categories.isNotEmpty) ...[
            _buildCategorySelector(),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 24),

          // Botones de acciÃ³n
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Actualizar' : 'Crear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption('income', 'Ingreso', Icons.trending_up, Colors.green),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeOption('expense', 'Gasto', Icons.trending_down, Colors.orange),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeOption('debt', 'Deuda', Icons.account_balance_wallet, Colors.red),
        ),
      ],
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon, Color color) {
    final isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () => setState(() => _transactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(Formatters.formatDate(_selectedDate.toIso8601String())),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'CategorÃ­a (opcional)',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('Sin categorÃ­a'),
        ),
        ...widget.categories.asMap().entries.map((entry) {
          return DropdownMenuItem<int>(
            value: entry.key + 1, // Asumiendo que las categorÃ­as empiezan en 1
            child: Text(entry.value),
          );
        }),
      ],
      onChanged: (value) => setState(() => _selectedCategoryId = value),
    );
  }

  IconData _getTransactionIcon() {
    switch (_transactionType) {
      case 'income':
        return Icons.trending_up;
      case 'debt':
        return Icons.account_balance_wallet;
      default:
        return Icons.trending_down;
    }
  }

  TransactionType _getTransactionTypeEnum() {
    switch (_transactionType) {
      case 'income':
        return TransactionType.INCOME;
      case 'expense':
      case 'debt':
      default:
        return TransactionType.EXPENSE;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final description = _descriptionController.text.trim();

    if (widget.transaction != null) {
      // Modo ediciÃ³n
      final updateDto = UpdateTransactionDTO(
        id: widget.transaction!.id,
        categoryId: _selectedCategoryId ?? 1, // Valor por defecto si es requerido
        budgetId: _selectedBudgetId ?? 1, // Valor por defecto si es requerido
        debtId: null, // Campo opcional
        name: name,
        description: DescriptionTransaction(
          description: description.isEmpty ? 'Sin descripciÃ³n' : description,
          type: _getTransactionTypeEnum(),
        ),
        amount: amount,
      );
      widget.onUpdateTransaction?.call(updateDto);
    } else {
      // Modo creaciÃ³n
      final createDto = NewTransactionDTO(
        categoryId: _selectedCategoryId,
        budgetId: _selectedBudgetId,
        debtId: null, // Campo opcional
        name: name,
        description: DescriptionTransaction(
          description: description.isEmpty ? 'Sin descripciÃ³n' : description,
          type: _getTransactionTypeEnum(),
        ),
        amount: amount,
      );
      widget.onCreateTransaction(createDto);
    }
  }
}

// Input formatter para formato de moneda
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,##0', 'es_CO');
    final formattedText = formatter.format(number);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
