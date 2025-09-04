import 'package:flutter/material.dart';

import '../../../controllers/debt_controller.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/debt/new_debt_dto.dart';
import '../common/detail_modal_widget.dart';
import '../transaction/multiple_operations_widget.dart';
import 'create_debt_widget.dart';
import 'create_multiple_debts_widget.dart';
import 'debt_list_widget.dart';
import 'delete_debt_widget.dart';
import 'delete_multiple_debts_widget.dart';
import 'edit_debt_widget.dart';
import 'edit_multiple_debts_widget.dart';

class DebtsTabWidget extends StatelessWidget {
  final String? userRole;
  final DebtController debtController;

  const DebtsTabWidget({
    Key? key,
    required this.userRole,
    required this.debtController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Solo mostrar operaciones múltiples para usuarios (NO perfiles)
          if (userRole != 'ROLE_PROFILE')
            MultipleOperationsWidget(
              title: 'Operaciones Múltiples de Deudas',
              color: Colors.red,
              onCreateMultiple: () => _showCreateMultipleDebtsModal(context),
              onEditMultiple: () => _showEditMultipleDebtsModal(context),
              onDeleteMultiple: () => _showDeleteMultipleDebtsModal(context),
            ),
          
          Expanded(
            // Los usuarios normales (NO perfiles) tienen acceso completo a deudas
            // Los perfiles (ROLE_PROFILE) tienen acceso limitado o nulo
            child: userRole != 'ROLE_PROFILE'
                ? _buildUserDebtsView(context)
                : _buildProfileDebtsView(context),
          ),
        ],
      ),
    );
  }

  // Vista para usuarios normales (CON acceso completo a deudas)
  Widget _buildUserDebtsView(BuildContext context) {
    return DebtListWidget(
      onDebtTap: (debt) => _showDebtActions(context, debt),
      onDebtEdit: (debt) => _editDebt(context, debt),
      onDebtDelete: (debt) => _deleteDebt(context, debt),
      onMarkAsPaid: (debtId) => _markDebtAsPaid(context, debtId),
      onAddDebt: () => _showCreateDebtModal(context),
      showFilters: true,
      showFab: true,  // ← Habilitado FloatingActionButton como en transacciones
      compact: false,
    );
  }

  // Vista para perfiles (SIN acceso a deudas)
  Widget _buildProfileDebtsView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Acceso Restringido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los perfiles no tienen acceso a la funcionalidad de deudas.',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDebtModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateDebtWidget(
        onCreateDebt: (newDebt) => _createDebt(context, newDebt),
        isLoading: debtController.isLoading,
      ),
    );
  }

  void _createDebt(BuildContext context, NewDebtDTO newDebt) async {
    try {
      await debtController.addDebt(newDebt);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deuda creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la deuda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editDebt(BuildContext context, DebtDTO debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditDebtWidget(
        debt: debt,
        onUpdateDebt: (updateDebt) => _updateDebt(context, updateDebt),
        isLoading: debtController.isLoading,
      ),
    );
  }

  void _updateDebt(BuildContext context, DebtDTO updateDebt) async {
    try {
      await debtController.updateDebt(updateDebt);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deuda actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la deuda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteDebt(BuildContext context, DebtDTO debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteDebtWidget(
        debt: debt,
        onDeleteDebt: (debtToDelete) => _performDeleteDebt(context, debtToDelete),
        isLoading: debtController.isLoading,
      ),
    );
  }

  void _performDeleteDebt(BuildContext context, DebtDTO debt) async {
    try {
      await debtController.deleteDebt(debt.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deuda eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la deuda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markDebtAsPaid(BuildContext context, int debtId) async {
    try {
      await debtController.markDebtAsPaid(debtId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deuda marcada como pagada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar como pagada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateMultipleDebtsModal(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateMultipleDebtsWidget(
        controller: debtController,
      ),
    );

    if (result == true) {
      debtController.loadDebts();
    }
  }

  void _showEditMultipleDebtsModal(BuildContext context) async {
    if (debtController.debts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay deudas disponibles para editar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => EditMultipleDebtsWidget(
        controller: debtController,
        debtsToEdit: debtController.debts,
      ),
    );
  }

  void _showDeleteMultipleDebtsModal(BuildContext context) async {
    if (debtController.debts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay deudas disponibles para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => DeleteMultipleDebtsWidget(
        controller: debtController,
        debtsToDelete: debtController.debts,
      ),
    );
  }

  void _showDebtActions(BuildContext context, DebtDTO debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailModalWidget(
        title: debt.name,
        amount: '\$${debt.totalAmount.toDouble().toStringAsFixed(0)}',
        color: Colors.red,
        icon: Icons.account_balance_wallet,
        details: [
          DetailItem(label: 'Fecha de inicio', value: '${debt.startDate.day}/${debt.startDate.month}/${debt.startDate.year}'),
          DetailItem(label: 'Fecha vencimiento', value: '${debt.expirationDate.day}/${debt.expirationDate.month}/${debt.expirationDate.year}'),
          DetailItem(label: 'Estado', value: debt.state.name),
          DetailItem(label: 'Monto pendiente', value: '\$${debt.pendingAmount.toDouble().toStringAsFixed(0)}'),
        ],
        actions: userRole == 'ROLE_PROFILE'
            ? [
                ActionButton(
                  label: 'Editar',
                  icon: Icons.edit,
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pop(context);
                    _editDebt(context, debt);
                  },
                ),
                ActionButton(
                  label: 'Pagar',
                  icon: Icons.check,
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pop(context);
                    _markDebtAsPaid(context, debt.id);
                  },
                ),
                ActionButton(
                  label: 'Eliminar',
                  icon: Icons.delete,
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteDebt(context, debt);
                  },
                ),
              ]
            : [],
      ),
    );
  }
}