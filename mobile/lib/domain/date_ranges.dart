/// Calendar-date helpers shared by the dashboard and ledger charts.
///
/// All dates are local calendar dates formatted as `YYYY-MM-DD`; weeks start
/// on Monday and ranges never extend past today.
enum PeriodKind { day, week, month, year }

enum SeriesGrain { day, week, month }

extension SeriesGrainApi on SeriesGrain {
  String get apiValue => name;
}

class PeriodRange {
  const PeriodRange({
    required this.from,
    required this.to,
    required this.grain,
  });

  final String from;
  final String to;
  final SeriesGrain grain;

  @override
  bool operator ==(Object other) =>
      other is PeriodRange &&
      other.from == from &&
      other.to == to &&
      other.grain == grain;

  @override
  int get hashCode => Object.hash(from, to, grain);
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Local calendar date as `YYYY-MM-DD` (never via UTC).
String toIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

DateTime parseIsoDate(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

String todayIso([DateTime? now]) => toIsoDate(now ?? DateTime.now());

/// Monday of the week containing [now] (local time).
String weekStartIso([DateTime? now]) {
  final n = now ?? DateTime.now();
  final offset = (n.weekday - DateTime.monday) % 7;
  return toIsoDate(DateTime(n.year, n.month, n.day - offset));
}

String monthStartIso([DateTime? now]) {
  final n = now ?? DateTime.now();
  return toIsoDate(DateTime(n.year, n.month, 1));
}

String yearStartIso([DateTime? now]) {
  final n = now ?? DateTime.now();
  return toIsoDate(DateTime(n.year, 1, 1));
}

/// Clamp an ISO date so it is never later than today.
String clampToToday(String value, [DateTime? now]) {
  final today = todayIso(now);
  return value.compareTo(today) > 0 ? today : value;
}

/// Pick a grain that keeps the number of buckets readable.
SeriesGrain grainForRange(String from, String to) {
  final days = parseIsoDate(to).difference(parseIsoDate(from)).inDays + 1;
  if (days <= 31) return SeriesGrain.day;
  if (days <= 120) return SeriesGrain.week;
  return SeriesGrain.month;
}

/// Date range for a named period ending today (week starts Monday).
PeriodRange periodRange(PeriodKind period, [DateTime? now]) {
  final to = todayIso(now);
  switch (period) {
    case PeriodKind.day:
      return PeriodRange(from: to, to: to, grain: SeriesGrain.day);
    case PeriodKind.week:
      return PeriodRange(
        from: weekStartIso(now),
        to: to,
        grain: SeriesGrain.day,
      );
    case PeriodKind.month:
      return PeriodRange(
        from: monthStartIso(now),
        to: to,
        grain: SeriesGrain.day,
      );
    case PeriodKind.year:
      return PeriodRange(
        from: yearStartIso(now),
        to: to,
        grain: SeriesGrain.month,
      );
  }
}

/// Normalise a user range: clamp both ends to today and keep from <= to.
({String from, String to}) normalizeRange(
  String from,
  String to, [
  DateTime? now,
]) {
  final clampedTo = clampToToday(to, now);
  final clampedFrom = clampToToday(from, now);
  return (
    from: clampedFrom.compareTo(clampedTo) > 0 ? clampedTo : clampedFrom,
    to: clampedTo,
  );
}
