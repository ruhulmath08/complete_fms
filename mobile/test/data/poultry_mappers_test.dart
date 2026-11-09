import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/poultry_mappers.dart';
import 'package:mobile/domain/entities/poultry.dart';

void main() {
  test('maps poultry group JSON including acquired_by snake_case', () {
    final group = mapPoultryGroup({
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'poultry_type': 'layer',
      'name': 'House A',
      'bird_count': 100,
      'date_acquired': null,
      'acquired_by': 'born_on_farm',
      'purchase_date': null,
      'purchase_price': null,
      'notes': null,
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });

    expect(group.name, 'House A');
    expect(group.poultryType, PoultryType.layer);
    expect(group.acquiredBy, AcquisitionSource.bornOnFarm);
    expect(group.eggsEligible, isTrue);
    expect(group.birdCount, 100);
  });

  test('broiler is not egg eligible', () {
    final group = mapPoultryGroup({
      'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'poultry_type': 'broiler',
      'name': 'Broilers',
      'bird_count': 200,
      'date_acquired': null,
      'acquired_by': 'purchased',
      'purchase_date': '2024-01-01',
      'purchase_price': '1000.00',
      'notes': null,
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });

    expect(group.eggsEligible, isFalse);
    expect(group.acquiredBy, AcquisitionSource.purchased);
  });

  test('poultryGroupWriteToJson clears purchase fields when born on farm', () {
    final json = poultryGroupWriteToJson(
      const PoultryGroupWriteParams(
        poultryType: PoultryType.duck,
        name: 'Ducks',
        birdCount: 20,
        acquiredBy: AcquisitionSource.bornOnFarm,
        purchaseDate: '2024-01-01',
        purchasePrice: '99',
      ),
    );

    expect(json['acquired_by'], 'born_on_farm');
    expect(json['purchase_date'], isNull);
    expect(json['purchase_price'], isNull);
  });

  test('poultryGroupWriteToJson keeps purchase fields when purchased', () {
    final json = poultryGroupWriteToJson(
      const PoultryGroupWriteParams(
        poultryType: PoultryType.local,
        name: 'Local',
        birdCount: 30,
        acquiredBy: AcquisitionSource.purchased,
        purchaseDate: '2024-06-01',
        purchasePrice: '5000.00',
      ),
    );

    expect(json['acquired_by'], 'purchased');
    expect(json['purchase_date'], '2024-06-01');
    expect(json['purchase_price'], '5000.00');
  });

  test('maps egg and feeding entries', () {
    final egg = mapEgg({
      'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      'poultry_group_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'produced_at': '2024-07-01T06:00:00Z',
      'quantity': '80.000',
      'unit': 'pcs',
      'price_per_unit': '12.00',
      'note': 'morning',
      'created_at': '2024-07-01T06:01:00Z',
    });
    final feeding = mapPoultryFeeding({
      'id': 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      'poultry_group_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'fed_at': '2024-07-01T08:00:00Z',
      'feed_name': 'Starter',
      'quantity': '25',
      'unit': 'kg',
      'note': null,
      'created_at': '2024-07-01T08:01:00Z',
    });

    expect(egg.quantity, '80.000');
    expect(egg.unit, 'pcs');
    expect(feeding.feedName, 'Starter');
  });
}
