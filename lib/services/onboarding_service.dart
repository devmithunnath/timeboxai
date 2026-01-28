import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class OnboardingService extends ChangeNotifier {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _userNameKey = 'user_name';
  static const String _presetTimersKey = 'preset_timers';

  static const String _notificationsEnabledKey = 'notifications_enabled';

  SharedPreferences? _prefs;
  bool _hasCompletedOnboarding = false;
  String _userName = '';
  List<int> _presetTimers = [5 * 60, 10 * 60, 15 * 60];
  bool _notificationsEnabled = true;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String get userName => _userName;
  List<int> get presetTimers => List.unmodifiable(_presetTimers);
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding =
        _prefs?.getBool(_hasCompletedOnboardingKey) ?? false;
    _userName = _prefs?.getString(_userNameKey) ?? '';
    _notificationsEnabled = _prefs?.getBool(_notificationsEnabledKey) ?? true;

    final presetTimersJson = _prefs?.getString(_presetTimersKey);
    if (presetTimersJson != null) {
      _presetTimers = List<int>.from(jsonDecode(presetTimersJson));
    }

    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs?.setBool(_notificationsEnabledKey, enabled);
    if (_hasCompletedOnboarding) {
      await SupabaseService().updateNotificationPermission(
        enabled ? 'granted' : 'denied',
      );
    }
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs?.setString(_userNameKey, name);
    notifyListeners();
  }

  Future<void> setPresetTimers(List<int> timers) async {
    _presetTimers = List.from(timers);
    await _prefs?.setString(_presetTimersKey, jsonEncode(timers));
    notifyListeners();
  }

  Future<void> addPresetTimer(int seconds) async {
    if (!_presetTimers.contains(seconds)) {
      _presetTimers.add(seconds);
      _presetTimers.sort();
      await _prefs?.setString(_presetTimersKey, jsonEncode(_presetTimers));
      if (_hasCompletedOnboarding) {
        await SupabaseService().updatePresetTimers(_presetTimers);
      }
      notifyListeners();
    }
  }

  Future<void> removePresetTimer(int seconds) async {
    _presetTimers.remove(seconds);
    await _prefs?.setString(_presetTimersKey, jsonEncode(_presetTimers));
    if (_hasCompletedOnboarding) {
      await SupabaseService().updatePresetTimers(_presetTimers);
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _prefs?.setBool(_hasCompletedOnboardingKey, true);

    // Create user in Supabase
    if (_userName.isNotEmpty) {
      await SupabaseService().createUser(_userName);
    }

    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    _userName = '';
    _presetTimers = [5 * 60, 10 * 60, 15 * 60];
    await _prefs?.setBool(_hasCompletedOnboardingKey, false);
    await _prefs?.remove(_userNameKey);
    await _prefs?.remove(_presetTimersKey);
    notifyListeners();
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) {
      return '$minutes min';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
