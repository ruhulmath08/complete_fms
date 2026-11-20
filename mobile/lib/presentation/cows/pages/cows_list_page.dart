import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/domain/failures.dart';
import 'package:mobile/domain/use_cases/cow/cows_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/shared/widgets/async_state_views.dart';
import 'package:mobile/presentation/shared/widgets/entity_list_card.dart';
import 'package:mobile/domain/entities/cow/cow_entity.dart';

class CowsListPage extends StatefulWidget {
  const CowsListPage({super.key});

  @override
  State<CowsListPage> createState() => _CowsListPageState();
}

class _CowsListPageState extends State<CowsListPage> {
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<CowEntity> _cows = const [];

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
    } on Failure catch (e) {
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
