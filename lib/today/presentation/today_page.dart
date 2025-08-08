import 'package:calories/core/ui/app_card.dart';
import 'package:calories/core/constants/ksizes.dart';
import 'package:flutter/material.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: const <Widget>[
        AppCard(child: Text('Calories ring (placeholder)')),
        AppCard(child: Text('Macro bars (placeholder)')),
        AppCard(child: Text('Meals list (placeholder)')),
      ],
    );
  }
}
