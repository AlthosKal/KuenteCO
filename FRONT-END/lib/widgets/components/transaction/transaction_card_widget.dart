import 'package:flutter/material.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../utils/formatters.dart';

class TransactionCardWidget extends StatelessWidget {
  final TransactionDetailDTO? transaction; // Opcional para el home
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final Color? customColor;
  final bool isHomeCard; // Para mostrar como card del home

  const TransactionCardWidget({
    Key? key,
    this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.customColor,
    this.isHomeCard = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isHomeCard) {
      return _buildHomeCard(context);
    }
    
    return _buildDetailCard(context);
  }

  Widget _buildHomeCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? () {
        Navigator.pushNamed(context, '/transactionView');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono principal
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.swap_horiz,
                size: 32,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Título
            const Text(
              'Transacciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Información
            const Text(
              'Ver todas las transacciones',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    if (transaction == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isIncome = transaction!.name.toLowerCase().contains('ingreso') || 
                    transaction!.name.toLowerCase().contains('income');
    final isExpense = transaction!.name.toLowerCase().contains('gasto') || 
                     transaction!.name.toLowerCase().contains('expense');
    final isDebt = transaction!.name.toLowerCase().contains('deuda') || 
                   transaction!.name.toLowerCase().contains('debt');

    // Determinar color basado en el tipo de transacción
    Color cardColor = customColor ?? _getTransactionColor(isIncome, isExpense, isDebt);
    IconData transactionIcon = _getTransactionIcon(isIncome, isExpense, isDebt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono, nombre y monto
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transactionIcon,
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction!.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (transaction!.description?.isNotEmpty == true)
                          Text(
                            transaction!.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(transaction!.amount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatDate(transaction!.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  if (transaction!.categoryId != null) ...[
                    Icon(
                      Icons.category,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cat. ${transaction!.categoryId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
              
              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTransactionColor(bool isIncome, bool isExpense, bool isDebt) {
    if (isIncome) return Colors.green;
    if (isExpense) return Colors.orange;
    if (isDebt) return Colors.red;
    return Colors.blue; // Default color
  }

  IconData _getTransactionIcon(bool isIncome, bool isExpense, bool isDebt) {
    if (isIncome) return Icons.trending_up;
    if (isExpense) return Icons.trending_down;
    if (isDebt) return Icons.account_balance_wallet;
    return Icons.swap_horiz; // Default icon
  }
}

// Widget compacto para listas
class TransactionListItemWidget extends StatelessWidget {
  final TransactionDetailDTO transaction;
  final VoidCallback? onTap;
  final bool showCategory;

  const TransactionListItemWidget({
    Key? key,
    required this.transaction,
    this.onTap,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.name.toLowerCase().contains('ingreso') || 
                    transaction.name.toLowerCase().contains('income');
    final isExpense = transaction.name.toLowerCase().contains('gasto') || 
                     transaction.name.toLowerCase().contains('expense');
    final isDebt = transaction.name.toLowerCase().contains('deuda') || 
                   transaction.name.toLowerCase().contains('debt');

    Color transactionColor = _getTransactionColor(isIncome, isExpense, isDebt);
    IconData transactionIcon = _getTransactionIcon(isIncome, isExpense, isDebt);

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: transactionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          transactionIcon,
          color: transactionColor,
          size: 20,
        ),
      ),
      title: Text(
        transaction.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (transaction.description?.isNotEmpty == true)
            Text(
              transaction.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          Text(
            Formatters.formatDate(transaction.date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.formatCurrency(transaction.amount),
            style: theme.textTheme.titleMedium?.copyWith(
              color: transactionColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showCategory && transaction.categoryId != null)
            Text(
              'Cat. ${transaction.categoryId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTransactionColor(bool isIncome, bool isExpense, bool isDebt) {
    if (isIncome) return Colors.green;
    if (isExpense) return Colors.orange;
    if (isDebt) return Colors.red;
    return Colors.blue;
  }

  IconData _getTransactionIcon(bool isIncome, bool isExpense, bool isDebt) {
    if (isIncome) return Icons.trending_up;
    if (isExpense) return Icons.trending_down;
    if (isDebt) return Icons.account_balance_wallet;
    return Icons.swap_horiz;
  }
}
