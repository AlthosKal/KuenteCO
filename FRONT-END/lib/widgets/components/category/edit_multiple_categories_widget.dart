import 'package:flutter/material.dart';
import '../../../controllers/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';
import '../../../dto/app/extra/description_category_extra.dart';
import '../../../utils/enum/state_enum.dart' as state_enum;

class EditMultipleCategoriesWidget extends StatefulWidget {
  final CategoryController controller;
  final List<CategoryDTO> categoriesToEdit;
  
  const EditMultipleCategoriesWidget({
    Key? key,
    required this.controller,
    required this.categoriesToEdit,
  }) : super(key: key);

  @override
  _EditMultipleCategoriesWidgetState createState() => _EditMultipleCategoriesWidgetState();
}

class _EditMultipleCategoriesWidgetState extends State<EditMultipleCategoriesWidget> {
  final _formKey = GlobalKey<FormState>();
  List<CategoryDTO> editableCategories = [];

  @override
  void initState() {
    super.initState();
    // Crear copias editables de las categorías
    editableCategories = widget.categoriesToEdit.map((category) {
      return CategoryDTO(
        id: category.id,
        name: category.name,
        description: DescriptionCategory(
          assignedBudget: category.description.assignedBudget,
          state: category.description.state,
        ),
        budgetId: category.budgetId,
        registerDate: category.registerDate,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar Múltiples Categorías',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
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
            
            Text(
              'Editando ${editableCategories.length} categorías',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Categories list
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: editableCategories.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categoría ${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Name field
                            TextFormField(
                              initialValue: editableCategories[index].name,
                              decoration: InputDecoration(
                                labelText: 'Nombre de la categoría',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.category),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un nombre para la categoría';
                                }
                                if (value.length > 50) {
                                  return 'El nombre no puede exceder 50 caracteres';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                editableCategories[index] = CategoryDTO(
                                  id: editableCategories[index].id,
                                  name: value,
                                  description: editableCategories[index].description,
                                  budgetId: editableCategories[index].budgetId,
                                  registerDate: editableCategories[index].registerDate,
                                );
                              },
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Budget field
                            TextFormField(
                              initialValue: editableCategories[index].description.assignedBudget.toString(),
                              decoration: InputDecoration(
                                labelText: 'Presupuesto asignado',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un presupuesto';
                                }
                                final budget = double.tryParse(value);
                                if (budget == null) {
                                  return 'Ingrese un valor numérico válido';
                                }
                                if (budget < 0) {
                                  return 'El presupuesto no puede ser negativo';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final budget = double.tryParse(value) ?? 0.0;
                                editableCategories[index] = CategoryDTO(
                                  id: editableCategories[index].id,
                                  name: editableCategories[index].name,
                                  description: DescriptionCategory(
                                    assignedBudget: budget,
                                    state: editableCategories[index].description.state,
                                  ),
                                  budgetId: editableCategories[index].budgetId,
                                  registerDate: editableCategories[index].registerDate,
                                );
                              },
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // State dropdown
                            DropdownButtonFormField<state_enum.State>(
                              value: editableCategories[index].description.state,
                              decoration: InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                prefixIcon: const Icon(Icons.flag),
                              ),
                              items: state_enum.State.values.map((state) {
                                return DropdownMenuItem<state_enum.State>(
                                  value: state,
                                  child: Text(state.name),
                                );
                              }).toList(),
                              onChanged: (state_enum.State? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    editableCategories[index] = CategoryDTO(
                                      id: editableCategories[index].id,
                                      name: editableCategories[index].name,
                                      description: DescriptionCategory(
                                        assignedBudget: editableCategories[index].description.assignedBudget,
                                        state: newValue,
                                      ),
                                      budgetId: editableCategories[index].budgetId,
                                      registerDate: editableCategories[index].registerDate,
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
                  onPressed: () => _updateCategories(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Actualizar Categorías'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateCategories() async {
    if (!_formKey.currentState!.validate()) {
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

      // Update categories in batch
      await widget.controller.updateCategoriesBatch(editableCategories);

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Close edit dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${editableCategories.length} categorías actualizadas exitosamente'),
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
          content: Text('Error al actualizar las categorías: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
