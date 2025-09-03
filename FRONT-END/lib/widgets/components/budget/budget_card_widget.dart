import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';

import '../../../controllers/budget_controller.dart';
import '../../../routes/app_routes.dart';

class BudgetCardWidget extends StatefulWidget {
  const BudgetCardWidget({super.key});

  @override
  State<BudgetCardWidget> createState() => _BudgetCardWidgetState();
}

class _BudgetCardWidgetState extends State<BudgetCardWidget> {
  final _storage = const FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    // Cargar presupuestos cuando se monta el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceCleanStateAndLoad();
    });
  }
  
  /// Fuerza un estado limpio antes de cargar datos
  Future<void> _forceCleanStateAndLoad() async {
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    
    // Limpiar completamente el estado antes de empezar
    budgetController.clearError();
    
    // Esperar un frame para asegurar que la UI se actualice
    await Future.delayed(const Duration(milliseconds: 10));
    
    // Ahora cargar los datos
    await _loadDataBasedOnRole();
  }
  
  /// Cargar datos seg�n el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    
    try {
      final role = await _storage.read(key: 'role');
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar enrollments de presupuestos
        await budgetController.loadEnrollments();
      } else {
        // Si es un usuario regular, cargar sus presupuestos
        print('BudgetCardWidget: Loading user budgets...');
        await budgetController.loadBudgets();
      }
    } catch (e) {
      print('BudgetCardWidget: Error loading data: $e');
      // No hacer fallback para perfiles, solo para usuarios
      final role = await _storage.read(key: 'role');
      if (role != 'ROLE_PROFILE') {
        try {
          await budgetController.loadBudgets();
        } catch (fallbackError) {
          print('BudgetCardWidget: Fallback also failed: $fallbackError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetController = Provider.of<BudgetController>(context);

    // = Estado de carga
    if (budgetController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // � Estado de error
    if (budgetController.errorMessage != null) {
      return _buildErrorCard(
        errorMessage: budgetController.errorMessage!,
        onRetry: () => _loadDataBasedOnRole(),
      );
    }

    return FutureBuilder<String?>(
      future: _storage.read(key: 'role'),
      builder: (context, snapshot) {
        final role = snapshot.data;
        
        if (role == 'ROLE_PROFILE') {
          // Mostrar enrollments para perfiles
          return _buildEnrollmentCard(budgetController);
        } else {
          // Mostrar presupuestos para usuarios
          return _buildBudgetCard(budgetController);
        }
      },
    );
  }
  
  /// Widget para mostrar presupuestos de usuarios
  Widget _buildBudgetCard(BudgetController budgetController) {
    // =9 Si no hay presupuestos � mostrar bot�n para crear
    if (budgetController.budgets.isEmpty) {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
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
              const Color(0xFF2196F3).withOpacity(0.3),
              const Color(0xFF21CBF3).withOpacity(0.1),
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
                      Icons.account_balance_wallet_outlined,
                      size: 28,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Presupuestos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gestionar presupuestos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purpleAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      );
    }

    // Si existen presupuestos
    final budget = budgetController.budgets.first;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
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
            const Color(0xFF4CAF50).withOpacity(0.3),
            const Color(0xFF81C784).withOpacity(0.1),
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
                    Icons.account_balance_wallet,
                    size: 28,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  budget.name,
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
                  '\$${budget.totalBudget}',
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
                    '${budgetController.budgets.length} presupuesto${budgetController.budgets.length > 1 ? 's' : ''}',
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
  
  /// Widget para mostrar enrollments de presupuestos para perfiles
  Widget _buildEnrollmentCard(BudgetController budgetController) {
    // Si no existen enrollments
    if (budgetController.enrollments.isEmpty) {
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
                      Icons.account_balance_outlined,
                      size: 28,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Presupuestos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'El administrador aún no te ha asignado presupuestos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      );
    }

    // Si Existen enrollments
    final enrollment = budgetController.enrollments.first;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
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
            const Color(0xFF673AB7).withOpacity(0.3),
            const Color(0xFF9C27B0).withOpacity(0.1),
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
                    Icons.account_balance,
                    size: 28,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  enrollment.budgetName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Presupuesto asignado',
                  style: TextStyle(
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
                    '${budgetController.enrollments.length} asignado${budgetController.enrollments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  /// � Helper para mostrar card de error
  Widget _buildErrorCard({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
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
            const Color(0xFFFF6B6B).withOpacity(0.3),
            const Color(0xFFFF8E53).withOpacity(0.1),
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
    );
  }
}