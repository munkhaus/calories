import 'package:calories/core/shell/root_shell.dart';
import 'package:calories/goals/presentation/goals_page.dart';
import 'package:calories/log/presentation/log_page.dart';
import 'package:calories/log/presentation/log_add_page.dart';
import 'package:calories/onboarding/presentation/onboarding_page.dart';
import 'package:calories/settings/presentation/settings_page.dart';
import 'package:calories/today/presentation/today_page.dart';
import 'package:calories/trends/presentation/trends_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Application-wide router configuration.
class AppRouter {
  /// Temporary in-memory onboarding flag (replace with persisted setting later).
  static bool _onboardingCompleted = true;

  /// Global [GoRouter] instance.
  static final GoRouter router = GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.uri.toString();
      final bool isOnboardingRoute = location == '/onboarding';
      if (!_onboardingCompleted && !isOnboardingRoute) {
        return '/onboarding';
      }
      if (_onboardingCompleted && isOnboardingRoute) {
        return '/today';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return RootShell(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            redirect: (BuildContext context, GoRouterState state) => '/today',
          ),
          GoRoute(
            path: '/today',
            builder: (BuildContext context, GoRouterState state) =>
                const TodayPage(),
          ),
          GoRoute(
            path: '/log',
            builder: (BuildContext context, GoRouterState state) =>
                const LogPage(),
          ),
          GoRoute(
            path: '/log/add',
            builder: (BuildContext context, GoRouterState state) =>
                const LogAddPage(),
          ),
          GoRoute(
            path: '/trends',
            builder: (BuildContext context, GoRouterState state) =>
                const TrendsPage(),
          ),
          GoRoute(
            path: '/goals',
            builder: (BuildContext context, GoRouterState state) =>
                const GoalsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
