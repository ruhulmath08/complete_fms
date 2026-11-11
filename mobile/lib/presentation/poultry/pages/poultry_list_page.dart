import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/poultry.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/poultry_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/entity_list_card.dart';

class PoultryListPage extends StatefulWidget {
  const PoultryListPage({super.key});

  @override
  State<PoultryListPage> createState() => _PoultryListPageState();
}

class _PoultryListPageState extends State<PoultryListPage> {
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<PoultryGroup> _groups = const [];

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
          await getIt<ListPoultryGroups>()(includeArchived: _includeArchived);
      if (!mounted) return;
      setState(() {
        _groups = page.items;
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
                  l10n.poultryTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push('/poultry/new');
                  _load();
                },
                child: Text(l10n.addPoultryGroup),
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
          else if (_groups.isEmpty)
            Expanded(child: Center(child: Text(l10n.noPoultryGroups)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _groups.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: tokens.space2),
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return EntityListCard(
                      title: group.name,
                      subtitle:
                          '${group.poultryType.name} · ${group.birdCount} ${l10n.birds}'
                          '${group.isArchived ? ' · ${l10n.archived}' : ''}',
                      onTap: () async {
                        await context.push('/poultry/${group.id}');
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
