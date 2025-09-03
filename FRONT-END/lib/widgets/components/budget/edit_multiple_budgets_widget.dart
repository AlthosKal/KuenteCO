import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/budget_controller.dart';
import '../../../dto/app/budget/budget_dto.dart';
import '../../../dto/app/budget/update_budget_dto.dart';

class EditMultipleBudgetsWidget extends StatefulWidget {
  final List<BudgetDTO> budgets;
  
  const EditMultipleBudgetsWidget({
    super.key,
    required this.budgets,
  });

  static Future<bool?> showEditDialog(BuildContext context, List<BudgetDTO> budgets) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditMultipleBudgetsWidget(budgets: budgets),
    );
  }

  @override
  State<EditMultipleBudgetsWidget> createState() => _EditMultipleBudgetsWidgetState();
}

class _EditMultipleBudgetsWidgetState extends State<EditMultipleBudgetsWidget> {
  final _formKey = GlobalKey<FormState>();
  late List<_BudgetEditItem> _budgetItems;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetItems = widget.budgets.map((budget) => _BudgetEditItem(
      budget: budget,
      nameController: TextEditingController(text: budget.name),
      amountController: TextEditingController(text: budget.totalBudget.toString()),
    )).toList();
  }

  @override
  void dispose() {
    for (final item in _budgetItems) {
      item.nameController.dispose();
      item.amountController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Editar ${widget.budgets.length} Presupuestos',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: _budgetItems.length,
                  itemBuilder: (context, index) {
                    final item = _budgetItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Presupuesto ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Name field
                            TextFormField(
                              controller: item.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del presupuesto',
                                prefixIcon: Icon(Icons.label),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Amount field
                            TextFormField(
                              controller: item.amountController,
                              decoration: const InputDecoration(
                                labelText: 'Monto total',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El monto es requerido';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Ingresa un monto válido';
                                }
                                return null;
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
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateBudgets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Actualizar Todos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBudgets() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('EditMultipleBudgetsWidget: Starting batch update for ${widget.budgets.length} budgets');
      final budgetController = Provider.of<BudgetController>(context, listen: false);
      
      final updateDtos = <UpdateBudgetDTO>[];
      
      for (int i = 0; i < _budgetItems.length; i++) {
        final item = _budgetItems[i];
        final originalBudget = widget.budgets[i];
        
        final double totalBudget = double.parse(item.amountController.text);
        
        // Calcular el presupuesto restante manteniendo la proporción
        final double currentTotal = originalBudget.totalBudget.toDouble();
        final double currentRemaining = originalBudget.remainingBudget.toDouble();
        final double remainingPercentage = currentTotal > 0 ? currentRemaining / currentTotal : 1.0;
        final double newRemaining = totalBudget * remainingPercentage;
        
        print('EditMultipleBudgetsWidget: Budget $i - ID: ${originalBudget.id}, Total: $totalBudget, Remaining: $newRemaining');
        
        updateDtos.add(UpdateBudgetDTO(
          id: originalBudget.id,
          name: item.nameController.text.trim(),
          totalBudget: totalBudget,
          remainingBudget: newRemaining,
        ));
      }

      print('EditMultipleBudgetsWidget: Created ${updateDtos.length} DTOs, calling batch update');
      await budgetController.updateBudgetsBatch(updateDtos);
      print('EditMultipleBudgetsWidget: Batch update completed successfully');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.budgets.length} presupuestos actualizados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('EditMultipleBudgetsWidget: Error in batch update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar presupuestos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _BudgetEditItem {
  final BudgetDTO budget;
  final TextEditingController nameController;
  final TextEditingController amountController;

  _BudgetEditItem({
    required this.budget,
    required this.nameController,
    required this.amountController,
  });
}