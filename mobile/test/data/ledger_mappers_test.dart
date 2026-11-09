import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/mappers/ledger_mappers.dart';
import 'package:mobile/domain/entities/ledger.dart';

void main() {
  test('maps ledger entry including total_price equals amount', () {
    final entry = mapLedgerEntry({
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'entry_type': 'income',
      'occurred_at': '2024-06-15',
      'category': 'product_sale',
      'amount': '100.00',
      'unit': null,
      'total_price': '100.00',
      'note': null,
      'is_archived': false,
      'created_at': '2024-06-15T10:00:00Z',
      'updated_at': '2024-06-15T10:00:00Z',
    });

    expect(entry.entryType, LedgerEntryType.income);
    expect(entry.category, LedgerEntryCategory.productSale);
    expect(entry.amount, '100.00');
    expect(entry.totalPrice, '100.00');
  });

  test('maps period totals and write payload snake_case', () {
    final totals = mapPeriodTotals({
      'from': '2024-06-01',
      'to': '2024-06-30',
      'total_income': '200.00',
      'total_expenses': '50.00',
      'net': '150.00',
    });
    expect(totals.net, '150.00');

    final json = ledgerEntryWriteToJson(
      const LedgerEntryWriteParams(
        entryType: LedgerEntryType.expense,
        occurredAt: '2024-06-10',
        category: LedgerEntryCategory.feedOrSupplies,
        amount: '25.00',
        unit: 'kg',
      ),
    );
    expect(json['entry_type'], 'expense');
    expect(json['category'], 'feed_or_supplies');
    expect(json['amount'], '25.00');
  });
}
