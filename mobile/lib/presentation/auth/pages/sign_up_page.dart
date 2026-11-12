import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/failures.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../infrastructure/di/injection.dart';
import '../../../infrastructure/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/widgets/form_field_column.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _latitude = TextEditingController(text: '23.81');
  final _longitude = TextEditingController(text: '90.41');
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _imagePath;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_imagePath == null) {
      setState(() => _error = l10n.profileImage);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await getIt<SignUp>()(
        SignUpParams(
          fullName: _fullName.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          latitude: double.parse(_latitude.text),
          longitude: double.parse(_longitude.text),
          password: _password.text,
          confirmPassword: _confirm.text,
          profileImagePath: _imagePath!,
        ),
      );
      if (!mounted) return;
      context.go(AppRoutes.signIn);
    } on AppFailure catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l10n.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signUp)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.signUpSubtitle),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FormFieldColumn(
            children: [
              TextField(
                controller: _fullName,
                decoration: InputDecoration(labelText: l10n.fullName),
              ),
              TextField(
                controller: _email,
                decoration: InputDecoration(labelText: l10n.email),
              ),
              TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              TextField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.address),
              ),
              TextField(
                controller: _latitude,
                decoration: InputDecoration(labelText: l10n.latitude),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _longitude,
                decoration: InputDecoration(labelText: l10n.longitude),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: FormFieldColumn.gap),
          OutlinedButton(
            onPressed: _pickImage,
            child: Text(
              _imagePath == null ? l10n.pickImage : l10n.profileImage,
            ),
          ),
          const SizedBox(height: FormFieldColumn.gap),
          FormFieldColumn(
            children: [
              TextField(
                controller: _password,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
              ),
              TextField(
                controller: _confirm,
                decoration: InputDecoration(labelText: l10n.confirmPassword),
                obscureText: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(l10n.signUp),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.signIn),
            child: Text(l10n.alreadyRegistered),
          ),
        ],
      ),
    );
  }
}
