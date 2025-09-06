import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/business_logic/category_controller.dart';
import '../../../dto/app/category/category_dto.dart';

class DeleteCategoryWidget extends StatefulWidget {
  final CategoryDTO category;
  
  const DeleteCategoryWidget({
    super.key,
    required this.category,
  });

  @override
  State<DeleteCategoryWidget> createState() => _DeleteCategoryWidgetState();

  /// MÃ©todo estÃ¡tico para mostrar el diÃ¡logo de eliminaciÃ³n
  static Future<bool?> showDeleteDialog(
    BuildContext context,
    CategoryDTO category,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DeleteCategoryWidget(category: category);
      },
    );
  }
}

class _DeleteCategoryWidgetState extends State<DeleteCategoryWidget> {
  bool _isDeleting = false;
  String? _errorMessage;

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  Future<void> _deleteCategory() async {
    // Evitar mÃºltiples eliminaciones si ya se estÃ¡ ejecutando
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final controller = Provider.of<CategoryController>(context, listen: false);
      await controller.deleteCategory(widget.category.id);
      
      if (mounted) {
        Navigator.pop(context, true);
        _showSnackBar(
          'CategorÃ­a "${widget.category.name}" eliminada exitosamente',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al eliminar la categorÃ­a: $e';
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.red.shade600,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Eliminar CategorÃ­a',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                children: [
                  const TextSpan(
                    text: 'Â¿EstÃ¡s seguro de que deseas eliminar la categorÃ­a ',
                  ),
                  TextSpan(
                    text: '"${widget.category.name}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const TextSpan(
                    text: '?',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acciÃ³n no se puede deshacer.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _deleteCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Eliminar'),
        ),
      ],
    );
  }
}
