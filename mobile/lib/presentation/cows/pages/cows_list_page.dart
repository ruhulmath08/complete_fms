import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/cow.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/cows_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';

class CowsListPage extends StatefulWidget {
  const CowsListPage({super.key});

  @override
  State<CowsListPage> createState() => _CowsListPageState();
}

class _CowsListPageState extends State<CowsListPage> {
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<Cow> _cows = const [];

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
      final page = await getIt<ListCows>()(includeArchived: _includeArchived);
      if (!mounted) return;
      setState(() {
        _cows = page.items;
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
                  l10n.cowsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push('/cows/new');
                  _load();
                },
                child: Text(l10n.addCow),
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
          else if (_cows.isEmpty)
            Expanded(child: Center(child: Text(l10n.noCows)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _cows.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cow = _cows[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      title: Text(
                        cow.name == null || cow.name!.isEmpty
                            ? cow.tagNumber
                            : '${cow.tagNumber} · ${cow.name}',
                      ),
                      subtitle: Text(
                        '${cow.purpose.name} · ${cow.gender.name}'
                        '${cow.isArchived ? ' · ${l10n.archived}' : ''}',
                      ),
                      onTap: () async {
                        await context.push('/cows/${cow.id}');
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
