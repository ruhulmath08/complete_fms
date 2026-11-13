import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../locale/locale_cubit.dart';

/// English / Bangla chips (moved from the old home page into the dashboard).
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.english),
              selected: code == 'en',
              onSelected: (_) =>
                  context.read<LocaleCubit>().setLocale(const Locale('en')),
            ),
            ChoiceChip(
              label: Text(l10n.bangla),
              selected: code == 'bn',
              onSelected: (_) =>
                  context.read<LocaleCubit>().setLocale(const Locale('bn')),
            ),
          ],
        ),
      ],
    );
  }
}
