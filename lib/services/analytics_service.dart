import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:flutter/foundation.dart';
import '../env/env.dart';

/// Analytics service using PostHog for event tracking
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = false;

  /// Initialize PostHog with the API key from environment variables
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final config = PostHogConfig(Env.posthogApiKey);
      config.host = Env.posthogHost; // US cloud instance
      config.debug = kDebugMode;
      config.captureApplicationLifecycleEvents = true;

      await Posthog().setup(config);
      _isInitialized = true;

      if (kDebugMode) {
        print('PostHog analytics initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing PostHog: $e');
      }
    }
  }

  /// Track a custom event
  void trackEvent(String eventName, {Map<String, Object>? properties}) {
    if (!_isInitialized) return;

    try {
      Posthog().capture(eventName: eventName, properties: properties);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking event: $e');
      }
    }
  }

  /// Track timer started
  void trackTimerStarted(int durationSeconds) {
    trackEvent(
      'timer_started',
      properties: {
        'duration_seconds': durationSeconds,
        'duration_minutes': durationSeconds ~/ 60,
      },
    );
  }

  /// Track timer paused
  void trackTimerPaused(int remainingSeconds) {
    trackEvent(
      'timer_paused',
      properties: {'remaining_seconds': remainingSeconds},
    );
  }

  /// Track timer stopped/reset
  void trackTimerStopped() {
    trackEvent('timer_stopped');
  }

  /// Track timer completed
  void trackTimerCompleted(int durationSeconds) {
    trackEvent(
      'timer_completed',
      properties: {
        'duration_seconds': durationSeconds,
        'duration_minutes': durationSeconds ~/ 60,
      },
    );
  }

  /// Track preset selected
  void trackPresetSelected(int seconds) {
    trackEvent(
      'preset_selected',
      properties: {
        'duration_seconds': seconds,
        'duration_minutes': seconds ~/ 60,
      },
    );
  }

  /// Identify a user (optional)
  void identify(String distinctId, {Map<String, Object>? properties}) {
    if (!_isInitialized) return;

    try {
      Posthog().identify(userId: distinctId, userProperties: properties);
    } catch (e) {
      if (kDebugMode) {
        print('Error identifying user: $e');
      }
    }
  }
}
