import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:habitpal_frontend/features/auth/domain/auth_provider.dart';

class OnboardingFlowState {
  final bool loading;
  final bool needsOnboarding;

  const OnboardingFlowState({
    this.loading = true,
    this.needsOnboarding = false,
  });
}

class OnboardingNotifier extends StateNotifier<OnboardingFlowState> {
  OnboardingNotifier(this._ref)
      : super(const OnboardingFlowState(loading: true, needsOnboarding: false)) {
    _ref.listen<AuthState>(authStateProvider, (_, next) {
      Future.microtask(() => _sync(next));
    });
    Future.microtask(() => _sync(_ref.read(authStateProvider)));
  }

  final Ref _ref;

  Future<void> _sync(AuthState auth) async {
    if (auth.status != AuthStatus.authenticated ||
        auth.user == null ||
        auth.user!.id.isEmpty) {
      state = const OnboardingFlowState(loading: false, needsOnboarding: false);
      return;
    }
    state = const OnboardingFlowState(loading: true, needsOnboarding: false);
    final storage = _ref.read(localStorageProvider);
    final need = await storage.needsOnboardingForUser(auth.user!.id);
    state = OnboardingFlowState(loading: false, needsOnboarding: need);
  }

  Future<void> markCompleted() async {
    final user = _ref.read(authStateProvider).user;
    final uid = user?.id;
    if (uid == null || uid.isEmpty) return;
    await _ref.read(localStorageProvider).setOnboardingCompletedForUser(uid);
    state = const OnboardingFlowState(loading: false, needsOnboarding: false);
  }
}

final onboardingFlowProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingFlowState>((ref) {
  return OnboardingNotifier(ref);
});
