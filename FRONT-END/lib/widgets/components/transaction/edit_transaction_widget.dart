import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../utils/enum/transaction_type_enum.dart';
import '../../../controllers/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';

class EditTransactionWidget extends StatefulWidget {
  final TransactionDetailDTO transaction;
  final Function(UpdateTransactionDTO) onUpdateTransaction;
  final bool isLoading;

  const EditTransactionWidget({
    Key? key,
    required this.transaction,
    required this.onUpdateTransaction,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<EditTransactionWidget> createState() => _EditTransactionWidgetState();
}

class _EditTransactionWidgetState extends State<EditTransactionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  
  CategoryDTO? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  void _loadTransactionData() {
    _nameController.text = widget.transaction.name;
    _descriptionController.text = widget.transaction.description ?? '';
    _amountController.text = widget.transaction.amount.toString();
    
    try {
      _selectedDate = DateTime.parse(widget.transaction.date);
    } catch (e) {
      _selectedDate = DateTime.now();
    }
    
    _dateController.text = _formatDate(_selectedDate);
    
    // Load categories and try to find the matching category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      if (categoryController.categories.isEmpty) {
        categoryController.loadCategories().then((_) {
          _findMatchingCategory();
        });
      } else {
        _findMatchingCategory();
      }
    });
  }
  
  void _findMatchingCategory() {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    if (widget.transaction.categoryId != null && categoryController.categories.isNotEmpty) {
      try {
        _selectedCategory = categoryController.categories.firstWhere(
          (category) => category.id == widget.transaction.categoryId,
        );
        setState(() {});
      } catch (e) {
        // If no matching category found, leave it null
        print('No matching category found for ID: ${widget.transaction.categoryId}');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange,
                  Colors.orange.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Transacción',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Modifica los detalles de tu transacción',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          /// FORM CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NOMBRE
                    _buildInputLabel('Nombre de la transacción'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        hint: 'Ej: Compra de mercado',
                        icon: Icons.receipt_long,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// DESCRIPCIÓN
                    _buildInputLabel('Descripción (opcional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        hint: 'Detalles adicionales...',
                        icon: Icons.description,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    /// MONTO
                    _buildInputLabel('Monto'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: _buildInputDecoration(
                        hint: '0.00',
                        icon: Icons.attach_money,
                        prefix: '\$',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'El monto es obligatorio';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// CATEGORÍA
                    _buildInputLabel('Categoría'),
                    const SizedBox(height: 8),
                    Consumer<CategoryController>(
                      builder: (context, categoryController, child) {
                        if (categoryController.isLoading) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.withValues(alpha: 0.05),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.category, color: Colors.grey),
                                SizedBox(width: 12),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Cargando categorías...'),
                              ],
                            ),
                          );
                        }

                        if (categoryController.categories.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.withValues(alpha: 0.05),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.category, color: Colors.grey),
                                SizedBox(width: 12),
                                Text('No hay categorías disponibles'),
                              ],
                            ),
                          );
                        }

                        return DropdownButtonFormField<CategoryDTO>(
                          value: _selectedCategory,
                          decoration: _buildInputDecoration(
                            hint: 'Selecciona una categoría',
                            icon: Icons.category,
                          ),
                          items: categoryController.categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecciona una categoría';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// FECHA
                    _buildInputLabel('Fecha'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      decoration: _buildInputDecoration(
                        hint: 'YYYY-MM-DD',
                        icon: Icons.calendar_today,
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 40),

                    /// BOTONES
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.isLoading ? null : () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: widget.isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: widget.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Actualizar Transacción',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.orange),
      prefixText: prefix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.orange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text = _formatDate(date);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final updateTransaction = UpdateTransactionDTO(
        id: widget.transaction.id,
        name: _nameController.text,
        description: DescriptionTransaction(
          description: _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
          type: TransactionType.EXPENSE, // You might want to determine this based on transaction type
        ),
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategory?.id ?? widget.transaction.categoryId ?? 1, // Use selected category ID, fallback to original
        budgetId: _selectedCategory?.budgetId ?? widget.transaction.budgetId ?? 1, // Use selected category's budget ID, fallback to original
      );

      widget.onUpdateTransaction(updateTransaction);
    }
  }
}