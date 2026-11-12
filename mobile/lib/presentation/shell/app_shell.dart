import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../infrastructure/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../session/session_cubit.dart';

enum _OverflowAction { profile, logout }

class _DrawerDestination {
  const _DrawerDestination({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  List<_DrawerDestination> _destinations(AppLocalizations l10n) => [
        _DrawerDestination(
          path: '/cows',
          label: l10n.cowsTitle,
          icon: Icons.pets_outlined,
        ),
        _DrawerDestination(
          path: '/poultry',
          label: l10n.poultryTitle,
          icon: Icons.egg_outlined,
        ),
        _DrawerDestination(
          path: '/crops',
          label: l10n.cropsTitle,
          icon: Icons.grass_outlined,
        ),
        _DrawerDestination(
          path: '/inventory',
          label: l10n.inventoryTitle,
          icon: Icons.inventory_2_outlined,
        ),
        _DrawerDestination(
          path: '/ledger',
          label: l10n.ledgerTitle,
          icon: Icons.account_balance_wallet_outlined,
        ),
        _DrawerDestination(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
        ),
        _DrawerDestination(
          path: '/settings',
          label: l10n.farmSettings,
          icon: Icons.settings_outlined,
        ),
      ];

  bool _isSelected(String location, String path) {
    return location == path || location.startsWith('$path/');
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.signOutConfirmTitle),
          content: Text(l10n.signOutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await context.read<SessionCubit>().signOut();
    }
  }

  Widget _menuRow({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = AppTokens.of(context);
    final destinations = _destinations(l10n);
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<_OverflowAction>(
            tooltip: l10n.moreOptions,
            icon: const Icon(Icons.more_vert),
            onSelected: (action) async {
              switch (action) {
                case _OverflowAction.profile:
                  context.go('/profile');
                case _OverflowAction.logout:
                  await _confirmSignOut(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _OverflowAction.profile,
                child: _menuRow(
                  icon: Icons.person_outline,
                  title: l10n.profile,
                ),
              ),
              PopupMenuItem(
                value: _OverflowAction.logout,
                child: _menuRow(
                  icon: Icons.logout,
                  title: l10n.signOut,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space4,
                  tokens.space5,
                  tokens.space4,
                  tokens.space3,
                ),
                child: Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              for (final destination in destinations)
                ListTile(
                  leading: Icon(destination.icon),
                  title: Text(destination.label),
                  selected: _isSelected(location, destination.path),
                  selectedColor: tokens.primary,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(destination.path);
                  },
                ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
