import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/budget_controller.dart';
import '../../../controllers/business_logic/category_controller.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/extra/description_category_extra.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../utils/enum/state_enum.dart' as state_enum;
import '../../../utils/enum/transaction_type_enum.dart';

class EditTransactionWidget extends StatefulWidget {
  final TransactionDetailDTO transaction;
  final Function(UpdateTransactionDTO) onUpdateTransaction;
  final bool isLoading;

  const EditTransactionWidget({
    super.key,
    required this.transaction,
    required this.onUpdateTransaction,
    this.isLoading = false,
  });

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
  BudgetEnrollmentDTO? _selectedBudget;
  DebtDTO? _selectedDebt;
  DateTime _selectedDate = DateTime.now();
  String? _userRole;
  TransactionType _selectedType = TransactionType.EXPENSE;
  
  // Special enrollment object to represent "Sin categoría" for profiles
  static final CategoryEnrollmentDTO _noCategoryOption = CategoryEnrollmentDTO(
    id: -1, // Use -1 as a special ID for "no category"
    profileId: -1,
    categoryName: 'Sin categoría',
    userEmail: '',
    profileEmail: '',
    enrollmentDate: DateTime.now().toIso8601String(),
  );
  
  // Special category object to represent "Sin categoría" for business users
  static final CategoryDTO _noCategoryBusinessOption = CategoryDTO(
    id: -1, // Use -1 as a special ID for "no category"
    name: 'Sin categoría',
    description: DescriptionCategory(
      assignedBudget: 0.0,
      state: state_enum.State.ACTIVE,
    ),
    businessAccountId: -1,
    registerDate: DateTime.now(),
  );

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
      // Try to determine transaction type from transaction name or amount pattern
      final name = widget.transaction.name.toLowerCase();
      if (name.contains('ingreso') || name.contains('income') || name.contains('salario') || name.contains('salary')) {
        _selectedType = TransactionType.INCOME;
      } else {
        _selectedType = TransactionType.EXPENSE;
      }
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
      final budgetController = Provider.of<BudgetController>(context, listen: false);
      final debtController = Provider.of<DebtController>(context, listen: false);
      
      if (_userRole == 'ROLE_PROFILE') {
        // For profiles, always try to load enrollments to ensure fresh data
        categoryController.loadProfileEnrollments().then((_) {
          _findMatchingEnrollment();
        }).catchError((error) {
          // Even if loading fails, try to find match with existing data
          _findMatchingEnrollment();
        });
        
        // Load budget enrollments for profiles
        budgetController.loadEnrollments().then((_) {
          _findMatchingBudget();
        }).catchError((error) {
          print('Error loading budget enrollments: $error');
        });
        
        // Load debts for profiles
        debtController.loadDebts().then((_) {
          _findMatchingDebt();
        }).catchError((error) {
          print('Error loading debts: $error');
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
        
        // Load budget enrollments for business users too
        budgetController.loadEnrollments().then((_) {
          _findMatchingBudget();
        }).catchError((error) {
          print('Error loading budget enrollments: $error');
        });
        
        // Load debts for business users too
        debtController.loadDebts().then((_) {
          _findMatchingDebt();
        }).catchError((error) {
          print('Error loading debts: $error');
        });
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
        return;
      } catch (e) {
        // If no matching category found, use "Sin categoría"
        print('No matching category found for ID: ${widget.transaction.categoryId}');
      }
    }
    
    // If no match or categoryId is null, default to "Sin categoría"
    _selectedCategory = _noCategoryBusinessOption;
    setState(() {});
  }
  
