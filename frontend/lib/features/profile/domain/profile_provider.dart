import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';

class ProfileState {
  final String email;
  final String displayName;
  final bool isDarkMode;
  final String locale;
  final bool isLoading;

  const ProfileState({
    this.email = '',
    this.displayName = '',
    this.isDarkMode = false,
    this.locale = 'en',
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? email,
    String? displayName,
    bool? isDarkMode,
    String? locale,
    bool? isLoading,
  }) {
    return ProfileState(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final LocalStorage _storage;
  final Ref _ref;

  ProfileNotifier(this._storage, this._ref) : super(const ProfileState());

  /// Loads profile info from auth state and persisted preferences.
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    // Read user info from auth state
    final authState = _ref.read(authStateProvider);
    final user = authState.user;

    // Read persisted preferences
    final isDarkMode = await _storage.isDarkMode();
    final locale = await _storage.getLocale();

    state = ProfileState(
      email: user?.email ?? '',
      displayName: user?.displayName ?? '',
      isDarkMode: isDarkMode,
      locale: locale,
    );
  }

  /// Toggles dark mode and persists the preference.
  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    _storage.setDarkMode(newValue);
  }

  /// Sets the locale and persists the preference.
  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _storage.setLocale(locale);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final storage = ref.read(localStorageProvider);
  return ProfileNotifier(storage, ref);
});

/// Convenience provider for theme mode preference.
final themeProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isDarkMode;
});

/// Convenience provider for locale preference.
final localeProvider = Provider<String>((ref) {
  return ref.watch(profileProvider).locale;
});
