import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Full-image profile preview (contain, not circular crop).
class ProfileImagePreview extends StatelessWidget {
  const ProfileImagePreview({
    super.key,
    this.localPath,
    this.bytes,
    this.height = 220,
  });

  final String? localPath;
  final Uint8List? bytes;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);

    final Widget? image;
    if (localPath != null) {
      image = Image.file(
        File(localPath!),
        fit: BoxFit.contain,
        width: double.infinity,
        height: height,
      );
    } else if (bytes != null) {
      image = Image.memory(
        bytes!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: height,
      );
    } else {
      image = null;
    }

    if (image == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: ColoredBox(
          color: tokens.border.withValues(alpha: 0.35),
          child: Semantics(
            label: l10n.profileImage,
            image: true,
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: image,
            ),
          ),
        ),
      ),
    );
  }
}
