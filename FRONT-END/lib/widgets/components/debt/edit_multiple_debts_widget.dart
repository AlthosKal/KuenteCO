import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../../controllers/business_logic/debt_controller.dart';
import '../../../dto/app/debt/debt_dto.dart';

class EditMultipleDebtsWidget extends StatefulWidget {
  final DebtController controller;
  final List<DebtDTO> debtsToEdit;

  const EditMultipleDebtsWidget({
    Key? key,
    required this.controller,
    required this.debtsToEdit,
  }) : super(key: key);

  @override
  State<EditMultipleDebtsWidget> createState() => _EditMultipleDebtsWidgetState();
}

class _EditMultipleDebtsWidgetState extends State<EditMultipleDebtsWidget> {
  final _formKey = GlobalKey<FormState>();
  final List<EditDebtFormData> _debtsData = [];
  bool _isLoading = false;
  final Set<int> _selectedDebtIds = {};

  @override
  void initState() {
    super.initState();
    _initializeDebtsData();
  }

  void _initializeDebtsData() {
    for (final debt in widget.debtsToEdit) {
      _debtsData.add(EditDebtFormData.fromDebt(debt));
    }
  }

  void _toggleDebtSelection(int index, bool selected) {
    setState(() {
      final debtId = widget.debtsToEdit[index].id;
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
      _selectedDebtIds.addAll(widget.debtsToEdit.map((d) => d.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedDebtIds.clear();
    });
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
            _buildSelectionControls(),
            Expanded(
              child: _buildDebtsList(),
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
        color: Colors.blue.withOpacity(0.1),
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
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note,
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
                  'Editar MÃºltiples Deudas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  '${widget.debtsToEdit.length} deuda(s) disponibles',
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

  Widget _buildSelectionControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_selectedDebtIds.length} de ${widget.debtsToEdit.length} seleccionadas',
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
    return Form(
      key: _formKey,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.debtsToEdit.length,
        itemBuilder: (context, index) {
          final debt = widget.debtsToEdit[index];
          final debtData = _debtsData[index];
          final isSelected = _selectedDebtIds.contains(debt.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 4 : 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) => _toggleDebtSelection(index, value ?? false),
                    title: Text(
                      debt.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[700] : null,
                      ),
                    ),
                    subtitle: Text(
                      'Total: \$${debt.totalAmount.toDouble().toStringAsFixed(0)} - Pendiente: \$${debt.pendingAmount.toDouble().toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected ? Colors.blue[600] : Colors.grey[600],
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildEditForm(index, debtData),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditForm(int index, EditDebtFormData debtData) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: debtData.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (_selectedDebtIds.contains(widget.debtsToEdit[index].id)) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: debtData.totalAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedDebtIds.contains(widget.debtsToEdit[index].id)) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'InvÃ¡lido';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Debe ser > 0';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: debtData.pendingAmountController,
                decoration: const InputDecoration(
                  labelText: 'Pendiente',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedDebtIds.contains(widget.debtsToEdit[index].id)) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'InvÃ¡lido';
                    }
                    final pendingAmount = double.parse(value);
                    if (pendingAmount < 0) {
                      return 'Debe ser >= 0';
                    }
                    final totalAmountText = debtData.totalAmountController.text.trim();
                    if (totalAmountText.isNotEmpty) {
                      final totalAmount = double.tryParse(totalAmountText);
                      if (totalAmount != null && pendingAmount > totalAmount) {
                        return 'No puede ser mayor al total';
                      }
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectStartDate(context, index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Inicio: ${debtData.startDate.day}/${debtData.startDate.month}/${debtData.startDate.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _selectExpirationDate(context, index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_busy, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vence: ${debtData.expirationDate.day}/${debtData.expirationDate.month}/${debtData.expirationDate.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
              onPressed: _isLoading || _selectedDebtIds.isEmpty ? null : _updateDebts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
                        const Icon(Icons.save, size: 18),
                        const SizedBox(width: 8),
                        Text('Actualizar (${_selectedDebtIds.length})'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context, int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _debtsData[index].startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _debtsData[index].startDate = picked;
      });
    }
  }

  Future<void> _selectExpirationDate(BuildContext context, int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _debtsData[index].expirationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
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
        _debtsData[index].expirationDate = picked;
      });
    }
  }

  Future<void> _updateDebts() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<DebtDTO> updateDTOs = [];

      for (int i = 0; i < widget.debtsToEdit.length; i++) {
        final debt = widget.debtsToEdit[i];
        if (_selectedDebtIds.contains(debt.id)) {
          final debtData = _debtsData[i];
          
          final totalAmount = Decimal.parse(debtData.totalAmountController.text.trim());
          final pendingAmount = Decimal.parse(debtData.pendingAmountController.text.trim());
          
          final dto = DebtDTO(
            id: debt.id,
            name: debtData.nameController.text.trim(),
            totalAmount: totalAmount,
            pendingAmount: pendingAmount,
            startDate: debtData.startDate,
            expirationDate: debtData.expirationDate,
            state: debt.state,
          );
          updateDTOs.add(dto);
        }
      }

      await widget.controller.updateMultipleDebts(updateDTOs);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updateDTOs.length} deuda(s) actualizada(s) exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar las deudas: ${e.toString()}'),
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

  @override
  void dispose() {
    for (final debtData in _debtsData) {
      debtData.dispose();
    }
    super.dispose();
  }
}

class EditDebtFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController pendingAmountController = TextEditingController();
  DateTime startDate;
  DateTime expirationDate;

  EditDebtFormData.fromDebt(DebtDTO debt) 
    : startDate = debt.startDate,
      expirationDate = debt.expirationDate {
    nameController.text = debt.name;
    totalAmountController.text = debt.totalAmount.toString();
    pendingAmountController.text = debt.pendingAmount.toString();
  }

  void dispose() {
    nameController.dispose();
    totalAmountController.dispose();
    pendingAmountController.dispose();
  }
}