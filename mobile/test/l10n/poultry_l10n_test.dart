import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('poultry strings resolve in English and Bangla', (tester) async {
    late AppLocalizations en;
    late AppLocalizations bn;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            en = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('bn'),
        home: Builder(
          builder: (context) {
            bn = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(en.poultryTitle, 'Poultry');
    expect(en.managePoultry, 'Manage poultry');
    expect(en.eggsNotForBroiler, contains('Broiler'));
    expect(bn.poultryTitle, 'হাঁস-মুরগি');
    expect(bn.managePoultry, 'হাঁস-মুরগি পরিচালনা');
  });
}
