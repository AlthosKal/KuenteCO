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
    return AlertDialog(
      title: const Text('Crear Nueva Categoría'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(
                labelText: 'Presupuesto asignado',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isLoading,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
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
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createCategory,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }

}
