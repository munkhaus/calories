import 'package:calories/core/constants/ksizes.dart';
import 'package:flutter/material.dart';

/// A reusable card with consistent shape and internal padding.
class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.margin, super.key});

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(KSizes.margin4x),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: child,
      ),
    );
  }
}
