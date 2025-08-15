import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/category_controller.dart';
import '../../../routes/app_routes.dart';

class CategoryCardWidget extends StatefulWidget {
  const CategoryCardWidget({super.key});

  @override
  State<CategoryCardWidget> createState() => _CategoryCardWidgetState();
}

class _CategoryCardWidgetState extends State<CategoryCardWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar categorías cuando se monta el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryController>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);

    // 🔄 Estado de carga
    if (categoryController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ⚠️ Estado de error
    if (categoryController.errorMessage != null) {
      return _buildErrorCard(
        errorMessage: categoryController.errorMessage!,
        onRetry: () => categoryController.loadCategories(),
      );
    }

    // // 🔹 Si no hay categorías → card para crear
    // if (categoryController.categories.isEmpty) {
    //   return InkWell(
    //     onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
    //     borderRadius: BorderRadius.circular(16),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
    //         borderRadius: BorderRadius.circular(16),
    //       ),
    //       child: const Padding(
    //         padding: EdgeInsets.all(12),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Icon(Icons.add_circle_outline, size: 32, color: Colors.green),
    //             SizedBox(height: 8),
    //             Text(
    //               'Crear nueva\ncategoría',
    //               style: TextStyle(
    //                 fontSize: 14,
    //                 fontWeight: FontWeight.w600,
    //                 color: Colors.black87,
    //               ),
    //               textAlign: TextAlign.center,
    //             ),
    //             SizedBox(height: 4),
    //             Text(
    //               'Aún no tienes categorías',
    //               style: TextStyle(
    //                 fontSize: 10,
    //                 color: Colors.black54,
    //               ),
    //               textAlign: TextAlign.center,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // 🔹 Si hay categorías → mostrar la primera
    final category = categoryController.categories.first;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              category.description.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '💰 ID: ${category.budgetId}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ⚠️ Helper para mostrar card de error
  Widget _buildErrorCard({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(height: 8),
          const Text(
            'Error al cargar categorías',
            style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.categoryView),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text(
                    'Ir a Categorías',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
