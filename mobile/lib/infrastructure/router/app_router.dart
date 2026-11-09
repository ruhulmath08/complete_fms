import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/pages/farm_settings_page.dart';
import '../../presentation/auth/pages/home_page.dart';
import '../../presentation/auth/pages/profile_page.dart';
import '../../presentation/auth/pages/sign_in_page.dart';
import '../../presentation/auth/pages/sign_up_page.dart';
import '../../presentation/cows/pages/cow_create_page.dart';
import '../../presentation/cows/pages/cow_detail_page.dart';
import '../../presentation/cows/pages/cows_list_page.dart';
import '../../presentation/poultry/pages/poultry_create_page.dart';
import '../../presentation/poultry/pages/poultry_detail_page.dart';
import '../../presentation/poultry/pages/poultry_list_page.dart';
import '../../presentation/session/session_cubit.dart';
import '../../presentation/shell/app_shell.dart';

GoRouter createRouter(SessionCubit sessionCubit) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
    redirect: (context, state) {
      final signedIn = sessionCubit.state;
      final loc = state.matchedLocation;
      final onAuth = loc == '/signin' || loc == '/signup';
      if (!signedIn && !onAuth) return '/signin';
      if (signedIn && onAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/cows',
            builder: (context, state) => const CowsListPage(),
          ),
          GoRoute(
            path: '/cows/new',
            builder: (context, state) => const CowCreatePage(),
          ),
          GoRoute(
            path: '/cows/:cowId',
            builder: (context, state) => CowDetailPage(
              cowId: state.pathParameters['cowId']!,
            ),
          ),
          GoRoute(
            path: '/poultry',
            builder: (context, state) => const PoultryListPage(),
          ),
          GoRoute(
            path: '/poultry/new',
            builder: (context, state) => const PoultryCreatePage(),
          ),
          GoRoute(
            path: '/poultry/:groupId',
            builder: (context, state) => PoultryDetailPage(
              groupId: state.pathParameters['groupId']!,
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const FarmSettingsPage(),
          ),
        ],
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
