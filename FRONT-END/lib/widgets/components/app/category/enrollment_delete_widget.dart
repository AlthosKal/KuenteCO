import 'package:flutter/material.dart';
import '../../../../controllers/category_controller.dart';
import '../../../../dto/app/category/category_enrollment_dto.dart';

class EnrollmentDeleteWidget extends StatefulWidget {
  final CategoryController controller;
  final List<CategoryEnrollmentDTO> enrollmentsToDelete;
  
  const EnrollmentDeleteWidget({
    Key? key,
    required this.controller,
    required this.enrollmentsToDelete,
  }) : super(key: key);

  @override
  _EnrollmentDeleteWidgetState createState() => _EnrollmentDeleteWidgetState();
}

class _EnrollmentDeleteWidgetState extends State<EnrollmentDeleteWidget> {
  List<bool> selectedForDeletion = [];

  @override
  void initState() {
    super.initState();
    // Inicialmente todas están seleccionadas para eliminar
    selectedForDeletion = List.generate(widget.enrollmentsToDelete.length, (index) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eliminar Asignaciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
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
            
            // Warning message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará las asignaciones de categorías a perfiles. Los perfiles ya no tendrán acceso a estas categorías.',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Seleccione las asignaciones que desea eliminar:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Enrollments list with checkboxes
            Expanded(
              child: ListView.builder(
                itemCount: widget.enrollmentsToDelete.length,
                itemBuilder: (context, index) {
                  final enrollment = widget.enrollmentsToDelete[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: selectedForDeletion[index],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedForDeletion[index] = value ?? false;
                        });
                      },
                      title: Text(
                        enrollment.categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Perfil: ${enrollment.profileEmail}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.business, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Usuario: ${enrollment.userEmail}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      secondary: const Icon(
                        Icons.link_off,
                        color: Colors.orange,
                      ),
                      activeColor: Colors.orange,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Selection summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asignaciones seleccionadas: ${selectedForDeletion.where((selected) => selected).length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedForDeletion = List.generate(widget.enrollmentsToDelete.length, (index) => true);
                          });
                        },
                        child: const Text('Seleccionar todas'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedForDeletion = List.generate(widget.enrollmentsToDelete.length, (index) => false);
                          });
                        },
                        child: const Text('Deseleccionar todas'),
                      ),
                    ],
                  ),
                ],
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
                  onPressed: selectedForDeletion.any((selected) => selected) 
                      ? () => _showConfirmationDialog() 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Eliminar ${selectedForDeletion.where((selected) => selected).length} Asignaciones',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    final selectedCount = selectedForDeletion.where((selected) => selected).length;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar eliminación de asignaciones',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Está seguro de que desea eliminar $selectedCount asignaciones de categorías?\n\nEsta acción eliminará el acceso de los perfiles a estas categorías, pero no eliminará las categorías en sí.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _deleteSelectedEnrollments();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Asignaciones'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedEnrollments() async {
    // Get enrollments to delete
    List<CategoryEnrollmentDTO> selectedEnrollments = [];
    for (int i = 0; i < widget.enrollmentsToDelete.length; i++) {
      if (selectedForDeletion[i]) {
        selectedEnrollments.add(widget.enrollmentsToDelete[i]);
      }
    }

    if (selectedEnrollments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay asignaciones seleccionadas para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show info message about limitation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nota: La eliminación de asignaciones requiere más información del servidor. '
          'Esta funcionalidad necesita ser completada cuando el backend proporcione los IDs de enrollment necesarios.'
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
      ),
    );

    // Close the dialog for now
    Navigator.of(context).pop();

    /* TODO: Implementar cuando el backend proporcione los IDs de enrollment
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

      // Delete enrollments one by one (since there's no batch delete for enrollments)
      int deletedCount = 0;
      List<String> errors = [];
      
      for (CategoryEnrollmentDTO enrollment in selectedEnrollments) {
        try {
          // Need enrollment ID from backend to delete
          // await widget.controller.deleteEnrollment(enrollment.id!);
          deletedCount++;
        } catch (e) {
          errors.add('Error eliminando ${enrollment.categoryName}: ${e.toString()}');
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Close delete dialog
      Navigator.of(context).pop();

      // Show result message
      if (deletedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deletedCount asignaciones eliminadas exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errores: ${errors.join(', ')}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar las asignaciones: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
    */
  }
}
