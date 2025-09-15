import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/transactions/income_controller.dart';
import '../../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../../utils/formatters.dart';
import '../transaction_card_widget.dart';
import '../transaction_form_widget.dart';

// Widget principal para mostrar la vista de ingresos
class IncomeView extends StatefulWidget {
  const IncomeView({super.key});

  @override
  State<IncomeView> createState() => _IncomeViewState();
}

class _IncomeViewState extends State<IncomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IncomeController>(context, listen: false).loadIncomes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos'),
        backgroundColor: Colors.green.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showIncomeAnalytics(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen de ingresos
          _buildIncomesSummary(),
          const SizedBox(height: 8),
          // Lista de ingresos
          Expanded(child: _buildIncomesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIncomesSummary() {
    return Consumer<IncomeController>(
      builder: (context, controller, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ingresos Totales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${controller.totalIncomeCount} registros',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                Formatters.formatCurrency(controller.totalIncomeAmount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.averageIncomeAmount > 0)
                Text(
                  'Promedio: ${Formatters.formatCurrency(controller.averageIncomeAmount)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomesList() {
    return Consumer<IncomeController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar ingresos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(controller.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadIncomes(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (controller.incomes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 64,
                  color: Colors.green.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay ingresos registrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Agrega tu primer ingreso para comenzar',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddIncomeDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Ingreso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.loadIncomes(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: controller.incomes.length,
            itemBuilder: (context, index) {
              final income = controller.incomes[index];
              return TransactionCardWidget(
                transaction: income,
                customColor: Colors.green,
                onTap: () => _showIncomeDetails(income),
                onEdit: () => _showEditIncomeDialog(income),
                onDelete: () => _showDeleteIncomeDialog(income),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddIncomeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Consumer<IncomeController>(
          builder: (context, controller, child) => TransactionFormWidget(
            selectedTransactionType: 'income',
            onCreateTransaction: (dto) async {
              try {
                await controller.addIncome(dto);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingreso creado exitosamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            isLoading: controller.isLoading,
          ),
        ),
      ),
    );
  }

  void _showEditIncomeDialog(TransactionDetailDTO income) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Consumer<IncomeController>(
          builder: (context, controller, child) => TransactionFormWidget(
            transaction: income,
            onCreateTransaction: (dto) {}, // No usado en modo edición
            onUpdateTransaction: (dto) async {
              try {
                await controller.updateIncome(dto);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingreso actualizado exitosamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            isLoading: controller.isLoading,
          ),
        ),
      ),
    );
  }

  void _showDeleteIncomeDialog(TransactionDetailDTO income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ingreso'),
        content: Text('Â¿Estás seguro de que deseas eliminar "${income.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          Consumer<IncomeController>(
            builder: (context, controller, child) => TextButton(
              onPressed: controller.isLoading 
                ? null 
                : () async {
                    try {
                      await controller.deleteIncome(income.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingreso eliminado exitosamente')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: controller.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncomeDetails(TransactionDetailDTO income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(income.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Monto', Formatters.formatCurrency(income.amount)),
            _buildDetailRow('Fecha', Formatters.formatDate(income.date)),
            if (income.description?.isNotEmpty == true)
              _buildDetailRow('Descripción', income.description!),
            if (income.categoryId != null)
              _buildDetailRow('Categoría', 'ID: ${income.categoryId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditIncomeDialog(income);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showIncomeAnalytics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: const IncomeAnalyticsWidget(),
      ),
    );
  }
}

// Widget para mostrar análisis de ingresos
class IncomeAnalyticsWidget extends StatelessWidget {
  const IncomeAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IncomeController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis de Ingresos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Tarjetas de estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    Formatters.formatCurrency(controller.totalIncomeAmount),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Promedio',
                    Formatters.formatCurrency(controller.averageIncomeAmount),
                    Icons.bar_chart,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Registros',
                    '${controller.totalIncomeCount}',
                    Icons.receipt,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Recientes',
                    '${controller.recentIncomes.length}',
                    Icons.schedule,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Lista de ingresos recientes
            if (controller.recentIncomes.isNotEmpty) ...[
              Text(
                'Ingresos Recientes (últimos 30 días)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.recentIncomes.length,
                  itemBuilder: (context, index) {
                    final income = controller.recentIncomes[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.green),
                      ),
                      title: Text(income.name),
                      subtitle: Text(Formatters.formatDateForDisplay(income.date)),
                      trailing: Text(
                        Formatters.formatCurrency(income.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
