import 'package:flutter/material.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

/// Same Mon–Sun calendar week in the local timezone.
bool isSameLocalCalendarWeek(DateTime a, DateTime b) {
  final al = DateUtils.dateOnly(a.toLocal());
  final bl = DateUtils.dateOnly(b.toLocal());
  final aMon = al.subtract(Duration(days: al.weekday - 1));
  final bMon = bl.subtract(Duration(days: bl.weekday - 1));
  return aMon == bMon;
}

/// Local Monday 00:00 for the week containing [d] (local date).
DateTime mondayOfLocalWeek(DateTime d) {
  final local = DateUtils.dateOnly(d.toLocal());
  return local.subtract(Duration(days: local.weekday - 1));
}

/// Dates to paint green in the habit activity heatmap.
///
/// For [HabitModel.frequency] `weekly`, any calendar week where the number of
/// completions is at least [HabitModel.targetCount] is shown as fully filled
/// (all Mon–Sun), not only the days that have DB rows — so one tap / one row
/// with target 1 still reads as “the whole week” in the grid.
List<DateTime> heatmapCompletionDates(HabitModel habit) {
  final raw = habit.completions.map((c) => c.completedAt).toList();
  if (habit.frequency != 'weekly') {
    return raw;
  }

  final countByWeekStart = <DateTime, int>{};
  for (final c in habit.completions) {
    final mon = mondayOfLocalWeek(c.completedAt);
    countByWeekStart[mon] = (countByWeekStart[mon] ?? 0) + 1;
  }

  final out = <DateTime>{};
  for (final c in habit.completions) {
    out.add(DateUtils.dateOnly(c.completedAt.toLocal()));
  }
  for (final e in countByWeekStart.entries) {
    if (e.value >= habit.targetCount) {
      for (var i = 0; i < 7; i++) {
        out.add(DateUtils.dateOnly(e.key.add(Duration(days: i))));
      }
    }
  }
  return out.toList();
}
