import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/router/app_router.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

/// Root widget for the Calories application.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    );
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: Colors.teal,
      ),
    );

    return MaterialApp.router(
      title: 'Calories',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
