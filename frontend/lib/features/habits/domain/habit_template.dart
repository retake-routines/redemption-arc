import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';

/// Stable ids for habit templates (icons must exist in [habitIconMap]).
const List<String> kHabitTemplateIds = [
  'sport',
  'water',
  'sleep',
  'reading',
  'meditation',
];

class HabitTemplateMeta {
  final String id;
  final String iconKey;
  final String colorHex;
  final String frequencyType;
  final int frequencyValue;

  const HabitTemplateMeta({
    required this.id,
    required this.iconKey,
    required this.colorHex,
    required this.frequencyType,
    required this.frequencyValue,
  });
}

const Map<String, HabitTemplateMeta> kHabitTemplateMeta = {
  'sport': HabitTemplateMeta(
    id: 'sport',
    iconKey: 'fitness',
    colorHex: '#F44336',
    frequencyType: 'daily',
    frequencyValue: 1,
  ),
  'water': HabitTemplateMeta(
    id: 'water',
    iconKey: 'water',
    colorHex: '#2196F3',
    frequencyType: 'daily',
    frequencyValue: 8,
  ),
  'sleep': HabitTemplateMeta(
    id: 'sleep',
    iconKey: 'sleep',
    colorHex: '#9C27B0',
    frequencyType: 'daily',
    frequencyValue: 1,
  ),
  'reading': HabitTemplateMeta(
    id: 'reading',
    iconKey: 'book',
    colorHex: '#009688',
    frequencyType: 'daily',
    frequencyValue: 1,
  ),
  'meditation': HabitTemplateMeta(
    id: 'meditation',
    iconKey: 'meditation',
    colorHex: '#4CAF50',
    frequencyType: 'daily',
    frequencyValue: 1,
  ),
};

CreateHabitRequest habitTemplateToRequest(String id, AppLocalizations l10n) {
  final meta = kHabitTemplateMeta[id];
  if (meta == null) {
    throw ArgumentError('Unknown habit template: $id');
  }
  return CreateHabitRequest(
    title: habitTemplateTitle(id, l10n),
    description: habitTemplateDescription(id, l10n),
    icon: meta.iconKey,
    color: meta.colorHex,
    frequencyType: meta.frequencyType,
    frequencyValue: meta.frequencyValue,
    templateKey: id,
  );
}

String habitTemplateTitle(String id, AppLocalizations l10n) {
  switch (id) {
    case 'sport':
      return l10n.templateSportTitle;
    case 'water':
      return l10n.templateWaterTitle;
    case 'sleep':
      return l10n.templateSleepTitle;
    case 'reading':
      return l10n.templateReadingTitle;
    case 'meditation':
      return l10n.templateMeditationTitle;
    default:
      return id;
  }
}

String habitTemplateDescription(String id, AppLocalizations l10n) {
  switch (id) {
    case 'sport':
      return l10n.templateSportDesc;
    case 'water':
      return l10n.templateWaterDesc;
    case 'sleep':
      return l10n.templateSleepDesc;
    case 'reading':
      return l10n.templateReadingDesc;
    case 'meditation':
      return l10n.templateMeditationDesc;
    default:
      return '';
  }
}

String habitTemplateFrequencyLabel(String id, AppLocalizations l10n) {
  switch (id) {
    case 'sport':
      return l10n.templateSportFrequency;
    case 'water':
      return l10n.templateWaterFrequency;
    case 'sleep':
      return l10n.templateSleepFrequency;
    case 'reading':
      return l10n.templateReadingFrequency;
    case 'meditation':
      return l10n.templateMeditationFrequency;
    default:
      return '';
  }
}
