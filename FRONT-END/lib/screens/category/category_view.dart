import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/common/category/category_list_widget.dart';
import '../../widgets/common/category/create_category_widget.dart';

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


  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CategoryController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorías"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CreateCategoryWidget(),
        ),
        tooltip: 'Crear nueva categoría',
        child: const Icon(Icons.add),
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
