import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/shared/widgets/series_chart.dart';

import '../../support/pump_app.dart';

void main() {
  test('yBounds always include zero and avoid a flat range', () {
    final bounds = SeriesChartPainter.yBounds([
      const ChartSeries(
        key: 'a',
        label: 'A',
        color: Color(0xFF000000),
        points: [ChartPoint('2026-11-01', 5), ChartPoint('2026-11-02', 20)],
      ),
      const ChartSeries(
        key: 'b',
        label: 'B',
        color: Color(0xFF000000),
        points: [ChartPoint('2026-11-01', -3)],
      ),
    ]);
    expect(bounds.min, -3);
    expect(bounds.max, 20);

    final flat = SeriesChartPainter.yBounds(const []);
    expect(flat.max, greaterThan(flat.min));
  });

  test('toChartNumber parses decimals and falls back to zero', () {
    expect(toChartNumber('12.50'), 12.5);
    expect(toChartNumber('x'), 0);
    expect(toChartNumber(null), 0);
  });

  testWidgets('renders legend and semantics when data exists', (tester) async {
    await pumpLocalized(
      tester,
      const SeriesChart(
        title: 'Income',
        semanticsLabel: 'Income chart',
        emptyMessage: 'Nothing',
        series: [
          ChartSeries(
            key: 'income',
            label: 'Income',
            color: Color(0xFF2F6A3A),
            points: [ChartPoint('2026-11-09', 1), ChartPoint('2026-11-10', 3)],
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Income chart'), findsOneWidget);
    expect(find.text('Nothing'), findsNothing);
  });

  testWidgets('shows empty message without points', (tester) async {
    await pumpLocalized(
      tester,
      const SeriesChart(
        title: 'Income',
        semanticsLabel: 'Income chart',
        emptyMessage: 'Nothing',
        series: [
          ChartSeries(
            key: 'income',
            label: 'Income',
            color: Color(0xFF2F6A3A),
            points: [],
          ),
        ],
      ),
    );
    expect(find.text('Nothing'), findsOneWidget);
    expect(find.bySemanticsLabel('Income chart'), findsNothing);
  });
}
