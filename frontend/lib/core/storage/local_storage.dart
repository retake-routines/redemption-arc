import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

class LocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _darkModeKey = 'dark_mode';
  static const String _localeKey = 'locale';
  static const String _onboardingUserIdKey = 'onboarding_completed_user_id';
  static const String _onboardingDoneKey = 'onboarding_completed_flag';
  static const String _onboardingGoalKey = 'onboarding_goal';
  static const String _onboardingReminderKey = 'onboarding_reminder';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --------------- Token ---------------

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  // --------------- User ---------------

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    final prefs = await _prefs;
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await _prefs;
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> deleteUser() async {
    final prefs = await _prefs;
    await prefs.remove(_userKey);
  }

  // --------------- Dark Mode ---------------

  Future<bool> isDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, value);
  }

  // --------------- Locale ---------------

  Future<String> getLocale() async {
    final prefs = await _prefs;
    return prefs.getString(_localeKey) ?? 'en';
  }

  Future<void> setLocale(String locale) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, locale);
  }

  // --------------- Onboarding ---------------

  /// True if this [userId] has not finished onboarding (or is a new account).
  Future<bool> needsOnboardingForUser(String userId) async {
    if (userId.isEmpty) return false;
    final prefs = await _prefs;
    final savedUser = prefs.getString(_onboardingUserIdKey);
    final done = prefs.getBool(_onboardingDoneKey) ?? false;
    if (savedUser != userId) return true;
    return !done;
  }

  Future<void> setOnboardingCompletedForUser(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_onboardingUserIdKey, userId);
    await prefs.setBool(_onboardingDoneKey, true);
  }

  Future<void> saveOnboardingChoices({
    required String goalId,
    required String reminderId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_onboardingGoalKey, goalId);
    await prefs.setString(_onboardingReminderKey, reminderId);
  }

  Future<String?> getOnboardingGoal() async {
    final prefs = await _prefs;
    return prefs.getString(_onboardingGoalKey);
  }

  Future<String?> getOnboardingReminder() async {
    final prefs = await _prefs;
    return prefs.getString(_onboardingReminderKey);
  }

  // --------------- Clear All ---------------

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
