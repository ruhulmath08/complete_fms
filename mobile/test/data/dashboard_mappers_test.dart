import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/dashboard_mappers.dart';
import 'package:mobile/domain/entities/dashboard.dart';

void main() {
  test('maps dashboard aggregates with all six series', () {
    final data = mapDashboardAggregates({
      'from': '2026-11-09',
      'to': '2026-11-13',
      'grain': 'day',
      'timezone': 'Asia/Dhaka',
      'series': {
        'egg_production': [
          {'bucket_start': '2026-11-09', 'value': '10'},
        ],
        'hen_headcount': [
          {'bucket_start': '2026-11-09', 'value': 100},
        ],
        'milk': [
          {'bucket_start': '2026-11-09', 'value': '5.5'},
        ],
        'cow_production': <dynamic>[],
        'expenses_cost': [
          {'bucket_start': '2026-11-09', 'value': '40.00'},
        ],
        'income': [
          {'bucket_start': '2026-11-09', 'value': '100.00'},
        ],
      },
    });

    expect(data.from, '2026-11-09');
    expect(data.timezone, 'Asia/Dhaka');
    expect(data.series.keys.length, DashboardSeriesKey.values.length);
    expect(data.pointsFor(DashboardSeriesKey.milk).single.value, '5.5');
    expect(data.pointsFor(DashboardSeriesKey.henHeadcount).single.value, '100');
    expect(data.pointsFor(DashboardSeriesKey.cowProduction), isEmpty);
  });

  test('missing series default to empty lists', () {
    final data = mapDashboardAggregates({
      'to': '2026-11-13',
      'grain': 'day',
      'timezone': 'Asia/Dhaka',
      'series': <String, dynamic>{},
    });
    expect(data.pointsFor(DashboardSeriesKey.income), isEmpty);
  });
}
