import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../utils/enum/transaction_type_enum.dart';
import '../../../controllers/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';

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
  final _storage = const FlutterSecureStorage();
  
  CategoryDTO? _selectedCategory;
  CategoryEnrollmentDTO? _selectedEnrollment;
  DateTime _selectedDate = DateTime.now();
  String? _userRole;
  TransactionType _selectedType = TransactionType.EXPENSE;

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  void _loadTransactionData() async {
    _nameController.text = widget.transaction.name;
    _descriptionController.text = widget.transaction.description ?? '';
    _amountController.text = widget.transaction.amount.toString();
    
    // Load transaction type from descriptionExtra if available
    if (widget.transaction.descriptionExtra?.type != null) {
      _selectedType = widget.transaction.descriptionExtra!.type;
    } else {
      // Default to EXPENSE if no type found
      _selectedType = TransactionType.EXPENSE;
    }
    
    try {
      _selectedDate = DateTime.parse(widget.transaction.date);
    } catch (e) {
      _selectedDate = DateTime.now();
    }
    
    _dateController.text = _formatDate(_selectedDate);
    
    // Detect user role and load appropriate categories
    _userRole = await _storage.read(key: 'role');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      
      if (_userRole == 'ROLE_PROFILE') {
        // For profiles, always try to load enrollments to ensure fresh data
        categoryController.loadProfileEnrollments().then((_) {
          _findMatchingEnrollment();
        }).catchError((error) {
          // Even if loading fails, try to find match with existing data
          _findMatchingEnrollment();
        });
      } else {
        // For business users, load categories if empty
        if (categoryController.categories.isEmpty) {
          categoryController.loadCategories().then((_) {
            _findMatchingCategory();
          });
        } else {
          _findMatchingCategory();
        }
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
  
  void _findMatchingEnrollment() {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    
    if (categoryController.enrollments.isNotEmpty) {
      if (widget.transaction.categoryId != null) {
        try {
          // First try to match by categoryId
          _selectedEnrollment = categoryController.enrollments.firstWhere(
            (enrollment) => enrollment.categoryId == widget.transaction.categoryId,
          );
          setState(() {});
          return;
        } catch (e) {
          // No matching enrollment found by category ID
        }
      }
      
      // If no match by ID, and if there's only one enrollment, select it as default
      if (categoryController.enrollments.length == 1) {
        _selectedEnrollment = categoryController.enrollments.first;
        setState(() {});
        return;
      }
      
      // If no specific match and multiple enrollments available, leave it null for user to select
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
  
  String _getTransactionTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return 'Ingreso';
      case TransactionType.EXPENSE:
        return 'Egreso';
      default:
        return 'Egreso';
    }
  }
  
  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return Icons.trending_up;
      case TransactionType.EXPENSE:
        return Icons.trending_down;
      default:
        return Icons.trending_down;
    }
  }
  
  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return Colors.green;
      case TransactionType.EXPENSE:
        return Colors.red;
      default:
        return Colors.red;
    }
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

                    /// TIPO DE TRANSACCIÓN
                    _buildInputLabel('Tipo de transacción'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TransactionType>(
                      key: ValueKey(_selectedType), // Force rebuild when type changes
                      value: _selectedType,
                      decoration: InputDecoration(
                        hintText: 'Selecciona el tipo',
                        prefixIcon: Icon(
                          _getTransactionTypeIcon(_selectedType),
                          color: _getTransactionTypeColor(_selectedType),
                        ),
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
                      ),
                      items: TransactionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getTransactionTypeIcon(type),
                                color: _getTransactionTypeColor(type),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(_getTransactionTypeDisplayName(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona el tipo de transacción';
                        }
                        return null;
                      },
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

                        // Check data availability based on user role
                        bool hasCategories = false;
                        if (_userRole == 'ROLE_PROFILE') {
                          hasCategories = categoryController.enrollments.isNotEmpty;
                        } else {
                          hasCategories = categoryController.categories.isNotEmpty;
                        }

                        if (!hasCategories) {
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

                        // Show appropriate dropdown based on user role
                        if (_userRole == 'ROLE_PROFILE') {
                          // For profiles, show enrollments
                          return DropdownButtonFormField<CategoryEnrollmentDTO>(
                            value: _selectedEnrollment,
                            decoration: _buildInputDecoration(
                              hint: 'Selecciona una categoría',
                              icon: Icons.category,
                            ),
                            items: categoryController.enrollments.map((enrollment) {
                              return DropdownMenuItem(
                                value: enrollment,
                                child: Text(enrollment.categoryName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEnrollment = value;
                                _selectedCategory = null; // Clear business category selection
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona una categoría';
                              }
                              return null;
                            },
                          );
                        } else {
                          // For business users, show categories
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
                              setState(() {
                                _selectedCategory = value;
                                _selectedEnrollment = null; // Clear profile enrollment selection
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona una categoría';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    /// BOTONES
                    Row(
                      children: [
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
      // Determine category and budget IDs based on user role and selection
      int? categoryId;
      int? budgetId;
      
      if (_userRole == 'ROLE_PROFILE') {
        // For profiles, use enrollment data
        categoryId = _selectedEnrollment?.categoryId ?? widget.transaction.categoryId;
        budgetId = widget.transaction.budgetId;
      } else {
        // For business users, use category data
        categoryId = _selectedCategory?.id ?? widget.transaction.categoryId;
        budgetId = _selectedCategory?.budgetId ?? widget.transaction.budgetId;
      }

      // Check if required values are available
      if (categoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo determinar la categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (budgetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo determinar el presupuesto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updateTransaction = UpdateTransactionDTO(
        id: widget.transaction.id,
        name: _nameController.text,
        description: DescriptionTransaction(
          description: _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
          type: _selectedType, // Use the selected transaction type
        ),
        amount: double.parse(_amountController.text),
        categoryId: categoryId,
        budgetId: budgetId,
      );

      widget.onUpdateTransaction(updateTransaction);
    }
  }
}