import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/domain/entities/crop.dart';
import 'package:mobile/domain/usecases/crops_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/presentation/crops/pages/crop_cycle_detail_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/pump_app.dart';

class _MockGetCycle extends Mock implements GetCropCycle {}

class _MockListNames extends Mock implements ListCropNames {}

class _MockSummary extends Mock implements GetCropCycleSummary {}

class _MockListExpenses extends Mock implements ListCropExpenses {}

class _MockListHarvests extends Mock implements ListHarvests {}

class _MockAddExpense extends Mock implements AddCropExpense {}

class _MockUpdateExpense extends Mock implements UpdateCropExpense {}

class _MockDeleteExpense extends Mock implements DeleteCropExpense {}

class _MockAddHarvest extends Mock implements AddHarvest {}

class _MockUpdateHarvest extends Mock implements UpdateHarvest {}

class _MockDeleteHarvest extends Mock implements DeleteHarvest {}

const _cycleId = 'cycle-1';

const _expense = CropExpense(
  id: 'exp-1',
  cropCycleId: _cycleId,
  spentAt: '2026-11-05',
  category: ExpenseCategory.seeds,
  amount: '150.00',
  note: 'Hybrid',
  createdAt: '2026-11-05T10:00:00Z',
);

const _harvest = Harvest(
  id: 'har-1',
  cropCycleId: _cycleId,
  harvestedAt: '2026-11-10',
  quantity: '100.000',
  unit: 'kg',
  saleAmount: '5000.00',
  note: null,
  createdAt: '2026-11-10T10:00:00Z',
);

