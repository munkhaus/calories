import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_navigation.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/onboarding/infrastructure/onboarding_storage_service.dart';
import 'features/info/presentation/info_page.dart';
import 'features/food_logging/infrastructure/favorite_food_service.dart';
import 'features/activity/infrastructure/favorite_activity_service.dart';
import 'features/splash/presentation/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize test favorites for demonstration
  // FavoriteFoodService.addTestFavorites();
  // FavoriteActivityService.addTestFavorites();
  
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
      title: 'Kalorie Tracker',
      theme: AppTheme.lightTheme,
      home: const AppWrapper(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('da', 'DK'),
        Locale('en', 'US'),
      ],
      locale: const Locale('da', 'DK'),
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
  bool? _isInfoAccepted;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Don't check status immediately, wait for splash to complete
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted = await OnboardingStorageService.isOnboardingCompleted();
    final isInfoAccepted = prefs.getBool('info_accepted') ?? false;
    
    if (mounted) {
      setState(() {
        _isOnboardingCompleted = isOnboardingCompleted;
        _isInfoAccepted = isInfoAccepted;
      });
    }
  }

  Future<void> _acceptInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('info_accepted', true);
    setState(() {
      _isInfoAccepted = true;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
    _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash first
    if (_showSplash) {
      return SplashPage(onComplete: _onSplashComplete);
    }
    
    if (_isOnboardingCompleted == null || _isInfoAccepted == null) {
      // Loading state
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show info page first if not accepted
    if (!_isInfoAccepted!) {
      return InfoPage(
        isInitialView: true,
        onAccepted: _acceptInfo,
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
