import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  String? _userId;

  bool get isInitialized => _client != null;

  Future<void> init() async {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      _client = Supabase.instance.client;

      // Try to load existing user ID
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('supabase_user_id');

      if (kDebugMode) {
        print('Supabase initialized. User ID: $_userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Supabase: $e');
      }
    }
  }

  Future<void> createUser(String name) async {
    if (!isInitialized) return;

    try {
      final response =
          await _client!.from('users').insert({'name': name}).select().single();

      _userId = response['id'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabase_user_id', _userId!);

      if (kDebugMode) {
        print('Created Supabase user: $_userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Supabase user: $e');
      }
    }
  }

  Future<String?> startSession({
    required int plannedDurationSeconds,
    required String platform,
    required String sessionSource,
  }) async {
    if (!isInitialized || _userId == null) return null;

    try {
      final response =
          await _client!
              .from('timer_sessions')
              .insert({
                'user_id': _userId,
                'planned_duration_seconds': plannedDurationSeconds,
                'platform': platform,
                'session_source': sessionSource,
                'status': 'active',
                'start_time': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      final sessionId = response['id'] as String;
      if (kDebugMode) {
        print('Started Supabase session: $sessionId');
      }

      return sessionId;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting Supabase session: $e');
      }
      return null;
    }
  }

  Future<void> endSession({
    required String sessionId,
    required int durationSeconds,
    required String completionReason,
    required bool wasPaused,
    required int pauseCount,
    required bool notificationDisplayed,
  }) async {
    if (!isInitialized) return;

    try {
      await _client!
          .from('timer_sessions')
          .update({
            'status': 'ended',
            'duration_seconds': durationSeconds,
            'completion_reason': completionReason,
            'end_time': DateTime.now().toIso8601String(),
            'was_paused': wasPaused,
            'pause_count': pauseCount,
            'notification_displayed': notificationDisplayed,
          })
          .eq('id', sessionId);

      if (kDebugMode) {
        print(
          'Ended Supabase session: $sessionId with reason: $completionReason',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ending Supabase session: $e');
      }
    }
  }

  Future<void> updateUserLanguage(String languageCode) async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'preferred_language': languageCode})
          .eq('id', _userId!);

      if (kDebugMode) {
        print('Updated user language preference: $languageCode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user language: $e');
      }
    }
  }

  Future<void> updateNotificationPermission(String status) async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'notification_permission': status})
          .eq('id', _userId!);

      if (kDebugMode) {
        print('Updated notification permission: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification permission: $e');
      }
    }
  }

  Future<void> updateMicrophonePermission(String status) async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'microphone_permission': status})
          .eq('id', _userId!);

      if (kDebugMode) {
        print('Updated microphone permission: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating microphone permission: $e');
      }
    }
  }

  Future<void> updateOnboardingCompleted() async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'onboarding_completed_at': DateTime.now().toIso8601String()})
          .eq('id', _userId!);

      if (kDebugMode) {
        print('Updated onboarding completed timestamp');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating onboarding completion: $e');
      }
    }
  }

  Future<void> updatePresetTimers(List<int> presets) async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'preset_timers': presets})
          .eq('id', _userId!);

      if (kDebugMode) {
        print('Updated preset timers: $presets');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating preset timers: $e');
      }
    }
  }

  Future<void> updateLastActive() async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'last_active_at': DateTime.now().toIso8601String()})
          .eq('id', _userId!);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last active: $e');
      }
    }
  }

  Future<void> updateUserMetadata({
    String? appVersion,
    String? platform,
    String? timezone,
  }) async {
    if (!isInitialized || _userId == null) return;

    try {
      final updates = <String, dynamic>{};
      if (appVersion != null) updates['app_version'] = appVersion;
      if (platform != null) updates['platform'] = platform;
      if (timezone != null) updates['timezone'] = timezone;

      if (updates.isNotEmpty) {
        await _client!.from('users').update(updates).eq('id', _userId!);

        if (kDebugMode) {
          print('Updated user metadata: $updates');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user metadata: $e');
      }
    }
  }

  Future<void> updateUseCase(String useCase) async {
    if (!isInitialized || _userId == null) return;

    try {
      await _client!
          .from('users')
          .update({'use_case': useCase})
          .eq('id', _userId!);

      if (kDebugMode) {
        print('Updated user use case: $useCase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating use case: $e');
      }
    }
  }

  Future<void> submitFeedback({
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    if (!isInitialized) {
      throw Exception('Supabase is not initialized');
    }
    
    if (_userId == null) {
      // Try to re-load user ID if it's missing
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('supabase_user_id');
      
      if (_userId == null) {
        throw Exception('User ID is missing. Please complete onboarding or restart the app.');
      }
    }

    try {
      await _client!.from('feedback').insert({
        'user_id': _userId,
        'title': title,
        'description': description,
        'attachment_url': attachmentUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Feedback submitted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting feedback detail: $e');
      }
      rethrow;
    }
  }
}
