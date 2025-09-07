import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../controllers/business_logic/category_controller.dart';
import '../../controllers/business_logic/debt_controller.dart';
import '../../controllers/transactions/transaction_controller.dart';
import '../../core/services/api_client.dart';
import '../../core/services/app/category_service.dart';
import '../../core/services/app/debt_service.dart';
import '../../core/services/app/transaction_service.dart';
import '../../widgets/common/background/background_widget.dart';
import '../../widgets/common/navbar/navbar_logged_widget.dart';
import '../../widgets/common/statistics_tab_widget.dart';
import '../../widgets/components/debt/debts_tab_widget.dart';
import '../../widgets/components/transaction/transaction_header_widget.dart';
import '../../widgets/components/transaction/transactions_tab_widget.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({Key? key}) : super(key: key);

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late TransactionController _transactionController;
  late DebtController _debtController;
  late CategoryController _categoryController;
  final _storage = const FlutterSecureStorage();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _transactionController = TransactionController(TransactionService(ApiClient()));
    _debtController = DebtController(DebtService(ApiClient()));
    _categoryController = CategoryController(CategoryService(ApiClient()));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataBasedOnRole();
    });
  }
  
  /// Cargar datos según el rol del usuario
  Future<void> _loadDataBasedOnRole() async {
    try {
      final role = await _storage.read(key: 'role');
      _userRole = role;
      
      // Inicializar TabController según el rol del usuario
      // Los perfiles solo tienen 2 tabs (sin deudas), los usuarios tienen 3 tabs
      final tabCount = (role == 'ROLE_PROFILE') ? 2 : 3;
      _tabController = TabController(length: tabCount, vsync: this);
      
      if (role == 'ROLE_PROFILE') {
        // Si es un perfil, cargar sus transacciones (puede crear/editar/eliminar)
        // Los perfiles NO pueden acceder a deudas
        await _transactionController.loadTransactions();
        await _categoryController.loadProfileEnrollments();
      } else {
        // Si es un usuario, cargar todas las transacciones y deudas
        await _transactionController.loadTransactions();
        await _debtController.loadDebts();
        await _categoryController.loadCategories();
      }
      
      setState(() {}); // Actualizar UI después de detectar el rol
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _transactionController.dispose();
    _debtController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading si aún no se ha inicializado el TabController
    if (_tabController == null) {
      return Background(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                KuentecoLoggedNavbar(
                  currentRoute: '/transactions',
                  onLogout: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                  tabController: _tabController!,
                ),

                /// CONTENIDO DE TABS
                Expanded(
                  child: TabBarView(
                    controller: _tabController!,
                    children: _buildTabViews(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye las vistas de tabs según el rol del usuario
  List<Widget> _buildTabViews() {
    final List<Widget> tabs = [
      /// TAB 1: LISTA DE TRANSACCIONES
      TransactionsTabWidget(
        userRole: _userRole,
        transactionController: _transactionController,
        categoryController: _categoryController,
        onRefresh: _refreshTransactions,
      ),
    ];

    // Solo agregar tab de deudas si NO es un perfil
    if (_userRole != 'ROLE_PROFILE') {
      tabs.add(
        /// TAB 2: DEUDAS (solo para usuarios, no perfiles)
        DebtsTabWidget(
          userRole: _userRole,
          debtController: _debtController,
        ),
      );
    }

    // TAB FINAL: ESTADÃSTICAS
    tabs.add(
      StatisticsTabWidget(
        userRole: _userRole,
      ),
    );

    return tabs;
  }

  /// Callback para refrescar la vista después de operaciones múltiples
  void _refreshTransactions() {
    if (mounted) {
      _loadDataBasedOnRole();
    }
  }
}