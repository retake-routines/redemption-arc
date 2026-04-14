import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_localized_display.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_template.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/features/habits/presentation/habit_user_messages.dart';
import 'package:habitpal_frontend/features/habits/presentation/widgets/habit_template_tile.dart';

class HabitTemplatesScreen extends ConsumerWidget {
  const HabitTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    ref.listen(habitsProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayHabitErrorUserMessage(next, l10n)),
            backgroundColor: scheme.error,
          ),
        );
      }
    });

    final habits = ref.watch(habitsProvider).habits;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/habits'),
        ),
        title: Text(l10n.habitTemplatesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.habitTemplatesSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ...kHabitTemplateIds.map((id) {
            final owned = habitListHasTemplate(habits, id);

            void showAlreadyHave() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.templateAlreadyExists)),
              );
            }

            Future<void> addFromTemplate() async {
              if (owned) {
                showAlreadyHave();
                return;
              }
              await ref
                  .read(habitsProvider.notifier)
                  .createHabit(habitTemplateToRequest(id, l10n));
              if (!context.mounted) return;
              if (ref.read(habitsProvider).errorMessage != null) return;
              await ref.read(habitsProvider.notifier).loadHabits();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.templateAdded)),
                );
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitTemplateTile(
                templateId: id,
                l10n: l10n,
                trailing: IconButton(
                  icon: Icon(
                    owned ? Icons.check_circle : Icons.add_circle_outline,
                  ),
                  onPressed: addFromTemplate,
                ),
                onTap: addFromTemplate,
              ),
            );
          }),
        ],
      ),
    );
  }
}
