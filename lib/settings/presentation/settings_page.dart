import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/storage/local_storage.dart';
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
        const AppCard(child: Text('Privacy & export (placeholder)')),
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
