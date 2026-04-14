import 'package:flutter/material.dart';
import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_template.dart';
import 'package:habitpal_frontend/shared/utils/habit_icons.dart';

class HabitTemplateTile extends StatelessWidget {
  const HabitTemplateTile({
    super.key,
    required this.templateId,
    required this.l10n,
    this.selected = false,
    this.onTap,
    this.trailing,
    /// When true, [trailing] is outside the main [InkWell] so taps (e.g. checkbox) do not double-fire.
    this.isolateTrailing = false,
  });

  final String templateId;
  final AppLocalizations l10n;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isolateTrailing;

  @override
  Widget build(BuildContext context) {
    final meta = kHabitTemplateMeta[templateId];
    if (meta == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final accent = parseHabitColor(meta.colorHex, scheme.primary);

    return Card(
      elevation: selected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? accent : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isolateTrailing && trailing != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: accent.withAlpha(40),
                            child: Icon(
                              resolveHabitIcon(meta.iconKey),
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _textColumn(context, templateId, l10n)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing!,
                ],
              )
            : InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: accent.withAlpha(40),
                      child: Icon(resolveHabitIcon(meta.iconKey), color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _textColumn(context, templateId, l10n)),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
      ),
    );
  }
}

Widget _textColumn(
  BuildContext context,
  String templateId,
  AppLocalizations l10n,
) {
  final scheme = Theme.of(context).colorScheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        habitTemplateTitle(templateId, l10n),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      Text(
        habitTemplateFrequencyLabel(templateId, l10n),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
      const SizedBox(height: 4),
      Text(
        habitTemplateDescription(templateId, l10n),
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
