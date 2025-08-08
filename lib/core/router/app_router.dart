import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/shell/root_shell.dart';
import 'package:calories/core/storage/local_storage.dart';
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
  static const bool _forceOnboarding = bool.fromEnvironment(
    'FORCE_ONBOARDING',
    defaultValue: false,
  );

  /// Temporary in-memory onboarding flag (replace with persisted setting later).
  static bool get _onboardingCompleted {
    if (_forceOnboarding) return false;
    // In tests or early app startup, storage may not be registered yet.
    if (!getIt.isRegistered<LocalStorage>()) {
      return true; // default to completed to allow app to render
    }
    return getIt<LocalStorage>().getOnboardingCompleted();
  }

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
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return RootShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                redirect: (BuildContext context, GoRouterState state) =>
                    '/today',
              ),
              GoRoute(
                path: '/today',
                builder: (BuildContext context, GoRouterState state) =>
                    const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/log',
                builder: (BuildContext context, GoRouterState state) =>
                    const LogPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'add',
                    builder: (BuildContext context, GoRouterState state) =>
                        const LogAddPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/trends',
                builder: (BuildContext context, GoRouterState state) =>
                    const TrendsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/goals',
                builder: (BuildContext context, GoRouterState state) =>
                    const GoalsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
