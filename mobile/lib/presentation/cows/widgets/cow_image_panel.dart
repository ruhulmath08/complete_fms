import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/failures.dart';
import '../../../domain/usecases/cows_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Local pick preview and/or authenticated remote cow image.
class CowImagePanel extends StatefulWidget {
  const CowImagePanel({
    super.key,
    this.cowId,
    this.hasRemoteImage = false,
    this.localPath,
    this.onLocalPathChanged,
    this.canPick = true,
    this.imageWidth,
    this.imageHeight = 160,
    this.semanticsLabel,
  });

  final String? cowId;
  final bool hasRemoteImage;
  final String? localPath;
  final ValueChanged<String?>? onLocalPathChanged;
  final bool canPick;
  final double? imageWidth;
  final double imageHeight;
  final String? semanticsLabel;

  @override
  State<CowImagePanel> createState() => _CowImagePanelState();
}

class _CowImagePanelState extends State<CowImagePanel> {
  Uint8List? _remoteBytes;
  bool _loadingRemote = false;
  bool _remoteFailed = false;

  @override
  void initState() {
    super.initState();
    _loadRemote();
  }

  @override
  void didUpdateWidget(covariant CowImagePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cowId != widget.cowId ||
        oldWidget.hasRemoteImage != widget.hasRemoteImage) {
      _loadRemote();
    }
  }

  Future<void> _loadRemote() async {
    final cowId = widget.cowId;
    if (cowId == null || !widget.hasRemoteImage) {
      setState(() {
        _remoteBytes = null;
        _remoteFailed = false;
        _loadingRemote = false;
      });
      return;
    }
    setState(() {
      _loadingRemote = true;
      _remoteFailed = false;
    });
    try {
      final bytes = await getIt<GetCowImageBytes>()(cowId);
      if (!mounted) return;
      setState(() {
        _remoteBytes = Uint8List.fromList(bytes);
        _loadingRemote = false;
      });
    } on AppFailure {
      if (!mounted) return;
      setState(() {
        _remoteBytes = null;
        _remoteFailed = true;
        _loadingRemote = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _remoteBytes = null;
        _remoteFailed = true;
        _loadingRemote = false;
      });
    }
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      widget.onLocalPathChanged?.call(file?.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.imagePickFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    final localPath = widget.localPath;

    final width = widget.imageWidth ?? double.infinity;
    final height = widget.imageHeight;
    final label = widget.semanticsLabel ?? l10n.cowImage;

    Widget preview;
    if (localPath != null) {
      preview = Image.file(
        File(localPath),
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    } else if (_loadingRemote) {
      preview = SizedBox(
        height: height,
        width: width,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (_remoteBytes != null) {
      preview = Image.memory(
        _remoteBytes!,
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    } else {
      preview = Semantics(
        label: l10n.cowNoPhoto,
        image: true,
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          color: tokens.border.withValues(alpha: 0.35),
          child: Text(
            _remoteFailed ? l10n.cowImageUnavailable : l10n.cowNoPhoto,
            style: TextStyle(color: tokens.muted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: Semantics(
            label: label,
            image: true,
            child: preview,
          ),
        ),
        if (widget.canPick) ...[
          SizedBox(height: tokens.space2),
          OutlinedButton(
            onPressed: _pick,
            child: Text(l10n.pickCowImage),
          ),
        ],
      ],
    );
  }
}
