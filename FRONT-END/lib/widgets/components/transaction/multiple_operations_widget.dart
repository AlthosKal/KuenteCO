import 'package:flutter/material.dart';

class MultipleOperationsWidget extends StatefulWidget {
  final String title;
  final Color color;
  final VoidCallback? onCreateMultiple;
  final VoidCallback? onEditMultiple;
  final VoidCallback? onDeleteMultiple;
  final VoidCallback? onSingleOperation;
  final String singleOperationLabel;

  const MultipleOperationsWidget({
    super.key,
    required this.title,
    required this.color,
    this.onCreateMultiple,
    this.onEditMultiple,
    this.onDeleteMultiple,
    this.onSingleOperation,
    this.singleOperationLabel = 'Nueva Operación',
  });

  @override
  State<MultipleOperationsWidget> createState() => _MultipleOperationsWidgetState();
}

class _MultipleOperationsWidgetState extends State<MultipleOperationsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título y botón expandible
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 12),
              
              // Si hay una sola operación, mostrar solo ese botón
              if (widget.onSingleOperation != null && widget.onCreateMultiple == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onSingleOperation,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(widget.singleOperationLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ]
              // Si hay operaciones múltiples, mostrar botón expandible
              else if (widget.onCreateMultiple != null || widget.onEditMultiple != null || widget.onDeleteMultiple != null) ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        const Text(
                          'Operaciones Múltiples',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Opciones expandibles
        if (_isExpanded && (widget.onCreateMultiple != null || widget.onEditMultiple != null || widget.onDeleteMultiple != null))
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                if (widget.onCreateMultiple != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onCreateMultiple,
                      icon: const Icon(Icons.add_box, size: 20),
                      label: const Text('Crear Múltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                if (widget.onEditMultiple != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onEditMultiple,
                      icon: const Icon(Icons.edit_note, size: 20),
                      label: const Text('Editar Múltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                if (widget.onDeleteMultiple != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onDeleteMultiple,
                      icon: const Icon(Icons.delete_sweep, size: 20),
                      label: const Text('Eliminar Múltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}