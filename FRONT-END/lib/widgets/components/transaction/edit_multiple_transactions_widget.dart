import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../controllers/business_logic/budget_controller.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../controllers/transactions/transaction_controller.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/extra/description_transaction_extra.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';

class EditMultipleTransactionsWidget extends StatefulWidget {
  final TransactionController controller;
  final List<TransactionDetailDTO> transactionsToEdit;

  const EditMultipleTransactionsWidget({
    Key? key,
    required this.controller,
    required this.transactionsToEdit,
  }) : super(key: key);

  @override
  State<EditMultipleTransactionsWidget> createState() => _EditMultipleTransactionsWidgetState();
}

class _EditMultipleTransactionsWidgetState extends State<EditMultipleTransactionsWidget> {
  final _formKey = GlobalKey<FormState>();
  List<UpdateTransactionDTO> editableTransactions = [];

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
    // Crear copias editables de las transacciones
    editableTransactions = widget.transactionsToEdit.map((transaction) {
      return UpdateTransactionDTO(
        id: transaction.id,
        name: transaction.name,
        amount: transaction.amount,
        description: transaction.descriptionExtra ?? DescriptionTransaction(
          description: transaction.description ?? '',
          type: TransactionType.EXPENSE,
        ),
        categoryId: transaction.categoryId,
        budgetId: transaction.budgetId,
        debtId: transaction.debtId,
      );
    }).toList();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    await categoryController.loadEnrollments();
  }

  // Método helper para obtener nombre del tipo de transacción
  String _getTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return 'Ingreso';
      case TransactionType.EXPENSE:
        return 'Egreso';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar Múltiples Transacciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Editando ${editableTransactions.length} transacciones',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Transactions list
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: editableTransactions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transacción ${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Name field
                            TextFormField(
                              initialValue: editableTransactions[index].name,
                              decoration: InputDecoration(
                                labelText: 'Nombre de la transacción',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.title),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un nombre para la transacción';
                                }
                                if (value.length > 100) {
                                  return 'El nombre no puede exceder 100 caracteres';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                editableTransactions[index] = UpdateTransactionDTO(
                                  id: editableTransactions[index].id,
                                  name: value,
                                  amount: editableTransactions[index].amount,
                                  description: editableTransactions[index].description,
                                  categoryId: editableTransactions[index].categoryId,
                                  budgetId: editableTransactions[index].budgetId,
                                  debtId: editableTransactions[index].debtId,
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Amount field
                            TextFormField(
                              initialValue: editableTransactions[index].amount.toString(),
                              decoration: InputDecoration(
                                labelText: 'Monto',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                                suffixText: 'COP',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un monto';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null) {
                                  return 'Ingrese un valor numérico válido';
                                }
                                if (amount < 0) {
                                  return 'El monto no puede ser negativo';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final amount = double.tryParse(value) ?? 0.0;
                                editableTransactions[index] = UpdateTransactionDTO(
                                  id: editableTransactions[index].id,
                                  name: editableTransactions[index].name,
                                  amount: amount,
                                  description: editableTransactions[index].description,
                                  categoryId: editableTransactions[index].categoryId,
                                  budgetId: editableTransactions[index].budgetId,
                                  debtId: editableTransactions[index].debtId,
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Description field
                            TextFormField(
                              initialValue: editableTransactions[index].description.description,
                              decoration: InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                editableTransactions[index] = UpdateTransactionDTO(
                                  id: editableTransactions[index].id,
                                  name: editableTransactions[index].name,
                                  amount: editableTransactions[index].amount,
                                  description: DescriptionTransaction(
                                    description: value,
                                    type: editableTransactions[index].description.type,
                                  ),
                                  categoryId: editableTransactions[index].categoryId,
                                  budgetId: editableTransactions[index].budgetId,
                                  debtId: editableTransactions[index].debtId,
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Type dropdown
                            DropdownButtonFormField<TransactionType>(
                              value: editableTransactions[index].description.type,
                              decoration: InputDecoration(
                                labelText: 'Tipo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.swap_horiz),
                              ),
                              items: TransactionType.values.map((type) {
                                return DropdownMenuItem<TransactionType>(
                                  value: type,
                                  child: Text(_getTypeDisplayName(type)),
                                );
                              }).toList(),
                              onChanged: (TransactionType? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    editableTransactions[index] = UpdateTransactionDTO(
                                      id: editableTransactions[index].id,
                                      name: editableTransactions[index].name,
                                      amount: editableTransactions[index].amount,
                                      description: DescriptionTransaction(
                                        description: editableTransactions[index].description.description,
                                        type: newValue,
                                      ),
                                      categoryId: editableTransactions[index].categoryId,
                                      budgetId: editableTransactions[index].budgetId,
                                      debtId: editableTransactions[index].debtId,
                                    );
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            // Category dropdown
                            Consumer<CategoryController>(
                              builder: (context, categoryController, child) {
                                final enrollments = [_noCategoryOption, ...categoryController.enrollments];
                                
                                // Find current enrollment
                                CategoryEnrollmentDTO? currentEnrollment = enrollments.firstWhere(
                                  (e) => e.categoryId == editableTransactions[index].categoryId,
                                  orElse: () => _noCategoryOption,
                                );

                                return DropdownButtonFormField<CategoryEnrollmentDTO>(
                                  value: currentEnrollment,
                                  decoration: InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    prefixIcon: const Icon(Icons.category),
                                  ),
                                  items: enrollments.map((enrollment) {
                                    return DropdownMenuItem<CategoryEnrollmentDTO>(
                                      value: enrollment,
                                      child: Text(enrollment.categoryName),
                                    );
                                  }).toList(),
                                  onChanged: (CategoryEnrollmentDTO? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        editableTransactions[index] = UpdateTransactionDTO(
                                          id: editableTransactions[index].id,
                                          name: editableTransactions[index].name,
                                          amount: editableTransactions[index].amount,
                                          description: editableTransactions[index].description,
                                          categoryId: newValue.categoryId,
                                          budgetId: editableTransactions[index].budgetId,
                                          debtId: editableTransactions[index].debtId,
                                        );
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _updateTransactions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Actualizar Transacciones'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateTransactions() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Update transactions in batch
      await widget.controller.updateTransactionsBatch(editableTransactions);

      // Close loading dialog
      Navigator.of(context).pop();

      // Close edit dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${editableTransactions.length} transacciones actualizadas exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar las transacciones: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}