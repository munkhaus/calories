import 'package:calories/home/presentation/home_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Application-wide router configuration.
class AppRouter {
  /// Global [GoRouter] instance.
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const MyHomePage(title: 'Home'),
      ),
    ],
  );
}
