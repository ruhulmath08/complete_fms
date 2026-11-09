import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/inventory_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
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
      final page =
          await getIt<ListInventoryItems>()(includeArchived: _includeArchived);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  await context.push('/inventory/new');
                  _load();
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
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_items.isEmpty)
            Expanded(child: Center(child: Text(l10n.noInventoryItems)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        '${inventoryCategoryLabel(l10n, item.category)} · '
                        '${item.quantity} ${item.unit}'
                        '${item.isArchived ? ' · ${l10n.archived}' : ''}',
                      ),
                      onTap: () async {
                        await context.push('/inventory/${item.id}');
                        _load();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
