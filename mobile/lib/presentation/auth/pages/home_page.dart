import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../locale/locale_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.welcome, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(l10n.welcomeBody),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/profile'),
            child: Text(l10n.profile),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/settings'),
            child: Text(l10n.farmSettings),
          ),
          const SizedBox(height: 24),
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
