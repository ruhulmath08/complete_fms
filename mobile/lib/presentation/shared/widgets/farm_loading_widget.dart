import 'package:material_ui/material_ui.dart';
import 'package:mobile/infrastructure/theme/app_theme.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Reusable farm-themed loading state with a looping animated GIF.
class FarmLoadingWidget extends StatelessWidget {
  const FarmLoadingWidget({
    super.key,
    this.message,
    this.size = 90,
    this.showMessage = true,
  });

  static const String animationAsset = 'assets/animations/farm_loading.gif';

  final String? message;
  final double size;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    final label = message ?? AppLocalizations.of(context)!.loadingLabel;
    final tokens = AppTokens.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          animationAsset,
          width: size,
          height: size,
          fit: BoxFit.fill,
          errorBuilder: (_, _, _) => SizedBox.square(
            dimension: size,
            child: Center(
              child: CircularProgressIndicator(
                color: tokens.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        if (showMessage) ...[
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: tokens.surface),
          ),
        ],
      ],
    );
  }
}
