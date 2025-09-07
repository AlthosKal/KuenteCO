import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../controllers/business_logic/budget_controller.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../controllers/transactions/transaction_controller.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';

// Clase auxiliar para manejar formularios múltiples
class TransactionFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  TransactionType type = TransactionType.EXPENSE;
  CategoryEnrollmentDTO? selectedEnrollment;
  BudgetEnrollmentDTO? selectedBudget;
  DebtDTO? selectedDebt;
  
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    amountController.dispose();
  }
  
  bool get isValid {
    if (nameController.text.trim().isEmpty) return false;
    if (amountController.text.trim().isEmpty) return false;
    
    // Validar que el monto sea un número válido y positivo usando Decimal
    try {
      final amount = Decimal.parse(amountController.text.trim());
      if (amount <= Decimal.zero) return false;
      
      // Validar que el monto no sea excesivamente grande (máximo 999,999,999.99)
      if (amount > Decimal.parse('999999999.99')) return false;
      
      // Validar que tenga máximo 2 decimales
      final amountString = amount.toString();
      if (amountString.contains('.')) {
        final decimalPart = amountString.split('.')[1];
        if (decimalPart.length > 2) return false;
      }
      
    } catch (e) {
      return false;
    }
    
    return true;
  }
  
  NewTransactionDTO toNewTransactionDTO() {
    // Usar Decimal para mejor precisión y luego convertir a double
    final decimal = Decimal.parse(amountController.text.trim());
    
    return NewTransactionDTO(
      name: nameController.text.trim(),
      amount: decimal.toDouble(), // Convertir Decimal a double
      description: DescriptionTransaction(
        description: descriptionController.text.trim().isEmpty 
            ? 'No description' 
            : descriptionController.text.trim(),
        type: type,
      ),
      categoryId: selectedEnrollment?.categoryId,
      budgetId: selectedBudget?.budgetId, // Use selected budget
      debtId: selectedDebt?.id, // Use selected debt
    );
  }
}

class CreateMultipleTransactionsWidget extends StatefulWidget {
  const CreateMultipleTransactionsWidget({super.key});

  @override
  State<CreateMultipleTransactionsWidget> createState() => _CreateMultipleTransactionsWidgetState();
}

