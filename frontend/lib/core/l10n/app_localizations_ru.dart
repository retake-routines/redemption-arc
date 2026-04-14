// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HabitPal';

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get displayName => 'Имя пользователя';

  @override
  String get loginButton => 'Войти';

  @override
  String get registerButton => 'Создать аккаунт';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get haveAccount => 'Уже есть аккаунт?';

  @override
  String get loginError => 'Ошибка входа. Проверьте данные.';

  @override
  String get registerError => 'Ошибка регистрации. Попробуйте снова.';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get habits => 'Привычки';

  @override
  String get myHabits => 'Мои привычки';

  @override
  String get addHabit => 'Добавить привычку';

  @override
  String get editHabit => 'Редактировать привычку';

  @override
  String get deleteHabit => 'Удалить привычку';

  @override
  String get habitName => 'Название привычки';

  @override
  String get habitDescription => 'Описание';

  @override
  String get habitIcon => 'Иконка';

  @override
  String get habitColor => 'Цвет';

  @override
  String get frequency => 'Частота';

  @override
  String get daily => 'Ежедневно';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get confirmDelete => 'Вы уверены, что хотите удалить эту привычку?';

  @override
  String get noHabits => 'Привычек пока нет';

  @override
  String get noHabitsSubtitle => 'Нажмите +, чтобы создать первую привычку';

  @override
  String get habitCreated => 'Привычка создана';

  @override
  String get habitDeleted => 'Привычка удалена';

  @override
  String get markComplete => 'Отметить выполнение';

  @override
  String get markIncomplete => 'Снять отметку';

  @override
  String get completedToday => 'Выполнено сегодня';

  @override
  String get streak => 'Серия';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get longestStreak => 'Лучшая серия';

  @override
  String get days => 'дней';

  @override
  String get statistics => 'Статистика';

  @override
  String get totalHabits => 'Всего привычек';

  @override
  String get completionRate => 'Процент выполнения';

  @override
  String get bestStreak => 'Лучшая серия';

  @override
  String get averageStreak => 'Средняя серия';

  @override
  String get activeHabits => 'Активные привычки';

  @override
  String get todayCompletions => 'Выполнено сегодня';

  @override
  String get noData => 'Данных пока нет';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get error => 'Ошибка';

  @override
  String get loading => 'Загрузка...';

  @override
  String get retry => 'Повторить';

  @override
  String get activity => 'Активность';

  @override
  String get target => 'Цель';

  @override
  String get frequencyValue => 'Раз за период';

  @override
  String get selectIcon => 'Выберите иконку';

  @override
  String get selectColor => 'Выберите цвет';

  @override
  String get habitNameRequired => 'Введите название привычки';

  @override
  String get emailRequired => 'Введите электронную почту';

  @override
  String get passwordRequired => 'Введите пароль';

  @override
  String get passwordTooShort => 'Пароль должен содержать минимум 6 символов';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get filterAll => 'Все';

  @override
  String get filterActive => 'Активные';

  @override
  String get filterDoneToday => 'Закрытые';

  @override
  String habitsProgressToday(int completed, int total) {
    return 'Сегодня выполнено $completed из $total привычек';
  }

  @override
  String get progressMessageStart => 'Начнём!';

  @override
  String get progressMessageKeep => 'Продолжайте!';

  @override
  String get progressMessageAlmost => 'Почти всё!';

  @override
  String get progressMessageDone => 'Готово! Отличная работа!';

  @override
  String get statTotalCompletions => 'Всего выполнений';

  @override
  String get statActiveDays => 'Активные дни';

  @override
  String get onboardingTitle => 'Добро пожаловать';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в HabitPal';

  @override
  String get onboardingWelcomeSubtitle =>
      'Несколько шагов, чтобы настроить напоминания и стартовые привычки.';

  @override
  String get onboardingGoalTitle => 'Что для вас главное?';

  @override
  String get onboardingGoalSubtitle =>
      'Мы используем это, чтобы персонализировать опыт.';

  @override
  String get onboardingGoalHealth => 'Здоровье и энергия';

  @override
  String get onboardingGoalProductivity => 'Продуктивность и фокус';

  @override
  String get onboardingGoalCalm => 'Спокойствие и осознанность';

  @override
  String get onboardingGoalBalance => 'Баланс и привычки';

  @override
  String get onboardingReminderTitle => 'Когда напоминать?';

  @override
  String get onboardingReminderSubtitle =>
      'Позже это можно изменить в настройках.';

  @override
  String get onboardingReminderMorning => 'Утром';

  @override
  String get onboardingReminderAfternoon => 'Днём';

  @override
  String get onboardingReminderEvening => 'Вечером';

  @override
  String get onboardingReminderAnytime => 'В любое время';

  @override
  String get onboardingHabitsTitle => 'Стартовые привычки';

  @override
  String get onboardingHabitsSubtitle => 'Выберите одну или две из шаблонов.';

  @override
  String get onboardingSelectUpToTwo => 'Не больше двух';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingPickAtLeastOne => 'Выберите хотя бы одну привычку.';

  @override
  String get onboardingSelectGoal => 'Выберите цель.';

  @override
  String get onboardingSelectReminder => 'Выберите время напоминаний.';

  @override
  String get habitTemplatesTitle => 'Шаблоны привычек';

  @override
  String get habitTemplatesSubtitle =>
      'Добавить готовую привычку с рекомендованным расписанием.';

  @override
  String get templateSportTitle => 'Движение';

  @override
  String get templateSportDesc => 'Короткая тренировка, прогулка или растяжка.';

  @override
  String get templateSportFrequency => 'Ежедневно · 1 раз';

  @override
  String get templateWaterTitle => 'Вода';

  @override
  String get templateWaterDesc => 'Пить достаточно воды в течение дня.';

  @override
  String get templateWaterFrequency => 'Ежедневно · 8 стаканов';

  @override
  String get templateSleepTitle => 'Сон';

  @override
  String get templateSleepDesc => 'Режим сна и спокойный вечер.';

  @override
  String get templateSleepFrequency => 'Ежедневно · 1 раз';

  @override
  String get templateReadingTitle => 'Чтение';

  @override
  String get templateReadingDesc => 'Несколько страниц каждый день.';

  @override
  String get templateReadingFrequency => 'Ежедневно · 1 раз';

  @override
  String get templateMeditationTitle => 'Осознанность';

  @override
  String get templateMeditationDesc => 'Короткая медитация или дыхание.';

  @override
  String get templateMeditationFrequency => 'Ежедневно · 1 раз';

  @override
  String get templateAdded => 'Привычка добавлена из шаблона';

  @override
  String get templateAlreadyExists => 'У вас уже есть эта привычка.';
}
