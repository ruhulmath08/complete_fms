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
  });

  final String? cowId;
  final bool hasRemoteImage;
  final String? localPath;
  final ValueChanged<String?>? onLocalPathChanged;
  final bool canPick;

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

    Widget preview;
    if (localPath != null) {
      preview = Image.file(
        File(localPath),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (_loadingRemote) {
      preview = const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_remoteBytes != null) {
      preview = Image.memory(
        _remoteBytes!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      preview = Container(
        height: 160,
        alignment: Alignment.center,
        color: tokens.border.withValues(alpha: 0.35),
        child: Text(
          _remoteFailed ? l10n.cowImageUnavailable : l10n.cowImage,
          style: TextStyle(color: tokens.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: preview,
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
