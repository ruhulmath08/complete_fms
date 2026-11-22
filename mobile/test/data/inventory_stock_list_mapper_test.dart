import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/inventory/inventory_mappers.dart';
import 'package:mobile/domain/entities/inventory/inventory_category_entity.dart';
import 'package:mobile/domain/entities/inventory/stock_change_type_entity.dart';

void main() {
  test('maps fertilizer stock update list item', () {
    final row = mapStockUpdateListItem({
      'id': 'a',
      'inventory_item_id': 'b',
      'item_name': 'Urea',
      'item_unit': 'kg',
      'item_category': 'fertilizer',
      'occurred_at': '2026-11-10',
      'change_type': 'use',
      'quantity_change': '2.500',
      'reason': null,
      'created_at': '2026-11-10T10:00:00Z',
    });

    expect(row.itemName, 'Urea');
    expect(row.itemCategory, InventoryCategoryEntity.fertilizer);
    expect(row.changeType, StockChangeTypeEntity.use);
    expect(row.quantityChange, '2.500');
    expect(row.reason, isNull);
  });
}
