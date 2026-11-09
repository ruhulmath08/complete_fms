import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'infrastructure/di/injection.dart';
import 'infrastructure/router/app_router.dart';
import 'infrastructure/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/locale/locale_cubit.dart';
import 'presentation/session/session_cubit.dart';

class FarmManagerApp extends StatelessWidget {
  FarmManagerApp({super.key});

  final _session = getIt<SessionCubit>();
  late final _router = createRouter(_session);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _session),
        BlocProvider.value(value: getIt<LocaleCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'Farm Manager',
            theme: AppTheme.light(),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
