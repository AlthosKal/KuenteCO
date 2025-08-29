import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../utils/enum/transaction_type_enum.dart';
import '../../../controllers/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';

class CreateTransactionWidget extends StatefulWidget {
  final Function(NewTransactionDTO) onCreateTransaction;
  final bool isLoading;

  const CreateTransactionWidget({
    Key? key,
    required this.onCreateTransaction,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CreateTransactionWidget> createState() => _CreateTransactionWidgetState();
}

class _CreateTransactionWidgetState extends State<CreateTransactionWidget> {
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
    _dateController.text = _formatDate(_selectedDate);
    
    // Load categories when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      if (categoryController.categories.isEmpty) {
        categoryController.loadCategories();
      }
    });
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
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear Transaccion',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registra un nuevo movimiento financiero',
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
                    _buildInputLabel('Nombre de la transacci�n'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        hint: 'Escribe aqui',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// DESCRIPCI�N
                    _buildInputLabel('Descripci�n (opcional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        hint: 'Descripcion',
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
                          return 'Ingresa un monto v�lido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// CATEGOR�A
                    _buildInputLabel('Categor�a'),
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
                                Icon(Icons.bookmarks, color: Colors.purpleAccent),
                                SizedBox(width: 12),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Cargando categor�as...'),
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
                                Icon(Icons.bookmarks, color: Colors.purpleAccent),
                                SizedBox(width: 12),
                                Text('No hay categor�as disponibles'),
                              ],
                            ),
                          );
                        }

                        return DropdownButtonFormField<CategoryDTO>(
                          value: _selectedCategory,
                          decoration: _buildInputDecoration(
                            hint: 'Selecciona una categor�a',
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
                              return 'Selecciona una categor�a';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

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
                              backgroundColor: Theme.of(context).primaryColor,
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
                                    'Crear Transacci�n',
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
    IconData? icon,
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
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
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
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
              primary: Theme.of(context).primaryColor,
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
      final newTransaction = NewTransactionDTO(
        name: _nameController.text,
        description: DescriptionTransaction(
          description: _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
          type: TransactionType.EXPENSE, // You might want to determine this based on transaction type
        ),
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategory?.id, // Use the selected category's ID
        budgetId: _selectedCategory?.budgetId, // Use the selected category's budget ID if available
      );

      widget.onCreateTransaction(newTransaction);
    }
  }
}