import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/extra/description_category_extra.dart';
import '../../../utils/enum/state_enum.dart' as state_enum;

class EditCategoryWidget extends StatefulWidget {
  final CategoryDTO category;

  const EditCategoryWidget({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryWidget> createState() => _EditCategoryWidgetState();

  /// Método estático para mostrar el diálogo de edición
  static Future<bool?> showEditDialog(
      BuildContext context,
      CategoryDTO category,
      ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditCategoryWidget(category: category);
      },
    );
  }
}

class _EditCategoryWidgetState extends State<EditCategoryWidget> {
  late final TextEditingController nameController;
  late final TextEditingController budgetController;
  late state_enum.State selectedState;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.category.name);
    budgetController = TextEditingController(
      text: widget.category.description.assignedBudget.toStringAsFixed(2),
    );
    selectedState = widget.category.description.state;
  }

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

  Future<void> _updateCategory() async {
    if (nameController.text.isEmpty || budgetController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa el nombre y el presupuesto';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = Provider.of<CategoryController>(
          context, listen: false);

      final updatedDescription = DescriptionCategory(
        assignedBudget: double.parse(budgetController.text),
        state: selectedState, // Usar el estado seleccionado
      );

      final updatedCategory = CategoryDTO(
        id: widget.category.id,
        budgetId: widget.category.budgetId,
        name: nameController.text,
        description: updatedDescription,
        registerDate: widget.category.registerDate,
      );

      print('âï¸ Original category: ${widget.category.toJson()}');
      print('âï¸ Updated category: ${updatedCategory.toJson()}');

      await controller.updateCategory(updatedCategory);

      if (mounted) {
        if (controller.errorMessage == null) {
          Navigator.pop(context, true);
          _showSnackBar(
            'Categoría "${nameController.text}" actualizada exitosamente',
            backgroundColor: Colors.green,
          );
        } else {
          setState(() {
            _errorMessage = controller.errorMessage;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al actualizar la categoría: $e';
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
      title: Row(
        children: [
          Icon(
            Icons.edit_rounded,
            color: Colors.purpleAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Editar Categoría',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<state_enum.State>(
              value: selectedState,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: state_enum.State.values.map((state) {
                return DropdownMenuItem<state_enum.State>(
                  value: state,
                  child: Text(state.name),
                );
              }).toList(),
              onChanged: _isLoading ? null : (state_enum.State? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedState = newValue;
                  });
                }
              },
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
                    Icon(Icons.error_outline, color: Colors.red.shade700,
                        size: 20),
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
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Actualizar'),
        ),
      ],
    );
  }
}