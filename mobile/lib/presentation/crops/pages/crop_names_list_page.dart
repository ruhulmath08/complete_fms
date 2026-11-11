import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/crop.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/crops_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/entity_list_card.dart';

class CropNamesListPage extends StatefulWidget {
  const CropNamesListPage({super.key});

  @override
  State<CropNamesListPage> createState() => _CropNamesListPageState();
}

class _CropNamesListPageState extends State<CropNamesListPage> {
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<CropName> _names = const [];

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
          await getIt<ListCropNames>()(includeArchived: _includeArchived);
      if (!mounted) return;
      setState(() {
        _names = page.items;
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
    final tokens = AppTokens.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.cropNamesTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push('/crops/names/new');
                  _load();
                },
                child: Text(l10n.addCropName),
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
          else if (_names.isEmpty)
            Expanded(child: Center(child: Text(l10n.noCropNames)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _names.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: tokens.space2),
                  itemBuilder: (context, index) {
                    final name = _names[index];
                    return EntityListCard(
                      title: name.name,
                      subtitle: name.isArchived
                          ? l10n.archived
                          : (name.notes ?? ''),
                      onTap: () async {
                        await context.push('/crops/names/${name.id}');
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
