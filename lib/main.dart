import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_navigation.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/onboarding/infrastructure/onboarding_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dit Sunde Jeg',
      theme: AppTheme.lightTheme,
      home: const AppWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Wrapper to determine which page to show based on onboarding status
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool? _isOnboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingStorageService.isOnboardingCompleted();
    if (mounted) {
      setState(() {
        _isOnboardingCompleted = isCompleted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnboardingCompleted == null) {
      // Loading state
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isOnboardingCompleted!) {
      // User has completed onboarding, show main app
      return const AppNavigation();
    } else {
      // User hasn't completed onboarding, show onboarding flow
      return const OnboardingPage();
    }
  }
}
