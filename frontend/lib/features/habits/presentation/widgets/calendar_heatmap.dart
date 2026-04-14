import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// GitHub-style activity grid.
///
/// **Single-habit / binary:** pass [completedDates] only. Past days without a
/// completion use [heatmapMissed]; completed days use green.
///
/// **Multi-habit (statistics):** pass [activeHabitCount] and [completionCountByDay]
/// (local calendar date -> number of habits completed that day). Colors: all done
/// green, partial yellow, none red, future grey.
class CalendarHeatmap extends StatelessWidget {
  final List<DateTime> completedDates;
  final int weeksToShow;

  /// When set with [completionCountByDay], enables green / yellow / red scale.
  final int? activeHabitCount;
  final Map<DateTime, int>? completionCountByDay;

  const CalendarHeatmap({
    super.key,
    this.completedDates = const [],
    this.weeksToShow = 16,
    this.activeHabitCount,
    this.completionCountByDay,
  });

  static const double _dayLabelWidth = 18.0;
  static const double _cellGap = 2.0;
  static const double _monthLabelHeight = 14.0;
  static const double _monthLabelSpacing = 4.0;

  bool get _multiMode =>
      activeHabitCount != null &&
      activeHabitCount! > 0 &&
      completionCountByDay != null;

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();
    final dateTooltipFmt = DateFormat.yMd(localeName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateUtils.dateOnly(DateTime.now());
    final totalDays = weeksToShow * 7;
    final startDate = today.subtract(Duration(days: totalDays - 1));

    final completedSet = <DateTime>{};
    for (final d in completedDates) {
      completedSet.add(DateUtils.dateOnly(d.toLocal()));
    }

    final adjustedStart = startDate.subtract(
      Duration(days: (startDate.weekday - 1) % 7),
    );

    final actualWeeks =
        ((today.difference(adjustedStart).inDays + 1) / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableGridWidth =
            constraints.maxWidth - _dayLabelWidth - _cellGap;
        final cellSize = ((availableGridWidth - (actualWeeks - 1) * _cellGap) /
                actualWeeks)
            .clamp(6.0, 14.0);

        final gridHeight = 7 * cellSize + 6 * _cellGap;
        final totalHeight = _monthLabelHeight + _monthLabelSpacing + gridHeight;

        return SizedBox(
          height: totalHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthLabels(
                context,
                localeName,
                adjustedStart,
                today,
                actualWeeks,
                cellSize,
              ),
              SizedBox(height: _monthLabelSpacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDayLabels(context, cellSize),
                  SizedBox(width: _cellGap),
                  Expanded(
                    child: Column(
                      children: List.generate(7, (dayOfWeek) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: dayOfWeek > 0 ? _cellGap : 0,
                          ),
                          child: Row(
                            children: List.generate(actualWeeks, (weekIndex) {
                              final date = adjustedStart.add(
                                Duration(days: weekIndex * 7 + dayOfWeek),
                              );
                              final dateOnly = DateUtils.dateOnly(date);
                              final isAfterToday = dateOnly.isAfter(today);
                              final isFuture = isAfterToday;

                              final Color cellColor;
                              final bool isCompletedFlag;
                              if (isFuture) {
                                cellColor =
                                    isDark
                                        ? AppColors.heatmapFuture
                                        : AppColors.heatmapEmpty;
                                isCompletedFlag = false;
                              } else if (_multiMode) {
                                final n =
                                    completionCountByDay![dateOnly] ?? 0;
                                final total = activeHabitCount!;
                                if (n <= 0) {
                                  cellColor = AppColors.heatmapMissed;
                                } else if (n >= total) {
                                  cellColor = AppColors.heatmapLevel3;
                                } else {
                                  cellColor = AppColors.heatmapPartial;
                                }
                                isCompletedFlag = n > 0;
                              } else {
                                isCompletedFlag =
                                    !isFuture && completedSet.contains(dateOnly);
                                cellColor =
                                    isCompletedFlag
                                        ? AppColors.heatmapLevel3
                                        : AppColors.heatmapMissed;
                              }

                              return Padding(
                                padding: EdgeInsets.only(
                                  left: weekIndex > 0 ? _cellGap : 0,
                                ),
                                child: Tooltip(
                                  message:
                                      '${dateTooltipFmt.format(dateOnly)}'
                                      '${isCompletedFlag ? ' \u2713' : ''}',
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    decoration: BoxDecoration(
                                      color: cellColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayLabels(BuildContext context, double cellSize) {
    final narrows = MaterialLocalizations.of(context).narrowWeekdays;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 9,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
    );

    return SizedBox(
      width: _dayLabelWidth,
      child: Column(
        children: List.generate(7, (i) {
          final weekday = i + 1;
          final idx = weekday % 7;
          final label =
              (i == 0 || i == 2 || i == 4) ? narrows[idx] : '';
          return Padding(
            padding: EdgeInsets.only(top: i > 0 ? _cellGap : 0),
            child: SizedBox(
              height: cellSize,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(label, style: labelStyle),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthLabels(
    BuildContext context,
    String localeName,
    DateTime start,
    DateTime today,
    int actualWeeks,
    double cellSize,
  ) {
    final monthFmt = DateFormat.MMM(localeName);

    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 9,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
    );

    final labels = <Widget>[];
    final seenMonths = <int>{};

    for (int week = 0; week < actualWeeks; week++) {
      final weekStart = start.add(Duration(days: week * 7));
      if (!weekStart.isAfter(today) && !seenMonths.contains(weekStart.month)) {
        seenMonths.add(weekStart.month);
        final left = _dayLabelWidth + _cellGap + week * (cellSize + _cellGap);
        labels.add(
          Positioned(
            left: left,
            top: 0,
            child: Text(monthFmt.format(weekStart), style: labelStyle),
          ),
        );
      }
    }

    return SizedBox(
      height: _monthLabelHeight,
      child: ClipRect(child: Stack(children: labels)),
    );
  }
}
