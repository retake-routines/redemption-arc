import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/core/storage/local_storage.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_localized_display.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_template.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/presentation/habit_user_messages.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/habit_template_tile.dart';
import 'package:habitpal_frontend/features/onboarding/domain/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  String? _goalId;
  String? _reminderId;
  final Set<String> _selectedTemplates = {};

  static const _goalKeys = ['health', 'productivity', 'calm', 'balance'];
  static const _reminderKeys = ['morning', 'afternoon', 'evening', 'anytime'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Finishes onboarding with default goal/reminder when skipping from Welcome.
  Future<void> _skipOnboarding() async {
    final storage = ref.read(localStorageProvider);
    await storage.saveOnboardingChoices(
      goalId: 'balance',
      reminderId: 'anytime',
    );
    await ref.read(onboardingFlowProvider.notifier).markCompleted();
    if (mounted) context.go('/habits');
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final storage = ref.read(localStorageProvider);
    await storage.saveOnboardingChoices(
      goalId: _goalId ?? 'balance',
      reminderId: _reminderId ?? 'anytime',
    );
    final notifier = ref.read(habitsProvider.notifier);
    final existing = ref.read(habitsProvider).habits;
    for (final id in _selectedTemplates) {
      if (habitListHasTemplate(existing, id)) {
        continue;
      }
      await notifier.createHabit(habitTemplateToRequest(id, l10n));
      if (!mounted) return;
      if (ref.read(habitsProvider).errorMessage != null) {
        return;
      }
    }
    await notifier.loadHabits();
    if (!mounted) return;
    if (ref.read(habitsProvider).errorMessage != null) {
      return;
    }
    await ref.read(onboardingFlowProvider.notifier).markCompleted();
    if (mounted) context.go('/habits');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    ref.listen(habitsProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayHabitErrorUserMessage(next, l10n)),
            backgroundColor: scheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.onboardingTitle),
        actions: [
          if (_page == 0)
            TextButton(
              onPressed: _skipOnboarding,
              child: Text(l10n.onboardingSkip),
            ),
          if (_page > 0)
            TextButton(
              onPressed: _back,
              child: Text(l10n.onboardingBack),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _WelcomePage(l10n: l10n),
                _ChoicePage(
                  title: l10n.onboardingGoalTitle,
                  subtitle: l10n.onboardingGoalSubtitle,
                  options: _goalKeys,
                  selectedId: _goalId,
                  labelFor: (k) => _goalLabel(k, l10n),
                  onSelect: (k) => setState(() => _goalId = k),
                ),
                _ChoicePage(
                  title: l10n.onboardingReminderTitle,
                  subtitle: l10n.onboardingReminderSubtitle,
                  options: _reminderKeys,
                  selectedId: _reminderId,
                  labelFor: (k) => _reminderLabel(k, l10n),
                  onSelect: (k) => setState(() => _reminderId = k),
                ),
                _HabitsPickPage(
                  l10n: l10n,
                  selected: _selectedTemplates,
                  onToggle: (id) {
                    if (habitListHasTemplate(
                      ref.read(habitsProvider).habits,
                      id,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.templateAlreadyExists)),
                      );
                      return;
                    }
                    setState(() {
                      if (_selectedTemplates.contains(id)) {
                        _selectedTemplates.remove(id);
                      } else if (_selectedTemplates.length < 2) {
                        _selectedTemplates.add(id);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_page < 3) {
                      _next();
                    } else {
                      _finish();
                    }
                  },
                  child: Text(_page < 3 ? l10n.onboardingNext : l10n.onboardingStart),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 88, color: scheme.primary),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChoicePage extends StatelessWidget {
  const _ChoicePage({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedId,
    required this.labelFor,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final String? selectedId;
  final String Function(String) labelFor;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        ...options.map((k) {
          final selected = selectedId == k;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onSelect(k),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          labelFor(k),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _HabitsPickPage extends StatelessWidget {
  const _HabitsPickPage({
    required this.l10n,
    required this.selected,
    required this.onToggle,
  });

  final AppLocalizations l10n;
  final Set<String> selected;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.onboardingHabitsTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingHabitsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingSelectUpToTwo,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),
        ...kHabitTemplateIds.map((id) {
          final isSelected = selected.contains(id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HabitTemplateTile(
              templateId: id,
              l10n: l10n,
              selected: isSelected,
              isolateTrailing: true,
              onTap: () => onToggle(id),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(id),
              ),
            ),
          );
        }),
      ],
    );
  }
}

String _goalLabel(String k, AppLocalizations l10n) {
  switch (k) {
    case 'health':
      return l10n.onboardingGoalHealth;
    case 'productivity':
      return l10n.onboardingGoalProductivity;
    case 'calm':
      return l10n.onboardingGoalCalm;
    case 'balance':
      return l10n.onboardingGoalBalance;
    default:
      return k;
  }
}

String _reminderLabel(String k, AppLocalizations l10n) {
  switch (k) {
    case 'morning':
      return l10n.onboardingReminderMorning;
    case 'afternoon':
      return l10n.onboardingReminderAfternoon;
    case 'evening':
      return l10n.onboardingReminderEvening;
    case 'anytime':
      return l10n.onboardingReminderAnytime;
    default:
      return k;
  }
}