  void _findMatchingEnrollment() {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    
    if (widget.transaction.categoryId != null && categoryController.enrollments.isNotEmpty) {
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
    
    // If no match or categoryId is null, default to "Sin categoría"
    _selectedEnrollment = _noCategoryOption;
    setState(() {});
  }
  
  void _findMatchingBudget() {
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    
    if (widget.transaction.budgetId != null && budgetController.enrollments.isNotEmpty) {
      try {
        _selectedBudget = budgetController.enrollments.firstWhere(
          (enrollment) => enrollment.budgetId == widget.transaction.budgetId,
        );
        setState(() {});
        return;
      } catch (e) {
        print('No matching budget enrollment found for ID: ${widget.transaction.budgetId}');
      }
    }
    
    // If no match or budgetId is null, leave as null (no budget selected)
    _selectedBudget = null;
    setState(() {});
  }
  
  void _findMatchingDebt() {
    final debtController = Provider.of<DebtController>(context, listen: false);
    
    if (widget.transaction.debtId != null && debtController.debts.isNotEmpty) {
      try {
        _selectedDebt = debtController.debts.firstWhere(
          (debt) => debt.id == widget.transaction.debtId,
        );
        setState(() {});
        return;
      } catch (e) {
        print('No matching debt found for ID: ${widget.transaction.debtId}');
      }
    }
    
    // If no match or debtId is null, leave as null (no debt selected)
    _selectedDebt = null;
    setState(() {});
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

                    /// DESCRIPCIÃN
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

                    /// TIPO DE TRANSACCIÃN
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                    /// CATEGORÃA
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
                            items: [
                              // Add "Sin categoría" option at the top
                              DropdownMenuItem(
                                value: _noCategoryOption,
                                child: Text(_noCategoryOption.categoryName),
                              ),
                              // Add all other enrollments
                              ...categoryController.enrollments.map((enrollment) {
                                return DropdownMenuItem(
                                  value: enrollment,
                                  child: Text(enrollment.categoryName),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedEnrollment = value;
                                _selectedCategory = null; // Clear business category selection
                              });
                            },
                            // Category is now optional - no validation needed
                          );
                        } else {
                          // For business users, show categories
                          return DropdownButtonFormField<CategoryDTO>(
                            value: _selectedCategory,
                            decoration: _buildInputDecoration(
                              hint: 'Selecciona una categoría',
                              icon: Icons.category,
                            ),
                            items: [
                              // Add "Sin categoría" option at the top
                              DropdownMenuItem(
                                value: _noCategoryBusinessOption,
                                child: Text(_noCategoryBusinessOption.name),
                              ),
                              // Add all other categories
                              ...categoryController.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                _selectedEnrollment = null; // Clear profile enrollment selection
                              });
                            },
                            // Category is now optional - no validation needed
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    /// PRESUPUESTO
                    _buildInputLabel('Presupuesto (opcional)'),
                    const SizedBox(height: 8),
                    Consumer<BudgetController>(
                      builder: (context, budgetController, child) {
                        if (budgetController.isLoading) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.withValues(alpha: 0.05),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: Colors.grey),
                                SizedBox(width: 12),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Cargando presupuestos...'),
                              ],
                            ),
                          );
                        }

                        return DropdownButtonFormField<BudgetEnrollmentDTO>(
                          value: _selectedBudget,
                          decoration: _buildInputDecoration(
                            hint: 'Selecciona un presupuesto (opcional)',
                            icon: Icons.account_balance_wallet,
                          ),
                          items: [
                            const DropdownMenuItem(
                              child: Text('Sin presupuesto'),
                            ),
                            ...budgetController.enrollments.map((budget) {
                              return DropdownMenuItem(
                                value: budget,
                                child: Text(budget.budgetName),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedBudget = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// DEUDA
                    _buildInputLabel('Deuda (opcional)'),
                    const SizedBox(height: 8),
                    Consumer<DebtController>(
                      builder: (context, debtController, child) {
                        if (debtController.isLoading) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.withValues(alpha: 0.05),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.grey),
                                SizedBox(width: 12),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Cargando deudas...'),
                              ],
                            ),
                          );
                        }

                        return DropdownButtonFormField<DebtDTO>(
                          value: _selectedDebt,
                          decoration: _buildInputDecoration(
                            hint: 'Selecciona una deuda (opcional)',
                            icon: Icons.credit_card,
                          ),
                          items: [
                            const DropdownMenuItem(
                              child: Text('Sin deuda'),
                            ),
                            ...debtController.debts.map((debt) {
                              return DropdownMenuItem(
                                value: debt,
                                child: Text(debt.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDebt = value;
                            });
                          },
                        );
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
        // If "Sin categoría" is selected (id == -1), use null for categoryId
        if (_selectedEnrollment?.id == -1) {
          categoryId = null;
        } else {
          categoryId = _selectedEnrollment?.categoryId ?? widget.transaction.categoryId;
        }
        budgetId = widget.transaction.budgetId;
      } else {
        // For business users, use category data
        // If "Sin categoría" is selected (id == -1), use null for categoryId and budgetId
        if (_selectedCategory?.id == -1) {
          categoryId = null;
          budgetId = null;
        } else {
          categoryId = _selectedCategory?.id ?? widget.transaction.categoryId;
          budgetId = _selectedCategory?.budgetId ?? widget.transaction.budgetId;
        }
      }

      // Both categoryId and budgetId can now be null - backend has been updated
      // No validation needed, both fields are optional

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
        debtId: _selectedDebt?.id ?? widget.transaction.debtId, // Use selected debt or keep current
      );

      widget.onUpdateTransaction(updateTransaction);
    }
  }
}