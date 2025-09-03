import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/category_controller.dart';
import '../../../dto/app/category/new_category_dto.dart';
import '../../../dto/app/extra/description_category_extra.dart';
import '../../../utils/enum/state_enum.dart' as state_enum;

class CreateCategoryWidget extends StatefulWidget {
  const CreateCategoryWidget({super.key});

  @override
  State<CreateCategoryWidget> createState() => _CreateCategoryWidgetState();
}

class _CreateCategoryWidgetState extends State<CreateCategoryWidget> {
  final nameController = TextEditingController();
  final budgetController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  Future<void> _createCategory() async {
    if (nameController.text.isEmpty || budgetController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa el nombre y el presupuesto';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpiar errores previos
    });

    try {
      final controller = Provider.of<CategoryController>(context, listen: false);
      
      final descriptionCategory = DescriptionCategory(
        assignedBudget: double.parse(budgetController.text),
        state: state_enum.State.ACTIVE,
      );
      
      final newCategory = NewCategoryDTO(
        budgetId: null,
        name: nameController.text,
        description: descriptionCategory,
      );

      await controller.addCategory(newCategory);
      
      // Verificar si hay errores después de la operación
      if (mounted) {
        if (controller.errorMessage == null) {
          // Éxito - cerrar diálogo y mostrar mensaje
          Navigator.pop(context);
          _showSnackBar(
            'Categoría creada exitosamente',
            backgroundColor: Colors.green,
          );
        } else {
          // Error desde el controller - mostrar en el diálogo
          setState(() {
            _errorMessage = controller.errorMessage;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al crear categoría: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con icono y título (similar al CategoryListWidget)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bookmarks,
                        size: 24,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Crear Nueva Categoría',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Campos de formulario
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la categoría',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: budgetController,
                          decoration: const InputDecoration(
                            labelText: 'Presupuesto asignado',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            prefixText: '\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          enabled: !_isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Mensaje de error (si existe)
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Botones de acción (estilo similar a los iconos del listado)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_outlined, size: 18),
                      label: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createCategory,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_outlined, size: 18),
                      label: const Text('Crear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
