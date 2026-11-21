import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/router/app_router.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/loading/loading_cubit.dart';
import 'package:mobile/presentation/locale/locale_cubit.dart';
import 'package:mobile/presentation/session/session_cubit.dart';
import 'package:mobile/presentation/shared/widgets/farm_loading_widget.dart';

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
        BlocProvider.value(value: getIt<LoadingCubit>()),
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
            builder: (context, child) {
              return BlocBuilder<LoadingCubit, bool>(
                builder: (context, loading) {
                  return Stack(
                    children: [
                      ?child,
                      if (loading)
                        const Positioned.fill(
                          child: AbsorbPointer(
                            child: ColoredBox(
                              color: Colors.black54,
                              child: Center(child: FarmLoadingWidget()),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
