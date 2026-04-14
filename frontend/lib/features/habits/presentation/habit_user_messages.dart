import 'package:habitpal_frontend/core/l10n/app_localizations.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_error_codes.dart';

String displayHabitErrorUserMessage(String message, AppLocalizations l10n) {
  if (message == kHabitErrorTemplateAlreadyExists) {
    return l10n.templateAlreadyExists;
  }
  return message;
}
