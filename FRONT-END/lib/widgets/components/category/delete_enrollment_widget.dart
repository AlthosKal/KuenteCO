import 'package:flutter/material.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../dto/app/category/category_enrollment_dto.dart';

class EnrollmentDeleteWidget extends StatefulWidget {
  final CategoryController controller;
  final List<CategoryEnrollmentDTO> enrollmentsToDelete;
  final bool isSingleMode;

  const EnrollmentDeleteWidget({
    Key? key,
    required this.controller,
    required this.enrollmentsToDelete,
    this.isSingleMode = false,
  }) : super(key: key);

  // MÃ©todo estÃ¡tico para eliminaciÃ³n individual
  static Future<bool?> showDeleteSingleDialog(
      BuildContext context,
      CategoryController controller,
      CategoryEnrollmentDTO enrollment,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EnrollmentDeleteWidget(
        controller: controller,
        enrollmentsToDelete: [enrollment],
        isSingleMode: true,
      ),
    );
  }

  // MÃ©todo estÃ¡tico para eliminaciÃ³n masiva
  static Future<bool?> showDeleteMultipleDialog(
      BuildContext context,
      CategoryController controller,
      List<CategoryEnrollmentDTO> enrollments,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EnrollmentDeleteWidget(
        controller: controller,
        enrollmentsToDelete: enrollments,
        isSingleMode: false,
      ),
    );
  }

  @override
  _EnrollmentDeleteWidgetState createState() => _EnrollmentDeleteWidgetState();
}

class _EnrollmentDeleteWidgetState extends State<EnrollmentDeleteWidget> {
  List<bool> selectedForDeletion = [];

