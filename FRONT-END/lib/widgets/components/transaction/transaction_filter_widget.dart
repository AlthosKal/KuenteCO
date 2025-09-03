import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/formatters.dart';

class TransactionFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback onReset;

  const TransactionFilterWidget({
    Key? key,
    required this.onFiltersChanged,
    required this.onReset,
  }) : super(key: key);

  @override
  State<TransactionFilterWidget> createState() => _TransactionFilterWidgetState();
}

class _TransactionFilterWidgetState extends State<TransactionFilterWidget> {
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedCategoryId;
  String? _selectedType;
  
  bool _hasActiveFilters = false;

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                TextButton(
                  onPressed: _resetAllFilters,
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Filtro por tipo
          _buildTypeFilter(),
          const SizedBox(height: 16),

          // Filtro por fecha
          _buildDateFilter(),
          const SizedBox(height: 16),

          // Filtro por monto
          _buildAmountFilter(),
          const SizedBox(height: 16),

          // Filtro por categoría
          _buildCategoryFilter(),
          const SizedBox(height: 20),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Transacción',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildTypeChip('income', 'Ingresos', Icons.trending_up, Colors.green),
            _buildTypeChip('expense', 'Gastos', Icons.trending_down, Colors.orange),
            _buildTypeChip('debt', 'Deudas', Icons.account_balance_wallet, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
          _updateActiveFilters();
        });
      },
      avatar: Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
      label: Text(label),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Fechas',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Desde',
                _fromDate,
                (date) => setState(() {
                  _fromDate = date;
                  _updateActiveFilters();
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                'Hasta',
                _toDate,
                (date) => setState(() {
                  _toDate = date;
                  _updateActiveFilters();
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onChanged) {
    return InkWell(
      onTap: () => _selectDate(onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(
          date != null 
              ? Formatters.formatDate(date.toIso8601String())
              : 'Seleccionar',
          style: TextStyle(
            color: date != null ? null : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Montos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto mínimo',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => _updateActiveFilters(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto máximo',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => _updateActiveFilters(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'Seleccionar categoría',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Todas las categorías'),
            ),
            // TODO: Cargar categorías reales desde el servicio
            DropdownMenuItem<int>(
              value: 1,
              child: Text('Categoría 1'),
            ),
            DropdownMenuItem<int>(
              value: 2,
              child: Text('Categoría 2'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
              _updateActiveFilters();
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(Function(DateTime?) onChanged) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      onChanged(picked);
    }
  }

  void _updateActiveFilters() {
    final hasFilters = _selectedType != null ||
        _fromDate != null ||
        _toDate != null ||
        _minAmountController.text.isNotEmpty ||
        _maxAmountController.text.isNotEmpty ||
        _selectedCategoryId != null;
    
    setState(() => _hasActiveFilters = hasFilters);
  }

  void _resetAllFilters() {
    setState(() {
      _selectedType = null;
      _fromDate = null;
      _toDate = null;
      _selectedCategoryId = null;
      _minAmountController.clear();
      _maxAmountController.clear();
      _hasActiveFilters = false;
    });
    widget.onReset();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (_selectedType != null) {
      filters['type'] = _selectedType;
    }
    
    if (_fromDate != null) {
      filters['fromDate'] = _fromDate!.toIso8601String();
    }
    
    if (_toDate != null) {
      filters['toDate'] = _toDate!.toIso8601String();
    }
    
    if (_minAmountController.text.isNotEmpty) {
      filters['minAmount'] = double.tryParse(_minAmountController.text);
    }
    
    if (_maxAmountController.text.isNotEmpty) {
      filters['maxAmount'] = double.tryParse(_maxAmountController.text);
    }
    
    if (_selectedCategoryId != null) {
      filters['categoryId'] = _selectedCategoryId;
    }
    
    widget.onFiltersChanged(filters);
  }
}

// Widget para filtros rápidos (chips horizontales)
class QuickFiltersWidget extends StatefulWidget {
  final Function(String) onFilterSelected;
  final String? selectedFilter;

  const QuickFiltersWidget({
    Key? key,
    required this.onFilterSelected,
    this.selectedFilter,
  }) : super(key: key);

  @override
  State<QuickFiltersWidget> createState() => _QuickFiltersWidgetState();
}

class _QuickFiltersWidgetState extends State<QuickFiltersWidget> {
  final List<Map<String, dynamic>> _quickFilters = [
    {'key': 'today', 'label': 'Hoy', 'icon': Icons.today},
    {'key': 'week', 'label': 'Esta semana', 'icon': Icons.date_range},
    {'key': 'month', 'label': 'Este mes', 'icon': Icons.calendar_month},
    {'key': 'income', 'label': 'Ingresos', 'icon': Icons.trending_up, 'color': Colors.green},
    {'key': 'expense', 'label': 'Gastos', 'icon': Icons.trending_down, 'color': Colors.orange},
    {'key': 'debt', 'label': 'Deudas', 'icon': Icons.account_balance_wallet, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickFilters.length,
        itemBuilder: (context, index) {
          final filter = _quickFilters[index];
          final isSelected = widget.selectedFilter == filter['key'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => widget.onFilterSelected(filter['key']),
              avatar: Icon(
                filter['icon'],
                size: 16,
                color: isSelected 
                    ? (filter['color'] ?? Theme.of(context).colorScheme.primary)
                    : Colors.grey,
              ),
              label: Text(filter['label']),
              selectedColor: (filter['color'] ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.2),
            ),
          );
        },
      ),
    );
  }
}
