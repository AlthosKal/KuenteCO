import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../controllers/business_logic/budget_controller.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';

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
  
  CategoryEnrollmentDTO? _selectedEnrollment;
  BudgetEnrollmentDTO? _selectedBudget;
  DebtDTO? _selectedDebt;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.EXPENSE; // Default to Egreso
  
  // Special enrollment object to represent "Sin categoría"
  static final CategoryEnrollmentDTO _noCategoryOption = CategoryEnrollmentDTO(
    id: -1, // Use -1 as a special ID for "no category"
    profileId: -1,
    categoryId: null, // null means no category
    categoryName: 'Sin categoría',
    userEmail: '',
    profileEmail: '',
    enrollmentDate: DateTime.now().toIso8601String(),
  );

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    
    // Set "Sin categoría" as default selection
    _selectedEnrollment = _noCategoryOption;
    
    // Load profile enrollments (assigned categories, budgets, debts) when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      categoryController.loadProfileEnrollments(); // Always reload categories
      
      final budgetController = Provider.of<BudgetController>(context, listen: false);
      if (budgetController.enrollments.isEmpty) {
        budgetController.loadEnrollments();
      }
      
      final debtController = Provider.of<DebtController>(context, listen: false);
      if (debtController.debts.isEmpty) {
        debtController.loadDebts();
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
                    _buildInputLabel('Nombre de la transaccion'),
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
                    _buildInputLabel('Descripcion (opcional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                        hint: 'Descripcion',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    /// TIPO DE TRANSACCI�N
                    _buildInputLabel('Tipo de transacci�n'),
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
                          return 'Selecciona el tipo de transacci�n';
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
                          return 'Ingresa un monto valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// CATEGOR�A
                    _buildInputLabel('Categoria'),
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
                                Text('Cargando categorias...'),
                              ],
                            ),
                          );
                        }

                        // Always show dropdown even if no enrollments - user can select "Sin categoría"

                        return DropdownButtonFormField<CategoryEnrollmentDTO>(
                          value: _selectedEnrollment,
                          decoration: _buildInputDecoration(
                            hint: 'Selecciona una categoria',
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
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedEnrollment = value);
                          },
                          // Category is now optional - no validation needed
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// PRESUPUESTO (OPCIONAL)
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
                                Icon(Icons.account_balance_wallet, color: Colors.blue),
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
                              value: null,
                              child: Text('Sin presupuesto'),
                            ),
                            ...budgetController.enrollments.map((budget) {
                              return DropdownMenuItem(
                                value: budget,
                                child: Text(budget.budgetName),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedBudget = value);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// DEUDA (OPCIONAL)
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
                                Icon(Icons.credit_card, color: Colors.orange),
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
                              value: null,
                              child: Text('Sin deuda'),
                            ),
                            ...debtController.debts.map((debt) {
                              return DropdownMenuItem(
                                value: debt,
                                child: Text(debt.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedDebt = value);
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
                                    'Crear Transaccion',
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
      // Category, budget, and debt are all optional
      final newTransaction = NewTransactionDTO(
        name: _nameController.text,
        description: DescriptionTransaction(
          description: _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
          type: _selectedType, // Use the selected transaction type
        ),
        amount: double.parse(_amountController.text),
        categoryId: _selectedEnrollment?.categoryId, // Can be null - category is optional
        budgetId: _selectedBudget?.budgetId, // Can be null - budget is optional
        debtId: _selectedDebt?.id, // Can be null - debt is optional
      );

      widget.onCreateTransaction(newTransaction);
    }
  }
}