import 'package:flutter/material.dart';
import '../../../dto/app/category/category_dto.dart';

class CategoryListWidget extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onAssign;

  const CategoryListWidget({
    super.key,
    required this.category,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.bookmarks,
                size: 40,
                color: Colors.purpleAccent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text("💰 Presupuesto: \$${category.description.assignedBudget}"),
                  ],
                ),
              ),
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
