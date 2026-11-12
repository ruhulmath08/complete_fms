import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/domain/usecases/auth_usecases.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/session/session_cubit.dart';
import 'package:mobile/presentation/shell/app_shell.dart';

class _MockIsSignedIn extends Mock implements IsSignedIn {}

class _MockSignOut extends Mock implements SignOut {}

void main() {
  late _MockIsSignedIn isSignedIn;
  late _MockSignOut signOut;
  late SessionCubit sessionCubit;

  setUp(() {
    isSignedIn = _MockIsSignedIn();
    signOut = _MockSignOut();
    when(() => signOut()).thenAnswer((_) async {});
    sessionCubit = SessionCubit(isSignedIn, signOut)..markSignedIn();
  });

  tearDown(() async {
    await sessionCubit.close();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const Text('Home body'),
            ),
            GoRoute(
              path: AppRoutes.cows,
              builder: (context, state) => const Text('Cows body'),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const Text('Profile body'),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: sessionCubit,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('drawer lists farm destinations and navigates', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Cows'), findsWidgets);
    expect(find.text('Poultry'), findsOneWidget);
    expect(find.text('Crops'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Income & expenses'), findsOneWidget);
    expect(find.text('Farm settings'), findsOneWidget);

    await tester.tap(find.text('Cows').last);
    await tester.pumpAndSettle();
    expect(find.text('Cows body'), findsOneWidget);
  });

  testWidgets('overflow menu opens logout confirm dialog', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Sign out'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.textContaining('signed out of Farm Manager'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => signOut());

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    verify(() => signOut()).called(1);
  });
}
