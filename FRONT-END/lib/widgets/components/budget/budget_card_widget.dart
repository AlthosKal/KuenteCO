import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/budget_controller.dart';
import '../../../routes/app_routes.dart';
import '../../common/hover_card.dart';

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
  
  /// Cargar datos segï¿½n el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    
    try {
      final role = await _storage.read(key: 'role');
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar enrollments de presupuestos
        await budgetController.loadEnrollments();
      } else {
        // Si es un usuario regular, cargar sus presupuestos
        await budgetController.loadBudgets();
      }
    } catch (e) {
      // No hacer fallback para perfiles, solo para usuarios
      final role = await _storage.read(key: 'role');
      if (role != 'ROLE_PROFILE') {
        try {
          await budgetController.loadBudgets();
        } catch (fallbackError) {
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

    // ï¿½ Estado de error
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
    // =9 Si no hay presupuestos ï¿½ mostrar botï¿½n para crear
    if (budgetController.budgets.isEmpty) {
      return HoverCard(
        title: 'Presupuestos',
        icon: Icons.account_balance_wallet_outlined,
        subtitle: 'Gestionar presupuestos',
        onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
        baseColor: const Color(0xFF890cac).withOpacity(0.3),
        hoverColor: const Color(0xFF890cac).withOpacity(0.5),
      );
    }

    // Si existen presupuestos
    final budget = budgetController.budgets.first;
    return HoverCard(
      title: budget.name,
      icon: Icons.account_balance_wallet,
      onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
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
              Icons.account_balance_wallet,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            budget.name,
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
            '\$${budget.totalBudget}',
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
              '${budgetController.budgets.length} presupuesto${budgetController.budgets.length > 1 ? 's' : ''}',
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
  
  /// Widget para mostrar enrollments de presupuestos para perfiles
  Widget _buildEnrollmentCard(BudgetController budgetController) {
    // Si no existen enrollments
    if (budgetController.enrollments.isEmpty) {
      return HoverCard(
        title: 'Presupuestos',
        icon: Icons.account_balance_outlined,
        subtitle: 'El administrador aún no te ha asignado presupuestos',
        onTap: () {}, // Sin navegación para perfiles sin enrollments
        baseColor: const Color(0xFF890cac).withOpacity(0.3),
        hoverColor: const Color(0xFF890cac).withOpacity(0.5),
      );
    }

    // Si Existen enrollments
    final enrollment = budgetController.enrollments.first;
    return HoverCard(
      title: enrollment.budgetName,
      icon: Icons.account_balance,
      subtitle: '${budgetController.enrollments.length} asignado${budgetController.enrollments.length > 1 ? 's' : ''}',
      onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
      baseColor: const Color(0xFF890cac).withOpacity(0.3),
      hoverColor: const Color(0xFF890cac).withOpacity(0.5),
    );
  }

  /// ï¿½ Helper para mostrar card de error
  Widget _buildErrorCard({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return HoverCard(
      title: 'Error',
      icon: Icons.warning_rounded,
      subtitle: 'Toca para reintentar',
      onTap: () => Navigator.pushNamed(context, AppRoutes.budgetView),
      baseColor: const Color(0xFFFF6B6B).withOpacity(0.3),
      hoverColor: const Color(0xFFFF6B6B).withOpacity(0.5),
    );
  }
}