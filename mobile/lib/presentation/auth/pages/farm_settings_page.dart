import 'package:material_ui/material_ui.dart';
import 'package:mobile/domain/use_cases/auth/auth_usecases.dart';
import 'package:mobile/infrastructure/di/injection.dart';
import 'package:mobile/l10n/app_localizations.dart';



class FarmSettingsPage extends StatefulWidget {
  const FarmSettingsPage({super.key});

  @override
  State<FarmSettingsPage> createState() => _FarmSettingsPageState();
}

class _FarmSettingsPageState extends State<FarmSettingsPage> {
  final _currency = TextEditingController();
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetFarmSettings>()();
    if (!mounted) return;
    result.when(
      success: (settings) {
        setState(() {
          _currency.text = settings.currencyCode;
          _loading = false;
        });
      },
      failure: (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
      _saved = false;
    });
    final result = await getIt<UpdateFarmSettings>()(_currency.text.trim());
    if (!mounted) return;
    result.when(
      success: (updated) {
        setState(() {
          _currency.text = updated.currencyCode;
          _saved = true;
        });
      },
      failure: (failure) => setState(() => _error = failure.message),
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _currency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.farmSettings, style: Theme.of(context).textTheme.headlineSmall),
          if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_saved) Text(l10n.saved),
          TextField(
            controller: _currency,
            decoration: InputDecoration(labelText: l10n.currencyCode),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
