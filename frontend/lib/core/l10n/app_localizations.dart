import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HabitPal'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginError;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerError;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @myHabits.
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get myHabits;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add Habit'**
  String get addHabit;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitName;

  /// No description provided for @habitDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get habitDescription;

  /// No description provided for @habitIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get habitIcon;

  /// No description provided for @habitColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get habitColor;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this habit?'**
  String get confirmDelete;

  /// No description provided for @noHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabits;

  /// No description provided for @noHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first habit'**
  String get noHabitsSubtitle;

  /// No description provided for @habitCreated.
  ///
  /// In en, this message translates to:
  /// **'Habit created successfully'**
  String get habitCreated;

  /// No description provided for @habitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted successfully'**
  String get habitDeleted;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @markIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Incomplete'**
  String get markIncomplete;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get completedToday;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalHabits.
  ///
  /// In en, this message translates to:
  /// **'Total Habits'**
  String get totalHabits;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @averageStreak.
  ///
  /// In en, this message translates to:
  /// **'Average Streak'**
  String get averageStreak;

  /// No description provided for @activeHabits.
  ///
  /// In en, this message translates to:
  /// **'Active Habits'**
  String get activeHabits;

  /// No description provided for @todayCompletions.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Completions'**
  String get todayCompletions;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noData;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @frequencyValue.
  ///
  /// In en, this message translates to:
  /// **'Times per period'**
  String get frequencyValue;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @habitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a habit name'**
  String get habitNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get filterDoneToday;

  /// No description provided for @habitsProgressToday.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} habits completed today'**
  String habitsProgressToday(int completed, int total);

  /// No description provided for @progressMessageStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started!'**
  String get progressMessageStart;

  /// No description provided for @progressMessageKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get progressMessageKeep;

  /// No description provided for @progressMessageAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get progressMessageAlmost;

  /// No description provided for @progressMessageDone.
  ///
  /// In en, this message translates to:
  /// **'All done! Great job!'**
  String get progressMessageDone;

  /// No description provided for @statTotalCompletions.
  ///
  /// In en, this message translates to:
  /// **'Total Completions'**
  String get statTotalCompletions;

  /// No description provided for @statActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get statActiveDays;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HabitPal'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few quick steps to tailor reminders and starter habits to you.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your main focus?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will use this to personalize your experience.'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingGoalHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & energy'**
  String get onboardingGoalHealth;

  /// No description provided for @onboardingGoalProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity & focus'**
  String get onboardingGoalProductivity;

  /// No description provided for @onboardingGoalCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm & mindfulness'**
  String get onboardingGoalCalm;

  /// No description provided for @onboardingGoalBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance & habits'**
  String get onboardingGoalBalance;

  /// No description provided for @onboardingReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'When should we remind you?'**
  String get onboardingReminderTitle;

  /// No description provided for @onboardingReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in settings.'**
  String get onboardingReminderSubtitle;

  /// No description provided for @onboardingReminderMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get onboardingReminderMorning;

  /// No description provided for @onboardingReminderAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get onboardingReminderAfternoon;

  /// No description provided for @onboardingReminderEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get onboardingReminderEvening;

  /// No description provided for @onboardingReminderAnytime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get onboardingReminderAnytime;

  /// No description provided for @onboardingHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick starter habits'**
  String get onboardingHabitsTitle;

  /// No description provided for @onboardingHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one or two templates to begin with.'**
  String get onboardingHabitsSubtitle;

  /// No description provided for @onboardingSelectUpToTwo.
  ///
  /// In en, this message translates to:
  /// **'Select up to 2'**
  String get onboardingSelectUpToTwo;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingPickAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please pick at least one habit.'**
  String get onboardingPickAtLeastOne;

  /// No description provided for @onboardingSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Please choose a goal.'**
  String get onboardingSelectGoal;

  /// No description provided for @onboardingSelectReminder.
  ///
  /// In en, this message translates to:
  /// **'Please choose a reminder time.'**
  String get onboardingSelectReminder;

  /// No description provided for @habitTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit templates'**
  String get habitTemplatesTitle;

  /// No description provided for @habitTemplatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a ready-made habit with a suggested schedule.'**
  String get habitTemplatesSubtitle;

  /// No description provided for @templateSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get templateSportTitle;

  /// No description provided for @templateSportDesc.
  ///
  /// In en, this message translates to:
  /// **'Short workout, walk, or stretch.'**
  String get templateSportDesc;

  /// No description provided for @templateSportFrequency.
  ///
  /// In en, this message translates to:
  /// **'Daily · 1×'**
  String get templateSportFrequency;

  /// No description provided for @templateWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get templateWaterTitle;

  /// No description provided for @templateWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink enough water during the day.'**
  String get templateWaterDesc;

  /// No description provided for @templateWaterFrequency.
  ///
  /// In en, this message translates to:
  /// **'Daily · 8 glasses'**
  String get templateWaterFrequency;

  /// No description provided for @templateSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep routine'**
  String get templateSleepTitle;

  /// No description provided for @templateSleepDesc.
  ///
  /// In en, this message translates to:
  /// **'Wind down and keep a consistent bedtime.'**
  String get templateSleepDesc;

  /// No description provided for @templateSleepFrequency.
  ///
  /// In en, this message translates to:
  /// **'Daily · 1×'**
  String get templateSleepFrequency;

  /// No description provided for @templateReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get templateReadingTitle;

  /// No description provided for @templateReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Read a few pages every day.'**
  String get templateReadingDesc;

  /// No description provided for @templateReadingFrequency.
  ///
  /// In en, this message translates to:
  /// **'Daily · 1×'**
  String get templateReadingFrequency;

  /// No description provided for @templateMeditationTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get templateMeditationTitle;

  /// No description provided for @templateMeditationDesc.
  ///
  /// In en, this message translates to:
  /// **'A short breathing or meditation session.'**
  String get templateMeditationDesc;

  /// No description provided for @templateMeditationFrequency.
  ///
  /// In en, this message translates to:
  /// **'Daily · 1×'**
  String get templateMeditationFrequency;

  /// No description provided for @templateAdded.
  ///
  /// In en, this message translates to:
  /// **'Habit added from template'**
  String get templateAdded;

  /// No description provided for @templateAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'You already have this habit.'**
  String get templateAlreadyExists;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
