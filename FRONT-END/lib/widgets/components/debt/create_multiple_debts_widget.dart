import 'package:flutter/material.dart';

import 'package:decimal/decimal.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../dto/app/debt/new_debt_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';

class CreateMultipleDebtsWidget extends StatefulWidget {
  final DebtController controller;
  
  const CreateMultipleDebtsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<CreateMultipleDebtsWidget> createState() => _CreateMultipleDebtsWidgetState();
}

class _CreateMultipleDebtsWidgetState extends State<CreateMultipleDebtsWidget> {
  final _formKey = GlobalKey<FormState>();
  final List<DebtFormData> _debts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addNewDebt();
  }

  void _addNewDebt() {
    setState(() {
      _debts.add(DebtFormData());
    });
  }

  void _removeDebt(int index) {
    if (_debts.length > 1) {
      setState(() {
        _debts.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildForm(),
            ),
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
              Icons.account_balance_wallet,
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
                  'Crear Múltiples Deudas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                Text(
                  'Agregar varias deudas de una vez',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_debts.length} deudas a crear',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addNewDebt,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar Deuda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _debts.length,
              itemBuilder: (context, index) {
                return _buildDebtCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(int index) {
    final debt = _debts[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Deuda ${index + 1}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (_debts.length > 1)
                  IconButton(
                    onPressed: () => _removeDebt(index),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: debt.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la deuda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: debt.totalAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto Total',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monetization_on),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Auto-llenar el monto pendiente si estÃ¡ vacÃ­o
                      if (debt.pendingAmountController.text.isEmpty) {
                        debt.pendingAmountController.text = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El monto total es requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Monto inválido';
                      }
                      if (double.parse(value) <= 0) {
                        return 'El monto debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: debt.pendingAmountController,
              decoration: const InputDecoration(
                labelText: 'Monto Pendiente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El monto pendiente es requerido';
                }
                final pendingAmount = double.tryParse(value);
                if (pendingAmount == null) {
                  return 'Monto inválido';
                }
                if (pendingAmount < 0) {
                  return 'El monto no puede ser negativo';
                }
                
                final totalAmount = double.tryParse(debt.totalAmountController.text);
                if (totalAmount != null && pendingAmount > totalAmount) {
                  return 'No puede ser mayor al total';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            /// FECHAS
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectStartDate(context, debt),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de Inicio',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                '${debt.startDate.day}/${debt.startDate.month}/${debt.startDate.year}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectExpirationDate(context, debt),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de Vencimiento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                '${debt.expirationDate.day}/${debt.expirationDate.month}/${debt.expirationDate.year}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              onPressed: _isLoading ? null : () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createDebts,
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
                      children: const [
                        Icon(Icons.save, size: 18),
                        SizedBox(width: 8),
                        Text('Crear Deudas'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createDebts() async {
    print('CreateMultipleDebtsWidget: Starting validation...');
    
    if (!_formKey.currentState!.validate()) {
      print('CreateMultipleDebtsWidget: Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('CreateMultipleDebtsWidget: Creating ${_debts.length} debts...');
      final List<NewDebtDTO> debtDTOs = [];

      for (int i = 0; i < _debts.length; i++) {
        final debt = _debts[i];
        final totalAmountText = debt.totalAmountController.text.trim();
        final pendingAmountText = debt.pendingAmountController.text.trim();
        
        print('   Processing debt ${i + 1}: "${debt.nameController.text.trim()}"');
        print('   Total: "$totalAmountText", Pending: "$pendingAmountText"');
        
        if (totalAmountText.isEmpty || pendingAmountText.isEmpty) {
          throw Exception('Debt ${i + 1}: Los campos de monto no pueden estar vacíos');
        }
        
        final totalAmount = Decimal.tryParse(totalAmountText);
        final pendingAmount = Decimal.tryParse(pendingAmountText);
        
        if (totalAmount == null || pendingAmount == null) {
          throw Exception('Debt ${i + 1}: Los montos deben ser números válidos');
        }
        
        final dto = NewDebtDTO(
          name: debt.nameController.text.trim(),
          totalAmount: totalAmount,
          pendingAmount: pendingAmount,
          startDate: debt.startDate,
          expirationDate: debt.expirationDate,
          state: StateDebt.ACTIVE,
        );
        debtDTOs.add(dto);
        print('   DTO created for debt ${i + 1}');
      }

      print('CreateMultipleDebtsWidget: All DTOs created, calling controller...');
      await widget.controller.addMultipleDebts(debtDTOs);
      print('CreateMultipleDebtsWidget: Controller call completed successfully');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_debts.length} deuda(s) creada(s) exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print(' CreateMultipleDebtsWidget: Error creating debts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear las deudas: ${e.toString()}'),
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

  Future<void> _selectStartDate(BuildContext context, DebtFormData debt) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: debt.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.red,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        debt.startDate = picked;
        // Si la fecha de vencimiento es anterior a la de inicio, ajustarla
        if (debt.expirationDate.isBefore(picked)) {
          debt.expirationDate = picked.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectExpirationDate(BuildContext context, DebtFormData debt) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: debt.expirationDate,
      firstDate: debt.startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 aÃ±os
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.red,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        debt.expirationDate = picked;
      });
    }
  }

  @override
  void dispose() {
    print('CreateMultipleDebtsWidget: Disposing ${_debts.length} debts...');
    for (final debt in _debts) {
      debt.dispose();
    }
    super.dispose();
  }
}

class DebtFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController pendingAmountController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime expirationDate = DateTime.now().add(const Duration(days: 30));

  void dispose() {
    nameController.dispose();
    totalAmountController.dispose();
    pendingAmountController.dispose();
  }
}