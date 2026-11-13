import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/date_ranges.dart';
import 'package:mobile/domain/entities/dashboard.dart';
import 'package:mobile/domain/failures.dart';
import 'package:mobile/domain/usecases/dashboard_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/presentation/dashboard/pages/dashboard_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/pump_app.dart';

class _MockGetDashboardAggregates extends Mock
    implements GetDashboardAggregates {}

DashboardAggregates _aggregates() {
  List<DashboardSeriesPoint> pts(List<String> v) => [
        for (var i = 0; i < v.length; i++)
          DashboardSeriesPoint(bucketStart: '2026-11-0${i + 1}', value: v[i]),
      ];
  return DashboardAggregates(
    from: '2026-11-09',
    to: '2026-11-13',
    grain: 'day',
    timezone: 'Asia/Dhaka',
    series: {
      DashboardSeriesKey.eggProduction: pts(['10', '12']),
      DashboardSeriesKey.henHeadcount: pts(['100', '100']),
      DashboardSeriesKey.milk: pts(['5.5', '6.0']),
      DashboardSeriesKey.cowProduction: pts(['3', '4']),
      DashboardSeriesKey.expensesCost: pts(['40.00', '0.00']),
      DashboardSeriesKey.income: pts(['100.00', '20.00']),
    },
  );
}

void main() {
  late _MockGetDashboardAggregates usecase;

  setUp(() {
    usecase = _MockGetDashboardAggregates();
    when(
      () => usecase(
        from: any(named: 'from'),
        to: any(named: 'to'),
        grain: any(named: 'grain'),
      ),
    ).thenAnswer((_) async => _aggregates());
    getIt.registerSingleton<GetDashboardAggregates>(usecase);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(tester, const DashboardPage());
  }

  testWidgets('loads this week (Monday to today, daily) with six charts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpDashboard(tester);

    verify(
      () => usecase(from: weekStartIso(), to: todayIso(), grain: 'day'),
    ).called(1);

    final week = tester.widget<ChoiceChip>(find.byKey(const ValueKey('period-week')));
    expect(week.selected, isTrue);

    for (final label in [
      'Egg production chart',
      'Hen headcount chart',
      'Milk chart',
      'Cow production chart',
      'Expenses cost chart',
      'Income chart',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    expect(find.textContaining('Asia/Dhaka'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('date pickers cannot select a future date', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const ValueKey('dashboard-to')));
    await tester.pumpAndSettle();

    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final today = DateTime.now();
    expect(
      picker.lastDate,
      DateTime(today.year, today.month, today.day),
    );
  });

  testWidgets('switching period refetches with matching range and grain', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const ValueKey('period-year')));
    await tester.pumpAndSettle();
    verify(
      () => usecase(from: yearStartIso(), to: todayIso(), grain: 'month'),
    ).called(1);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('period-year')))
          .selected,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('period-day')));
    await tester.pumpAndSettle();
    verify(
      () => usecase(from: todayIso(), to: todayIso(), grain: 'day'),
    ).called(1);
  });

  testWidgets('shows the failure message when loading fails', (tester) async {
    when(
      () => usecase(
        from: any(named: 'from'),
        to: any(named: 'to'),
        grain: any(named: 'grain'),
      ),
    ).thenThrow(
      AppFailure(code: 'FUTURE_DATE_NOT_ALLOWED', message: 'No future dates'),
    );
    await pumpDashboard(tester);

    expect(find.text('No future dates'), findsOneWidget);
  });

  testWidgets('renders Bangla labels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(
      tester,
      const DashboardPage(),
      locale: const Locale('bn'),
    );
    expect(find.text('ড্যাশবোর্ড'), findsOneWidget);
    expect(find.text('সপ্তাহ'), findsOneWidget);
  });
}
