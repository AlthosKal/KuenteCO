import 'package:flutter/material.dart';
import '../../../dto/app/category/category_dto.dart';

class CategoryListWidget extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback onTap;

  const CategoryListWidget({
    super.key,
    required this.category,
    required this.onTap,
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
