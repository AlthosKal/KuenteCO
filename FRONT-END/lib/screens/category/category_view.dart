import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/common/category/category_list_widget.dart';
import '../../widgets/common/category/create_category_widget.dart';
import '../../widgets/common/category/delete_category_widget.dart';
import '../../widgets/common/category/edit_category_widget.dart';
import '../../widgets/common/category/assign_category_widget.dart';
import '../../core/services/app/auth_service.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final _storage = const FlutterSecureStorage();
  bool _isBusinessUser = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    Future.microtask(() =>
        Provider.of<CategoryController>(context, listen: false).loadCategories());
  }

  Future<void> _checkUserType() async {
    try {
      final role = await _storage.read(key: 'role');
      if (role == 'ROLE_PROFILE') {
        // Los perfiles no son usuarios Business
        setState(() {
          _isBusinessUser = false;
        });
        return;
      }
      
      // Para usuarios normales, verificar el userType
      final authService = AuthService();
      final user = await authService.getAuthenticatedUser();
      setState(() {
        _isBusinessUser = user.userType.toLowerCase() != 'personal';
      });
    } catch (e) {
      print('Error checking user type: $e');
      setState(() {
        _isBusinessUser = false;
      });
    }
  }

  Future<void> _handleDeleteCategory(category) async {
    final result = await DeleteCategoryWidget.showDeleteDialog(context, category);
    if (result == true) {
      // La eliminación fue exitosa, la lista se actualizará automáticamente
      // gracias al Provider y el controlador
    }
  }

  Future<void> _handleEditCategory(category) async {
    final result = await EditCategoryWidget.showEditDialog(context, category);
    if (result == true) {
      // La edición fue exitosa, la lista se actualizará automáticamente
      // gracias al Provider y el controlador
    }
  }

  Future<void> _handleAssignCategory(category) async {
    final result = await AssignCategoryWidget.showAssignDialog(context, category);
    if (result == true) {
      // La asignación fue exitosa
      // No necesitamos recargar la lista ya que no cambia las categorías
    }
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
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Mensaje de no hay categorías
                      Expanded(
                        child: Center(
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
                                'Crea tu primera categoría usando el botón de abajo',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Botón de crear categoría
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => const CreateCategoryWidget(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.purpleAccent.withValues(alpha: 0.3),
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        size: 24,
                                        color: Colors.purpleAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Crear primera categoría',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purpleAccent,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Toca para comenzar a organizar tus gastos',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.purpleAccent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.categories.length + 1, // +1 para el botón de agregar
                  itemBuilder: (context, index) {
                    // Si es el último item, mostrar el botón de agregar
                    if (index == controller.categories.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => const CreateCategoryWidget(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.purpleAccent.withValues(alpha: 0.3),
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        size: 24,
                                        color: Colors.purpleAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Crear nueva categoría',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purpleAccent,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Toca para agregar una nueva categoría',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.purpleAccent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Items normales de categorías
                    final category = controller.categories[index];
                    return CategoryListWidget(
                      category: category,
                      onTap: () => _showCategoryDetail(context, category),
                      onEdit: () => _handleEditCategory(category),
                      onDelete: () => _handleDeleteCategory(category),
                      onAssign: _isBusinessUser ? () => _handleAssignCategory(category) : null,
                    );
                  },
                ),
    );
  }
}
