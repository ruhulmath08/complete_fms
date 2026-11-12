import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../locale/locale_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.welcome, style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: tokens.space2),
          Text(l10n.welcomeBody),
          SizedBox(height: tokens.space4),
          Text(
            l10n.useMenuHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.muted,
                ),
          ),
          SizedBox(height: tokens.space5),
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.space2),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.english),
                selected: Localizations.localeOf(context).languageCode == 'en',
                onSelected: (_) =>
                    context.read<LocaleCubit>().setLocale(const Locale('en')),
              ),
              ChoiceChip(
                label: Text(l10n.bangla),
                selected: Localizations.localeOf(context).languageCode == 'bn',
                onSelected: (_) =>
                    context.read<LocaleCubit>().setLocale(const Locale('bn')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
