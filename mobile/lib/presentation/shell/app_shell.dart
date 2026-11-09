import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../session/session_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          TextButton(
            onPressed: () => context.go('/profile'),
            child: Text(l10n.profile),
          ),
          TextButton(
            onPressed: () => context.go('/settings'),
            child: Text(l10n.farmSettings),
          ),
          TextButton(
            onPressed: () => context.read<SessionCubit>().signOut(),
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: child,
    );
  }
}
