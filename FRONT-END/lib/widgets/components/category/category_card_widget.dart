import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../routes/app_routes.dart';
import '../../common/hover_card.dart';

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
        
        // ESTRATEGIA MÃS AGRESIVA: Priorizar el estado correcto sobre el error
        // Si tenemos datos válidos (aunque sea una lista vacía), mostrar el estado correcto
        final bool hasValidData = role != null && !categoryController.isLoading;
        final bool hasCategories = role != 'ROLE_PROFILE' && categoryController.categories.isNotEmpty;
        final bool hasEnrollments = role == 'ROLE_PROFILE' && categoryController.enrollments.isNotEmpty;
        final bool hasEmptyValidState = role != null && 
            ((role == 'ROLE_PROFILE' && categoryController.enrollments.isEmpty) ||
             (role != 'ROLE_PROFILE' && categoryController.categories.isEmpty));

        // Solo mostrar error si realmente no podemos mostrar una interfaz válida
        final bool shouldShowError = categoryController.errorMessage != null && 
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
    // ð¹ Si no hay categorías â mostrar botón para crear
    if (categoryController.categories.isEmpty) {
      return HoverCard(
        title: 'Categorías',
        icon: Icons.category_outlined,
        subtitle: 'Gestionar categorías',
        onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
        baseColor: const Color(0xFF890cac).withOpacity(0.3),
        hoverColor: const Color(0xFF890cac).withOpacity(0.5),
      );
    }

    // ð¹ Si hay categorías â mostrar información de la primera
    final category = categoryController.categories.first;
    return HoverCard(
      title: category.name,
      icon: Icons.folder_special,
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
      baseColor: const Color(0xFF890cac).withOpacity(0.3),
      hoverColor: const Color(0xFF890cac).withOpacity(0.5),
      customContent: Column(
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              color: Colors.white70,
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
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Widget para mostrar enrollments de perfiles
  Widget _buildEnrollmentCard(CategoryController categoryController) {
    // ð¹ Si no hay enrollments â mostrar mensaje sin navegación
    if (categoryController.enrollments.isEmpty) {
      return HoverCard(
        title: 'Categorías',
        icon: Icons.assignment_ind_outlined,
        subtitle: 'El administrador aún no te ha asignado categorías',
        onTap: () {}, // Sin navegación para perfiles sin enrollments
        baseColor: const Color(0xFF890cac).withOpacity(0.3),
        hoverColor: const Color(0xFF890cac).withOpacity(0.5),
      );
    }

    // ð¹ Si hay enrollments â mostrar información del primero
    final enrollment = categoryController.enrollments.first;
    return HoverCard(
      title: enrollment.categoryName,
      icon: Icons.assignment_turned_in,
      subtitle: '${categoryController.enrollments.length} asignada${categoryController.enrollments.length > 1 ? 's' : ''}',
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
      baseColor: const Color(0xFF890cac).withOpacity(0.3),
      hoverColor: const Color(0xFF890cac).withOpacity(0.5),
    );
  }

  /// â ï¸ Helper para mostrar card de error
  Widget _buildErrorCard({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return HoverCard(
      title: 'Error',
      icon: Icons.warning_rounded,
      subtitle: 'Toca para reintentar',
      onTap: () => Navigator.pushNamed(context, AppRoutes.categoryView),
      baseColor: const Color(0xFFFF6B6B).withOpacity(0.3),
      hoverColor: const Color(0xFFFF6B6B).withOpacity(0.5),
    );
  }
}
