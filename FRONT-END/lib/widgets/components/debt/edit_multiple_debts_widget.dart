import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:decimal/decimal.dart';
import '../../../controllers/debt_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';

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
                  'Editar M�ltiples Deudas',
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
                      'Monto actual: \$${debt.totalAmount.toDouble().toStringAsFixed(2)}',
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
                controller: debtData.amountController,
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
                      return 'Inv�lido';
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
        TextFormField(
          controller: debtData.descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripci�n',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Consumer<CategoryController>(
          builder: (context, categoryController, child) {
            final categories = categoryController.categories;
            
            return DropdownButtonFormField<int>(
              value: debtData.selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categor�a',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Sin categor�a'),
                ),
                ...categories.map((category) => DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  debtData.selectedCategoryId = value;
                });
              },
            );
          },
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
          
          final newAmount = Decimal.parse(debtData.amountController.text.trim());
          
          final dto = DebtDTO(
            id: debt.id,
            name: debtData.nameController.text.trim(),
            totalAmount: newAmount,
            pendingAmount: debt.pendingAmount, // Mantener el monto pendiente actual
            startDate: debt.startDate,
            expirationDate: debt.expirationDate,
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
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int? selectedCategoryId;

  EditDebtFormData.fromDebt(DebtDTO debt) {
    nameController.text = debt.name;
    amountController.text = debt.totalAmount.toString();
    
    // DebtDTO no tiene campos de descripción como TransactionDetailDTO
    // Inicializamos con información básica
    descriptionController.text = 'Deuda: ${debt.name}';
    
    selectedCategoryId = null; // DebtDTO no tiene categoryId
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    descriptionController.dispose();
  }
}