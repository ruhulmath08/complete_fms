import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entities/cow.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/cows/widgets/cow_form_fields.dart';

void main() {
  testWidgets('create form shows Weight (kg), auto-tag hint, no tag field', (
    tester,
  ) async {
    final name = TextEditingController();
    final breed = TextEditingController();
    final dateOfBirth = TextEditingController();
    final color = TextEditingController();
    final weight = TextEditingController();
    final age = TextEditingController();
    final purchaseDate = TextEditingController();
    final purchasePrice = TextEditingController();
    final notes = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CowFormFields(
              isCreate: true,
              name: name,
              breed: breed,
              dateOfBirth: dateOfBirth,
              color: color,
              weight: weight,
              age: age,
              purchaseDate: purchaseDate,
              purchasePrice: purchasePrice,
              notes: notes,
              purpose: CowPurpose.milk,
              gender: CowGender.female,
              acquiredBy: AcquisitionSource.bornOnFarm,
              onPurposeChanged: (_) {},
              onGenderChanged: (_) {},
              onAcquiredByChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Weight (kg)'), findsOneWidget);
    expect(
      find.text('Tag number is generated automatically after create.'),
      findsOneWidget,
    );
    expect(find.text('Tag number'), findsNothing);
  });

  test('buildCowWriteParams requires name and breed', () {
    final name = TextEditingController(text: '');
    final breed = TextEditingController(text: 'Jersey');
    final empty = TextEditingController();

    expect(
      buildCowWriteParams(
        name: name,
        breed: breed,
        dateOfBirth: empty,
        color: empty,
        weight: empty,
        age: empty,
        purchaseDate: empty,
        purchasePrice: empty,
        notes: empty,
        purpose: CowPurpose.milk,
        gender: CowGender.female,
        acquiredBy: AcquisitionSource.bornOnFarm,
      ),
      isNull,
    );

    name.text = 'Daisy';
    final params = buildCowWriteParams(
      name: name,
      breed: breed,
      dateOfBirth: empty,
      color: empty,
      weight: empty,
      age: empty,
      purchaseDate: empty,
      purchasePrice: empty,
      notes: empty,
      purpose: CowPurpose.milk,
      gender: CowGender.female,
      acquiredBy: AcquisitionSource.bornOnFarm,
    );
    expect(params, isNotNull);
    expect(params!.name, 'Daisy');
    expect(params.breed, 'Jersey');
  });
}
