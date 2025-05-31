import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';

class FoodDatabaseSearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const FoodDatabaseSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Søg efter mad...',
          prefixIcon: Icon(
            MdiIcons.magnify,
            color: Theme.of(context).colorScheme.outline,
          ),
          suffixIcon: value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    MdiIcons.close,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () => onChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: KSizes.margin4x,
            vertical: KSizes.margin3x,
          ),
        ),
      ),
    );
  }
} 