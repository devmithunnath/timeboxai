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
}
