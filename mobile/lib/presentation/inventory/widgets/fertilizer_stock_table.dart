import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/inventory.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/inventory_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/router/app_routes.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../shared/widgets/offset_pagination_controls.dart';

/// Read-only fertilizer stock history (all fertilizer items), paginated.
class FertilizerStockTable extends StatefulWidget {
  const FertilizerStockTable({super.key, this.pageSize = 10});

  final int pageSize;

  @override
  State<FertilizerStockTable> createState() => FertilizerStockTableState();
}

class FertilizerStockTableState extends State<FertilizerStockTable> {
  bool _loading = true;
  String? _error;
  int _offset = 0;
  int _total = 0;
  List<StockUpdateListItem> _rows = const [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await getIt<ListFertilizerStockUpdates>()(
        limit: widget.pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _rows = page.items;
        _total = page.total;
        _loading = false;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  String _summary(AppLocalizations l10n) {
    final page = (_offset ~/ widget.pageSize) + 1;
    final totalPages = (_total / widget.pageSize).ceil().clamp(1, 1 << 30);
    return l10n.paginationSummary(page, totalPages, _total);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.fertilizerStockHistory,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: tokens.space2),
        if (_error != null) ErrorView(message: _error!),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingView(),
          )
        else if (_rows.isEmpty && _error == null)
          Text(l10n.noFertilizerStockUpdates)
        else if (_rows.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.rowNumber)),
                DataColumn(label: Text(l10n.dateLabel)),
                DataColumn(label: Text(l10n.itemLabel)),
                DataColumn(label: Text(l10n.stockChangeType)),
                DataColumn(label: Text(l10n.quantity)),
                DataColumn(label: Text(l10n.reason)),
              ],
              rows: [
                for (var i = 0; i < _rows.length; i++)
                  DataRow(
                    cells: [
                      DataCell(Text('${_offset + i + 1}')),
                      DataCell(Text(_rows[i].occurredAt)),
                      DataCell(
                        InkWell(
                          onTap: () => context.push(
                            AppRoutes.inventoryItem(_rows[i].inventoryItemId),
                          ),
                          child: Text(
                            _rows[i].itemName,
                            style: TextStyle(
                              color: tokens.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _rows[i].changeType == StockChangeType.add
                              ? l10n.stockAdd
                              : l10n.stockUse,
                        ),
                      ),
                      DataCell(
                        Text('${_rows[i].quantityChange} ${_rows[i].itemUnit}'),
                      ),
                      DataCell(Text(_rows[i].reason ?? '—')),
                    ],
                  ),
              ],
            ),
          ),
          OffsetPaginationControls(
            total: _total,
            limit: widget.pageSize,
            offset: _offset,
            onOffsetChanged: (next) async {
              setState(() => _offset = next);
              await reload();
            },
            semanticsLabel: l10n.fertilizerStockHistory,
            summaryText: _summary(l10n),
            previousLabel: l10n.paginationPrevious,
            nextLabel: l10n.paginationNext,
          ),
        ],
      ],
    );
  }
}
