import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_template.dart';

String _normColor(String hex) {
  var s = hex.trim();
  if (s.isEmpty) return '';
  if (!s.startsWith('#')) s = '#$s';
  if (s.length == 7) {
    return '#${s.substring(1).toUpperCase()}';
  }
  return s.toUpperCase();
}

/// Resolves a template id for this habit (stored key or fingerprint match).
String? templateIdForHabit(HabitModel habit) {
  if (habit.templateKey.isNotEmpty &&
      kHabitTemplateMeta.containsKey(habit.templateKey)) {
    return habit.templateKey;
  }
  for (final id in kHabitTemplateIds) {
    final m = kHabitTemplateMeta[id]!;
    if (habit.icon != m.iconKey) continue;
    if (_normColor(habit.color) != _normColor(m.colorHex)) continue;
    if (habit.frequency != m.frequencyType) continue;
    if (habit.targetCount != m.frequencyValue) continue;
    return id;
  }
  return null;
}

String localizedHabitTitle(HabitModel habit, AppLocalizations l10n) {
  final id = templateIdForHabit(habit);
  if (id != null) return habitTemplateTitle(id, l10n);
  return habit.name;
}

String localizedHabitDescription(HabitModel habit, AppLocalizations l10n) {
  final id = templateIdForHabit(habit);
  if (id != null) return habitTemplateDescription(id, l10n);
  return habit.description;
}

bool habitListHasTemplate(List<HabitModel> habits, String templateId) {
  for (final h in habits) {
    if (templateIdForHabit(h) == templateId) return true;
  }
  return false;
}
