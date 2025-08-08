import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:flutter/material.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: const <Widget>[
        AppCard(child: Text('Kcal vs target chart (placeholder)')),
        AppCard(child: Text('Adherence & insights (placeholder)')),
        AppCard(child: Text('Weight trend (placeholder)')),
      ],
    );
  }
}
