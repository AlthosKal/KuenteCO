import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/debt_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/services/api_client.dart';
import '../../core/services/app/category_service.dart';
import '../../core/services/app/debt_service.dart';
import '../../core/services/app/transaction_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/components/debt/debts_tab_widget.dart';
import '../../widgets/components/common/statistics_tab_widget.dart';
import '../../widgets/components/transaction/transaction_header_widget.dart';
import '../../widgets/components/transaction/transactions_tab_widget.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({Key? key}) : super(key: key);

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionController _transactionController;
  late DebtController _debtController;
  late CategoryController _categoryController;
  final _storage = const FlutterSecureStorage();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _transactionController = TransactionController(TransactionService(ApiClient()));
    _debtController = DebtController(DebtService(ApiClient()));
    _categoryController = CategoryController(CategoryService(ApiClient()));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('TransactionView: PostFrameCallback executing - about to call _loadDataBasedOnRole()');
      _loadDataBasedOnRole();
    });
  }
  
  /// Cargar datos según el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    try {
      print('TransactionView: Starting _loadDataBasedOnRole()');
      final role = await _storage.read(key: 'role');
      _userRole = role;
      print('TransactionView: User role detected: $role');
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar sus transacciones (puede crear/editar/eliminar)
        print('TransactionView: Loading profile transactions...');
        await _transactionController.loadTransactions();
        print('TransactionView: Profile transactions loaded, count: ${_transactionController.transactions.length}');
        // Los perfiles NO pueden acceder a deudas según el backend
        print('TransactionView: Skipping debts load for profile - not allowed by backend');
        await _categoryController.loadProfileEnrollments();
        print('TransactionView: Profile enrollments loaded');
      } else {
        // Si es un usuario de negocio, cargar todas las transacciones y deudas
        print('TransactionView: Loading business user transactions...');
        await _transactionController.loadTransactions();
        print('TransactionView: Business user transactions loaded, count: ${_transactionController.transactions.length}');
        await _debtController.loadDebts();
        print('TransactionView: Business debts loaded, count: ${_debtController.debts.length}');
        await _categoryController.loadCategories();
        print('TransactionView: Categories loaded');
      }
      
      print('TransactionView: About to call setState()');
      setState(() {}); // Actualizar UI después de detectar el rol
      print('TransactionView: setState() completed');
    } catch (e) {
      print('TransactionView: Error loading data: $e');
      print('TransactionView: Error stack trace: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transactionController.dispose();
    _debtController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionController>.value(value: _transactionController),
        ChangeNotifierProvider<DebtController>.value(value: _debtController),
        ChangeNotifierProvider<CategoryController>.value(value: _categoryController),
      ],
      child: Background(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                /// NAVBAR
                KuentecoLoggedNavbar(
                  currentRoute: '/transactions',
                  onLogout: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),

                /// HEADER CON TABS
                TransactionHeaderWidget(
                  userRole: _userRole,
                  tabController: _tabController,
                ),

                /// CONTENIDO DE TABS
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      /// TAB 1: LISTA DE TRANSACCIONES
                      TransactionsTabWidget(
                        userRole: _userRole,
                        transactionController: _transactionController,
                        categoryController: _categoryController,
                        onRefresh: _refreshTransactions,
                      ),
                      
                      /// TAB 2: DEUDAS
                      DebtsTabWidget(
                        userRole: _userRole,
                        debtController: _debtController,
                      ),
                      
                      /// TAB 3: ESTADÍSTICAS
                      StatisticsTabWidget(
                        userRole: _userRole,
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
  }

  /// Callback para refrescar la vista después de operaciones múltiples
  void _refreshTransactions() {
    if (mounted) {
      _loadDataBasedOnRole();
    }
  }
}