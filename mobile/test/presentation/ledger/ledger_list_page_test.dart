import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/date_ranges.dart';
import 'package:mobile/domain/entities/ledger.dart';
import 'package:mobile/domain/usecases/ledger_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/presentation/ledger/pages/ledger_list_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/pump_app.dart';

class _MockListEntries extends Mock implements ListLedgerEntries {}

class _MockTotals extends Mock implements GetPeriodTotals {}

class _MockSeries extends Mock implements GetLedgerSeries {}

void main() {
  late _MockListEntries list;
  late _MockTotals totals;
  late _MockSeries series;

  setUp(() {
    list = _MockListEntries();
    totals = _MockTotals();
    series = _MockSeries();
    when(
      () => list(
        includeArchived: any(named: 'includeArchived'),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer(
      (_) async => const PagedResult<LedgerEntry>(
        items: [],
        total: 0,
        limit: 100,
        offset: 0,
      ),
    );
    when(() => totals(from: any(named: 'from'), to: any(named: 'to')))
        .thenAnswer(
      (_) async => const PeriodTotals(
        from: '2026-11-01',
        to: '2026-11-30',
        totalIncome: '120.00',
        totalExpenses: '45.00',
        net: '75.00',
      ),
    );
    when(
      () => series(
        from: any(named: 'from'),
        to: any(named: 'to'),
        grain: any(named: 'grain'),
      ),
    ).thenAnswer(
      (_) async => const LedgerSeries(
        from: '2026-11-01',
        to: '2026-11-13',
        grain: 'day',
        points: [
          LedgerSeriesPoint(
            bucketStart: '2026-11-01',
            income: '100.00',
            expenses: '40.00',
            net: '60.00',
          ),
          LedgerSeriesPoint(
            bucketStart: '2026-11-02',
            income: '20.00',
            expenses: '5.00',
            net: '15.00',
          ),
        ],
      ),
    );
    getIt
      ..registerSingleton<ListLedgerEntries>(list)
      ..registerSingleton<GetPeriodTotals>(totals)
      ..registerSingleton<GetLedgerSeries>(series);
  });

  tearDown(() async => getIt.reset());

  testWidgets('shows series chart below Apply and keeps numeric totals', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(tester, const LedgerListPage());

    expect(find.text('Total income: 120.00'), findsOneWidget);
    expect(find.text('Total expenses: 45.00'), findsOneWidget);
    expect(find.text('Net: 75.00'), findsOneWidget);
    expect(find.text('Income and expenses over time'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Income, expenses and net over the selected date range',
      ),
      findsOneWidget,
    );

    final applyY = tester.getTopLeft(find.text('Apply date range')).dy;
    final chartY =
        tester.getTopLeft(find.text('Income and expenses over time')).dy;
    expect(chartY, greaterThan(applyY));

    // Series range is clamped to today (never the future month end).
    verify(
      () => series(
        from: any(named: 'from'),
        to: todayIso(),
        grain: any(named: 'grain'),
      ),
    ).called(1);
    semantics.dispose();
  });

  testWidgets('Apply date range refetches the series', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(tester, const LedgerListPage());

    await tester.tap(find.text('Apply date range'));
    await tester.pumpAndSettle();

    verify(
      () => series(
        from: any(named: 'from'),
        to: any(named: 'to'),
        grain: any(named: 'grain'),
      ),
    ).called(2);
  });
}
