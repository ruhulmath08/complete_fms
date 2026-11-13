import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/date_ranges.dart';

void main() {
  // Friday 2026-11-13 (local).
  final friday = DateTime(2026, 11, 13, 15, 30);

  test('weekStartIso returns the local Monday', () {
    expect(weekStartIso(friday), '2026-11-09');
    expect(weekStartIso(DateTime(2026, 11, 9)), '2026-11-09'); // Monday
    expect(weekStartIso(DateTime(2026, 11, 15)), '2026-11-09'); // Sunday
    expect(weekStartIso(DateTime(2026, 11, 2)), '2026-11-02');
  });

  test('weekStartIso crosses month and year boundaries', () {
    expect(weekStartIso(DateTime(2026, 1, 1)), '2025-12-29');
  });

  test('default week range is Monday to today with daily grain', () {
    final r = periodRange(PeriodKind.week, friday);
    expect(r.from, '2026-11-09');
    expect(r.to, '2026-11-13');
    expect(r.grain, SeriesGrain.day);
  });

  test('period ranges for day, month and year', () {
    expect(periodRange(PeriodKind.day, friday),
        const PeriodRange(from: '2026-11-13', to: '2026-11-13', grain: SeriesGrain.day));
    expect(periodRange(PeriodKind.month, friday).from, '2026-11-01');
    final year = periodRange(PeriodKind.year, friday);
    expect(year.from, '2026-01-01');
    expect(year.grain, SeriesGrain.month);
  });

  test('clampToToday and normalizeRange block future dates', () {
    expect(clampToToday('2999-12-31', friday), '2026-11-13');
    expect(clampToToday('2026-11-01', friday), '2026-11-01');
    final n = normalizeRange('2999-01-01', '2999-12-31', friday);
    expect(n.from, '2026-11-13');
    expect(n.to, '2026-11-13');
    final swapped = normalizeRange('2026-11-12', '2026-11-05', friday);
    expect(swapped.from, '2026-11-05');
    expect(swapped.to, '2026-11-05');
  });

  test('grainForRange keeps bucket counts readable', () {
    expect(grainForRange('2026-11-01', '2026-11-13'), SeriesGrain.day);
    expect(grainForRange('2026-09-01', '2026-11-13'), SeriesGrain.week);
    expect(grainForRange('2026-01-01', '2026-11-13'), SeriesGrain.month);
  });
}
