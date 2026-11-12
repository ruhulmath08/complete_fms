import 'package:flutter/material.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: tokens.space3),
          Text(
            message ?? l10n.loadingLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.muted,
                ),
          ),
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.action,
  });

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: tokens.muted,
                  ),
            ),
            if (action != null) ...[
              SizedBox(height: tokens.space4),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Material(
      color: tokens.dangerBg,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: Padding(
        padding: EdgeInsets.all(tokens.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: tokens.danger),
            SizedBox(width: tokens.space2),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.danger,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
