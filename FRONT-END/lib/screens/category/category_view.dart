import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/category_controller.dart';
import '../../dto/app/category/new_category_dto.dart';
import '../../dto/app/extra/description_category_extra.dart';
import '../../utils/enum/state_enum.dart' as StateEnum;
import '../../widgets/common/category/category_list_widget.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CategoryController>(context, listen: false).loadCategories());
  }

  void _showCategoryDetail(BuildContext context, category) {
    final registerDateStr = "${category.registerDate.day}/${category.registerDate.month}/${category.registerDate.year}";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 8,
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
              const SizedBox(height: 10),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Text("📅 Fecha de registro: $registerDateStr"),
              Text("💰 Presupuesto asignado: \$${category.description.assignedBudget}"),
              Text("💰 Presupuesto ID: ${category.budgetId ?? 'Sin asignar'}"),
              Text("🔄 Estado: ${category.description.state}"),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Aquí podrías navegar a un reporte detallado si lo deseas
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text("Ver reporte completo"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final controller = Provider.of<CategoryController>(context, listen: false);
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    final budgetIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: budgetIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID del presupuesto (opcional)',
                        border: OutlineInputBorder(),
                        helperText: 'Dejar vacío si no hay presupuesto asociado',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        budgetController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, completa el nombre y el presupuesto'),
                        ),
                      );
                      return;
                    }

                    try {
                      final descriptionCategory = DescriptionCategory(
                        assignedBudget: double.parse(budgetController.text),
                        state: StateEnum.State.ACTIVE,
                      );
                      
                      final newCategory = NewCategoryDTO(
                        budgetId: budgetIdController.text.isNotEmpty 
                            ? int.parse(budgetIdController.text) 
                            : null,
                        name: nameController.text,
                        description: descriptionCategory,
                      );

                      await controller.addCategory(newCategory);
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Categoría creada exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al crear la categoría: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CategoryController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorías"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCategoryDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Crear nueva categoría',
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadCategories(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : controller.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes categorías aún',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presiona el botón + para crear tu primera categoría',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return CategoryListWidget(
                      category: category,
                      onTap: () => _showCategoryDetail(context, category),
                    );
                  },
                ),
    );
  }
}
