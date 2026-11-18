import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/domain/entities/inventory.dart';
import 'package:mobile/domain/failures.dart';
import 'package:mobile/domain/usecases/inventory_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/inventory/widgets/inventory_item_form_fields.dart';

class InventoryCreatePage extends StatefulWidget {
  const InventoryCreatePage({super.key});

  @override
  State<InventoryCreatePage> createState() => _InventoryCreatePageState();
}

class _InventoryCreatePageState extends State<InventoryCreatePage> {
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '0');
  final _unit = TextEditingController(text: 'kg');
  final _pricePerUnit = TextEditingController(text: '0');
  final _note = TextEditingController();
  InventoryCategory _category = InventoryCategory.feed;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    _pricePerUnit.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final item = await getIt<CreateInventoryItem>()(
        buildInventoryItemCreateParams(
          name: _name,
          quantity: _quantity,
          unit: _unit,
          pricePerUnit: _pricePerUnit,
          note: _note,
          category: _category,
        ),
      );
      if (!mounted) return;
      context.go(AppRoutes.inventoryItem(item.id));
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.addInventoryItem,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        InventoryItemFormFields(
          includeQuantity: true,
          name: _name,
          quantity: _quantity,
          unit: _unit,
          pricePerUnit: _pricePerUnit,
          note: _note,
          category: _category,
          onCategoryChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? l10n.saving : l10n.createInventoryItem),
        ),
      ],
    );
  }
}
