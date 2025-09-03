import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:decimal/decimal.dart';
import '../../../controllers/debt_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../dto/app/debt/new_debt_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';

class CreateMultipleDebtsWidget extends StatefulWidget {
  const CreateMultipleDebtsWidget({Key? key}) : super(key: key);

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
                  'Crear M�ltiples Deudas',
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
                  '${_debts.length} deuda(s) a crear',
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
                    controller: debt.amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El monto es requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Monto inv�lido';
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
              controller: debt.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripci�n (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Consumer<CategoryController>(
              builder: (context, categoryController, child) {
                final categories = categoryController.categories;
                
                if (categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No hay categor�as disponibles',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return DropdownButtonFormField<int>(
                  value: debt.selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categor�a (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
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
                      debt.selectedCategoryId = value;
                    });
                  },
                );
              },
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final debtController = Provider.of<DebtController>(context, listen: false);
      final List<NewDebtDTO> debtDTOs = [];

      for (final debt in _debts) {
        final amount = Decimal.parse(debt.amountController.text.trim());
        
        final dto = NewDebtDTO(
          transactionId: 1, // TODO: Obtener el ID de transacción real
          name: debt.nameController.text.trim(),
          totalAmount: amount,
          pendingAmount: amount, // Inicialmente, todo el monto está pendiente
          startDate: debt.startDate,
          expirationDate: debt.expirationDate,
          state: StateDebt.ACTIVE,
        );
        debtDTOs.add(dto);
      }

      await debtController.addMultipleDebts(debtDTOs);

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
}

class DebtFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int? selectedCategoryId;
  DateTime startDate = DateTime.now();
  DateTime expirationDate = DateTime.now().add(Duration(days: 30));

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    descriptionController.dispose();
  }
}