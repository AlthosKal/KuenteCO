import 'package:flutter/material.dart';
import '../../../dto/app/category/category_dto.dart';

class CategoryListWidget extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onAssign;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const CategoryListWidget({
    super.key,
    required this.category,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.onAssign,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelectionMode ? onSelectionToggle : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected 
              ? BorderSide(color: Colors.blue, width: 2) 
              : BorderSide.none,
        ),
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Selection checkbox in selection mode
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onSelectionToggle?.call(),
                  activeColor: Colors.blue,
                ),
                const SizedBox(width: 8),
              ],
              
              // Category icon
              Icon(
                Icons.bookmarks,
                size: 40,
                color: isSelected ? Colors.blue : Colors.purpleAccent,
              ),
              const SizedBox(width: 12),
              
              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[800] : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "💰 Presupuesto: \$${category.description.assignedBudget}",
                      style: TextStyle(
                        color: isSelected ? Colors.blue[600] : null,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons (hidden in selection mode)
              if (!isSelectionMode)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                    if (onAssign != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onAssign,
                        icon: const Icon(
                          Icons.person_add_outlined,
                          color: Colors.green,
                        ),
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Asignar a perfil',
                      ),
                    ],
                    if (onEdit != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
