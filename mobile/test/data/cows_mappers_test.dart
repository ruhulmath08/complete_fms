import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/cows_mappers.dart';
import 'package:mobile/domain/entities/cow.dart';

void main() {
  test('maps cow JSON including acquired_by and image_url', () {
    final cow = mapCow({
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'tag_number': 'C-100',
      'name': 'Bella',
      'breed': null,
      'date_of_birth': null,
      'purpose': 'milk',
      'gender': 'female',
      'color': null,
      'weight': '120.5',
      'age': 3,
      'acquired_by': 'born_on_farm',
      'purchase_date': null,
      'purchase_price': null,
      'notes': null,
      'image_url': '/api/v1/cows/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/image',
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });

    expect(cow.tagNumber, 'C-100');
    expect(cow.purpose, CowPurpose.milk);
    expect(cow.acquiredBy, AcquisitionSource.bornOnFarm);
    expect(cow.milkEligible, isTrue);
    expect(cow.weight, '120.5');
    expect(
      cow.imageUrl,
      '/api/v1/cows/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/image',
    );
  });

  test('meat purpose is not milk eligible', () {
    final cow = mapCow({
      'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'tag_number': 'T-1',
      'name': null,
      'breed': null,
      'date_of_birth': null,
      'purpose': 'meat',
      'gender': 'male',
      'color': null,
      'weight': null,
      'age': null,
      'acquired_by': 'purchased',
      'purchase_date': '2024-01-01',
      'purchase_price': '1000.00',
      'notes': null,
      'image_url': null,
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });

    expect(cow.milkEligible, isFalse);
    expect(cow.acquiredBy, AcquisitionSource.purchased);
    expect(cow.imageUrl, isNull);
  });

  test('cowWriteToJson omits tag_number and clears purchase when born on farm',
      () {
    final json = cowWriteToJson(
      const CowWriteParams(
        purpose: CowPurpose.both,
        gender: CowGender.female,
        acquiredBy: AcquisitionSource.bornOnFarm,
        name: 'Daisy',
        breed: 'Holstein',
        purchaseDate: '2024-01-01',
        purchasePrice: '99',
      ),
    );

    expect(json.containsKey('tag_number'), isFalse);
    expect(json['name'], 'Daisy');
    expect(json['breed'], 'Holstein');
    expect(json['acquired_by'], 'born_on_farm');
    expect(json['purchase_date'], isNull);
    expect(json['purchase_price'], isNull);
  });

  test('cowWriteToJson keeps purchase fields when purchased', () {
    final json = cowWriteToJson(
      const CowWriteParams(
        purpose: CowPurpose.milk,
        gender: CowGender.female,
        acquiredBy: AcquisitionSource.purchased,
        name: 'Bella',
        breed: 'Jersey',
        purchaseDate: '2024-06-01',
        purchasePrice: '25000.00',
      ),
    );

    expect(json.containsKey('tag_number'), isFalse);
    expect(json['acquired_by'], 'purchased');
    expect(json['purchase_date'], '2024-06-01');
    expect(json['purchase_price'], '25000.00');
  });

  test('maps milk and feeding entries', () {
    final milk = mapMilk({
      'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      'cow_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'produced_at': '2024-07-01T06:00:00Z',
      'quantity': '12.500',
      'unit': 'L',
      'price_per_unit': '50.00',
      'note': 'morning',
      'created_at': '2024-07-01T06:01:00Z',
    });
    final feeding = mapFeeding({
      'id': 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      'cow_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'fed_at': '2024-07-01T08:00:00Z',
      'feed_name': 'Hay',
      'quantity': '5',
      'unit': 'kg',
      'note': null,
      'created_at': '2024-07-01T08:01:00Z',
    });

    expect(milk.quantity, '12.500');
    expect(milk.unit, 'L');
    expect(feeding.feedName, 'Hay');
  });
}
