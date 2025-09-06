import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/budget_controller.dart';
import '../../../dto/app/budget/budget_enrollment_dto.dart';
import '../../../dto/app/budget/budget_enrollment_summary_dto.dart';
import '../../../mixins/multi_selection_mixin.dart';
import 'profile_budget_assignment_widget.dart';

class AssignmentListWidget extends StatefulWidget {
  const AssignmentListWidget({super.key});

  static Future<bool?> showAssignmentList(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AssignmentListWidget(),
    );
  }

  @override
  State<AssignmentListWidget> createState() => _AssignmentListWidgetState();
}

class _AssignmentListWidgetState extends State<AssignmentListWidget> with MultiSelectionMixin {
  final Set<String> _expandedBudgets = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnrollments();
    });
  }

  Future<void> _loadEnrollments() async {
    final controller = Provider.of<BudgetController>(context, listen: false);
    await controller.loadUserEnrollments();
  }

  String _getEnrollmentKey(BudgetEnrollmentDTO enrollment) {
    return '${enrollment.budgetName}-${enrollment.profileEmail}-${enrollment.userEmail}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showBulkAssignmentDialog() async {
    final result = await ProfileBudgetAssignmentWidget.showAssignmentDialog(context);
    if (result == true) {
      await _loadEnrollments();
      _showSuccessSnackBar('Asignaciones creadas exitosamente');
    }
  }


  Future<void> _showBatchDeleteDialog(BudgetController controller) async {
    // Obtener todos los enrollments que necesitamos eliminar
    List<BudgetEnrollmentDTO> selectedEnrollments = [];
    
    // Primero, obtener las summaries agrupadas
    final summaries = BudgetEnrollmentSummaryDTO.fromEnrollmentList(controller.enrollments);
    
    for (final key in selectedEnrollmentKeys) {
      print('AssignmentListWidget: Processing selection key: $key');
      
      // Verificar si es una clave de summary (presupuesto completo)
      final summary = summaries.where((s) => s.selectionKey == key).firstOrNull;
      if (summary != null) {
        print('AssignmentListWidget: Found summary for ${summary.budgetName}, adding ${summary.enrollments.length} enrollments');
        selectedEnrollments.addAll(summary.enrollments);
        continue;
      }
      
      // Si no es summary, buscar enrollment individual
      final enrollment = controller.enrollments.where((e) => _getEnrollmentKey(e) == key).firstOrNull;
      if (enrollment != null) {
        print('AssignmentListWidget: Found individual enrollment: ${enrollment.profileEmail}');
        selectedEnrollments.add(enrollment);
      }
    }

    // Remover duplicados
    selectedEnrollments = selectedEnrollments.toSet().toList();
    print('AssignmentListWidget: Total enrollments to delete: ${selectedEnrollments.length}');

    if (selectedEnrollments.isEmpty) {
      _showErrorSnackBar('No hay asignaciones seleccionadas para eliminar');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar EliminaciÃ³n'),
        content: Text(
          'Â¿EstÃ¡s seguro de que deseas eliminar ${selectedEnrollments.length} asignaciones?\n\nEsta acciÃ³n no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final ids = selectedEnrollments.map((e) => e.id).toList();
        print('AssignmentListWidget: Enrollment details before deletion:');
        for (final enrollment in selectedEnrollments) {
          print('  - ID: ${enrollment.id}, Budget: ${enrollment.budgetName}, Profile: ${enrollment.profileEmail}');
        }
        print('AssignmentListWidget: Attempting to delete enrollment IDs: $ids');
        
        // Verificar que no hay IDs invÃ¡lidos (0 o null)
        final validIds = ids.where((id) => id != 0).toList();
        if (validIds.length != ids.length) {
          print('AssignmentListWidget: Warning! Found invalid IDs. Original: $ids, Valid: $validIds');
        }
        
        if (validIds.isEmpty) {
          _showErrorSnackBar('No se encontraron IDs vÃ¡lidos para eliminar');
          return;
        }
        
        await controller.deleteEnrollmentsBatch(validIds);
        clearSelection();
        _showSuccessSnackBar('${validIds.length} asignaciones eliminadas exitosamente');
      } catch (e) {
        print('AssignmentListWidget: Error deleting enrollments: $e');
        _showErrorSnackBar('Error al eliminar asignaciones: $e');
      }
    }
  }

  PreferredSizeWidget _buildAppBar(BudgetController controller) {
    return AppBar(
      title: selectedEnrollmentKeys.isNotEmpty 
          ? Text('${selectedEnrollmentKeys.length} seleccionadas')
          : const Text('GestiÃ³n de Asignaciones'),
      actions: [
        if (selectedEnrollmentKeys.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showBatchDeleteDialog(controller),
            tooltip: 'Eliminar seleccionadas',
          ),
        if (selectedEnrollmentKeys.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSelection,
            tooltip: 'Limpiar selecciÃ³n',
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetController>(
      builder: (context, controller, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Scaffold(
              appBar: _buildAppBar(controller),
              body: Column(
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : controller.enrollments.isEmpty
                            ? Column(
                                children: [
                                  Expanded(child: _buildEmptyState()),
                                  _buildCreateAssignmentsContainer(),
                                ],
                              )
                            : _buildGroupedEnrollmentsList(controller, scrollController),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupedEnrollmentsList(BudgetController controller, ScrollController scrollController) {
    print('AssignmentListWidget: Building grouped list with ${controller.enrollments.length} enrollments');
    for (int i = 0; i < controller.enrollments.length; i++) {
      final e = controller.enrollments[i];
      print('  [$i] ID: ${e.id}, Budget: "${e.budgetName}", Profile: "${e.profileEmail}", User: "${e.userEmail}"');
    }
    
    final summaries = BudgetEnrollmentSummaryDTO.fromEnrollmentList(controller.enrollments);
    print('AssignmentListWidget: Created ${summaries.length} summaries');
    
    return ListView.builder(
      controller: scrollController,
      itemCount: summaries.length + 1, // +1 para el contenedor de crear asignaciones
      itemBuilder: (context, index) {
        // Si es el Ãºltimo item, mostrar el contenedor de crear asignaciones
        if (index == summaries.length) {
          return _buildCreateAssignmentsContainer();
        }
        
        final summary = summaries[index];
        return _buildBudgetSummaryCard(summary, controller);
      },
    );
  }

  Widget _buildCreateAssignmentsContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _showBulkAssignmentDialog,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.3),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crear mÃºltiples asignaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para asignar presupuestos a perfiles',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryCard(BudgetEnrollmentSummaryDTO summary, BudgetController controller) {
    final isExpanded = _expandedBudgets.contains(summary.budgetName);
    final isSelected = selectedEnrollmentKeys.contains(summary.selectionKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  toggleEnrollmentSelection(summary.selectionKey);
                },
              ),
              title: Text(
                summary.budgetName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${summary.totalEnrollments} ${summary.totalEnrollments == 1 ? 'perfil asignado' : 'perfiles asignados'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (summary.totalEnrollments > 1)
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedBudgets.remove(summary.budgetName);
                          } else {
                            _expandedBudgets.add(summary.budgetName);
                          }
                        });
                      },
                      tooltip: isExpanded ? 'Contraer' : 'Ver perfiles',
                    ),
                ],
              ),
              onTap: () {
                toggleEnrollmentSelection(summary.selectionKey);
              },
            ),
            if (isExpanded)
              ...summary.enrollments.map((enrollment) => 
                _buildIndividualEnrollmentTile(enrollment, controller)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualEnrollmentTile(BudgetEnrollmentDTO enrollment, BudgetController controller) {
    final enrollmentKey = _getEnrollmentKey(enrollment);
    final isSelected = selectedEnrollmentKeys.contains(enrollmentKey);

    // Determine display name and subtitle
    String displayName;
    String displaySubtitle;
    
    if (enrollment.profileEmail.isNotEmpty) {
      // If we have a profile email, use it
      if (enrollment.profileEmail.contains('@')) {
        // It's an actual email
        displayName = enrollment.profileEmail.split('@')[0];
        displaySubtitle = enrollment.profileEmail;
      } else {
        // It's probably a profile name
        displayName = enrollment.profileEmail;
        displaySubtitle = 'Perfil asignado';
      }
    } else {
      // No profile email/name available
      displayName = 'Perfil #${enrollment.id}';
      displaySubtitle = enrollment.userEmail.isNotEmpty 
          ? 'Usuario: ${enrollment.userEmail}' 
          : 'ID: ${enrollment.id}';
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: ListTile(
        dense: true,
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            toggleEnrollmentSelection(enrollmentKey);
          },
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          displaySubtitle,
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          toggleEnrollmentSelection(enrollmentKey);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay asignaciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera asignaciÃ³n usando el contenedor de abajo',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}