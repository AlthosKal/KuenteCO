import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../dto/app/category/new_category_dto.dart';
import '../../../dto/app/extra/description_category_extra.dart';
import '../../../utils/enum/state_enum.dart' as state_enum;

// Clase auxiliar para manejar formularios múltiples
class CategoryFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  
  void dispose() {
    nameController.dispose();
    budgetController.dispose();
  }
  
  bool get isValid => nameController.text.trim().isNotEmpty && budgetController.text.trim().isNotEmpty;
  
  NewCategoryDTO toNewCategoryDTO() {
    return NewCategoryDTO(
      budgetId: null,
      name: nameController.text.trim(),
      description: DescriptionCategory(
        assignedBudget: double.parse(budgetController.text.trim()),
        state: state_enum.State.ACTIVE,
      ),
    );
  }
}

class CreateMultipleCategoriesWidget extends StatefulWidget {
  const CreateMultipleCategoriesWidget({super.key});

  @override
  State<CreateMultipleCategoriesWidget> createState() => _CreateMultipleCategoriesWidgetState();
}

class _CreateMultipleCategoriesWidgetState extends State<CreateMultipleCategoriesWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  List<CategoryFormData> _categories = [CategoryFormData()];

  @override
  void initState() {
    super.initState();
    // Inicializar con una categoría
    _categories = [CategoryFormData()];
  }

  @override
  void dispose() {
    for (var category in _categories) {
      category.dispose();
    }
    super.dispose();
  }
  
  void _addCategory() {
    setState(() {
      _categories.add(CategoryFormData());
    });
  }
  
  void _removeCategory(int index) {
    if (_categories.length > 1) {
      setState(() {
        _categories[index].dispose();
        _categories.removeAt(index);
      });
    }
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

  Future<void> _createCategories() async {
    // Validar que todas las categorías tengan datos válidos
    final invalidCategories = _categories.where((cat) => !cat.isValid).toList();
    if (invalidCategories.isNotEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos de las categorías';
      });
      return;
    }

    // Validar que haya al menos 2 categorías para justificar el batch
    if (_categories.length == 1) {
      setState(() {
        _errorMessage = 'Para creación en lote, agrega al menos 2 categorías';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = Provider.of<CategoryController>(context, listen: false);
      
      // Crear múltiples categorías usando batch
      final newCategories = _categories.map((cat) => cat.toNewCategoryDTO()).toList();
      await controller.addCategoriesBatch(newCategories);
      
      if (mounted) {
        if (controller.errorMessage == null) {
          Navigator.pop(context, true);
          _showSnackBar(
            '${_categories.length} categorías creadas exitosamente',
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
          _errorMessage = 'Error al crear categorías: $e';
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

  Widget _buildCategoryForm(int index) {
    final category = _categories[index];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header de la categoría con número y botón eliminar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Categoría ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (_categories.length > 1)
                  IconButton(
                    onPressed: _isLoading ? null : () => _removeCategory(index),
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Campos del formulario
            TextField(
              controller: category.nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
                isDense: true,
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: category.budgetController,
              decoration: const InputDecoration(
                labelText: 'Presupuesto asignado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '\$ ',
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.library_add,
                        size: 24,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Crear Múltiples Categorís',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Botón para agregar categoría
                    IconButton(
                      onPressed: _isLoading ? null : _addCategory,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                      tooltip: 'Agregar categoría',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de formularios de categorías
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < _categories.length; i++)
                          _buildCategoryForm(i),
                      ],
                    ),
                  ),
                ),
                
                // Mensaje de error
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
                
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Información de categorías
                    Text(
                      '${_categories.length} categoría${_categories.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    // Botones
                    Row(
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
                          onPressed: _isLoading ? null : _createCategories,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.library_add, size: 18),
                          label: const Text('Crear Todas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<bool?> showBatchCreateDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const CreateMultipleCategoriesWidget(),
    );
  }
}
