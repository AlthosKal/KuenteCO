import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';

import '../../../controllers/category_controller.dart';
import '../../../routes/app_routes.dart';

class CategoryCardWidget extends StatefulWidget {
  const CategoryCardWidget({super.key});

  @override
  State<CategoryCardWidget> createState() => _CategoryCardWidgetState();
}

class _CategoryCardWidgetState extends State<CategoryCardWidget> {
  final _storage = const FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    // Cargar categorías cuando se monta el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceCleanStateAndLoad();
    });
  }
  
  /// Fuerza un estado limpio antes de cargar datos
  Future<void> _forceCleanStateAndLoad() async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    
    // Limpiar completamente el estado antes de empezar
    categoryController.clearError();
    
    // Esperar un frame para asegurar que la UI se actualice
    await Future.delayed(const Duration(milliseconds: 10));
    
    // Ahora cargar los datos
    await _loadDataBasedOnRole();
  }
  
  /// Cargar datos según el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    
    // Forzar limpieza del error antes de cargar
    categoryController.clearError();
    
    try {
      final role = await _storage.read(key: 'role');
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar sus inscripciones de categorías
        await categoryController.loadProfileEnrollments();
      } else {
        // Si es un usuario regular, cargar sus categorías
        await categoryController.loadCategories();
      }
      
      // Asegurar que el error esté limpio después de cargar exitosamente
      // Esto es especialmente importante cuando se obtiene una lista vacía válida
      if (categoryController.errorMessage == null || 
          categoryController.errorMessage!.isEmpty ||
          categoryController.errorMessage!.toLowerCase().contains('empty') ||
          categoryController.errorMessage!.toLowerCase().contains('no data') ||
          categoryController.errorMessage!.toLowerCase().contains('not found')) {
        categoryController.clearError();
      }
      
    } catch (e) {
      // No hacer fallback para perfiles, solo para usuarios
      final role = await _storage.read(key: 'role');
      if (role != 'ROLE_PROFILE') {
        try {
          await categoryController.loadCategories();
          // Limpiar error después del fallback exitoso
          categoryController.clearError();
        } catch (fallbackError) {
          // Error en fallback - mantener el error original
        }
      } else {
        // Para perfiles, si hay error verificar si es realmente un error o lista vacía
        if (e.toString().toLowerCase().contains('empty') ||
            e.toString().toLowerCase().contains('no data') ||
            e.toString().toLowerCase().contains('not found') ||
            e.toString().contains('404')) {
          categoryController.clearError();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);

    // Si está cargando, mostrar loading
    if (categoryController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: _storage.read(key: 'role'),
      builder: (context, snapshot) {
        final role = snapshot.data;
        
        // ESTRATEGIA MÁS AGRESIVA: Priorizar el estado correcto sobre el error
        // Si tenemos datos válidos (aunque sea una lista vacía), mostrar el estado correcto
        bool hasValidData = role != null && !categoryController.isLoading;
        bool hasCategories = role != 'ROLE_PROFILE' && categoryController.categories.isNotEmpty;
        bool hasEnrollments = role == 'ROLE_PROFILE' && categoryController.enrollments.isNotEmpty;
        bool hasEmptyValidState = role != null && 
            ((role == 'ROLE_PROFILE' && categoryController.enrollments.isEmpty) ||
             (role != 'ROLE_PROFILE' && categoryController.categories.isEmpty));

        // Solo mostrar error si realmente no podemos mostrar una interfaz válida
        bool shouldShowError = categoryController.errorMessage != null && 
            categoryController.errorMessage!.isNotEmpty &&
            !hasValidData &&
            !hasCategories &&
            !hasEnrollments &&
            !hasEmptyValidState &&
            // Excluir errores que sabemos que son de listas vacías válidas
            !categoryController.errorMessage!.contains('Data field is a string message') &&
            !categoryController.errorMessage!.toLowerCase().contains('empty') &&
            !categoryController.errorMessage!.toLowerCase().contains('no data') &&
            !categoryController.errorMessage!.toLowerCase().contains('not found') &&
            !categoryController.errorMessage!.contains('404');

        if (shouldShowError) {
          return _buildErrorCard(
            errorMessage: categoryController.errorMessage!,
            onRetry: () => _loadDataBasedOnRole(),
          );
        }
        
        // Si llegamos aquí, siempre mostrar la interfaz correcta (con o sin datos)
        if (role == 'ROLE_PROFILE') {
          return _buildEnrollmentCard(categoryController);
        } else {
          return _buildCategoryCard(categoryController);
        }
      },
    );
  }
  
  /// Widget para mostrar categorías de usuarios
  Widget _buildCategoryCard(CategoryController categoryController) {
    // 🔹 Si no hay categorías → mostrar botón para crear
    if (categoryController.categories.isEmpty) {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
        borderRadius: BorderRadius.circular(20),
        child: GlassmorphicContainer(
          width: 180,
          height: 180,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.3),
              const Color(0xFF4CAF50).withOpacity(0.1),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    size: 28,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gestionar categorías',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🔹 Si hay categorías → mostrar información de la primera
    final category = categoryController.categories.first;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
      borderRadius: BorderRadius.circular(20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.3),
            const Color(0xFF764ba2).withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.5),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_special,
                  size: 28,
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${category.description.assignedBudget}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${categoryController.categories.length} categoría${categoryController.categories.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Widget para mostrar enrollments de perfiles
  Widget _buildEnrollmentCard(CategoryController categoryController) {
    // 🔹 Si no hay enrollments → mostrar mensaje sin navegación
    if (categoryController.enrollments.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: GlassmorphicContainer(
          width: 180,
          height: 180,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF890cac).withOpacity(0.3),
              const Color(0xFF890cac).withOpacity(0.3),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_ind_outlined,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'El administrador aún no te ha asignado categorías',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🔹 Si hay enrollments → mostrar información del primero
    final enrollment = categoryController.enrollments.first;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF56AB2F), Color(0xFFA8E6CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in,
                    size: 28,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  enrollment.categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Categorías asignadas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${categoryController.enrollments.length} asignada${categoryController.enrollments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ⚠️ Helper para mostrar card de error
  Widget _buildErrorCard({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 28,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Toca para reintentar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
