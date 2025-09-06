import 'package:flutter/material.dart';

class MultipleOperationsWidget extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onCreateMultiple;
  final VoidCallback? onEditMultiple;
  final VoidCallback? onDeleteMultiple;
  final VoidCallback? onSingleOperation;
  final String singleOperationLabel;

  const MultipleOperationsWidget({
    Key? key,
    required this.title,
    required this.color,
    this.onCreateMultiple,
    this.onEditMultiple,
    this.onDeleteMultiple,
    this.onSingleOperation,
    this.singleOperationLabel = 'Nueva OperaciÃ³n',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          
          // Si hay una sola operaciÃ³n, mostrar solo ese botÃ³n
          if (onSingleOperation != null && onCreateMultiple == null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSingleOperation,
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(singleOperationLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ]
          // Si hay operaciones mÃºltiples, mostrar todos los botones
          else if (onCreateMultiple != null || onEditMultiple != null || onDeleteMultiple != null) ...[
            Row(
              children: [
                if (onCreateMultiple != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCreateMultiple,
                      icon: const Icon(Icons.add_box, size: 20),
                      label: const Text('Crear MÃºltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onEditMultiple != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEditMultiple,
                      icon: const Icon(Icons.edit_note, size: 20),
                      label: const Text('Editar MÃºltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onDeleteMultiple != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDeleteMultiple,
                      icon: const Icon(Icons.delete_sweep, size: 20),
                      label: const Text('Eliminar MÃºltiples'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700]!,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}