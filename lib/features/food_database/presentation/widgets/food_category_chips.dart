import 'package:flutter/material.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../domain/food_record_model.dart';

class FoodCategoryChips extends StatelessWidget {
  final FoodCategory? selectedCategory;
  final ValueChanged<FoodCategory?> onCategorySelected;

  const FoodCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All categories chip
          Padding(
            padding: EdgeInsets.only(right: KSizes.margin2x),
            child: FilterChip(
              label: const Text('Alle'),
              selected: selectedCategory == null,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(null);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selectedCategory == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selectedCategory == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          
          // Individual category chips
          ...FoodCategory.values.map((category) => Padding(
            padding: EdgeInsets.only(right: KSizes.margin2x),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.emoji),
                  SizedBox(width: KSizes.margin1x),
                  Text(category.displayName),
                ],
              ),
              selected: selectedCategory == category,
              onSelected: (selected) {
                onCategorySelected(selected ? category : null);
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selectedCategory == category
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selectedCategory == category
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          )),
        ],
      ),
    );
  }
} 