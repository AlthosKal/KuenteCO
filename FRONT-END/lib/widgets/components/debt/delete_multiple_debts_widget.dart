import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/debt_controller.dart';
import '../../../dto/app/debt/debt_dto.dart';

class DeleteMultipleDebtsWidget extends StatefulWidget {
  final DebtController controller;
  final List<DebtDTO> debtsToDelete;

  const DeleteMultipleDebtsWidget({
    Key? key,
    required this.controller,
    required this.debtsToDelete,
  }) : super(key: key);

  @override
  State<DeleteMultipleDebtsWidget> createState() => _DeleteMultipleDebtsWidgetState();
}

class _DeleteMultipleDebtsWidgetState extends State<DeleteMultipleDebtsWidget> {
  bool _isLoading = false;
  final Set<int> _selectedDebtIds = {};

  void _toggleDebtSelection(int debtId, bool selected) {
    setState(() {
      if (selected) {
        _selectedDebtIds.add(debtId);
      } else {
        _selectedDebtIds.remove(debtId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedDebtIds.clear();
      _selectedDebtIds.addAll(widget.debtsToDelete.map((d) => d.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedDebtIds.clear();
    });
  }

  double _getTotalSelectedAmount() {
    return widget.debtsToDelete
        .where((debt) => _selectedDebtIds.contains(debt.id))
        .fold(0.0, (sum, debt) => sum + debt.totalAmount.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildWarningMessage(),
            _buildSelectionControls(),
            Expanded(
              child: _buildDebtsList(),
            ),
            _buildSummary(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_sweep,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eliminar Mï¿½ltiples Deudas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                Text(
                  '${widget.debtsToDelete.length} deuda(s) disponibles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ï¿½ Advertencia',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Esta acciï¿½n eliminarï¿½ permanentemente las deudas seleccionadas y no se puede deshacer.',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedDebtIds.length} de ${widget.debtsToDelete.length} seleccionadas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: _selectAll,
                child: const Text('Seleccionar Todo'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _deselectAll,
                child: const Text('Deseleccionar Todo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.debtsToDelete.length,
      itemBuilder: (context, index) {
        final debt = widget.debtsToDelete[index];
        final isSelected = _selectedDebtIds.contains(debt.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 3 : 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) => _toggleDebtSelection(debt.id, value ?? false),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.red[700] : null,
                          ),
                        ),
                        Text(
                          '\$${debt.totalAmount.toDouble().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isSelected ? Colors.red[600] : Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_getDebtDescription(debt).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getDebtDescription(debt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${debt.startDate.day}/${debt.startDate.month}/${debt.startDate.year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              activeColor: Colors.red,
              checkColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary() {
    if (_selectedDebtIds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Eliminaciï¿½n',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedDebtIds.length} deuda(s) seleccionadas',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Monto Total',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${_getTotalSelectedAmount().toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading || _selectedDebtIds.isEmpty ? null : _deleteDebts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever, size: 18),
                        const SizedBox(width: 8),
                        Text('Eliminar (${_selectedDebtIds.length})'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDebtDescription(DebtDTO debt) {
    // DebtDTO no tiene campos de descripción como TransactionDetailDTO
    // Devolvemos información básica de la deuda
    return 'Estado: ${debt.state.name} - Vence: ${debt.expirationDate.day}/${debt.expirationDate.month}/${debt.expirationDate.year}';
  }

  Future<void> _deleteDebts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<int> idsToDelete = _selectedDebtIds.toList();
      await widget.controller.deleteMultipleDebts(idsToDelete);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${idsToDelete.length} deuda(s) eliminada(s) exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar las deudas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}