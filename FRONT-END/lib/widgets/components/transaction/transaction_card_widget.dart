import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap ?? () {
        Navigator.pushNamed(context, '/transactionView');
      },
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
            Colors.blue.shade400.withOpacity(0.3),
            Colors.blue.shade600.withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
          ],
        ),
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
                Icons.swap_horiz,
                size: 28,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 12),
            
            // Título
            const Text(
              'Transacciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Información
            const Text(
              'Ver todas las transacciones',
              style: TextStyle(
                fontSize: 12,
                color: Colors.purpleAccent,
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
    
    // Determinar el tipo de transacción usando lógica híbrida
    TransactionType transactionType = _determineTransactionType(transaction!);
    
    // Determinar color e icono basado en el tipo de transacción
    Color cardColor = customColor ?? _getTransactionColorByType(transactionType);
    IconData transactionIcon = _getTransactionIconByType(transactionType);

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
                        if (_getTransactionDescription().isNotEmpty)
                          Text(
                            _getTransactionDescription(),
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

  TransactionType _determineTransactionType(TransactionDetailDTO transaction) {
    // Primero, intentar obtener el tipo desde descriptionExtra
    if (transaction.descriptionExtra?.type != null) {
      return transaction.descriptionExtra!.type;
    }
    
    // Fallback: detectar por nombre si no hay tipo explícito
    final name = transaction.name.toLowerCase();
    
    if (name.contains('ingreso') || name.contains('income')) {
      return TransactionType.INCOME;
    }
    if (name.contains('egreso') || name.contains('gasto') || name.contains('expense')) {
      return TransactionType.EXPENSE;
    }
    
    // Default a EXPENSE si no podemos determinar
    return TransactionType.EXPENSE;
  }

  Color _getTransactionColorByType(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return Colors.green;
      case TransactionType.EXPENSE:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  IconData _getTransactionIconByType(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return Icons.trending_up;
      case TransactionType.EXPENSE:
        return Icons.trending_down;
      default:
        return Icons.trending_down;
    }
  }

  String _getTransactionDescription() {
    if (transaction == null) return '';
    
    // Priorizar descriptionExtra.description si existe
    if (transaction!.descriptionExtra != null) {
      final desc = transaction!.descriptionExtra!.description;
      return (desc != null && desc != 'No description') ? desc : '';
    }
    
    // Fallback al campo description simple
    if (transaction!.description != null && transaction!.description != 'No description') {
      return transaction!.description!;
    }
    
    return '';
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
    
    // Determinar el tipo de transacción usando lógica híbrida
    TransactionType transactionType = _determineTransactionType(transaction);
    
    Color transactionColor = _getTransactionColorByType(transactionType);
    IconData transactionIcon = _getTransactionIconByType(transactionType);

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
          if (_getDescriptionText(transaction).isNotEmpty)
            Text(
              _getDescriptionText(transaction),
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

  TransactionType _determineTransactionType(TransactionDetailDTO transaction) {
    // Primero, intentar obtener el tipo desde descriptionExtra
    if (transaction.descriptionExtra?.type != null) {
      return transaction.descriptionExtra!.type;
    }
    
    // Fallback: detectar por nombre si no hay tipo explícito
    final name = transaction.name.toLowerCase();
    
    if (name.contains('ingreso') || name.contains('income')) {
      return TransactionType.INCOME;
    }
    if (name.contains('egreso') || name.contains('gasto') || name.contains('expense')) {
      return TransactionType.EXPENSE;
    }
    
    // Default a EXPENSE si no podemos determinar
    return TransactionType.EXPENSE;
  }

  Color _getTransactionColorByType(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return Colors.green;
      case TransactionType.EXPENSE:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  IconData _getTransactionIconByType(TransactionType type) {
    switch (type) {
      case TransactionType.INCOME:
        return Icons.trending_up;
      case TransactionType.EXPENSE:
        return Icons.trending_down;
      default:
        return Icons.trending_down;
    }
  }

  String _getDescriptionText(TransactionDetailDTO transaction) {
    // Priorizar descriptionExtra.description si existe
    if (transaction.descriptionExtra != null) {
      final desc = transaction.descriptionExtra!.description;
      return (desc != null && desc != 'No description') ? desc : '';
    }
    
    // Fallback al campo description simple
    if (transaction.description != null && transaction.description != 'No description') {
      return transaction.description!;
    }
    
    return '';
  }
}
