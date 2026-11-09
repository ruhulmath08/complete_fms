import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/failures.dart';

void main() {
  test('AppFailure exposes stable code and user-facing message', () {
    final failure = AppFailure(
      code: 'INVALID_CREDENTIALS',
      message: 'Email or password is incorrect.',
    );
    expect(failure.code, 'INVALID_CREDENTIALS');
    expect(failure.message, 'Email or password is incorrect.');
    expect(failure.toString(), 'Email or password is incorrect.');
  });
}
