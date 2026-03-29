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

  static const double _dayLabelWidth = 18.0;
  static const double _cellGap = 2.0;
  static const double _monthLabelHeight = 14.0;
  static const double _monthLabelSpacing = 4.0;

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
              // Month labels row
              _buildMonthLabels(
                context,
                adjustedStart,
                today,
                actualWeeks,
                cellSize,
              ),
              SizedBox(height: _monthLabelSpacing),
              // Grid area
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day-of-week labels
                  _buildDayLabels(context, cellSize),
                  SizedBox(width: _cellGap),
                  // Heatmap grid: 7 rows, each with N cells
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
                              final isAfterToday = date.isAfter(today);
                              final isCompleted =
                                  !isAfterToday && completedSet.contains(date);

                              return Padding(
                                padding: EdgeInsets.only(
                                  left: weekIndex > 0 ? _cellGap : 0,
                                ),
                                child:
                                    isAfterToday
                                        ? SizedBox(
                                          width: cellSize,
                                          height: cellSize,
                                        )
                                        : Tooltip(
                                          message:
                                              '${date.day}/${date.month}/${date.year}'
                                              '${isCompleted ? ' \u2713' : ''}',
                                          child: Container(
                                            width: cellSize,
                                            height: cellSize,
                                            decoration: BoxDecoration(
                                              color:
                                                  isCompleted
                                                      ? AppColors.heatmapLevel3
                                                      : (isDark
                                                          ? AppColors
                                                              .heatmapEmptyDark
                                                          : AppColors
                                                              .heatmapEmpty),
                                              borderRadius:
                                                  BorderRadius.circular(2),
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
    final dayLabels = ['M', '', 'W', '', 'F', '', ''];
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 9,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
    );

    return SizedBox(
      width: _dayLabelWidth,
      child: Column(
        children: List.generate(7, (i) {
          return Padding(
            padding: EdgeInsets.only(top: i > 0 ? _cellGap : 0),
            child: SizedBox(
              height: cellSize,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(dayLabels[i], style: labelStyle),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthLabels(
    BuildContext context,
    DateTime start,
    DateTime today,
    int actualWeeks,
    double cellSize,
  ) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 9,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
    );

    // Build positioned month labels
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
            child: Text(months[weekStart.month - 1], style: labelStyle),
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
