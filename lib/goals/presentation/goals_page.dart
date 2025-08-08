import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: const <Widget>[
        AppCard(child: Text('Goal summary (placeholder)')),
        AppCard(child: Text('Macro presets (placeholder)')),
      ],
    );
  }
}
