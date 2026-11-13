import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<AppLocalizations> _load(WidgetTester tester, String code) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(code),
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return l10n;
}

void main() {
  testWidgets('ops-calc strings resolve in English and Bangla', (tester) async {
    final en = await _load(tester, 'en');
    final bn = await _load(tester, 'bn');

    expect(en.dashboardTitle, 'Dashboard');
    expect(bn.dashboardTitle, 'ড্যাশবোর্ড');
    expect(en.periodWeek, 'Week');
    expect(bn.periodWeek, 'সপ্তাহ');
    expect(en.fertilizerStockHistory, 'Fertilizer stock history');
    expect(bn.fertilizerStockHistory, isNot(en.fertilizerStockHistory));
    expect(en.deleteExpenseConfirm, contains('expense'));
    expect(en.deleteHarvestConfirm, contains('harvest'));
    expect(bn.deleteExpenseConfirm, isNotEmpty);
    expect(bn.deleteHarvestConfirm, isNotEmpty);
    expect(en.updateExpenseEntry, 'Update expense');
    expect(en.updateHarvestEntry, 'Update harvest');
    expect(en.ledgerChartTitle, isNotEmpty);
    expect(bn.ledgerChartTitle, isNot(en.ledgerChartTitle));

    final enCharts = [
      en.chartEggProductionSemantics,
      en.chartHenHeadcountSemantics,
      en.chartMilkSemantics,
      en.chartCowProductionSemantics,
      en.chartExpensesCostSemantics,
      en.chartIncomeSemantics,
    ];
    final bnCharts = [
      bn.chartEggProductionSemantics,
      bn.chartHenHeadcountSemantics,
      bn.chartMilkSemantics,
      bn.chartCowProductionSemantics,
      bn.chartExpensesCostSemantics,
      bn.chartIncomeSemantics,
    ];
    expect(enCharts.toSet().length, 6);
    expect(bnCharts.toSet().length, 6);
  });
}