void main() {
  setUpAll(() => registerFallbackValue(ExpenseCategory.labour));

  late _MockUpdateExpense updateExpense;
  late _MockDeleteExpense deleteExpense;
  late _MockUpdateHarvest updateHarvest;
  late _MockDeleteHarvest deleteHarvest;
  late _MockListExpenses listExpenses;

  setUp(() {
    final getCycle = _MockGetCycle();
    final listNames = _MockListNames();
    final summary = _MockSummary();
    listExpenses = _MockListExpenses();
    final listHarvests = _MockListHarvests();
    updateExpense = _MockUpdateExpense();
    deleteExpense = _MockDeleteExpense();
    updateHarvest = _MockUpdateHarvest();
    deleteHarvest = _MockDeleteHarvest();

    when(() => getCycle(_cycleId)).thenAnswer(
      (_) async => const CropCycle(
        id: _cycleId,
        cropNameId: 'name-1',
        plantedAt: '2026-10-01',
        isArchived: false,
        createdAt: '2026-10-01T10:00:00Z',
        updatedAt: '2026-10-01T10:00:00Z',
      ),
    );
    when(() => listNames(includeArchived: any(named: 'includeArchived')))
        .thenAnswer(
      (_) async => const PagedResult<CropName>(
        items: [
          CropName(
            id: 'name-1',
            name: 'Rice',
            isArchived: false,
            createdAt: '2026-10-01T10:00:00Z',
            updatedAt: '2026-10-01T10:00:00Z',
          ),
        ],
        total: 1,
        limit: 100,
        offset: 0,
      ),
    );
    when(() => summary(_cycleId)).thenAnswer(
      (_) async => const CycleSummary(
        cropCycleId: _cycleId,
        totalExpenses: '150.00',
        totalSaleIncome: '5000.00',
        result: '4850.00',
      ),
    );
    when(() => listExpenses(_cycleId)).thenAnswer(
      (_) async => const PagedResult<CropExpense>(
        items: [_expense],
        total: 1,
        limit: 50,
        offset: 0,
      ),
    );
    when(() => listHarvests(_cycleId)).thenAnswer(
      (_) async => const PagedResult<Harvest>(
        items: [_harvest],
        total: 1,
        limit: 50,
        offset: 0,
      ),
    );
    when(() => deleteExpense(_cycleId, 'exp-1')).thenAnswer((_) async {});
    when(() => deleteHarvest(_cycleId, 'har-1')).thenAnswer((_) async {});
    when(
      () => updateExpense(
        cycleId: any(named: 'cycleId'),
        expenseId: any(named: 'expenseId'),
        spentAt: any(named: 'spentAt'),
        category: any(named: 'category'),
        amount: any(named: 'amount'),
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async => _expense);
    when(
      () => updateHarvest(
        cycleId: any(named: 'cycleId'),
        harvestId: any(named: 'harvestId'),
        harvestedAt: any(named: 'harvestedAt'),
        quantity: any(named: 'quantity'),
        unit: any(named: 'unit'),
        saleAmount: any(named: 'saleAmount'),
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async => _harvest);

    getIt
      ..registerSingleton<GetCropCycle>(getCycle)
      ..registerSingleton<ListCropNames>(listNames)
      ..registerSingleton<GetCropCycleSummary>(summary)
      ..registerSingleton<ListCropExpenses>(listExpenses)
      ..registerSingleton<ListHarvests>(listHarvests)
      ..registerSingleton<AddCropExpense>(_MockAddExpense())
      ..registerSingleton<UpdateCropExpense>(updateExpense)
      ..registerSingleton<DeleteCropExpense>(deleteExpense)
      ..registerSingleton<AddHarvest>(_MockAddHarvest())
      ..registerSingleton<UpdateHarvest>(updateHarvest)
      ..registerSingleton<DeleteHarvest>(deleteHarvest);
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpDetail(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLocalized(tester, const CropCycleDetailPage(cycleId: _cycleId));
  }

  testWidgets('expense and harvest tables expose primary edit / danger delete',
      (tester) async {
    await pumpDetail(tester);

    expect(find.byType(DataTable), findsNWidgets(2));
    expect(find.text('Actions'), findsNWidgets(2));
    expect(find.text('Hybrid'), findsOneWidget);
    expect(find.text('Seeds'), findsWidgets);
    expect(find.text('5000.00'), findsWidgets);

    for (final prefix in ['expense', 'harvest']) {
      final id = prefix == 'expense' ? 'exp-1' : 'har-1';
      final edit = tester.widget<IconButton>(
        find.byKey(ValueKey('$prefix-edit-$id')),
      );
      final del = tester.widget<IconButton>(
        find.byKey(ValueKey('$prefix-delete-$id')),
      );
      expect(edit.color, AppTokens.light.primary);
      expect(del.color, AppTokens.light.danger);
    }
  });

  testWidgets('delete expense confirms then calls the delete use case', (
    tester,
  ) async {
    await pumpDetail(tester);

    await tester.tap(find.byKey(const ValueKey('expense-delete-exp-1')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this expense entry?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(() => deleteExpense(_cycleId, 'exp-1')).called(1);
    // list reloaded after delete (initial load + refresh)
    verify(() => listExpenses(_cycleId)).called(2);
  });

  testWidgets('cancelling delete does not call the use case', (tester) async {
    await pumpDetail(tester);

    await tester.tap(find.byKey(const ValueKey('harvest-delete-har-1')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this harvest entry?'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    verifyNever(() => deleteHarvest(any(), any()));
  });

  testWidgets('edit expense loads the form and updates via PATCH use case', (
    tester,
  ) async {
    await pumpDetail(tester);

    await tester.tap(find.byKey(const ValueKey('expense-edit-exp-1')));
    await tester.pumpAndSettle();

    expect(find.text('Update expense'), findsOneWidget);
    expect(find.text('Cancel edit'), findsOneWidget);
    final amountField = find.widgetWithText(TextField, 'Amount');
    expect(
      tester.widget<TextField>(amountField).controller!.text,
      '150.00',
    );

    await tester.enterText(amountField, '175.50');
    await tester.tap(find.text('Update expense'));
    await tester.pumpAndSettle();

    verify(
      () => updateExpense(
        cycleId: _cycleId,
        expenseId: 'exp-1',
        spentAt: '2026-11-05',
        category: ExpenseCategory.seeds,
        amount: '175.50',
        note: 'Hybrid',
      ),
    ).called(1);
    expect(find.text('Update expense'), findsNothing);
    expect(find.text('Add expense'), findsOneWidget);
  });

  testWidgets('edit harvest updates via use case and clears blank sale', (
    tester,
  ) async {
    await pumpDetail(tester);

    await tester.tap(find.byKey(const ValueKey('harvest-edit-har-1')));
    await tester.pumpAndSettle();
    expect(find.text('Update harvest'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Quantity').last,
      '120',
    );
    await tester.tap(find.text('Update harvest'));
    await tester.pumpAndSettle();

    verify(
      () => updateHarvest(
        cycleId: _cycleId,
        harvestId: 'har-1',
        harvestedAt: '2026-11-10',
        quantity: '120',
        unit: 'kg',
        saleAmount: '5000.00',
        note: null,
      ),
    ).called(1);
  });
}
