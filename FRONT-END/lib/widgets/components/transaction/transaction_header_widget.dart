import 'package:flutter/material.dart';

class TransactionHeaderWidget extends StatelessWidget {
  final String? userRole;
  final TabController tabController;

  const TransactionHeaderWidget({
    super.key,
    required this.userRole,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TÃTULO
          Text(
            'Transacciones',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userRole == 'ROLE_PROFILE'
                ? 'Gestiona tus movimientos financieros'
                : 'Resumen de transacciones',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),

          /// TABS
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: userRole == 'ROLE_PROFILE'
                  ? const [
                      Tab(
                        icon: Icon(Icons.list, size: 20),
                        text: 'Mis Transacciones',
                      ),
                      Tab(
                        icon: Icon(Icons.bar_chart, size: 20),
                        text: 'Estadísticas',
                      ),
                    ]
                  : const [
                      Tab(
                        icon: Icon(Icons.dashboard, size: 20),
                        text: 'Resumen',
                      ),
                      Tab(
                        icon: Icon(Icons.account_balance_wallet, size: 20),
                        text: 'Deudas',
                      ),
                      Tab(
                        icon: Icon(Icons.analytics, size: 20),
                        text: 'Análisis',
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}