class _CreateMultipleTransactionsWidgetState extends State<CreateMultipleTransactionsWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  List<TransactionFormData> _transactions = [TransactionFormData()];
  
  // Special enrollment object to represent "Sin categoría"
  static final CategoryEnrollmentDTO _noCategoryOption = CategoryEnrollmentDTO(
    id: -1,
    profileId: -1,
    categoryId: null,
    categoryName: 'Sin categoría',
    userEmail: '',
    profileEmail: '',
    enrollmentDate: DateTime.now().toIso8601String(),
  );

  @override
  void initState() {
    super.initState();
    // Inicializar con una transacción
    _transactions = [TransactionFormData()];
    _transactions[0].selectedEnrollment = _noCategoryOption;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadBudgets();
      _loadDebts();
    });
  }

  @override
  void dispose() {
    for (var transaction in _transactions) {
      transaction.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    await categoryController.loadEnrollments();
  }
  
  Future<void> _loadBudgets() async {
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    if (budgetController.enrollments.isEmpty) {
      await budgetController.loadEnrollments();
    }
  }
  
  Future<void> _loadDebts() async {
    final debtController = Provider.of<DebtController>(context, listen: false);
    if (debtController.debts.isEmpty) {
      await debtController.loadDebts();
    }
  }

  void _addTransaction() {
    setState(() {
      final newTransaction = TransactionFormData();
      newTransaction.selectedEnrollment = _noCategoryOption;
      _transactions.add(newTransaction);
    });
  }
  
  void _removeTransaction(int index) {
    if (_transactions.length > 1) {
      setState(() {
        _transactions[index].dispose();
        _transactions.removeAt(index);
      });
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  String? _getAmountErrorText(String value) {
    if (value.isEmpty) return null;
    
    try {
      final amount = Decimal.parse(value);
      if (amount <= Decimal.zero) {
        return 'El monto debe ser mayor a 0';
      }
      if (amount > Decimal.parse('999999999.99')) {
        return 'El monto es demasiado grande';
      }
      
      // Validar decimales
      if (value.contains('.')) {
        final decimalPart = value.split('.')[1];
        if (decimalPart.length > 2) {
          return 'Máximo 2 decimales';
        }
      }
    } catch (e) {
      return 'Formato de número inválido';
    }
    
    return null;
  }

  Future<void> _createTransactions() async {
    // Validar que todas las transacciones tengan datos válidos
    final invalidTransactions = _transactions.where((trans) => !trans.isValid).toList();
    if (invalidTransactions.isNotEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos de las transacciones';
      });
      return;
    }

    // Validar que haya al menos 2 transacciones para justificar el batch
    if (_transactions.length == 1) {
      setState(() {
        _errorMessage = 'Para creación en lote, agrega al menos 2 transacciones';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = Provider.of<TransactionController>(context, listen: false);
      
      // Crear múltiples transacciones usando batch con validación adicional
      final newTransactions = _transactions.map((trans) {
        // Validar que el monto se pueda parsear correctamente usando Decimal
        Decimal amount;
        try {
          amount = Decimal.parse(trans.amountController.text.trim());
          if (amount <= Decimal.zero) {
            throw Exception('El monto debe ser mayor a 0');
          }
        } catch (e) {
          throw Exception('Monto inválido en transacción "${trans.nameController.text}"');
        }
        
        return trans.toNewTransactionDTO();
      }).toList();
      
      print('ð Creating ${newTransactions.length} transactions:');
      for (int i = 0; i < newTransactions.length; i++) {
        final json = newTransactions[i].toJson();
        print('   Transaction $i: $json');
        print('   â Amount type: ${json['amount'].runtimeType}');
        print('   â Amount value: ${json['amount']}');
        print('   â Name: "${json['name']}"');
        print('   â CategoryId: ${json['categoryId']}');
        print('   â BudgetId: ${json['budgetId']}');
        print('   â DebtId: ${json['debtId']}');
        print('   â Description: ${json['description']}');
      }
      
      // Log final JSON array que se enviará
      final finalJson = newTransactions.map((e) => e.toJson()).toList();
      print('ð¡ Final JSON to send:');
      print('ð¡ JSON Array Length: ${finalJson.length}');
      print('ð¡ Full JSON: $finalJson');
      
      // Comparar con el JSON que funciona en Postman
      print('ð¡ First transaction comparison with Postman format:');
      if (finalJson.isNotEmpty) {
        final first = finalJson[0];
        print('ð¡   Our format: $first');
        print('ð¡   Expected format from Postman should be:');
        print('ð¡   {categoryId: null, budgetId: null, debtId: null, name: "...", description: {...}, amount: X.X}');
      }
      
      await controller.addTransactionsBatch(newTransactions);
      
      if (mounted) {
        if (controller.errorMessage == null) {
          Navigator.pop(context, true);
          _showSnackBar(
            '${_transactions.length} transacciones creadas exitosamente',
            backgroundColor: Colors.green,
          );
        } else {
          setState(() {
            _errorMessage = controller.errorMessage;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al crear transacciones: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTransactionForm(int index) {
    final transaction = _transactions[index];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header de la transacción con número y botón eliminar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Transacción ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (_transactions.length > 1)
                  IconButton(
                    onPressed: _isLoading ? null : () => _removeTransaction(index),
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Campos del formulario
            TextField(
              controller: transaction.nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la transacción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
                isDense: true,
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: transaction.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                isDense: true,
              ),
              enabled: !_isLoading,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: transaction.amountController,
              decoration: InputDecoration(
                labelText: 'Monto',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                prefixText: '\$ ',
                suffixText: 'COP',
                isDense: true,
                errorText: _getAmountErrorText(transaction.amountController.text.trim()),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isLoading,
              onChanged: (value) {
                // Trigger rebuild to update error text
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            
            // Tipo de transacción
            DropdownButtonFormField<TransactionType>(
              value: transaction.type,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_horiz),
                isDense: true,
              ),
              items: TransactionType.values.map((type) {
                String displayName;
                Icon icon;
                switch (type) {
                  case TransactionType.INCOME:
                    displayName = 'Ingreso';
                    icon = const Icon(Icons.add, color: Colors.green);
                    break;
                  case TransactionType.EXPENSE:
                    displayName = 'Egreso';
                    icon = const Icon(Icons.remove, color: Colors.red);
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  transaction.type = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            
            // Categoría
            Consumer<CategoryController>(
              builder: (context, categoryController, child) {
                final enrollments = [_noCategoryOption, ...categoryController.enrollments];
                
                return DropdownButtonFormField<CategoryEnrollmentDTO>(
                  value: transaction.selectedEnrollment,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                    isDense: true,
                  ),
                  items: enrollments.map((enrollment) {
                    return DropdownMenuItem<CategoryEnrollmentDTO>(
                      value: enrollment,
                      child: Text(enrollment.categoryName),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (value) {
                    setState(() {
                      transaction.selectedEnrollment = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Presupuesto
            Consumer<BudgetController>(
              builder: (context, budgetController, child) {
                if (budgetController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<BudgetEnrollmentDTO>(
                  value: transaction.selectedBudget,
                  decoration: const InputDecoration(
                    labelText: 'Presupuesto (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    isDense: true,
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
                  onChanged: _isLoading ? null : (value) {
                    setState(() {
                      transaction.selectedBudget = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Deuda
            Consumer<DebtController>(
              builder: (context, debtController, child) {
                if (debtController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<DebtDTO>(
                  value: transaction.selectedDebt,
                  decoration: const InputDecoration(
                    labelText: 'Deuda (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                    isDense: true,
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
                  onChanged: _isLoading ? null : (value) {
                    setState(() {
                      transaction.selectedDebt = value;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.library_add,
                        size: 24,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Crear Múltiples Transacciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Botón para agregar transacción
                    IconButton(
                      onPressed: _isLoading ? null : _addTransaction,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                      tooltip: 'Agregar transacción',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de formularios de transacciones
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < _transactions.length; i++)
                          _buildTransactionForm(i),
                      ],
                    ),
                  ),
                ),
                
                // Mensaje de error
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Información de transacciones
                    Text(
                      '${_transactions.length} transacción${_transactions.length > 1 ? 'es' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    // Botones
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.close_outlined, size: 18),
                          label: const Text('Cancelar'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createTransactions,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.library_add, size: 18),
                          label: const Text('Crear Todas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<bool?> showBatchCreateDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const CreateMultipleTransactionsWidget(),
    );
  }
}