import 'package:flutter/material.dart';

import '../../../controllers/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';

class DeleteMultipleCategoriesWidget extends StatefulWidget {
  final CategoryController controller;
  final List<CategoryDTO> categoriesToDelete;
  
  const DeleteMultipleCategoriesWidget({
    Key? key,
    required this.controller,
    required this.categoriesToDelete,
  }) : super(key: key);

  @override
  _DeleteMultipleCategoriesWidgetState createState() => _DeleteMultipleCategoriesWidgetState();
}

class _DeleteMultipleCategoriesWidgetState extends State<DeleteMultipleCategoriesWidget> {
  List<bool> selectedForDeletion = [];

  @override
  void initState() {
    super.initState();
    // Inicialmente todas están seleccionadas para eliminar
    selectedForDeletion = List.generate(widget.categoriesToDelete.length, (index) => true);
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
                  'Eliminar Múltiples Categorías',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará permanentemente las categorías seleccionadas. Esta operación no se puede deshacer.',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Seleccione las categorías que desea eliminar:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Categories list with checkboxes
            Expanded(
              child: ListView.builder(
                itemCount: widget.categoriesToDelete.length,
                itemBuilder: (context, index) {
                  final category = widget.categoriesToDelete[index];
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
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${category.id}'),
                          Text('Presupuesto: \$${category.description.assignedBudget.toStringAsFixed(2)}'),
                          Text('Estado: ${category.description.state.name}'),
                          Text('Fecha: ${category.registerDate.toString().split(' ')[0]}'),
                        ],
                      ),
                      secondary: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      activeColor: Colors.red,
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
                    'Categorías seleccionadas: ${selectedForDeletion.where((selected) => selected).length}',
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
                            selectedForDeletion = List.generate(widget.categoriesToDelete.length, (index) => true);
                          });
                        },
                        child: const Text('Seleccionar todas'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedForDeletion = List.generate(widget.categoriesToDelete.length, (index) => false);
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
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Eliminar ${selectedForDeletion.where((selected) => selected).length} Categorías',
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
            'Confirmar eliminación',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Está seguro de que desea eliminar $selectedCount categorías?\n\nEsta acción es irreversible y eliminará todas las categorías seleccionadas de forma permanente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _deleteSelectedCategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedCategories() async {
    // Get IDs of selected categories
    List<int> selectedIds = [];
    for (int i = 0; i < widget.categoriesToDelete.length; i++) {
      if (selectedForDeletion[i]) {
        selectedIds.add(widget.categoriesToDelete[i].id);
      }
    }

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categorías seleccionadas para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

      // Delete categories in batch
      await widget.controller.deleteCategoriesBatch(selectedIds);

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Close delete dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedIds.length} categorías eliminadas exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar las categorías: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
