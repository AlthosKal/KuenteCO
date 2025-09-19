import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/budget_controller.dart';
import '../../../controllers/business_logic/category_controller.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../controllers/transactions/transaction_controller.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';
import '../../../utils/formatters.dart';
import '../../common/hover_card.dart';

class TransactionCardWidget extends StatefulWidget {
  final TransactionDetailDTO? transaction; // Opcional para el home
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final Color? customColor;
  final bool isHomeCard; // Para mostrar como card del home

  const TransactionCardWidget({
    super.key,
    this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.customColor,
    this.isHomeCard = false,
  });

  @override
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.isHomeCard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransactions();
      });
    }
  }

  Future<void> _loadTransactions() async {
    final transactionController = Provider.of<TransactionController>(context, listen: false);
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    final debtController = Provider.of<DebtController>(context, listen: false);
    
    try {
      await Future.wait([
        transactionController.loadTransactions(),
        categoryController.loadCategories(),
        budgetController.loadBudgets(),
        debtController.loadDebts(),
      ]);
    } catch (e) {
      // Error manejado por el controller
    }
  }

  String _getEntityName(TransactionDetailDTO transaction) {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    final debtController = Provider.of<DebtController>(context, listen: false);

    // Prioridad: Categoría > Presupuesto > Deuda
    if (transaction.categoryId != null) {
      final category = categoryController.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        return 'Cat: ${category.name}';
      }
    }

    if (transaction.budgetId != null) {
      final budget = budgetController.budgets
          .where((b) => b.id == transaction.budgetId)
          .firstOrNull;
      if (budget != null) {
        return 'Pres: ${budget.name}';
      }
    }

    if (transaction.debtId != null) {
      final debt = debtController.debts
          .where((d) => d.id == transaction.debtId)
          .firstOrNull;
      if (debt != null) {
        return 'Deuda: ${debt.name}';
      }
    }

    return 'Sin asignar';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHomeCard) {
      return _buildHomeCard(context);
    }
    
    return _buildDetailCard(context);
  }

  Widget _buildHomeCard(BuildContext context) {
    return Consumer<TransactionController>(
      builder: (context, transactionController, _) {
        // Si está cargando
        if (transactionController.isLoading) {
          return HoverCard(
            title: 'Transacciones',
            icon: Icons.swap_horiz,
            subtitle: 'Cargando...',
            onTap: widget.onTap ?? () {
              Navigator.pushNamed(context, '/transactionView');
            },
            baseColor: const Color(0xFF890cac).withOpacity(0.3),
            hoverColor: const Color(0xFF890cac).withOpacity(0.5),
          );
        }

        // Si hay error
        if (transactionController.errorMessage != null) {
          return HoverCard(
            title: 'Error',
            icon: Icons.warning_rounded,
            subtitle: 'Toca para reintentar',
            onTap: () => _loadTransactions(),
            baseColor: const Color(0xFFFF6B6B).withOpacity(0.3),
            hoverColor: const Color(0xFFFF6B6B).withOpacity(0.5),
          );
        }

        // Si no hay transacciones
        if (transactionController.transactions.isEmpty) {
          return HoverCard(
            title: 'Transacciones',
            icon: Icons.swap_horiz,
            subtitle: 'Gestionar transacciones',
            onTap: widget.onTap ?? () {
              Navigator.pushNamed(context, '/transactionView');
            },
            baseColor: const Color(0xFF890cac).withOpacity(0.3),
            hoverColor: const Color(0xFF890cac).withOpacity(0.5),
          );
        }

        // Si hay transacciones - mostrar información de la más reciente (ordenar por fecha)
        final sortedTransactions = List<TransactionDetailDTO>.from(transactionController.transactions)
          ..sort((a, b) => b.date.compareTo(a.date)); // Ordenar por fecha descendente (más reciente primero)
        final latestTransaction = sortedTransactions.first;
        final transactionType = _determineTransactionType(latestTransaction);
        final transactionIcon = _getTransactionIconByType(transactionType);
        final isIncome = transactionType == TransactionType.INCOME;

        return HoverCard(
          title: latestTransaction.name,
          icon: transactionIcon,
          onTap: widget.onTap ?? () {
            Navigator.pushNamed(context, '/transactionView');
          },
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
                child: Icon(
                  transactionIcon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                latestTransaction.name,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatCurrency(latestTransaction.amount),
                    style: TextStyle(
                      fontSize: 12,
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_getEntityName(latestTransaction)} • ${transactionController.transactions.length} transacción${transactionController.transactions.length > 1 ? 'es' : ''}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    if (widget.transaction == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    // Determinar el tipo de transacción usando lógica híbrida
    final TransactionType transactionType = _determineTransactionType(widget.transaction!);
    
    // Determinar color e icono basado en el tipo de transacción
    final Color cardColor = widget.customColor ?? _getTransactionColorByType(transactionType);
    final IconData transactionIcon = _getTransactionIconByType(transactionType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
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
                          widget.transaction!.name,
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
                    Formatters.formatCurrency(widget.transaction!.amount),
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
                    Formatters.formatDate(widget.transaction!.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  _buildEntityInfo(theme),
                ],
              ),
              
              if (widget.showActions) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onEdit != null)
                      TextButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    if (widget.onDelete != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: widget.onDelete,
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

  Widget _buildEntityInfo(ThemeData theme) {
    if (widget.transaction == null) return const SizedBox.shrink();
    
    final entityName = _getEntityName(widget.transaction!);
    IconData icon;
    
    if (widget.transaction!.categoryId != null) {
      icon = Icons.category;
    } else if (widget.transaction!.budgetId != null) {
      icon = Icons.account_balance_wallet;
    } else if (widget.transaction!.debtId != null) {
      icon = Icons.account_balance;
    } else {
      icon = Icons.help_outline;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          entityName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _getTransactionDescription() {
    if (widget.transaction == null) return '';
    
    // Priorizar descriptionExtra.description si existe
    if (widget.transaction!.descriptionExtra != null) {
      final desc = widget.transaction!.descriptionExtra!.description;
      return (desc != 'No description') ? desc : '';
    }
    
    // Fallback al campo description simple
    if (widget.transaction!.description != null && widget.transaction!.description != 'No description') {
      return widget.transaction!.description!;
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
    super.key,
    required this.transaction,
    this.onTap,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determinar el tipo de transacción usando lógica híbrida
    final TransactionType transactionType = _determineTransactionType(transaction);
    
    final Color transactionColor = _getTransactionColorByType(transactionType);
    final IconData transactionIcon = _getTransactionIconByType(transactionType);

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
          if (showCategory)
            Text(
              _getEntityNameStatic(transaction, context),
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
      return (desc != 'No description') ? desc : '';
    }
    
    // Fallback al campo description simple
    if (transaction.description != null && transaction.description != 'No description') {
      return transaction.description!;
    }
    
    return '';
  }

  static String _getEntityNameStatic(TransactionDetailDTO transaction, BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    final budgetController = Provider.of<BudgetController>(context, listen: false);
    final debtController = Provider.of<DebtController>(context, listen: false);

    // Prioridad: Categoría > Presupuesto > Deuda
    if (transaction.categoryId != null) {
      final category = categoryController.categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (category != null) {
        return 'Cat: ${category.name}';
      }
    }

    if (transaction.budgetId != null) {
      final budget = budgetController.budgets
          .where((b) => b.id == transaction.budgetId)
          .firstOrNull;
      if (budget != null) {
        return 'Pres: ${budget.name}';
      }
    }

    if (transaction.debtId != null) {
      final debt = debtController.debts
          .where((d) => d.id == transaction.debtId)
          .firstOrNull;
      if (debt != null) {
        return 'Deuda: ${debt.name}';
      }
    }

    return 'Sin asignar';
  }
}
