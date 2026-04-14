// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HabitPal';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get displayName => 'Display Name';

  @override
  String get loginButton => 'Sign In';

  @override
  String get registerButton => 'Create Account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get loginError => 'Login failed. Please check your credentials.';

  @override
  String get registerError => 'Registration failed. Please try again.';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get habits => 'Habits';

  @override
  String get myHabits => 'My Habits';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String get habitName => 'Habit Name';

  @override
  String get habitDescription => 'Description';

  @override
  String get habitIcon => 'Icon';

  @override
  String get habitColor => 'Color';

  @override
  String get frequency => 'Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get confirmDelete => 'Are you sure you want to delete this habit?';

  @override
  String get noHabits => 'No habits yet';

  @override
  String get noHabitsSubtitle => 'Tap + to create your first habit';

  @override
  String get habitCreated => 'Habit created successfully';

  @override
  String get habitDeleted => 'Habit deleted successfully';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get markIncomplete => 'Mark Incomplete';

  @override
  String get completedToday => 'Completed Today';

  @override
  String get streak => 'Streak';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get days => 'days';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalHabits => 'Total Habits';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get averageStreak => 'Average Streak';

  @override
  String get activeHabits => 'Active Habits';

  @override
  String get todayCompletions => 'Today\'s Completions';

  @override
  String get noData => 'No data available yet';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get appVersion => 'App Version';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get activity => 'Activity';

  @override
  String get target => 'Target';

  @override
  String get frequencyValue => 'Times per period';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get habitNameRequired => 'Please enter a habit name';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get filterDoneToday => 'Done today';

  @override
  String habitsProgressToday(int completed, int total) {
    return '$completed of $total habits completed today';
  }

  @override
  String get progressMessageStart => 'Let\'s get started!';

  @override
  String get progressMessageKeep => 'Keep going!';

  @override
  String get progressMessageAlmost => 'Almost there!';

  @override
  String get progressMessageDone => 'All done! Great job!';

  @override
  String get statTotalCompletions => 'Total Completions';

  @override
  String get statActiveDays => 'Active Days';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingWelcomeTitle => 'Welcome to HabitPal';

  @override
  String get onboardingWelcomeSubtitle =>
      'A few quick steps to tailor reminders and starter habits to you.';

  @override
  String get onboardingGoalTitle => 'What is your main focus?';

  @override
  String get onboardingGoalSubtitle =>
      'We will use this to personalize your experience.';

  @override
  String get onboardingGoalHealth => 'Health & energy';

  @override
  String get onboardingGoalProductivity => 'Productivity & focus';

  @override
  String get onboardingGoalCalm => 'Calm & mindfulness';

  @override
  String get onboardingGoalBalance => 'Balance & habits';

  @override
  String get onboardingReminderTitle => 'When should we remind you?';

  @override
  String get onboardingReminderSubtitle =>
      'You can change this later in settings.';

  @override
  String get onboardingReminderMorning => 'Morning';

  @override
  String get onboardingReminderAfternoon => 'Afternoon';

  @override
  String get onboardingReminderEvening => 'Evening';

  @override
  String get onboardingReminderAnytime => 'Any time';

  @override
  String get onboardingHabitsTitle => 'Pick starter habits';

  @override
  String get onboardingHabitsSubtitle =>
      'Choose one or two templates to begin with.';

  @override
  String get onboardingSelectUpToTwo => 'Select up to 2';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPickAtLeastOne => 'Please pick at least one habit.';

  @override
  String get onboardingSelectGoal => 'Please choose a goal.';

  @override
  String get onboardingSelectReminder => 'Please choose a reminder time.';

  @override
  String get habitTemplatesTitle => 'Habit templates';

  @override
  String get habitTemplatesSubtitle =>
      'Add a ready-made habit with a suggested schedule.';

  @override
  String get templateSportTitle => 'Movement';

  @override
  String get templateSportDesc => 'Short workout, walk, or stretch.';

  @override
  String get templateSportFrequency => 'Daily · 1×';

  @override
  String get templateWaterTitle => 'Hydration';

  @override
  String get templateWaterDesc => 'Drink enough water during the day.';

  @override
  String get templateWaterFrequency => 'Daily · 8 glasses';

  @override
  String get templateSleepTitle => 'Sleep routine';

  @override
  String get templateSleepDesc => 'Wind down and keep a consistent bedtime.';

  @override
  String get templateSleepFrequency => 'Daily · 1×';

  @override
  String get templateReadingTitle => 'Reading';

  @override
  String get templateReadingDesc => 'Read a few pages every day.';

  @override
  String get templateReadingFrequency => 'Daily · 1×';

  @override
  String get templateMeditationTitle => 'Mindfulness';

  @override
  String get templateMeditationDesc =>
      'A short breathing or meditation session.';

  @override
  String get templateMeditationFrequency => 'Daily · 1×';

  @override
  String get templateAdded => 'Habit added from template';

  @override
  String get templateAlreadyExists => 'You already have this habit.';
}
