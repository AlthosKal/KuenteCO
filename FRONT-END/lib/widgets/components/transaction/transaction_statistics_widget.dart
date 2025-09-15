import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/transactions/transaction_controller.dart';
import '../../../utils/formatters.dart';

class TransactionStatisticsWidget extends StatefulWidget {
  const TransactionStatisticsWidget({super.key});

  @override
  State<TransactionStatisticsWidget> createState() => _TransactionStatisticsWidgetState();
}

class _TransactionStatisticsWidgetState extends State<TransactionStatisticsWidget> {
  String _selectedPeriod = 'month';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final controller = Provider.of<TransactionController>(context, listen: false);
    controller.loadTransactions();
    controller.loadTransactionSummaries();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con selector de período
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        
        // Tarjetas de resumen
        _buildSummaryCards(),
        const SizedBox(height: 20),
        
        // Gráfico de distribución por tipo
        _buildTypeDistribution(),
        const SizedBox(height: 20),
        
        // Lista de transacciones recientes
        _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: _selectedPeriod,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedPeriod = value);
              _loadData();
            }
          },
          items: const [
            DropdownMenuItem(value: 'week', child: Text('Esta semana')),
            DropdownMenuItem(value: 'month', child: Text('Este mes')),
            DropdownMenuItem(value: 'year', child: Text('Este año')),
            DropdownMenuItem(value: 'all', child: Text('Todo el tiempo')),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<TransactionController>(
      builder: (context, controller, child) {
        final transactions = controller.transactions;
        
        // Calcular estadísticas
        final incomes = transactions.where((t) => 
            t.name.toLowerCase().contains('ingreso') || 
            t.name.toLowerCase().contains('income')).toList();
        final expenses = transactions.where((t) => 
            t.name.toLowerCase().contains('gasto') || 
            t.name.toLowerCase().contains('expense')).toList();
        final debts = transactions.where((t) => 
            t.name.toLowerCase().contains('deuda') || 
            t.name.toLowerCase().contains('debt')).toList();
        
        final totalIncome = incomes.fold(0.0, (sum, t) => sum + t.amount);
        final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
        final totalDebts = debts.fold(0.0, (sum, t) => sum + t.amount);
        final balance = totalIncome - totalExpenses - totalDebts;

        return Column(
          children: [
            // Primera fila: Balance y Total
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Balance',
                    Formatters.formatCurrency(balance),
                    Icons.account_balance,
                    balance >= 0 ? Colors.green : Colors.red,
                    '${transactions.length} transacciones',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Movimientos',
                    Formatters.formatCurrency(controller.totalAmount),
                    Icons.swap_horiz,
                    Colors.blue,
                    'Suma de todos los movimientos',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Segunda fila: Ingresos y Gastos
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Ingresos',
                    Formatters.formatCurrency(totalIncome),
                    Icons.trending_up,
                    Colors.green,
                    '${incomes.length} registros',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Gastos',
                    Formatters.formatCurrency(totalExpenses),
                    Icons.trending_down,
                    Colors.orange,
                    '${expenses.length} registros',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tercera fila: Deudas
            if (debts.isNotEmpty)
              _buildSummaryCard(
                'Deudas',
                Formatters.formatCurrency(totalDebts),
                Icons.account_balance_wallet,
                Colors.red,
                '${debts.length} registros',
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistribution() {
    return Consumer<TransactionController>(
      builder: (context, controller, child) {
        final transactions = controller.transactions;
        
        if (transactions.isEmpty) {
          return const SizedBox.shrink();
        }

        // Calcular distribución por tipo
        final incomes = transactions.where((t) => 
            t.name.toLowerCase().contains('ingreso') || 
            t.name.toLowerCase().contains('income')).length;
        final expenses = transactions.where((t) => 
            t.name.toLowerCase().contains('gasto') || 
            t.name.toLowerCase().contains('expense')).length;
        final debts = transactions.where((t) => 
            t.name.toLowerCase().contains('deuda') || 
            t.name.toLowerCase().contains('debt')).length;
        
        final total = transactions.length;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distribución por Tipo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              if (incomes > 0)
                _buildDistributionRow(
                  'Ingresos', 
                  incomes, 
                  total, 
                  Colors.green,
                  Icons.trending_up,
                ),
              if (expenses > 0) ...[
                const SizedBox(height: 8),
                _buildDistributionRow(
                  'Gastos', 
                  expenses, 
                  total, 
                  Colors.red,
                  Icons.trending_down,
                ),
              ],
              if (debts > 0) ...[
                const SizedBox(height: 8),
                _buildDistributionRow(
                  'Deudas',
                  debts, 
                  total, 
                  Colors.orange,
                  Icons.account_balance_wallet,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDistributionRow(String label, int count, int total, Color color, IconData icon) {
    final percentage = count / total * 100;
    
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        Text(
          '$count (${percentage.toStringAsFixed(1)}%)',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Consumer<TransactionController>(
      builder: (context, controller, child) {
        if (controller.transactions.isEmpty) {
          return const SizedBox.shrink();
        }

        // Obtener las 5 transacciones más recientes
        final recentTransactions = List.from(controller.transactions)
          ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)))
          ..take(5);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Transacciones Recientes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: Navegar a la vista completa de transacciones
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              ...recentTransactions.map((transaction) {
                final isIncome = transaction.name.toLowerCase().contains('ingreso') || 
                                transaction.name.toLowerCase().contains('income');
                final isExpense = transaction.name.toLowerCase().contains('gasto') || 
                                 transaction.name.toLowerCase().contains('expense');
                final isDebt = transaction.name.toLowerCase().contains('deuda') || 
                               transaction.name.toLowerCase().contains('debt');

                Color color = Colors.blue;
                IconData icon = Icons.swap_horiz;

                if (isIncome) {
                  color = Colors.green;
                  icon = Icons.trending_up;
                } else if (isExpense) {
                  color = Colors.red;
                  icon = Icons.trending_down;
                } else if (isDebt) {
                  color = Colors.orange;
                  icon = Icons.account_balance_wallet;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              Formatters.formatDateForDisplay(transaction.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(transaction.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// Widget compacto para mostrar estadísticas en dashboard
class TransactionStatsCompactWidget extends StatelessWidget {
  const TransactionStatsCompactWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionController>(
      builder: (context, controller, child) {
        if (controller.transactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin estadísticas disponibles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega transacciones para ver estadísticas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resumen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildCompactStat(
                      'Transacciones',
                      '${controller.transactionCount}',
                      Icons.receipt,
                      Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildCompactStat(
                      'Total',
                      Formatters.formatCurrency(controller.totalAmount),
                      Icons.account_balance,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

}
