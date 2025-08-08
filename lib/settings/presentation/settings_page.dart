import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: const <Widget>[
        AppCard(child: Text('Units & profile (placeholder)')),
        AppCard(child: Text('Notifications (placeholder)')),
        AppCard(child: Text('Privacy & export (placeholder)')),
      ],
    );
  }
}
