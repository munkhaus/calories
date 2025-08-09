import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:calories/core/storage/local_storage.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: <Widget>[
        const AppCard(child: Text('Units & profile (placeholder)')),
        const AppCard(child: Text('Notifications (placeholder)')),
        AppCard(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () async {
                // Naive JSON export of Hive boxes content
                final HiveBoxes boxes = getIt<HiveBoxes>();
                final Map<String, dynamic> dump = <String, dynamic>{
                  'profiles': boxes.profiles.toMap(),
                  'goals': boxes.goals.toMap(),
                  'food_entries': boxes.foodEntries.toMap(),
                  'weights': boxes.weights.toMap(),
                  'water': boxes.water.toMap(),
                };
                final String jsonStr = const JsonEncoder.withIndent('  ').convert(dump);
                await Clipboard.setData(ClipboardData(text: jsonStr));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data copied to clipboard')),
                  );
                }
              },
              child: const Text('Export data (JSON)'),
            ),
          ),
        ),
        AppCard(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.tonal(
              onPressed: () async {
                await getIt<LocalStorage>().setOnboardingCompleted(false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Onboarding reset. Restart the app to see it.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Reset onboarding'),
            ),
          ),
        ),
      ],
    );
  }
}
