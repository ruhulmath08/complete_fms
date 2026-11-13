import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/owner_profile.dart';
import '../../../domain/failures.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';
import '../widgets/profile_image_preview.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  OwnerProfile? _profile;
  Uint8List? _imageBytes;
  String? _error;
  String? _imagePath;
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await getIt<GetProfile>()();
      final bytes = await getIt<AuthRepository>().getProfileImageBytes();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _imageBytes = Uint8List.fromList(bytes);
        _fullName.text = profile.fullName;
        _email.text = profile.email;
        _phone.text = profile.phone;
        _address.text = profile.address;
        _latitude.text = profile.latitude.toString();
        _longitude.text = profile.longitude.toString();
        _loading = false;
      });
    } on AppFailure catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
      _saved = false;
    });
    try {
      final updated = await getIt<UpdateProfile>()(
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        latitude: double.parse(_latitude.text),
        longitude: double.parse(_longitude.text),
        profileImagePath: _imagePath,
      );
      final bytes = await getIt<AuthRepository>().getProfileImageBytes();
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _imageBytes = Uint8List.fromList(bytes);
        _imagePath = null;
        _saved = true;
      });
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.profile, style: Theme.of(context).textTheme.headlineSmall),
        if (_error != null)
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        if (_saved) Text(l10n.saved),
        ProfileImagePreview(localPath: _imagePath, bytes: _imageBytes),
        FormFieldColumn(
          children: [
            TextField(controller: _fullName, decoration: InputDecoration(labelText: l10n.fullName)),
            TextField(controller: _email, decoration: InputDecoration(labelText: l10n.email)),
            TextField(controller: _phone, decoration: InputDecoration(labelText: l10n.phone)),
            TextField(controller: _address, decoration: InputDecoration(labelText: l10n.address)),
            TextField(controller: _latitude, decoration: InputDecoration(labelText: l10n.latitude)),
            TextField(controller: _longitude, decoration: InputDecoration(labelText: l10n.longitude)),
          ],
        ),
        const SizedBox(height: FormFieldColumn.gap),
        OutlinedButton(
          onPressed: () async {
            final file = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (file != null) setState(() => _imagePath = file.path);
          },
          child: Text(l10n.pickImage),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
        if (_profile != null)
          Text('${_profile!.email} · ${_profile!.updatedAt}', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
