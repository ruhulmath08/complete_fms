import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/domain/failures.dart';
import 'package:mobile/domain/usecases/crop/crops_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/infrastructure/router/app_routes.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/shared/widgets/async_state_views.dart';
import 'package:mobile/presentation/shared/widgets/entity_list_card.dart';
import 'package:mobile/domain/entities/crop/crop_cycle.dart';

class CropCyclesListPage extends StatefulWidget {
  const CropCyclesListPage({super.key});

  @override
  State<CropCyclesListPage> createState() => _CropCyclesListPageState();
}

class _CropCyclesListPageState extends State<CropCyclesListPage> {
  bool _includeArchived = false;
  bool _loading = true;
  String? _error;
  List<CropCycle> _cycles = const [];
  Map<String, String> _nameById = const {};

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
      final names = await getIt<ListCropNames>()(includeArchived: true);
      final cycles = await getIt<ListCropCycles>()(
        includeArchived: _includeArchived,
      );
      if (!mounted) return;
      setState(() {
        _nameById = {for (final name in names.items) name.id: name.name};
        _cycles = cycles.items;
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
                  l10n.cropsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(AppRoutes.cropNames);
                  _load();
                },
                child: Text(l10n.cropNamesTitle),
              ),
              FilledButton(
                onPressed: () async {
                  await context.push(AppRoutes.cropCyclesNew);
                  _load();
                },
                child: Text(l10n.addCropCycle),
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
          else if (_cycles.isEmpty)
            Expanded(child: Center(child: Text(l10n.noCropCycles)))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _cycles.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: tokens.space2),
                  itemBuilder: (context, index) {
                    final cycle = _cycles[index];
                    final cropLabel =
                        _nameById[cycle.cropNameId] ?? l10n.cropLabel;
                    final title =
                        cycle.plotName == null || cycle.plotName!.isEmpty
                        ? cropLabel
                        : '$cropLabel · ${cycle.plotName}';
                    return EntityListCard(
                      title: title,
                      subtitle:
                          '${l10n.plantedPrefix} ${cycle.plantedAt}'
                          '${cycle.isArchived ? ' · ${l10n.archived}' : ''}',
                      onTap: () async {
                        await context.push(AppRoutes.cropCycle(cycle.id));
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
