import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';
import 'package:habitpal_frontend/features/profile/domain/profile_provider.dart';
import 'package:habitpal_frontend/shared/widgets/platform_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
          const SizedBox(height: 16),
          Text(
            profile.email.isNotEmpty ? profile.email : 'User',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(l10n.darkMode),
                  trailing: AdaptiveSwitch(
                    value: profile.isDarkMode,
                    onChanged: (_) {
                      ref.read(profileProvider.notifier).toggleDarkMode();
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: Text(
                    profile.locale == 'en' ? l10n.english : l10n.russian,
                  ),
                  onTap: () {
                    final newLocale = profile.locale == 'en' ? 'ru' : 'en';
                    ref.read(profileProvider.notifier).setLocale(newLocale);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.logout,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                final confirmed = await showAdaptiveConfirmDialog<bool>(
                  context: context,
                  title: l10n.logout,
                  content: l10n.logoutConfirm,
                  confirmText: l10n.logout,
                  isDestructive: true,
                );
                if (confirmed == true && context.mounted) {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/habits');
            case 1:
              context.go('/statistics');
            case 2:
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            label: l10n.habits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
