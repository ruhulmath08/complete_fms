import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/crops_mappers.dart';
import 'package:mobile/domain/entities/crop.dart';

void main() {
  test('maps crop name JSON', () {
    final name = mapCropName({
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'name': 'Rice',
      'notes': null,
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });

    expect(name.name, 'Rice');
    expect(name.isArchived, isFalse);
  });

  test('maps crop cycle and expense category snake_case', () {
    final cycle = mapCropCycle({
      'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'crop_name_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'plot_name': 'North',
      'area': '2.500',
      'location': 'Block A',
      'planted_at': '2024-06-01',
      'expected_harvest_at': null,
      'notes': null,
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });
    final expense = mapCropExpense({
      'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      'crop_cycle_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'spent_at': '2024-06-10',
      'category': 'pesticides_and_chemicals',
      'amount': '150.00',
      'note': null,
      'created_at': '2024-06-10T08:00:00Z',
    });

    expect(cycle.cropNameId, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    expect(cycle.area, '2.500');
    expect(expense.category, ExpenseCategory.pesticidesAndChemicals);
    expect(expenseCategoryToApi(expense.category), 'pesticides_and_chemicals');
  });

  test('maps harvest and cycle summary', () {
    final harvest = mapHarvest({
      'id': 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      'crop_cycle_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'harvested_at': '2024-09-01',
      'quantity': '100.000',
      'unit': 'kg',
      'sale_amount': '5000.00',
      'note': null,
      'created_at': '2024-09-01T10:00:00Z',
    });
    final summary = mapCycleSummary({
      'crop_cycle_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'total_expenses': '150.00',
      'total_sale_income': '5000.00',
      'result': '4850.00',
    });

    expect(harvest.saleAmount, '5000.00');
    expect(summary.result, '4850.00');
  });

  test('cropCycleWriteToJson keeps optional nulls', () {
    final json = cropCycleWriteToJson(
      const CropCycleWriteParams(
        cropNameId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        plantedAt: '2024-06-01',
      ),
    );

    expect(json['crop_name_id'], 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    expect(json['planted_at'], '2024-06-01');
    expect(json['plot_name'], isNull);
    expect(json['area'], isNull);
  });
}
