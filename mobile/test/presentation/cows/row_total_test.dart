import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/cows/pages/cow_detail_page.dart';

void main() {
  test('rowTotal prefers API total', () {
    expect(rowTotal('2', '10', '25.00'), '25.00');
  });

  test('rowTotal multiplies when API total missing', () {
    expect(rowTotal('2.5', '4', null), '10.00');
  });

  test('rowTotal returns dash when values invalid', () {
    expect(rowTotal('x', '1', null), '—');
  });
}
