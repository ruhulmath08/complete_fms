import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/cow.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/cows_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/router/app_routes.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/async_state_views.dart';
import '../../shared/widgets/entity_list_card.dart';

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
                  l10n.cowsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push(AppRoutes.cowsNew);
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
          if (_error != null) ErrorView(message: _error!),
          if (_loading)
            const Expanded(child: LoadingView())
          else if (_cows.isEmpty)
            Expanded(
              child: EmptyView(
                message: l10n.noCows,
                action: FilledButton(
                  onPressed: () async {
                    await context.push(AppRoutes.cowsNew);
                    _load();
                  },
                  child: Text(l10n.addCow),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _cows.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: tokens.space2),
                  itemBuilder: (context, index) {
                    final cow = _cows[index];
                    return EntityListCard(
                      title: cow.name == null || cow.name!.isEmpty
                          ? cow.tagNumber
                          : '${cow.tagNumber} · ${cow.name}',
                      subtitle:
                          '${cow.purpose.name} · ${cow.gender.name}'
                          '${cow.isArchived ? ' · ${l10n.archived}' : ''}',
                      onTap: () async {
                        await context.push(AppRoutes.cow(cow.id));
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
