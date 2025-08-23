import 'package:KuenteCO/widgets/common/category/create_multiple_categories_widget.dart';
import 'package:KuenteCO/widgets/common/category/delete_multiple_categories_widget.dart';
import 'package:KuenteCO/widgets/common/category/edit_multiple_categories_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/common/category/category_list_widget.dart';
import '../../widgets/common/category/create_category_widget.dart';
import '../../widgets/common/category/delete_category_widget.dart';
import '../../widgets/common/category/edit_category_widget.dart';
import '../../widgets/common/category/assign_category_widget.dart';
import '../../widgets/components/app/category/enrollment_delete_widget.dart' as ComponentEnrollmentDelete;
import '../../core/services/app/auth_service.dart';
import '../../dto/app/category/category_enrollment_dto.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final _storage = const FlutterSecureStorage();
  bool _isBusinessUser = false;
  
  // Multi-select functionality
  bool _isSelectionMode = false;
  Set<int> _selectedCategoryIds = {};
  Set<String> _selectedEnrollmentKeys = {}; // For enrollments: "categoryName-profileEmail-userEmail"

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkUserType();
      await _loadDataBasedOnRole();
    });
  }
  
  /// Cargar datos según el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    
    try {
      final role = await _storage.read(key: 'role');
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar sus inscripciones de categorías
        await categoryController.loadProfileEnrollments();
      } else {
        // Si es un usuario regular, cargar sus categorías
        await categoryController.loadCategories();
        
        // Si es usuario business, también cargar enrollment summaries (opcional)
        if (_isBusinessUser) {
          try {
            await categoryController.loadEnrollments();
            print('✅ CategoryView: Enrollment summaries loaded successfully');
          } catch (enrollmentError) {
            print('⚠️ CategoryView: Error loading enrollment summaries: $enrollmentError');
            print('📌 CategoryView: Continuing without enrollment summaries - categories will still be available');
            // No es crítico si fallan los enrollment summaries
            // Las categorías seguirán siendo visibles y funcionales
          }
        }
      }
    } catch (e) {
      print('Error loading data in CategoryView: $e');
      // No hacer fallback para perfiles, solo para usuarios
      final role = await _storage.read(key: 'role');
      if (role != 'ROLE_PROFILE') {
        try {
          await categoryController.loadCategories();
        } catch (fallbackError) {
          print('CategoryView: Fallback also failed: $fallbackError');
        }
      }
    }
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
  
  /// Obtener elementos a mostrar según el rol
  List<dynamic> _getItemsToDisplay(CategoryController controller) {
    // Para perfiles, usar enrollments pero mostrar como si fueran categorías
    // Para usuarios, usar categories normal
    return controller.categories;
  }
  
  /// Verificar si el usuario actual es un perfil
  Future<bool> _isProfile() async {
    final role = await _storage.read(key: 'role');
    return role == 'ROLE_PROFILE';
  }
  
  // ============= MULTI-SELECT AND BATCH OPERATIONS =============
  
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedCategoryIds.clear();
        _selectedEnrollmentKeys.clear();
      }
    });
  }
  
  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
      
      // Exit selection mode if no items selected
      if (_selectedCategoryIds.isEmpty && _selectedEnrollmentKeys.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }
  
  void _toggleEnrollmentSelection(String enrollmentKey) {
    setState(() {
      if (_selectedEnrollmentKeys.contains(enrollmentKey)) {
        _selectedEnrollmentKeys.remove(enrollmentKey);
      } else {
        _selectedEnrollmentKeys.add(enrollmentKey);
      }
      
      // Exit selection mode if no items selected
      if (_selectedCategoryIds.isEmpty && _selectedEnrollmentKeys.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }
  
  void _selectAllCategories(CategoryController controller) {
    setState(() {
      _selectedCategoryIds.clear();
      for (final category in controller.categories) {
        _selectedCategoryIds.add(category.id);
      }
    });
  }
  
  void _selectAllEnrollments(CategoryController controller) {
    setState(() {
      _selectedEnrollmentKeys.clear();
      for (final enrollment in controller.enrollments) {
        final key = '${enrollment.categoryName}-${enrollment.profileEmail}-${enrollment.userEmail}';
        _selectedEnrollmentKeys.add(key);
      }
    });
  }
  
  void _clearSelection() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedEnrollmentKeys.clear();
      _isSelectionMode = false;
    });
  }
  
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
        .where((category) => _selectedCategoryIds.contains(category.id))
        .toList();
        
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categorías seleccionadas para editar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditMultipleCategoriesWidget(
        controller: controller,
        categoriesToEdit: selectedCategories,
      ),
    );
    
    _clearSelection();
    
    // Si se editaron categorías exitosamente, recargar la lista
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  Future<void> _showBatchDeleteDialog(CategoryController controller) async {
    final selectedCategories = controller.categories
        .where((category) => _selectedCategoryIds.contains(category.id))
        .toList();
        
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categorías seleccionadas para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteMultipleCategoriesWidget(
        controller: controller,
        categoriesToDelete: selectedCategories,
      ),
    );
    
    _clearSelection();
    
    // Si se eliminaron categorías exitosamente, recargar la lista
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  Future<void> _showEnrollmentDeleteDialog(CategoryController controller) async {
    final selectedEnrollments = controller.enrollments
        .where((enrollment) {
          final key = '${enrollment.categoryName}-${enrollment.profileEmail}-${enrollment.userEmail}';
          return _selectedEnrollmentKeys.contains(key);
        })
        .toList();
        
    if (selectedEnrollments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay asignaciones seleccionadas para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ComponentEnrollmentDelete.EnrollmentDeleteWidget(
        controller: controller,
        enrollmentsToDelete: selectedEnrollments,
      ),
    );
    
    _clearSelection();
    
    // Si se eliminaron asignaciones exitosamente, recargar la lista
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  // Enrollment management for business users
  Future<void> _showEnrollmentManagementDialog(CategoryController controller) async {
    // Cargar enrollments si no están cargados
    if (controller.enrollmentSummaries.isEmpty) {
      await controller.loadEnrollments();
    }
    
    if (controller.enrollmentSummaries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay asignaciones de categorías para gestionar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Mostrar dialog con lista de enrollments que el usuario puede gestionar
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Handle
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
                  const SizedBox(height: 16),
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.manage_accounts, color: Colors.blue, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Gestionar Asignaciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Lista de enrollments
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: controller.enrollmentSummaries.length,
                      itemBuilder: (context, index) {
                        final enrollmentSummary = controller.enrollmentSummaries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: enrollmentSummary.totalEnrollments! > 0 ? Colors.green : Colors.grey,
                              child: Text(
                                '${enrollmentSummary.totalEnrollments ?? 0}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              enrollmentSummary.categoryName ?? 'Sin nombre',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Perfiles inscritos: ${enrollmentSummary.enrolledProfilesCount ?? 0}'),
                                Text('Estado: ${enrollmentSummary.categoryStatus ?? 'Desconocido'}'),
                                const SizedBox(height: 4),
                                Text(
                                  'Toca el ícono de personas para intentar ver asignaciones individuales',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botón para eliminar asignación individual (usando el primer ID)
                                if (enrollmentSummary.totalEnrollments == 1 && 
                                    enrollmentSummary.categoryEnrollmentIds != null &&
                                    enrollmentSummary.categoryEnrollmentIds!.isNotEmpty)
                                  IconButton(
                                    onPressed: () => _deleteIndividualEnrollment(
                                      controller, 
                                      enrollmentSummary.categoryEnrollmentIds![0],
                                      enrollmentSummary.categoryName ?? 'Categoría'
                                    ),
                                    icon: const Icon(Icons.delete, color: Colors.orange),
                                    tooltip: 'Eliminar única asignación',
                                  ),
                                // Botón para ver asignaciones individuales (solo si hay más de 1)
                                if (enrollmentSummary.totalEnrollments! > 1)
                                  IconButton(
                                    onPressed: () => _showDetailedEnrollmentsDialog(controller, enrollmentSummary),
                                    icon: const Icon(Icons.people, color: Colors.blue),
                                    tooltip: 'Ver asignaciones individuales',
                                  ),
                                // Botón para eliminar TODAS las asignaciones (solo si hay más de 1)
                                if (enrollmentSummary.totalEnrollments! > 1)
                                  IconButton(
                                    onPressed: () => _deleteAllCategoryAssignments(controller, enrollmentSummary),
                                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                                    tooltip: 'Eliminar todas las asignaciones',
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // ============= APP BAR BUILDER =============
  
  PreferredSizeWidget _buildAppBar(CategoryController controller, bool isProfile) {
    // Los perfiles nunca entran en modo selección, solo tienen AppBar simple
    if (_isSelectionMode && !isProfile) {
      // Selection mode AppBar with batch operations (solo para usuarios regulares)
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _clearSelection,
        ),
        title: Text('${_selectedCategoryIds.length} seleccionadas'),
        actions: [
          // Select All button
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => _selectAllCategories(controller),
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
              onPressed: _toggleSelectionMode,
              tooltip: 'Selección múltiple',
            ),
          
          // Enrollment management button (only for business users)
          if (!isProfile && _isBusinessUser)
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              onPressed: () => _showEnrollmentManagementDialog(controller),
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
        
        return Scaffold(
          appBar: _buildAppBar(controller, isProfile),
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
                        onPressed: () => _loadDataBasedOnRole(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : isProfile
                  ? _buildProfileView(controller)
                  : _buildUserView(controller),
        );
      },
    );
  }
  
  /// Vista para usuarios regulares (pueden crear/editar categorías)
  Widget _buildUserView(CategoryController controller) {
    return controller.categories.isEmpty
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
                          onTap: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => const CreateCategoryWidget(),
                            );
                            if (result == true) {
                              await _loadDataBasedOnRole();
                            }
                          },
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
                          onTap: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => const CreateCategoryWidget(),
                            );
                            if (result == true) {
                              await _loadDataBasedOnRole();
                            }
                          },
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
                      isSelectionMode: _isSelectionMode,
                      isSelected: _selectedCategoryIds.contains(category.id),
                      onSelectionToggle: () {
                        _toggleCategorySelection(category.id);
                        // Enter selection mode if not already in it
                        if (!_isSelectionMode) {
                          setState(() {
                            _isSelectionMode = true;
                          });
                        }
                      },
                    );
                  },
                );
  }
  
  /// Vista para perfiles (solo pueden ver categorías asignadas)
  Widget _buildProfileView(CategoryController controller) {
    return controller.enrollments.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
        : ListView.builder(
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
          );
  }
  
  // Individual delete enrollment by ID
  Future<void> _deleteIndividualEnrollment(CategoryController controller, int enrollmentId, String categoryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Asignación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se eliminará la asignación de la categoría:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '"$categoryName"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      print('📌 CategoryView: Deleting individual enrollment ID: $enrollmentId');
      print('📌 CategoryView: Category: $categoryName');
      
      await controller.deleteEnrollment(enrollmentId);
      
      // Cerrar loading
      Navigator.pop(context);
      
      // Cerrar el diálogo de gestión de asignaciones
      Navigator.pop(context);
      
      // Recargar los datos para actualizar la UI
      await _loadDataBasedOnRole();
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Asignación eliminada de "$categoryName"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Cerrar loading
      Navigator.pop(context);
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Error al eliminar asignación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('$e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
  
  // Direct delete all category assignments
  Future<void> _deleteAllCategoryAssignments(CategoryController controller, enrollmentSummary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Todas las Asignaciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se eliminarán TODAS las asignaciones de la categoría:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '"${enrollmentSummary.categoryName}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará ${enrollmentSummary.totalEnrollments} asignaciones y no se puede deshacer.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Todas'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Validar que tenemos categoryEnrollmentIds válidos
      if (enrollmentSummary.categoryEnrollmentIds == null || enrollmentSummary.categoryEnrollmentIds!.isEmpty) {
        throw Exception('No hay IDs de enrollments disponibles para eliminar');
      }
      
      print('📌 CategoryView: Attempting to delete enrollments for category: "${enrollmentSummary.categoryName}"');
      print('📌 CategoryView: Enrollment IDs to delete: ${enrollmentSummary.categoryEnrollmentIds}');
      print('📌 CategoryView: Total Enrollments: ${enrollmentSummary.totalEnrollments}');
      
      // Usar el nuevo método que utiliza categoryEnrollmentIds directamente
      await controller.deleteEnrollmentsByCategorySummary(enrollmentSummary);
      
      // Cerrar loading
      Navigator.pop(context);
      
      // Cerrar el diálogo de gestión de asignaciones
      Navigator.pop(context);
      
      // Recargar los datos para actualizar la UI
      await _loadDataBasedOnRole();
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eliminadas todas las asignaciones de "${enrollmentSummary.categoryName ?? 'Categoría sin nombre'}"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Cerrar loading
      Navigator.pop(context);
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Error al eliminar asignaciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('$e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
  
  // Detailed enrollment management dialog
  Future<void> _showDetailedEnrollmentsDialog(CategoryController controller, enrollmentSummary) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    List<dynamic> categoryEnrollments = [];
    
    try {
      // Cargar enrollments detallados
      await controller.loadDetailedEnrollments();
      
      print('🔍 Debug: Total detailed enrollments loaded: ${controller.detailedEnrollments.length}');
      print('🔍 Debug: Looking for category: "${enrollmentSummary.categoryName}"');
      
      // Filtrar enrollments por categoria
      categoryEnrollments = controller.detailedEnrollments
          .where((enrollment) => enrollment.categoryName == enrollmentSummary.categoryName)
          .toList();
      
      print('🔍 Debug: Found ${categoryEnrollments.length} enrollments for this category');
      
      // Debug: Log all detailed enrollments
      for (int i = 0; i < controller.detailedEnrollments.length; i++) {
        final enrollment = controller.detailedEnrollments[i];
        print('🔍 Debug Enrollment $i: ID=${enrollment.id}, Category="${enrollment.categoryName}", Profile="${enrollment.profileEmail}"');
      }
      
      // Cerrar loading
      Navigator.pop(context);
      
      if (categoryEnrollments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontraron asignaciones detalladas para "${enrollmentSummary.categoryName}"'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } catch (e) {
      // Cerrar loading si hay error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando asignaciones detalladas: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Handle
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
                  const SizedBox(height: 16),
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asignaciones de:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              enrollmentSummary.categoryName ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón para eliminación masiva
                      IconButton(
                        onPressed: () => _showMassDeleteForCategory(context, controller, categoryEnrollments),
                        icon: const Icon(Icons.checklist, color: Colors.orange),
                        tooltip: 'Eliminación masiva',
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Lista de enrollments detallados
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: categoryEnrollments.length,
                      itemBuilder: (context, index) {
                        final enrollment = categoryEnrollments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              enrollment.profileEmail,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Asignado por: ${enrollment.userEmail}'),
                            trailing: enrollment.id != null
                                ? IconButton(
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Eliminar Asignación'),
                                          content: Text(
                                            '¿Estás seguro de que quieres eliminar la asignación de "${enrollment.categoryName}" para ${enrollment.profileEmail}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirmed == true) {
                                        try {
                                          print('📌 CategoryView: Deleting individual enrollment ID: ${enrollment.id}');
                                          print('📌 CategoryView: Profile: ${enrollment.profileEmail}');
                                          print('📌 CategoryView: Category: ${enrollment.categoryName}');
                                          
                                          // Mostrar loading mientras se elimina
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                          
                                          await controller.deleteEnrollment(enrollment.id!);
                                          
                                          // Cerrar loading
                                          Navigator.pop(context);
                                          
                                          Navigator.pop(context); // Cerrar el diálogo detallado
                                          Navigator.pop(context); // Cerrar el diálogo de gestión
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Asignación eliminada: ${enrollment.profileEmail}'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          
                                          // Recargar todos los datos para actualizar la UI
                                          await _loadDataBasedOnRole();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error al eliminar asignación: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Eliminar asignación',
                                  )
                                : const Icon(Icons.info_outline, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Método para mostrar eliminación masiva de una categoría específica
  Future<void> _showMassDeleteForCategory(BuildContext context, CategoryController controller, List<dynamic> categoryEnrollments) async {
    // Cerrar el modal de asignaciones detalladas
    Navigator.pop(context);
    
    final result = await ComponentEnrollmentDelete.EnrollmentDeleteWidget.showDeleteMultipleDialog(
      context,
      controller,
      categoryEnrollments.cast<CategoryEnrollmentDTO>(),
    );
    
    if (result == true) {
      // Cerrar también el modal de gestión de asignaciones
      Navigator.pop(context);
      
      // Recargar la lista de resúmenes
      await controller.loadEnrollments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignaciones eliminadas exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
