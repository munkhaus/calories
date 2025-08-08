import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: const <Widget>[
        AppCard(child: Text('Search field (placeholder)')),
        AppCard(child: Text('Recents/Favorites (placeholder)')),
      ],
    );
  }
}
