import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/debt_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/debt/new_debt_dto.dart';
import '../../../dto/app/profile/profile_detail_dto.dart';
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
          // Solo mostrar operaciones mÃºltiples para usuarios (NO perfiles)
          if (userRole != 'ROLE_PROFILE')
            MultipleOperationsWidget(
              title: 'Operaciones MÃºltiples de Deudas',
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
      onDebtAssign: (debt) => _assignDebtToProfile(context, debt),
      onAddDebt: () => _showCreateDebtModal(context),
      showFilters: true,
      showFab: true,  // â Habilitado FloatingActionButton como en transacciones
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

  void _assignDebtToProfile(BuildContext context, DebtDTO debt) async {
    // Show profile selection dialog
    final selectedProfile = await showDialog<ProfileDetailDTO>(
      context: context,
      builder: (context) => _ProfileSelectionDialog(debt: debt),
    );

    if (selectedProfile != null) {
      try {
        await debtController.enrollProfileToDebt(selectedProfile.id, debt.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deuda "${debt.name}" asignada a "${selectedProfile.username}" exitosamente'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver asignaciones',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to debt enrollments view
              },
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar deuda: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _assignDebtToProfile(context, debt),
            ),
          ),
        );
      }
    }
  }
}

class _ProfileSelectionDialog extends StatefulWidget {
  final DebtDTO debt;

  const _ProfileSelectionDialog({required this.debt});

  @override
  State<_ProfileSelectionDialog> createState() => _ProfileSelectionDialogState();
}

class _ProfileSelectionDialogState extends State<_ProfileSelectionDialog> {
  ProfileController? _profileController;
  ProfileDetailDTO? _selectedProfile;

  @override
  void initState() {
    super.initState();
    _initializeProfileController();
  }

  void _initializeProfileController() {
    // Try to get existing ProfileController from context
    try {
      _profileController = Provider.of<ProfileController>(context, listen: false);
    } catch (e) {
      // If not available in context, create a new instance
      _profileController = ProfileController();
    }
    
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    if (_profileController != null) {
      try {
        await _profileController!.loadAllProfiles();
        if (mounted) setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cargando perfiles: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Asignar Deuda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Selecciona el perfil para "${widget.debt.name}" (ID: ${widget.debt.id})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _profileController?.isLoading ?? ValueNotifier(false),
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando perfiles...'),
                        ],
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<ProfileDetailDTO>>(
                    valueListenable: _profileController?.profiles ?? ValueNotifier([]),
                    builder: (context, profiles, child) {
                      if (profiles.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No hay perfiles disponibles'),
                              SizedBox(height: 8),
                              Text(
                                'Crea un perfil para poder asignar deudas',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Info section
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Selecciona el perfil que podrÃ¡ gestionar esta deuda',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Profiles list
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: profiles.length,
                              itemBuilder: (context, index) {
                                final profile = profiles[index];
                                final isSelected = _selectedProfile?.id == profile.id;

                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected ? Colors.orange : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected ? Colors.orange : Colors.grey[300],
                                      child: Text(
                                        profile.username.isNotEmpty ? profile.username[0].toUpperCase() : 'P',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      profile.username,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(profile.email),
                                        Text('ID: ${profile.id}', 
                                             style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                      ],
                                    ),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle, color: Colors.orange)
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedProfile = profile;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _selectedProfile != null
                        ? () => Navigator.of(context).pop(_selectedProfile)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Asignar Deuda'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}