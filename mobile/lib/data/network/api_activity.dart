import 'dart:async';

/// Counts user-facing write requests so the app can show one loading overlay.
///
/// Retries and token refresh stay inside a single request, so they do not
/// change the count on their own.
class ApiActivity {
  final _pending = StreamController<int>.broadcast(sync: true);
  int _count = 0;

  int get count => _count;

  Stream<int> get stream => _pending.stream;

  void begin() {
    _count += 1;
    _pending.add(_count);
  }

  void end() {
    if (_count == 0) return;
    _count -= 1;
    _pending.add(_count);
  }
}