  @override
  void initState() {
    super.initState();
    selectedForDeletion = List.generate(widget.enrollmentsToDelete.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSingleMode && widget.enrollmentsToDelete.length == 1) {
      return _buildSingleModeDialog();
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header con tÃ­tulo y botÃ³n eliminar todas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eliminar Asignaciones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: selectedForDeletion.any((selected) => selected)
                          ? () => _showConfirmationDialog()
                          : null,
                      icon: const Icon(Icons.delete_forever),
                      color: Colors.redAccent,
                      tooltip: 'Eliminar seleccionadas',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Advertencia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acciÃ³n eliminarÃ¡ las asignaciones seleccionadas. Los perfiles ya no tendrÃ¡n acceso a estas categorÃ­as.',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lista de asignaciones
            Expanded(
              child: ListView.builder(
                itemCount: widget.enrollmentsToDelete.length,
                itemBuilder: (context, index) {
                  final enrollment = widget.enrollmentsToDelete[index];
                  return Card(
                    elevation: 1,
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Perfil: ${enrollment.profileEmail}', style: TextStyle(color: Colors.grey[600])),
                          Text('Usuario: ${enrollment.userEmail}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      secondary: const Icon(Icons.link_off, color: Colors.orange),
                      activeColor: Colors.orange,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // SelecciÃ³n rÃ¡pida
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionadas: ${selectedForDeletion.where((s) => s).length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedForDeletion = List.generate(widget.enrollmentsToDelete.length, (_) => true);
                        });
                      },
                      child: const Text('Todas'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedForDeletion = List.generate(widget.enrollmentsToDelete.length, (_) => false);
                        });
                      },
                      child: const Text('Ninguna'),
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

  void _showConfirmationDialog() {
    final selectedCount = selectedForDeletion.where((s) => s).length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar eliminaciÃ³n',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Text('Â¿EstÃ¡ seguro de que desea eliminar $selectedCount asignaciones?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedEnrollments();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedEnrollments() async {
    final selectedEnrollments = [
      for (int i = 0; i < widget.enrollmentsToDelete.length; i++)
        if (selectedForDeletion[i]) widget.enrollmentsToDelete[i],
    ];

    if (selectedEnrollments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay asignaciones seleccionadas para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que las asignaciones tengan IDs vÃ¡lidos
    final validEnrollments = selectedEnrollments
        .where((enrollment) => enrollment.id != null && enrollment.id! > 0)
        .toList();
        
    if (validEnrollments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las asignaciones seleccionadas no tienen IDs vÃ¡lidos para eliminaciÃ³n'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (validEnrollments.length != selectedEnrollments.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solo ${validEnrollments.length} de ${selectedEnrollments.length} asignaciones pueden eliminarse'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Usar eliminaciÃ³n por lotes para mejor rendimiento
      final enrollmentIds = validEnrollments.map((e) => e.id!).toList();
      print('ð EnrollmentDeleteWidget: Using batch deletion for ${enrollmentIds.length} enrollments');
      
      await widget.controller.deleteEnrollmentsByIds(enrollmentIds);
      
      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).pop(true); // Cierra el dialog principal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${validEnrollments.length} asignaciones eliminadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('â EnrollmentDeleteWidget: Batch deletion failed: $e');
      Navigator.of(context).pop(); // Cierra loading
      
      // Intentar eliminaciÃ³n individual como fallback
      await _fallbackIndividualDeletion(validEnrollments);
    }
  }
  
  // MÃ©todo de respaldo para eliminaciÃ³n individual
  Future<void> _fallbackIndividualDeletion(List<CategoryEnrollmentDTO> enrollments) async {
    print('ð EnrollmentDeleteWidget: Attempting fallback individual deletion');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      int deletedCount = 0;
      List<String> errors = [];
      
      for (var enrollment in enrollments) {
        try {
          await widget.controller.deleteEnrollment(enrollment.id!);
          deletedCount++;
        } catch (individualError) {
          errors.add('Error eliminando ${enrollment.categoryName}: ${individualError.toString()}');
          print('â EnrollmentDeleteWidget: Individual delete failed for ${enrollment.categoryName}: $individualError');
        }
      }
      
      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).pop(deletedCount > 0); // Cierra el dialog principal
      
      // Mostrar resultado
      if (deletedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deletedCount asignaciones eliminadas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Algunos errores: ${errors.first}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).pop(false); // Cierra el dialog principal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar las asignaciones: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildSingleModeDialog() {
    final enrollment = widget.enrollmentsToDelete.first;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Eliminar AsignaciÃ³n', style: TextStyle(color: Colors.orange)),
      content: Text('Â¿EstÃ¡ seguro de eliminar la asignaciÃ³n "${enrollment.categoryName}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => _deleteSingleEnrollment(enrollment),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }

  Future<void> _deleteSingleEnrollment(CategoryEnrollmentDTO enrollment) async {
    print('ð EnrollmentDeleteWidget: Starting single enrollment deletion');
    print('ð EnrollmentDeleteWidget: Enrollment ID: ${enrollment.id}');
    print('ð EnrollmentDeleteWidget: Category: ${enrollment.categoryName}');
    print('ð EnrollmentDeleteWidget: Profile: ${enrollment.profileEmail}');
    
    // Validar que la asignaciÃ³n tenga un ID vÃ¡lido
    if (enrollment.id == null || enrollment.id! <= 0) {
      print('â EnrollmentDeleteWidget: Invalid enrollment ID detected: ${enrollment.id}');
      Navigator.of(context).pop(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La asignaciÃ³n no tiene un ID vÃ¡lido para eliminaciÃ³n (ID: ${enrollment.id})'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator())
    );
    
    try {
      print('â EnrollmentDeleteWidget: Enrollment ID is valid, proceeding with deletion');
      await widget.controller.deleteEnrollment(enrollment.id!);
      
      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).pop(true); // Cierra dialog con Ã©xito
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AsignaciÃ³n de "${enrollment.categoryName}" eliminada exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      print('â EnrollmentDeleteWidget: Single enrollment deleted successfully');
    } catch (e) {
      print('â EnrollmentDeleteWidget: Error deleting single enrollment: $e');
      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).pop(false); // Cierra dialog con fallo
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la asignaciÃ³n: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
