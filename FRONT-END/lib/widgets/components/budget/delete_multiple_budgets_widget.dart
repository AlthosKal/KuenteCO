import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/budget_controller.dart';
import '../../../dto/app/budget/budget_dto.dart';

class DeleteMultipleBudgetsWidget extends StatefulWidget {
  final List<BudgetDTO> budgets;
  
  const DeleteMultipleBudgetsWidget({
    super.key,
    required this.budgets,
  });

  static Future<bool?> showDeleteDialog(BuildContext context, List<BudgetDTO> budgets) {
    if (budgets.isEmpty) return Future.value(false);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteMultipleBudgetsWidget(budgets: budgets),
    );
  }

  @override
  State<DeleteMultipleBudgetsWidget> createState() => _DeleteMultipleBudgetsWidgetState();
}

class _DeleteMultipleBudgetsWidgetState extends State<DeleteMultipleBudgetsWidget> {
  final Map<int, bool> _selectedBudgets = {};
  bool _isLoading = false;
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    for (final budget in widget.budgets) {
      _selectedBudgets[budget.id] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedBudgets.values.where((selected) => selected).length;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.delete_sweep, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Eliminar Presupuestos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Warning message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará los presupuestos seleccionados permanentemente.',
                      style: TextStyle(fontSize: 13, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Select all checkbox
            CheckboxListTile(
              title: Text(
                'Seleccionar todos ($selectedCount/${widget.budgets.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _selectAll,
              onChanged: _isLoading ? null : (value) {
                setState(() {
                  _selectAll = value ?? false;
                  for (final budget in widget.budgets) {
                    _selectedBudgets[budget.id] = _selectAll;
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red,
            ),
            const Divider(height: 1),
            
            // Budget list
            Flexible(
              child: widget.budgets.length > 5 
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.budgets.length,
                    itemBuilder: (context, index) => _buildBudgetTile(widget.budgets[index]),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.budgets.map(_buildBudgetTile).toList(),
                  ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCount > 0 
                    ? '$selectedCount presupuesto${selectedCount == 1 ? '' : 's'} seleccionado${selectedCount == 1 ? '' : 's'}'
                    : 'Ningún presupuesto seleccionado',
                  style: TextStyle(
                    color: selectedCount > 0 ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (_isLoading || selectedCount == 0) ? null : _deleteSelectedBudgets,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Eliminar ($selectedCount)'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTile(BudgetDTO budget) {
    final isSelected = _selectedBudgets[budget.id] ?? false;
    
    return CheckboxListTile(
      title: Text(
        budget.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monto: \$${budget.totalAmount}'),
          Text(
            'Estado: ${budget.status}',
            style: TextStyle(
              color: _getStatusColor(budget.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      value: isSelected,
      onChanged: _isLoading ? null : (value) {
        setState(() {
          _selectedBudgets[budget.id] = value ?? false;
          _updateSelectAllState();
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.red,
      enabled: !_isLoading,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _updateSelectAllState() {
    final selectedCount = _selectedBudgets.values.where((selected) => selected).length;
    final totalCount = widget.budgets.length;
    
    setState(() {
      _selectAll = selectedCount == totalCount;
    });
  }

  Future<void> _deleteSelectedBudgets() async {
    final selectedIds = _selectedBudgets.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final budgetController = Provider.of<BudgetController>(context, listen: false);
      
      // Usar el método batch para eliminar múltiples presupuestos
      await budgetController.deleteBudgetsBatch(selectedIds);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedIds.length} presupuesto${selectedIds.length == 1 ? '' : 's'} eliminado${selectedIds.length == 1 ? '' : 's'} exitosamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error al eliminar presupuestos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('$e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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