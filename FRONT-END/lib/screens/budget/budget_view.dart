import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../controllers/business_logic/budget_controller.dart';
import '../../core/services/app/auth_service.dart';
import '../../mixins/multi_selection_mixin.dart';
import '../../widgets/components/budget/assign_budget_to_profiles_widget.dart';
import '../../widgets/components/budget/assignment_management_widget.dart';
import '../../widgets/components/budget/budget_list_widget.dart';
import '../../widgets/components/budget/create_budget_widget.dart';
import '../../widgets/components/budget/delete_budget_widget.dart';
import '../../widgets/components/budget/delete_multiple_budgets_widget.dart';
import '../../widgets/components/budget/edit_budget_widget.dart';
import '../../widgets/components/budget/edit_multiple_budgets_widget.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> with MultiSelectionMixin {
  final _storage = const FlutterSecureStorage();
  bool _isBusinessUser = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkUserType();
      await _loadDataBasedOnRole();
    });
  }
  
  /// Cargar datos segÃºn el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    print('BudgetView: _loadDataBasedOnRole() called');
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    
    try {
      final role = await _storage.read(key: 'role');
      print('BudgetView: User role detected: $role');
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar sus enrollments de presupuestos
        print('BudgetView: Loading enrollments for profile');
        await budgetController.loadEnrollments();
      } else {
        // Si es un usuario regular, cargar sus presupuestos
        print('BudgetView: Loading budgets for regular user');
        await budgetController.loadBudgets();
      }
      print('BudgetView: Data loading completed successfully');
    } catch (e) {
      print('BudgetView: Error loading data: $e');
      // No hacer fallback para perfiles, solo para usuarios
      final role = await _storage.read(key: 'role');
      if (role != 'ROLE_PROFILE') {
        print('BudgetView: Attempting fallback loadBudgets()');
        try {
          await budgetController.loadBudgets();
          print('BudgetView: Fallback loadBudgets() succeeded');
        } catch (fallbackError) {
          print('BudgetView: Fallback also failed: $fallbackError');
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

  Future<void> _handleDeleteBudget(budget) async {
    final result = await DeleteBudgetWidget.showDeleteDialog(context, budget);
    if (result == true) {
      // La eliminaciÃ³n fue exitosa, la lista se actualizarÃ¡ automÃ¡ticamente
    }
  }

  Future<void> _handleEditBudget(budget) async {
    final result = await EditBudgetWidget.showEditDialog(context, budget);
    if (result == true) {
      // La ediciÃ³n fue exitosa, la lista se actualizarÃ¡ automÃ¡ticamente
    }
  }

  Future<void> _handleAssignBudget(budget) async {
    final result = await AssignBudgetToProfilesWidget.showAssignDialog(context, budget);
    if (result == true) {
      // La asignaciÃ³n fue exitosa
    }
  }

  void _showBudgetDetail(BuildContext context, budget) {
    final registerDateStr = "${budget.creationDate.day}/${budget.creationDate.month}/${budget.creationDate.year}";

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
                budget.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Text("Fecha de creación: $registerDateStr"),
              Text("Monto total: \$${budget.totalAmount}"),
              Text("Estado: ${budget.status}"),
              if (budget.description != null)
                Text("Descripción: ${budget.description}"),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // AquÃ­ podrÃ­as navegar a un reporte detallado si lo deseas
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
  
  /// Verificar si el usuario actual es un perfil
  Future<bool> _isProfile() async {
    final role = await _storage.read(key: 'role');
    return role == 'ROLE_PROFILE';
  }
  
  // ============= BATCH OPERATIONS =============
  
  Future<void> _showBatchCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateBudgetWidget(),
    );
    
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  Future<void> _showBatchEditDialog(BudgetController controller) async {
    final selectedBudgets = controller.budgets
        .where((budget) => selectedCategoryIds.contains(budget.id))
        .toList();
        
    if (selectedBudgets.isEmpty) {
      _showNoSelectionSnackBar('No hay presupuestos seleccionados para editar');
      return;
    }
    
    final result = await EditMultipleBudgetsWidget.showEditDialog(context, selectedBudgets);
    
    if (result == true) {
      clearSelection();
    }
  }
  
  Future<void> _showBatchDeleteDialog(BudgetController controller) async {
    final selectedBudgets = controller.budgets
        .where((budget) => selectedCategoryIds.contains(budget.id))
        .toList();
        
    if (selectedBudgets.isEmpty) {
      _showNoSelectionSnackBar('No hay presupuestos seleccionados para eliminar');
      return;
    }
    
    final result = await DeleteMultipleBudgetsWidget.showDeleteDialog(context, selectedBudgets);
    
    if (result == true) {
      clearSelection();
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
  
  PreferredSizeWidget _buildAppBar(BudgetController controller, bool isProfile) {
    // Los perfiles nunca entran en modo selecciÃ³n, solo tienen AppBar simple
    if (isSelectionMode && !isProfile) {
      // Selection mode AppBar with batch operations (solo para usuarios regulares)
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: clearSelection,
        ),
        title: Text('${selectedCategoryIds.length} seleccionados'),
        actions: [
          // Select All button
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => selectAllCategories(controller.budgets),
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
                    title: Text('Editar seleccionados'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'batch_delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Eliminar seleccionados'),
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
        title: Text(isProfile ? "Mis Presupuestos Asignados" : "Presupuestos"),
        actions: [
          // Assignment management button (only for business users)
          if (!isProfile && _isBusinessUser)
            IconButton(
              icon: const Icon(Icons.assignment_outlined),
              onPressed: () => AssignmentManagementWidget.showAssignmentManagement(context),
              tooltip: 'Gestionar asignaciones',
            ),
          
          // Multi-select toggle button (only for regular users with budgets)
          if (!isProfile && controller.budgets.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: toggleSelectionMode,
              tooltip: 'Selección múltiple',
            ),
          
          // Create budget button (only for regular users)
          if (!isProfile)
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: _showBatchCreateDialog,
              tooltip: 'Crear presupuesto',
            ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BudgetController>(context);

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
  
  /// Construir botÃ³n reutilizable para crear presupuesto
  Widget _buildCreateBudgetButton(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _showCreateBudgetDialog(),
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
                color: Colors.blueAccent.withValues(alpha: 0.3),
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
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: Colors.blueAccent,
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
                            color: Colors.blueAccent,
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
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Mostrar diÃ¡logo para crear presupuesto
  Future<void> _showCreateBudgetDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateBudgetWidget(),
    );
    if (result == true) {
      await _loadDataBasedOnRole();
    }
  }
  
  /// Vista para usuarios regulares (pueden crear/editar presupuestos)
  Widget _buildUserView(BudgetController controller) {
    if (controller.budgets.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: controller.budgets.length + 1, // +1 para el botÃ³n de agregar
      itemBuilder: (context, index) => _buildUserViewItem(context, controller, index),
    );
  }
  
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes presupuestos aún',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer presupuesto usando el botón de abajo',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          _buildCreateBudgetButton(
            'Crear primer presupuesto',
            'Toca para comenzar a gestionar tu dinero',
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserViewItem(BuildContext context, BudgetController controller, int index) {
    // Si es el Ãºltimo item, mostrar el botÃ³n de agregar
    if (index == controller.budgets.length) {
      return _buildCreateBudgetButton(
        'Crear nuevo presupuesto',
        'Toca para agregar un nuevo presupuesto',
      );
    }
    
    // Items normales de presupuestos
    final budget = controller.budgets[index];
    return BudgetListWidget(
      key: ValueKey(budget.id),
      budget: budget,
      onTap: () => _showBudgetDetail(context, budget),
      onEdit: () => _handleEditBudget(budget),
      onDelete: () => _handleDeleteBudget(budget),
      onAssign: () => _handleAssignBudget(budget),
      isSelectionMode: isSelectionMode,
      isSelected: selectedCategoryIds.contains(budget.id),
      onSelectionToggle: () {
        toggleCategorySelection(budget.id);
        enterSelectionMode();
      },
    );
  }
  
  /// Vista para perfiles (solo pueden ver presupuestos asignados)
  Widget _buildProfileView(BudgetController controller) {
    return controller.enrollments.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes presupuestos asignados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacta al administrador para que te asigne presupuestos',
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
                        color: Colors.blue.withValues(alpha: 0.3),
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
                              color: Colors.blue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              size: 24,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enrollment.budgetName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Presupuesto asignado por ${enrollment.userEmail}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
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
}