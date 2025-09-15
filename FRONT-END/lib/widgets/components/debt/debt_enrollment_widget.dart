import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/debt_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../dto/app/debt/debt_enrollment_dto.dart';

class DebtEnrollmentWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function(List<DebtEnrollmentDTO>)? onEnrollmentsLoaded;

  const DebtEnrollmentWidget({
    super.key,
    this.title = 'Asignaciones de Deudas',
    this.subtitle = 'Administra las deudas asignadas al perfil',
    this.onEnrollmentsLoaded,
  });

  @override
  State<DebtEnrollmentWidget> createState() => _DebtEnrollmentWidgetState();
}

class _DebtEnrollmentWidgetState extends State<DebtEnrollmentWidget> {
  final Set<String> _selectedEnrollmentIds = <String>{};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDebtEnrollments();
    });
  }

  Future<void> _loadDebtEnrollments() async {
    final debtController = Provider.of<DebtController>(context, listen: false);
    await debtController.loadEnrollments();
    if (widget.onEnrollmentsLoaded != null) {
      widget.onEnrollmentsLoaded!(debtController.enrollments);
    }
  }

  void _toggleSelection(String key) {
    setState(() {
      if (_selectedEnrollmentIds.contains(key)) {
        _selectedEnrollmentIds.remove(key);
      } else {
        _selectedEnrollmentIds.add(key);
      }
      
      if (_selectedEnrollmentIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedEnrollmentIds.clear();
      }
    });
  }

  void _selectAll() {
    final debtController = Provider.of<DebtController>(context, listen: false);
    setState(() {
      if (_selectedEnrollmentIds.length == debtController.enrollments.length) {
        _selectedEnrollmentIds.clear();
      } else {
        _selectedEnrollmentIds.clear();
        _selectedEnrollmentIds.addAll(debtController.enrollments.map((e) => e.enrollmentId?.toString() ?? '${e.userEmail}-${e.debtId}'));
      }
    });
  }

  Future<void> _removeSelectedEnrollments() async {
    if (_selectedEnrollmentIds.isEmpty) return;

    final debtController = Provider.of<DebtController>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas remover ${_selectedEnrollmentIds.length} asignación(es) de deuda?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Convert string IDs back to integers for the API call
        final enrollmentIds = _selectedEnrollmentIds
            .map((id) => int.tryParse(id))
            .where((id) => id != null)
            .cast<int>()
            .toList();
        
        await debtController.removeDebtEnrollmentsBatch(enrollmentIds);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedEnrollmentIds.length} asignaciones removidas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedEnrollmentIds.clear();
          _isSelectionMode = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al remover asignaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEnrollmentDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _DebtEnrollmentDialog(
        onEnrollmentsAdded: () {
          // No need to reload - controller handles local updates automatically
          // _loadDebtEnrollments(); // Removed to avoid unnecessary server calls
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
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
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                if (_isSelectionMode) ...[
                  IconButton(
                    onPressed: _selectAll,
                    icon: const Icon(Icons.select_all, color: Colors.white),
                    tooltip: 'Seleccionar todo',
                  ),
                  IconButton(
                    onPressed: _selectedEnrollmentIds.isNotEmpty ? _removeSelectedEnrollments : null,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    tooltip: 'Eliminar seleccionados',
                  ),
                ],
                IconButton(
                  onPressed: _toggleSelectionMode,
                  icon: Icon(
                    _isSelectionMode ? Icons.close : Icons.checklist,
                    color: Colors.white,
                  ),
                  tooltip: _isSelectionMode ? 'Cancelar selección' : 'Seleccionar múltiple',
                ),
                IconButton(
                  onPressed: _showEnrollmentDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: 'Asignar deuda',
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Consumer<DebtController>(
              builder: (context, debtController, child) {
                if (debtController.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando asignaciones de deudas...'),
                      ],
                    ),
                  );
                }

                if (debtController.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${debtController.errorMessage}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDebtEnrollments,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (debtController.enrollments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay deudas asignadas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Asigna deudas para comenzar a gestionarlas',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showEnrollmentDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Asignar Deuda'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: debtController.enrollments.length,
                  itemBuilder: (context, index) {
                    final enrollment = debtController.enrollments[index];
                    final enrollmentKey = enrollment.enrollmentId?.toString() ?? '${enrollment.userEmail}-${enrollment.debtId}';
                    final isSelected = _selectedEnrollmentIds.contains(enrollmentKey);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? Colors.orange : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: _isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(enrollmentKey),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.orange[100],
                                child: Icon(
                                  Icons.credit_card,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                              ),
                        title: Text(
                          enrollment.debtName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (enrollment.userEmail.isNotEmpty)
                              Text('Usuario: ${enrollment.userEmail}'),
                            if (enrollment.profileEmail.isNotEmpty)
                              Text('Perfil: ${enrollment.profileEmail}'),
                          ],
                        ),
                        trailing: _isSelectionMode
                            ? null
                            : PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.remove_circle, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Remover asignación'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'remove') {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar'),
                                        content: Text('¿Remover asignación de "${enrollment.debtName}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: const Text('Remover'),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirmed == true) {
                                      try {
                                        await debtController.removeDebtEnrollment(enrollment.enrollmentId ?? 0);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Asignación removida exitosamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                        onTap: _isSelectionMode ? () => _toggleSelection(enrollmentKey) : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtEnrollmentDialog extends StatefulWidget {
  final VoidCallback? onEnrollmentsAdded;

  const _DebtEnrollmentDialog({this.onEnrollmentsAdded});

  @override
  State<_DebtEnrollmentDialog> createState() => _DebtEnrollmentDialogState();
}

class _DebtEnrollmentDialogState extends State<_DebtEnrollmentDialog> {
  final Set<int> _selectedDebtIds = <int>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDebts();
    });
  }

  Future<void> _loadDebts() async {
    final debtController = Provider.of<DebtController>(context, listen: false);
    if (debtController.debts.isEmpty) {
      await debtController.loadDebts();
    }
  }

  void _toggleDebtSelection(int debtId) {
    setState(() {
      if (_selectedDebtIds.contains(debtId)) {
        _selectedDebtIds.remove(debtId);
      } else {
        _selectedDebtIds.add(debtId);
      }
    });
  }

  Future<void> _enrollSelectedDebts() async {
    if (_selectedDebtIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una deuda para asignar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final debtController = Provider.of<DebtController>(context, listen: false);
      final profileController = Provider.of<ProfileController>(context, listen: false);
      
      // Get the authenticated profile ID
      if (profileController.authenticatedProfile.value == null) {
        await profileController.loadAuthenticatedProfile();
      }
      
      final profileId = profileController.authenticatedProfile.value?.id;
      if (profileId == null) {
        throw Exception('No se pudo obtener el ID del perfil autenticado');
      }
      
      // Create enrollment data with actual profile ID
      final enrollmentData = _selectedDebtIds.map((debtId) => {
        'profileId': profileId,
        'debtId': debtId,
      }).toList();

      await debtController.enrollProfileToDebtsBatch(enrollmentData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedDebtIds.length} deuda(s) asignada(s) exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
      widget.onEnrollmentsAdded?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al asignar deudas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Asignar Deudas al Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
              child: Consumer<DebtController>(
                builder: (context, debtController, child) {
                  if (debtController.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando deudas disponibles...'),
                        ],
                      ),
                    );
                  }

                  if (debtController.debts.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay deudas disponibles para asignar'),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Selection info
                      if (_selectedDebtIds.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.orange[50],
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDebtIds.length} deuda(s) seleccionada(s)',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Debt list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: debtController.debts.length,
                          itemBuilder: (context, index) {
                            final debt = debtController.debts[index];
                            final isSelected = _selectedDebtIds.contains(debt.id);

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
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => _toggleDebtSelection(debt.id),
                                title: Text(
                                  debt.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Monto total: \$${debt.totalAmount}'),
                                    Text('Estado: ${debt.state.name}'),
                                  ],
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: isSelected ? Colors.orange : Colors.grey[300],
                                  child: Icon(
                                    Icons.credit_card,
                                    color: isSelected ? Colors.white : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                    onPressed: _isLoading ? null : _enrollSelectedDebts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Asignar Deudas'),
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