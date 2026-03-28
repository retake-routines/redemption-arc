import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/theme/app_colors.dart';

class CalendarHeatmap extends StatelessWidget {
  final List<DateTime> completedDates;
  final int weeksToShow;

  const CalendarHeatmap({
    super.key,
    this.completedDates = const [],
    this.weeksToShow = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateUtils.dateOnly(DateTime.now());
    final totalDays = weeksToShow * 7;
    final startDate = today.subtract(Duration(days: totalDays - 1));

    // Normalize completed dates to date-only for lookup
    final completedSet = <DateTime>{};
    for (final d in completedDates) {
      completedSet.add(DateUtils.dateOnly(d));
    }

    // Align start to Monday
    final adjustedStart = startDate.subtract(
      Duration(days: (startDate.weekday - 1) % 7),
    );

    final dayLabels = ['M', '', 'W', '', 'F', '', ''];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels row
        _buildMonthLabels(context, adjustedStart, today),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels
            Column(
              children: List.generate(7, (i) {
                return SizedBox(
                  height: 14,
                  width: 16,
                  child: Text(
                    dayLabels[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(128),
                        ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 2),
            // Heatmap grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final actualWeeks =
                      ((today.difference(adjustedStart).inDays + 1) / 7).ceil();
                  final cellSize =
                      ((constraints.maxWidth - (actualWeeks - 1) * 2) /
                              actualWeeks)
                          .clamp(6.0, 14.0);

                  return Wrap(
                    direction: Axis.vertical,
                    spacing: 2,
                    runSpacing: 2,
                    children: List.generate(actualWeeks * 7, (index) {
                      final weekIndex = index ~/ 7;
                      final dayIndex = index % 7;
                      final date = adjustedStart.add(
                        Duration(days: weekIndex * 7 + dayIndex),
                      );

                      if (date.isAfter(today)) {
                        return SizedBox(
                            width: cellSize, height: cellSize);
                      }

                      final isCompleted = completedSet.contains(date);

                      return Tooltip(
                        message:
                            '${date.day}/${date.month}/${date.year}${isCompleted ? ' ✓' : ''}',
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.heatmapLevel3
                                : (isDark
                                    ? AppColors.heatmapEmptyDark
                                    : AppColors.heatmapEmpty),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthLabels(
      BuildContext context, DateTime start, DateTime today) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final labels = <Widget>[];
    final seenMonths = <int>{};
    var current = start;

    while (!current.isAfter(today)) {
      if (!seenMonths.contains(current.month)) {
        seenMonths.add(current.month);
        labels.add(
          Text(
            months[current.month - 1],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
          ),
        );
        labels.add(const SizedBox(width: 8));
      }
      current = current.add(const Duration(days: 7));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: Row(children: labels),
    );
  }
}
