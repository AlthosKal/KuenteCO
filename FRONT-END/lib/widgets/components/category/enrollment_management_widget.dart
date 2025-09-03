import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/category_controller.dart';
import 'batch_assign_category_widget.dart';

class EnrollmentManagementWidget extends StatelessWidget {
  final VoidCallback? onEnrollmentChanged;

  const EnrollmentManagementWidget({
    super.key,
    this.onEnrollmentChanged,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onEnrollmentChanged}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EnrollmentManagementWidget(onEnrollmentChanged: onEnrollmentChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CategoryController>(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHandle(),
              const SizedBox(height: 16),
              _buildHeader(context),
              _buildInfoContainer(),
              const Divider(),
              Expanded(child: _buildEnrollmentsList(controller, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.manage_accounts, color: Colors.blue, size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Gestionar Asignaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showBatchAssignDialog(context),
          icon: const Icon(Icons.assignment_add, color: Colors.green),
          tooltip: 'Asignación masiva',
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Usa el botón de asignación masiva (➕) para asignar múltiples categorías a múltiples perfiles de una vez.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentsList(CategoryController controller, ScrollController scrollController) {
    return FutureBuilder(
      future: _ensureEnrollmentsLoaded(controller),
      builder: (context, snapshot) {
        if (controller.enrollmentSummaries.isEmpty) {
          return const Center(
            child: Text('No hay asignaciones de categorías para gestionar'),
          );
        }
        
        return ListView.builder(
          controller: scrollController,
          itemCount: controller.enrollmentSummaries.length,
          itemBuilder: (context, index) {
            final enrollmentSummary = controller.enrollmentSummaries[index];
            return _buildEnrollmentCard(context, controller, enrollmentSummary);
          },
        );
      },
    );
  }

  Future<void> _ensureEnrollmentsLoaded(CategoryController controller) async {
    if (controller.enrollmentSummaries.isEmpty) {
      await controller.loadEnrollments();
    }
  }

  Widget _buildEnrollmentCard(BuildContext context, CategoryController controller, enrollmentSummary) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: enrollmentSummary.totalEnrollments! > 0 ? Colors.green : Colors.grey,
          child: Text(
            '${enrollmentSummary.totalEnrollments ?? 0}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          enrollmentSummary.categoryName ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perfiles inscritos: ${enrollmentSummary.enrolledProfilesCount ?? 0}'),
            Text('Estado: ${enrollmentSummary.categoryStatus ?? 'Desconocido'}'),
            const SizedBox(height: 4),
            Text(
              'Toca el ícono de personas para intentar ver asignaciones individuales',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: _buildEnrollmentActions(context, controller, enrollmentSummary),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEnrollmentActions(BuildContext context, CategoryController controller, enrollmentSummary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (enrollmentSummary.totalEnrollments == 1 && 
            enrollmentSummary.categoryEnrollmentIds != null &&
            enrollmentSummary.categoryEnrollmentIds!.isNotEmpty)
          IconButton(
            onPressed: () => _deleteIndividualEnrollment(
              context,
              controller, 
              enrollmentSummary.categoryEnrollmentIds![0],
              enrollmentSummary.categoryName ?? 'Categoría'
            ),
            icon: const Icon(Icons.delete, color: Colors.orange),
            tooltip: 'Eliminar única asignación',
          ),
        if (enrollmentSummary.totalEnrollments! > 1)
          IconButton(
            onPressed: () => _showDetailedEnrollmentsDialog(context, controller, enrollmentSummary),
            icon: const Icon(Icons.people, color: Colors.blue),
            tooltip: 'Ver asignaciones individuales',
          ),
        if (enrollmentSummary.totalEnrollments! > 1)
          IconButton(
            onPressed: () => _deleteAllCategoryAssignments(context, controller, enrollmentSummary),
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Eliminar todas las asignaciones',
          ),
      ],
    );
  }

  Future<void> _showBatchAssignDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const BatchAssignCategoryWidget(),
    );
    
    if (result == true) {
      Navigator.pop(context);
      final categoryController = Provider.of<CategoryController>(context, listen: false);
      await categoryController.loadEnrollments();
      
      if (onEnrollmentChanged != null) {
        onEnrollmentChanged!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignaciones masivas creadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteIndividualEnrollment(BuildContext context, CategoryController controller, int enrollmentId, String categoryName) async {
    final confirmed = await _showDeleteConfirmDialog(
      context, 
      'Eliminar Asignación',
      'Se eliminará la asignación de la categoría:\n"$categoryName"',
      'Esta acción no se puede deshacer.',
      Colors.orange,
    );
    
    if (confirmed != true) return;
    
    await _performEnrollmentDeletion(
      context,
      () => controller.deleteEnrollment(enrollmentId),
      'Asignación eliminada de "$categoryName"',
    );
  }

  Future<void> _deleteAllCategoryAssignments(BuildContext context, CategoryController controller, enrollmentSummary) async {
    final confirmed = await _showDeleteConfirmDialog(
      context,
      'Eliminar Todas las Asignaciones',
      'Se eliminarán TODAS las asignaciones de la categoría:\n"${enrollmentSummary.categoryName}"',
      'Esta acción eliminará ${enrollmentSummary.totalEnrollments} asignaciones y no se puede deshacer.',
      Colors.red,
    );
    
    if (confirmed != true) return;
    
    await _performEnrollmentDeletion(
      context,
      () => controller.deleteEnrollmentsByCategorySummary(enrollmentSummary),
      'Eliminadas todas las asignaciones de "${enrollmentSummary.categoryName ?? 'Categoría sin nombre'}"',
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, String title, String description, String warning, Color warningColor) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: warningColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: warningColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(warning, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: warningColor,
              foregroundColor: Colors.white,
            ),
            child: Text(title.contains('Todas') ? 'Eliminar Todas' : 'Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _performEnrollmentDeletion(
    BuildContext context,
    Future<void> Function() deleteAction,
    String successMessage,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await deleteAction();
      Navigator.pop(context); // Cerrar loading
      Navigator.pop(context); // Cerrar diálogo de gestión
      
      if (onEnrollmentChanged != null) {
        onEnrollmentChanged!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Error al eliminar asignación', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showDetailedEnrollmentsDialog(BuildContext context, CategoryController controller, enrollmentSummary) {
    // Implementation for detailed enrollments would go here
    // For now, showing a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asignaciones de ${enrollmentSummary.categoryName}'),
        content: Text('Total de asignaciones: ${enrollmentSummary.totalEnrollments}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}