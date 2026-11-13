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
import '../../shared/widgets/entity_list_card.dart';
import '../widgets/fertilizer_stock_table.dart';
import '../widgets/inventory_item_form_fields.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<InventoryItem> _items = const [];
  final _stockTableKey = GlobalKey<FertilizerStockTableState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await getIt<ListInventoryItems>()(
        includeArchived: _includeArchived,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items;
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

  Future<void> _refreshAll() async {
    await Future.wait([
      _load(),
      _stockTableKey.currentState?.reload() ?? Future<void>.value(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: EdgeInsets.all(tokens.space4),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.inventoryTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push(AppRoutes.inventoryNew);
                  _refreshAll();
                },
                child: Text(l10n.addInventoryItem),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.includeArchived),
            value: _includeArchived,
            onChanged: (value) {
              setState(() => _includeArchived = value);
              _load();
            },
          ),
          if (_error != null) ErrorView(message: _error!),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingView(),
            )
          else if (_items.isEmpty)
            Padding(
              padding: EdgeInsets.all(tokens.space4),
              child: Center(child: Text(l10n.noInventoryItems)),
            )
          else
            for (final item in _items) ...[
              EntityListCard(
                title: item.name,
                subtitle: '${inventoryCategoryLabel(l10n, item.category)} · '
                    '${item.quantity} ${item.unit}'
                    '${item.isArchived ? ' · ${l10n.archived}' : ''}',
                onTap: () async {
                  await context.push(AppRoutes.inventoryItem(item.id));
                  _refreshAll();
                },
              ),
              SizedBox(height: tokens.space2),
            ],
          const Divider(height: 32),
          FertilizerStockTable(key: _stockTableKey),
        ],
      ),
    );
  }
}
