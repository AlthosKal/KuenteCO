import 'package:flutter/material.dart';
import '../../../dto/app/category/category_dto.dart';

class CategoryListItem extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback onTap;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final start = category.startDate != null
        ? "${category.startDate!.day}/${category.startDate!.month}"
        : "Sin fecha";
    final finish = category.finishDate != null
        ? "${category.finishDate!.day}/${category.finishDate!.month}"
        : "Sin fecha";

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
                Icons.category,
                size: 40,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.description.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text("📅 $start → $finish"),
                    Text("💰 Presupuesto ID: ${category.budgetId}"),
                  ],
                ),
              ),
              const Icon(
                Icons.info_outline,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
