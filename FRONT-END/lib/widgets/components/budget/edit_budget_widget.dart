import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/budget_controller.dart';
import '../../../dto/app/budget/budget_dto.dart';
import '../../../dto/app/budget/update_budget_dto.dart';

class EditBudgetWidget extends StatefulWidget {
  final BudgetDTO budget;
  
  const EditBudgetWidget({
    super.key,
    required this.budget,
  });

  static Future<bool?> showEditDialog(BuildContext context, BudgetDTO budget) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditBudgetWidget(budget: budget),
    );
  }

  @override
  State<EditBudgetWidget> createState() => _EditBudgetWidgetState();
}

class _EditBudgetWidgetState extends State<EditBudgetWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _remainingController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget.name);
    _amountController = TextEditingController(text: widget.budget.totalBudget.toString());
    _remainingController = TextEditingController(text: widget.budget.remainingBudget.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _remainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Editar Presupuesto',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
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
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _amountController,
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
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _remainingController,
                    decoration: const InputDecoration(
                      labelText: 'Presupuesto restante',
                      prefixIcon: Icon(Icons.savings),
                      border: OutlineInputBorder(),
                      helperText: 'Cantidad disponible para gastar',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El presupuesto restante es requerido';
                      }
                      final remaining = double.tryParse(value);
                      if (remaining == null || remaining < 0) {
                        return 'Ingresa un monto válido (puede ser 0)';
                      }
                      final total = double.tryParse(_amountController.text);
                      if (total != null && remaining > total) {
                        return 'El restante no puede ser mayor al total';
                      }
                      return null;
                    },
                  ),
                ],
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
                  onPressed: _isLoading ? null : _updateBudget,
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
                      : const Text('Actualizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('EditBudgetWidget: Starting budget update');
      final budgetController = Provider.of<BudgetController>(context, listen: false);
      
      final double totalBudget = double.parse(_amountController.text);
      final double remainingBudget = double.parse(_remainingController.text);
      
      print('EditBudgetWidget: Parsed total budget: $totalBudget');
      print('EditBudgetWidget: Parsed remaining budget: $remainingBudget');
      
      final updateDto = UpdateBudgetDTO(
        id: widget.budget.id,
        name: _nameController.text.trim(),
        totalBudget: totalBudget,
        remainingBudget: remainingBudget,
      );

      print('EditBudgetWidget: Created UpdateBudgetDTO: ${updateDto.toJson()}');
      print('EditBudgetWidget: Calling budgetController.updateBudget');
      
      await budgetController.updateBudget(updateDto);
      
      print('EditBudgetWidget: Budget update completed successfully');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presupuesto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('EditBudgetWidget: Error updating budget: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar presupuesto: $e'),
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