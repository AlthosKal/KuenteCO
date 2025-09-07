import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../controllers/business_logic/category_controller.dart';
import '../../core/services/app/auth_service.dart';
import '../../mixins/multi_selection_mixin.dart';
import '../../widgets/components/category/assign_category_widget.dart';
import '../../widgets/components/category/category_list_widget.dart';
import '../../widgets/components/category/create_category_widget.dart';
import '../../widgets/components/category/create_multiple_categories_widget.dart';
import '../../widgets/components/category/delete_category_widget.dart';
import '../../widgets/components/category/delete_enrollment_widget.dart' as ComponentEnrollmentDelete;
import '../../widgets/components/category/delete_multiple_categories_widget.dart';
import '../../widgets/components/category/edit_category_widget.dart';
import '../../widgets/components/category/edit_multiple_categories_widget.dart';
import '../../widgets/components/category/enrollment_management_widget.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/common/footer/footer_logged_widget.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> with MultiSelectionMixin {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isBusinessUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _checkUserType();
      await _loadDataBasedOnRole();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadDataBasedOnRole() async {
    final CategoryController categoryController = 
        Provider.of<CategoryController>(context, listen: false);
    
    try {
      final String? role = await _storage.read(key: 'role');
      
      if (role == 'ROLE_PROFILE') {
        await categoryController.loadProfileEnrollments();
      } else {
        await categoryController.loadCategories();
        
        if (_isBusinessUser) {
          try {
            await categoryController.loadEnrollments();
          } catch (enrollmentError) {
            if (mounted) {
              debugPrint('â ï¸ CategoryView: Error loading enrollment summaries: $enrollmentError');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('â Error loading data in CategoryView: $e');
      }
      
      final String? role = await _storage.read(key: 'role');
      if (role != 'ROLE_PROFILE') {
        try {
          await categoryController.loadCategories();
        } catch (fallbackError) {
          if (mounted) {
            debugPrint('â CategoryView: Fallback also failed: $fallbackError');
          }
        }
      }
    }
  }

  Future<void> _checkUserType() async {
    try {
      final String? role = await _storage.read(key: 'role');
      if (role == 'ROLE_PROFILE') {
        if (mounted) {
          setState(() => _isBusinessUser = false);
        }
        return;
      }
      
      final AuthService authService = AuthService();
      final user = await authService.getAuthenticatedUser();
      
      if (mounted) {
        setState(() {
          _isBusinessUser = user.userType.toLowerCase() != 'personal';
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('â Error checking user type: $e');
        setState(() => _isBusinessUser = false);
      }
    }
  }

  Future<void> _handleDeleteCategory(category) async {
    final result = await DeleteCategoryWidget.showDeleteDialog(context, category);
    if (result == true) {
      // Forzar recarga después de eliminación exitosa
      await _loadDataBasedOnRole();
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
      // La asignación fue exitosa - para usuarios business necesitamos
      // recargar los enrollment summaries para actualizar los contadores
      if (_isBusinessUser) {
        final categoryController = Provider.of<CategoryController>(context, listen: false);
        await categoryController.loadEnrollments();
      }
    }
  }
  
  // Método para manejar eliminación individual de asignaciones
  Future<void> _handleDeleteSingleEnrollment(enrollment) async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    
    final result = await ComponentEnrollmentDelete.EnrollmentDeleteWidget.showDeleteSingleDialog(
      context,
      categoryController,
      enrollment,
    );
    
    if (result == true) {
      // La eliminación fue exitosa, recargar los datos
      await _loadDataBasedOnRole();
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
              Text("Fecha de registro: $registerDateStr"),
              Text("Presupuesto asignado: \$${category.description.assignedBudget}"),
              Text("Presupuesto ID: ${category.budgetId ?? 'Sin asignar'}"),
              Text("Estado: ${category.description.state}"),
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
  
  /// Obtener elementos a mostrar según el rol
  List<dynamic> _getItemsToDisplay(CategoryController controller) {
    return controller.categories;
  }
  
  /// Verificar si el usuario actual es un perfil
  Future<bool> _isProfile() async {
    final role = await _storage.read(key: 'role');
    return role == 'ROLE_PROFILE';
  }
  
  // ============= BATCH OPERATIONS =============
  
  // Batch operations for categories
  Future<void> _showBatchCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateMultipleCategoriesWidget(),
    );
    
    // Si se crearon categorías exitosamente, recargar la lista
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  Future<void> _showBatchEditDialog(CategoryController controller) async {
    final selectedCategories = controller.categories
        .where((category) => selectedCategoryIds.contains(category.id))
        .toList();
        
    if (selectedCategories.isEmpty) {
      _showNoSelectionSnackBar('No hay categorías seleccionadas para editar');
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditMultipleCategoriesWidget(
        controller: controller,
        categoriesToEdit: selectedCategories,
      ),
    );
    
    clearSelection();
    
    // Si se editaron categorías exitosamente, recargar la lista
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  Future<void> _showBatchDeleteDialog(CategoryController controller) async {
    final selectedCategories = controller.categories
        .where((category) => selectedCategoryIds.contains(category.id))
        .toList();
        
    if (selectedCategories.isEmpty) {
      _showNoSelectionSnackBar('No hay categorías seleccionadas para eliminar');
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteMultipleCategoriesWidget(
        controller: controller,
        categoriesToDelete: selectedCategories,
      ),
    );
    
    clearSelection();
    
    // Si se eliminaron categorías exitosamente, recargar la lista
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  void _showNoSelectionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  // ============= APP BAR BUILDER =============
  
  PreferredSizeWidget _buildAppBar(CategoryController controller, bool isProfile) {
    if (isSelectionMode && !isProfile) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: clearSelection,
        ),
        title: Text('${selectedCategoryIds.length} seleccionadas'),
        actions: [
          // Select All button
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => selectAllCategories(controller.categories),
            tooltip: 'Seleccionar todo',
          ),
          
          // Batch operations menu (solo para usuarios regulares)
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'batch_edit':
                  _showBatchEditDialog(controller);
                  break;
                case 'batch_delete':
                  _showBatchDeleteDialog(controller);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'batch_edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Editar seleccionadas'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'batch_delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Eliminar seleccionadas'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      );
    } else {
      // Normal AppBar para perfiles (sin acciones) y usuarios regulares
      return AppBar(
        title: Text(isProfile ? "Mis Categorías Asignadas" : "Categorías"),
        actions: [
          // Multi-select toggle button (only for regular users with categories)
          if (!isProfile && controller.categories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: toggleSelectionMode,
              tooltip: 'Selección múltiple',
            ),
          
          // Enrollment management button (only for business users)
          if (!isProfile && _isBusinessUser)
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              onPressed: () => EnrollmentManagementWidget.show(context, onEnrollmentChanged: _loadDataBasedOnRole),
              tooltip: 'Gestionar asignaciones',
            ),
          
          // Batch create button (only for regular users)
          if (!isProfile)
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: _showBatchCreateDialog,
              tooltip: 'Crear múltiples categorías',
            ),
        ],
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CategoryController>(context);

    return FutureBuilder<bool>(
      future: _isProfile(),
      builder: (context, snapshot) {
        final isProfile = snapshot.data ?? false;
        
        return Background(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  /// NAVBAR
                  KuentecoLoggedNavbar(
                    currentRoute: '/categories',
                    onLogout: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),

                  /// HEADER CON TÍTULO
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categorías',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isProfile
                              ? 'Gestiona tus categorías de gastos'
                              : 'Administra las categorías de tus perfiles',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// CONTENIDO
                  Expanded(
                    child: controller.isLoading
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
                                  onPressed: () => _loadDataBasedOnRole(),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        : isProfile
                            ? _buildProfileView(controller)
                            : _buildUserView(controller),
                  ),

                  /// FOOTER
                  const FooterLoggedWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Construir botón reutilizable para crear categoría
  Widget _buildCreateCategoryButton(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _showCreateCategoryDialog(),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
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
  
  /// Mostrar diálogo para crear categoría
  Future<void> _showCreateCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateCategoryWidget(),
    );
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  /// Vista para usuarios regulares (pueden crear/editar categorías)
  Widget _buildUserView(CategoryController controller) {
    if (controller.categories.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: controller.categories.length + 1, // +1 para el botón de agregar
        itemBuilder: (context, index) => _buildUserViewItem(context, controller, index),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 24),
              _buildCreateCategoryButton(
                'Crear primera categoría',
                'Toca para comenzar a organizar tus gastos',
              ),
            ],
          ),
        ),
    );
  }
  
  Widget _buildUserViewItem(BuildContext context, CategoryController controller, int index) {
    // Si es el último item, mostrar el botón de agregar
    if (index == controller.categories.length) {
      return _buildCreateCategoryButton(
        'Crear nueva categoría',
        'Toca para agregar una nueva categoría',
      );
    }
    
    // Items normales de categorías
    final category = controller.categories[index];
    return CategoryListWidget(
      key: ValueKey(category.id),
      category: category,
      onTap: () => _showCategoryDetail(context, category),
      onEdit: () => _handleEditCategory(category),
      onDelete: () => _handleDeleteCategory(category),
      onAssign: _isBusinessUser ? () => _handleAssignCategory(category) : null,
      isSelectionMode: isSelectionMode,
      isSelected: selectedCategoryIds.contains(category.id),
      onSelectionToggle: () {
        toggleCategorySelection(category.id);
        enterSelectionMode();
      },
    );
  }
  
  /// Vista para perfiles (solo pueden ver categorías asignadas)
  Widget _buildProfileView(CategoryController controller) {
    return controller.enrollments.isEmpty
        ? Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_ind_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes categorías asignadas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contacta al administrador para que te asigne categorías',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          )
        : Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = controller.enrollments[index];
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
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
                              color: Colors.green.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assignment_turned_in,
                              size: 24,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enrollment.categoryName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Categoría asignada por ${enrollment.userEmail}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón para eliminar la asignación individual
                          IconButton(
                            onPressed: () => _handleDeleteSingleEnrollment(enrollment),
                            icon: const Icon(
                              Icons.link_off,
                              size: 20,
                              color: Colors.orange,
                            ),
                            tooltip: 'Eliminar asignación',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          );
  }
}
