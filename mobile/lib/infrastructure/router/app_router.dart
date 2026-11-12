import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/presentation/auth/pages/farm_settings_page.dart';
import 'package:mobile/presentation/auth/pages/home_page.dart';
import 'package:mobile/presentation/auth/pages/profile_page.dart';
import 'package:mobile/presentation/auth/pages/sign_in_page.dart';
import 'package:mobile/presentation/auth/pages/sign_up_page.dart';
import 'package:mobile/presentation/cows/pages/cow_create_page.dart';
import 'package:mobile/presentation/cows/pages/cow_detail_page.dart';
import 'package:mobile/presentation/cows/pages/cows_list_page.dart';
import 'package:mobile/presentation/crops/pages/crop_cycle_create_page.dart';
import 'package:mobile/presentation/crops/pages/crop_cycle_detail_page.dart';
import 'package:mobile/presentation/crops/pages/crop_cycles_list_page.dart';
import 'package:mobile/presentation/crops/pages/crop_name_create_page.dart';
import 'package:mobile/presentation/crops/pages/crop_name_detail_page.dart';
import 'package:mobile/presentation/crops/pages/crop_names_list_page.dart';
import 'package:mobile/presentation/inventory/pages/inventory_create_page.dart';
import 'package:mobile/presentation/inventory/pages/inventory_detail_page.dart';
import 'package:mobile/presentation/inventory/pages/inventory_list_page.dart';
import 'package:mobile/presentation/ledger/pages/ledger_create_page.dart';
import 'package:mobile/presentation/ledger/pages/ledger_detail_page.dart';
import 'package:mobile/presentation/ledger/pages/ledger_list_page.dart';
import 'package:mobile/presentation/poultry/pages/poultry_create_page.dart';
import 'package:mobile/presentation/poultry/pages/poultry_detail_page.dart';
import 'package:mobile/presentation/poultry/pages/poultry_list_page.dart';
import 'package:mobile/presentation/session/session_cubit.dart';
import 'package:mobile/presentation/shell/app_shell.dart';

GoRouter createRouter(SessionCubit sessionCubit) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
    redirect: (context, state) {
      final signedIn = sessionCubit.state;
      final loc = state.matchedLocation;
      final onAuth = loc == AppRoutes.signIn || loc == AppRoutes.signUp;
      if (!signedIn && !onAuth) return AppRoutes.signIn;
      if (signedIn && onAuth) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.cows,
            builder: (context, state) => const CowsListPage(),
          ),
          GoRoute(
            path: AppRoutes.cowsNew,
            builder: (context, state) => const CowCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.cowDetail,
            builder: (context, state) => CowDetailPage(
              cowId: state.pathParameters[AppRoutes.cowIdParam]!,
            ),
          ),
          GoRoute(
            path: AppRoutes.poultry,
            builder: (context, state) => const PoultryListPage(),
          ),
          GoRoute(
            path: AppRoutes.poultryNew,
            builder: (context, state) => const PoultryCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.poultryDetail,
            builder: (context, state) => PoultryDetailPage(
              groupId: state.pathParameters[AppRoutes.groupIdParam]!,
            ),
          ),
          GoRoute(
            path: AppRoutes.crops,
            builder: (context, state) => const CropCyclesListPage(),
          ),
          GoRoute(
            path: AppRoutes.cropNames,
            builder: (context, state) => const CropNamesListPage(),
          ),
          GoRoute(
            path: AppRoutes.cropNamesNew,
            builder: (context, state) => const CropNameCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.cropNameDetail,
            builder: (context, state) => CropNameDetailPage(
              cropNameId: state.pathParameters[AppRoutes.cropNameIdParam]!,
            ),
          ),
          GoRoute(
            path: AppRoutes.cropCyclesNew,
            builder: (context, state) => const CropCycleCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.cropCycleDetail,
            builder: (context, state) => CropCycleDetailPage(
              cycleId: state.pathParameters[AppRoutes.cycleIdParam]!,
            ),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            builder: (context, state) => const InventoryListPage(),
          ),
          GoRoute(
            path: AppRoutes.inventoryNew,
            builder: (context, state) => const InventoryCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.inventoryDetail,
            builder: (context, state) => InventoryDetailPage(
              itemId: state.pathParameters[AppRoutes.itemIdParam]!,
            ),
          ),
          GoRoute(
            path: AppRoutes.ledger,
            builder: (context, state) => const LedgerListPage(),
          ),
          GoRoute(
            path: AppRoutes.ledgerNew,
            builder: (context, state) => const LedgerCreatePage(),
          ),
          GoRoute(
            path: AppRoutes.ledgerDetail,
            builder: (context, state) => LedgerDetailPage(
              entryId: state.pathParameters[AppRoutes.entryIdParam]!,
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
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
