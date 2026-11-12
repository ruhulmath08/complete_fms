import 'package:flutter/material.dart';
import '../../../infrastructure/theme/app_theme.dart';

/// Offset-based list pagination (default page size 10 on cow histories).
class OffsetPaginationControls extends StatelessWidget {
  const OffsetPaginationControls({
    super.key,
    required this.total,
    required this.limit,
    required this.offset,
    required this.onOffsetChanged,
    required this.semanticsLabel,
    required this.summaryText,
    required this.previousLabel,
    required this.nextLabel,
  });

  final int total;
  final int limit;
  final int offset;
  final ValueChanged<int> onOffsetChanged;
  final String semanticsLabel;
  final String summaryText;
  final String previousLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final tokens = AppTokens.of(context);
    final canPrev = offset > 0;
    final canNext = offset + limit < total;

    return Semantics(
      label: semanticsLabel,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                summaryText,
                style: TextStyle(color: tokens.muted, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: canPrev
                  ? () => onOffsetChanged((offset - limit).clamp(0, total))
                  : null,
              child: Text(previousLabel),
            ),
            TextButton(
              onPressed: canNext ? () => onOffsetChanged(offset + limit) : null,
              child: Text(nextLabel),
            ),
          ],
        ),
      ),
    );
  }
}
