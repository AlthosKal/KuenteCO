import 'package:flutter/material.dart';

import '../../../dto/app/budget/budget_dto.dart';

class BudgetListWidget extends StatelessWidget {
  final BudgetDTO budget;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAssign;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const BudgetListWidget({
    super.key,
    required this.budget,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAssign,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
            color: isSelected ? Colors.blue.withValues(alpha: 0.05) : null,
          ),
          child: InkWell(
            onTap: isSelectionMode ? onSelectionToggle : onTap,
            onLongPress: onSelectionToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icono o checkbox de selección
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.blue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelectionMode && isSelected
                          ? Icons.check
                          : Icons.account_balance_wallet,
                      size: 24,
                      color: isSelected ? Colors.white : Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Información del presupuesto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monto total: \$${budget.totalAmount}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(budget.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            budget.status,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(budget.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botones de acción (solo si no está en modo selección)
                  if (!isSelectionMode) ...[
                    IconButton(
                      onPressed: onAssign,
                      icon: const Icon(Icons.group_add, color: Colors.purple),
                      tooltip: 'Asignar a perfiles',
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Editar presupuesto',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar presupuesto',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'activo':
        return Colors.green;
      case 'inactive':
      case 'inactivo':
        return Colors.red;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}