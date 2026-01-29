import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

class OnboardingService extends ChangeNotifier {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _userNameKey = 'user_name';
  static const String _presetTimersKey = 'preset_timers';
  static const String _hotkeyKey = 'voice_hotkey';

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _microphoneEnabledKey = 'microphone_enabled';
  
  static const String _hotkeyIdKey = 'hotkey_id';
  static const String _hotkeyModifiersKey = 'hotkey_modifiers';

  SharedPreferences? _prefs;
  bool _hasCompletedOnboarding = false;
  String _userName = '';
  List<int> _presetTimers = [5 * 60, 10 * 60, 15 * 60];
  bool _notificationsEnabled = true;
  bool _microphoneEnabled = false;
  String _hotkeyLabel = 'Escape';
  int _hotkeyId = LogicalKeyboardKey.escape.keyId;
  List<String> _hotkeyModifiers = [];

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String get userName => _userName;
  List<int> get presetTimers => List.unmodifiable(_presetTimers);
  bool get notificationsEnabled => _notificationsEnabled;
  bool get microphoneEnabled => _microphoneEnabled;
  String get hotkey => _hotkeyLabel;
  int get hotkeyId => _hotkeyId;
  List<String> get hotkeyModifiers => List.unmodifiable(_hotkeyModifiers);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding =
        _prefs?.getBool(_hasCompletedOnboardingKey) ?? false;
    _userName = _prefs?.getString(_userNameKey) ?? '';
    _notificationsEnabled = _prefs?.getBool(_notificationsEnabledKey) ?? true;
    _microphoneEnabled = _prefs?.getBool(_microphoneEnabledKey) ?? false;
    _hotkeyLabel = _prefs?.getString(_hotkeyKey) ?? 'Escape';
    _hotkeyId = _prefs?.getInt(_hotkeyIdKey) ?? LogicalKeyboardKey.escape.keyId;
    _hotkeyModifiers = _prefs?.getStringList(_hotkeyModifiersKey) ?? [];

    final presetTimersJson = _prefs?.getString(_presetTimersKey);
    if (presetTimersJson != null) {
      _presetTimers = List<int>.from(jsonDecode(presetTimersJson));
    }

    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs?.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      // Request OS-level permissions when enabling
      await NotificationService().requestPermissions();
    }

    if (_hasCompletedOnboarding) {
      await SupabaseService().updateNotificationPermission(
        enabled ? 'granted' : 'denied',
      );
    }
    notifyListeners();
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    _microphoneEnabled = enabled;
    await _prefs?.setBool(_microphoneEnabledKey, enabled);
    if (_hasCompletedOnboarding) {
      await SupabaseService().updateMicrophonePermission(
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

  Future<void> setHotkeyCustom({
    required String label,
    required int keyId,
    required List<String> modifiers,
  }) async {
    _hotkeyLabel = label;
    _hotkeyId = keyId;
    _hotkeyModifiers = modifiers;
    
    await _prefs?.setString(_hotkeyKey, label);
    await _prefs?.setInt(_hotkeyIdKey, keyId);
    await _prefs?.setStringList(_hotkeyModifiersKey, modifiers);
    
    notifyListeners();
  }

  Future<void> setHotkey(String label) async {
    // Legacy support for the 4 presets
    _hotkeyLabel = label;
    int keyId = LogicalKeyboardKey.escape.keyId;
    List<String> modifiers = [];

    if (label == 'Shift+Option+V') {
      keyId = LogicalKeyboardKey.keyV.keyId;
      modifiers = ['Shift', 'Alt'];
    } else if (label == 'Control+Space') {
      keyId = LogicalKeyboardKey.space.keyId;
      modifiers = ['Control'];
    } else if (label == 'Command+Option+T') {
      keyId = LogicalKeyboardKey.keyT.keyId;
      modifiers = ['Meta', 'Alt'];
    }

    await setHotkeyCustom(label: label, keyId: keyId, modifiers: modifiers);
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
      
      // Push initial permissions/settings to the newly created user record
      await SupabaseService().updateNotificationPermission(_notificationsEnabled ? 'granted' : 'denied');
      await SupabaseService().updateMicrophonePermission(_microphoneEnabled ? 'granted' : 'denied');
      await SupabaseService().updatePresetTimers(_presetTimers);
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
