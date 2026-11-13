import 'package:flutter/material.dart';

import '../../../infrastructure/theme/app_theme.dart';

class ChartPoint {
  const ChartPoint(this.x, this.y);

  /// Bucket label (usually `YYYY-MM-DD`).
  final String x;
  final double y;
}

class ChartSeries {
  const ChartSeries({
    required this.key,
    required this.label,
    required this.color,
    required this.points,
  });

  final String key;
  final String label;
  final Color color;
  final List<ChartPoint> points;
}

/// Parse API decimal strings for charting; invalid values become 0.
double toChartNumber(String? value) => double.tryParse(value ?? '') ?? 0;

/// Simple multi-series line chart drawn with [CustomPainter] (no dependency).
class SeriesChart extends StatelessWidget {
  const SeriesChart({
    super.key,
    required this.title,
    required this.semanticsLabel,
    required this.emptyMessage,
    required this.series,
    this.height = 180,
  });

  final String title;
  final String semanticsLabel;
  final String emptyMessage;
  final List<ChartSeries> series;
  final double height;

  bool get _hasData => series.any((s) => s.points.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.space2),
        if (!_hasData)
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space3),
            child: Text(
              emptyMessage,
              style: TextStyle(color: tokens.muted),
            ),
          )
        else ...[
          Wrap(
            spacing: tokens.space3,
            runSpacing: tokens.space1,
            children: [
              for (final s in series)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 3, color: s.color),
                    SizedBox(width: tokens.space1),
                    Text(s.label, style: const TextStyle(fontSize: 12)),
                  ],
                ),
            ],
          ),
          SizedBox(height: tokens.space2),
          Semantics(
            label: semanticsLabel,
            container: true,
            image: true,
            child: SizedBox(
              height: height,
              child: CustomPaint(
                key: ValueKey('series-chart-paint-$title'),
                painter: SeriesChartPainter(
                  series: series,
                  gridColor: tokens.border,
                  labelColor: tokens.muted,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SeriesChartPainter extends CustomPainter {
  SeriesChartPainter({
    required this.series,
    required this.gridColor,
    required this.labelColor,
  });

  final List<ChartSeries> series;
  final Color gridColor;
  final Color labelColor;

  static const double _leftPad = 44;
  static const double _bottomPad = 20;
  static const double _topPad = 6;
  static const double _rightPad = 8;

  /// Y-axis bounds always include zero.
  static ({double min, double max}) yBounds(List<ChartSeries> series) {
    var minY = 0.0;
    var maxY = 0.0;
    for (final s in series) {
      for (final p in s.points) {
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
    }
    if (maxY == minY) maxY = minY + 1;
    return (min: minY, max: maxY);
  }

  static String formatTick(double v) {
    if (v.abs() >= 1000) return v.toStringAsFixed(0);
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  void _text(Canvas canvas, String text, Offset offset, {bool right = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: labelColor, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, right ? Offset(offset.dx - tp.width, offset.dy) : offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _leftPad,
      _topPad,
      size.width - _rightPad,
      size.height - _bottomPad,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    final bounds = yBounds(series);
    final span = bounds.max - bounds.min;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final t = i / 4;
      final y = plot.bottom - plot.height * t;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _text(
        canvas,
        formatTick(bounds.min + span * t),
        Offset(plot.left - 4, y - 6),
        right: true,
      );
    }

    final longest = series.fold<List<ChartPoint>>(
      const [],
      (acc, s) => s.points.length > acc.length ? s.points : acc,
    );
    final n = longest.length;
    double xFor(int i) =>
        n <= 1 ? plot.center.dx : plot.left + plot.width * i / (n - 1);
    double yFor(double v) =>
        plot.bottom - plot.height * ((v - bounds.min) / span);

    if (n > 0) {
      final labelIdx = <int>{0, n ~/ 2, n - 1}.toList()..sort();
      for (final i in labelIdx) {
        final label = longest[i].x;
        final tp = TextPainter(
          text: TextSpan(
            text: label.length >= 10 ? label.substring(5) : label,
            style: TextStyle(color: labelColor, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final dx = (xFor(i) - tp.width / 2).clamp(
          0.0,
          size.width - tp.width,
        );
        tp.paint(canvas, Offset(dx, plot.bottom + 4));
      }
    }

    for (final s in series) {
      if (s.points.isEmpty) continue;
      final linePaint = Paint()
        ..color = s.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final dotPaint = Paint()..color = s.color;
      final path = Path();
      for (var i = 0; i < s.points.length; i++) {
        final pt = Offset(xFor(i), yFor(s.points[i].y));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawCircle(pt, 2.5, dotPaint);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SeriesChartPainter old) =>
      old.series != series ||
      old.gridColor != gridColor ||
      old.labelColor != labelColor;
}
