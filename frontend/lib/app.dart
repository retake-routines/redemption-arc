import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/core/router/app_router.dart';
import 'package:habitpal_frontend/core/theme/app_theme.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';
import 'package:habitpal_frontend/features/profile/domain/profile_provider.dart';

class HabitPalApp extends ConsumerStatefulWidget {
  const HabitPalApp({super.key});

  @override
  ConsumerState<HabitPalApp> createState() => _HabitPalAppState();
}

class _HabitPalAppState extends ConsumerState<HabitPalApp> {
  @override
  void initState() {
    super.initState();
    // Restore auth, then theme/locale/user fields for profile from storage
    Future.microtask(() async {
      await ref.read(authStateProvider.notifier).checkAuthStatus();
      await ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final isDarkMode = ref.watch(themeProvider);
    final localeCode = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'HabitPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      locale: Locale(localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
