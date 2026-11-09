import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/inventory_mappers.dart';
import 'package:mobile/domain/entities/inventory.dart';

void main() {
  test('maps inventory item including total_price', () {
    final item = mapInventoryItem({
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'name': 'Layer feed',
      'category': 'feed',
      'quantity': '100.000',
      'unit': 'kg',
      'price_per_unit': '50.00',
      'total_price': '5000.00',
      'note': null,
      'is_archived': false,
      'created_at': '2026-11-09T10:00:00Z',
      'updated_at': '2026-11-09T10:00:00Z',
    });

    expect(item.name, 'Layer feed');
    expect(item.category, InventoryCategory.feed);
    expect(item.totalPrice, '5000.00');
  });

  test('maps stock update change_type and write payloads omit quantity on update', () {
    final update = mapStockUpdate({
      'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      'inventory_item_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'occurred_at': '2024-06-01',
      'change_type': 'use',
      'quantity_change': '5.000',
      'reason': null,
      'created_at': '2024-06-01T08:00:00Z',
    });
    expect(update.changeType, StockChangeType.use);

    final createJson = inventoryItemCreateToJson(
      const InventoryItemCreateParams(
        name: 'Urea',
        category: InventoryCategory.fertilizer,
        quantity: '20',
        unit: 'kg',
        pricePerUnit: '30',
      ),
    );
    expect(createJson['quantity'], '20');
    expect(createJson['category'], 'fertilizer');

    final updateJson = inventoryItemUpdateToJson(
      const InventoryItemUpdateParams(
        name: 'Urea',
        category: InventoryCategory.fertilizer,
        unit: 'kg',
        pricePerUnit: '30',
      ),
    );
    expect(updateJson.containsKey('quantity'), isFalse);
  });
}
