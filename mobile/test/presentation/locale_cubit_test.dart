import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/locale/locale_cubit.dart';

void main() {
  test('locale cubit switches between English and Bangla', () {
    final cubit = LocaleCubit();
    expect(cubit.state.languageCode, 'en');
    cubit.setLocale(const Locale('bn'));
    expect(cubit.state.languageCode, 'bn');
    cubit.setLocale(const Locale('en'));
    expect(cubit.state.languageCode, 'en');
    cubit.close();
  });
}
