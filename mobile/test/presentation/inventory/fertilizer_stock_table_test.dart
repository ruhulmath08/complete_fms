import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entities/inventory.dart';
import 'package:mobile/domain/usecases/inventory_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/presentation/inventory/widgets/fertilizer_stock_table.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/pump_app.dart';

class _MockListFertilizer extends Mock implements ListFertilizerStockUpdates {}

StockUpdateListItem _row(String id, String name, StockChangeType type) =>
    StockUpdateListItem(
      id: id,
      inventoryItemId: 'item-$id',
      itemName: name,
      itemUnit: 'kg',
      itemCategory: InventoryCategory.fertilizer,
      occurredAt: '2026-11-10',
      changeType: type,
      quantityChange: '2.500',
      createdAt: '2026-11-10T10:00:00Z',
      reason: id == '1' ? 'Top dressing' : null,
    );

void main() {
  late _MockListFertilizer usecase;

  setUp(() {
    usecase = _MockListFertilizer();
    getIt.registerSingleton<ListFertilizerStockUpdates>(usecase);
  });

  tearDown(() async => getIt.reset());

  testWidgets('shows fertilizer stock history rows with pagination', (
    tester,
  ) async {
    when(() => usecase(limit: any(named: 'limit'), offset: 0)).thenAnswer(
      (_) async => PagedResult(
        items: [
          _row('1', 'Urea', StockChangeType.use),
          _row('2', 'TSP', StockChangeType.add),
        ],
        total: 25,
        limit: 10,
        offset: 0,
      ),
    );
    when(() => usecase(limit: any(named: 'limit'), offset: 10)).thenAnswer(
      (_) async => PagedResult(
        items: [_row('3', 'MOP', StockChangeType.add)],
        total: 25,
        limit: 10,
        offset: 10,
      ),
    );

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(tester, const SingleChildScrollView(child: FertilizerStockTable()));

    expect(find.text('Fertilizer stock history'), findsWidgets);
    expect(find.text('Urea'), findsOneWidget);
    expect(find.text('TSP'), findsOneWidget);
    expect(find.text('Use'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('2.500 kg'), findsNWidgets(2));
    expect(find.text('Top dressing'), findsOneWidget);
    expect(find.text('Page 1 of 3 · 25 total'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    verify(() => usecase(limit: 10, offset: 10)).called(1);
    expect(find.text('MOP'), findsOneWidget);
    expect(find.text('11'), findsOneWidget); // row number continues paging
    expect(find.text('Page 2 of 3 · 25 total'), findsOneWidget);
  });

  testWidgets('shows empty message', (tester) async {
    when(() => usecase(limit: any(named: 'limit'), offset: any(named: 'offset')))
        .thenAnswer(
      (_) async => const PagedResult<StockUpdateListItem>(
        items: [],
        total: 0,
        limit: 10,
        offset: 0,
      ),
    );
    await pumpLocalized(tester, const FertilizerStockTable());
    expect(find.text('No fertilizer stock updates yet.'), findsOneWidget);
  });
}
