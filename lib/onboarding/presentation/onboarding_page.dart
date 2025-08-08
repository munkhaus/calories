import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/storage/local_storage.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: SizedBox(
          width: 240,
          height: 48,
          child: FilledButton(
            onPressed: () async {
              await getIt<LocalStorage>().setOnboardingCompleted(true);
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/today');
              }
            },
            child: const Text('Complete onboarding'),
          ),
        ),
      ),
    );
  }
}
