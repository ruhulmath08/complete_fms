import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('cow strings resolve in English and Bangla', (tester) async {
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

    expect(en.cowsTitle, 'Cows');
    expect(en.manageCows, 'Manage cows');
    expect(en.archivedReadOnly, contains('archived'));
    expect(bn.cowsTitle, 'গরু');
    expect(bn.manageCows, 'গরু পরিচালনা');
  });
}
