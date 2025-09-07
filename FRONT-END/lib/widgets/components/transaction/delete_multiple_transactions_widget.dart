import 'package:flutter/material.dart';

import '../../../controllers/transactions/transaction_controller.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';

class DeleteMultipleTransactionsWidget extends StatefulWidget {
  final TransactionController controller;
  final List<TransactionDetailDTO> transactionsToDelete;
  
  const DeleteMultipleTransactionsWidget({
    Key? key,
    required this.controller,
    required this.transactionsToDelete,
  }) : super(key: key);

  @override
  State<DeleteMultipleTransactionsWidget> createState() =>
      _DeleteMultipleTransactionsWidgetState();
}

class _DeleteMultipleTransactionsWidgetState
    extends State<DeleteMultipleTransactionsWidget> {
  List<bool> selectedForDeletion = [];

  @override
  void initState() {
    super.initState();
    // Inicialmente todas están seleccionadas para eliminar
    selectedForDeletion = List.generate(widget.transactionsToDelete.length, (index) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eliminar Múltiples Transacciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Warning message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta acción eliminará permanentemente las transacciones seleccionadas. Esta operación no se puede deshacer.',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Seleccione las transacciones que desea eliminar:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Transactions list with checkboxes
            Expanded(
              child: ListView.builder(
                itemCount: widget.transactionsToDelete.length,
                itemBuilder: (context, index) {
                  final transaction = widget.transactionsToDelete[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: selectedForDeletion[index],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedForDeletion[index] = value ?? false;
                        });
                      },
                      title: Text(
                        transaction.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${transaction.id}'),
                          Text('Monto: \$${transaction.amount.toStringAsFixed(2)}'),
                          Text('Tipo: ${(transaction.descriptionExtra?.type ?? TransactionType.EXPENSE).name}'),
                          Text('Fecha: ${transaction.date}'),
                          if (transaction.descriptionExtra?.description != null)
                            Text('Descripción: ${transaction.descriptionExtra!.description}'),
                        ],
                      ),
                      secondary: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      activeColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Selection summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transacciones seleccionadas: ${selectedForDeletion.where((selected) => selected).length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedForDeletion = List.generate(widget.transactionsToDelete.length, (index) => true);
                          });
                        },
                        child: const Text('Seleccionar todas'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedForDeletion = List.generate(widget.transactionsToDelete.length, (index) => false);
                          });
                        },
                        child: const Text('Deseleccionar todas'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: selectedForDeletion.any((selected) => selected) 
                      ? () => _showConfirmationDialog() 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Eliminar ${selectedForDeletion.where((selected) => selected).length} Transacciones',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    final selectedCount = selectedForDeletion.where((selected) => selected).length;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Â¿Está seguro de que desea eliminar $selectedCount transacciones?\n\nEsta acción es irreversible y eliminará todas las transacciones seleccionadas de forma permanente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _deleteSelectedTransactions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedTransactions() async {
    // Get IDs of selected transactions
    List<int> selectedIds = [];
    for (int i = 0; i < widget.transactionsToDelete.length; i++) {
      if (selectedForDeletion[i]) {
        selectedIds.add(widget.transactionsToDelete[i].id);
      }
    }

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay transacciones seleccionadas para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Delete transactions in batch
      await widget.controller.deleteTransactionsBatch(selectedIds);

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Close delete dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedIds.length} transacciones eliminadas exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar las transacciones: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}