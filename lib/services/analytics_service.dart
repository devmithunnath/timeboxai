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
    if (kDebugMode) {
      print('[Analytics] trackEvent: $eventName, properties: $properties');
    }

    if (!_isInitialized) {
      if (kDebugMode) {
        print('[Analytics] WARNING: Not initialized, skipping event');
      }
      return;
    }

    try {
      Posthog().capture(eventName: eventName, properties: properties);
      if (kDebugMode) {
        print('[Analytics] Event sent successfully: $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] Error tracking event: $e');
      }
    }
  }

  /// Track timer started
  void trackTimerStarted({
    required int durationSeconds,
    required String platform,
    required String sessionSource,
  }) {
    if (kDebugMode) {
      print(
        '[Analytics] >>> TIMER STARTED: ${durationSeconds}s, Platform: $platform, Source: $sessionSource',
      );
    }
    trackEvent(
      'timer_started',
      properties: {
        'duration_seconds': durationSeconds,
        'duration_minutes': durationSeconds ~/ 60,
        'platform': platform,
        'session_source': sessionSource,
      },
    );
  }

  /// Track timer paused
  void trackTimerPaused(int remainingSeconds) {
    if (kDebugMode) {
      print('[Analytics] >>> TIMER PAUSED: ${remainingSeconds}s remaining');
    }
    trackEvent(
      'timer_paused',
      properties: {'remaining_seconds': remainingSeconds},
    );
  }

  /// Track timer stopped/reset
  void trackTimerStopped({
    required int durationSeconds,
    required String completionReason,
    required int pauseCount,
    required bool wasPaused,
    required bool notificationDisplayed,
  }) {
    if (kDebugMode) {
      print('[Analytics] >>> TIMER STOPPED. Reason: $completionReason');
    }
    trackEvent(
      'timer_stopped',
      properties: {
        'duration_seconds': durationSeconds,
        'duration_minutes': durationSeconds ~/ 60,
        'completion_reason': completionReason,
        'pause_count': pauseCount,
        'was_paused': wasPaused,
        'notification_displayed': notificationDisplayed,
      },
    );
  }

  /// Track timer completed
  void trackTimerCompleted({
    required int durationSeconds,
    required String completionReason,
    required int pauseCount,
    required bool wasPaused,
    required bool notificationDisplayed,
  }) {
    if (kDebugMode) {
      print('[Analytics] >>> TIMER COMPLETED: ${durationSeconds}s');
    }
    trackEvent(
      'timer_completed',
      properties: {
        'duration_seconds': durationSeconds,
        'duration_minutes': durationSeconds ~/ 60,
        'completion_reason': completionReason,
        'pause_count': pauseCount,
        'was_paused': wasPaused,
        'notification_displayed': notificationDisplayed,
      },
    );
  }

  /// Track preset selected
  void trackPresetSelected(int seconds) {
    if (kDebugMode) {
      print(
        '[Analytics] >>> PRESET SELECTED: ${seconds}s (${seconds ~/ 60} min)',
      );
    }
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

  void trackOnboardingStarted() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING STARTED');
    }
    trackEvent('onboarding_started');
  }

  void trackOnboardingWelcomeViewed() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING WELCOME VIEWED');
    }
    trackEvent('onboarding_welcome_viewed');
  }

  void trackOnboardingNameEntered(String name) {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING NAME ENTERED: $name');
    }
    trackEvent(
      'onboarding_name_entered',
      properties: {'name_length': name.length},
    );
  }

  void trackOnboardingPresetAdded(int seconds) {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING PRESET ADDED: ${seconds}s');
    }
    trackEvent(
      'onboarding_preset_added',
      properties: {
        'duration_seconds': seconds,
        'duration_minutes': seconds ~/ 60,
      },
    );
  }

  void trackOnboardingPresetRemoved(int seconds) {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING PRESET REMOVED: ${seconds}s');
    }
    trackEvent(
      'onboarding_preset_removed',
      properties: {
        'duration_seconds': seconds,
        'duration_minutes': seconds ~/ 60,
      },
    );
  }

  void trackOnboardingCompleted(int presetCount) {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING COMPLETED with $presetCount presets');
    }
    trackEvent(
      'onboarding_completed',
      properties: {'preset_count': presetCount},
    );
  }

  void trackOnboardingLanguageViewed() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING LANGUAGE SCREEN VIEWED');
    }
    trackEvent('onboarding_language_viewed');
  }

  void trackOnboardingLanguageSelected(
    String languageCode,
    String languageName,
  ) {
    if (kDebugMode) {
      print(
        '[Analytics] >>> ONBOARDING LANGUAGE SELECTED: $languageName ($languageCode)',
      );
    }
    trackEvent(
      'onboarding_language_selected',
      properties: {
        'language_code': languageCode,
        'language_name': languageName,
      },
    );
  }

  void trackOnboardingNotificationStepViewed() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING NOTIFICATION STEP VIEWED');
    }
    trackEvent('onboarding_notification_step_viewed');
  }

  void trackOnboardingNotificationPermissionGranted() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING NOTIFICATION PERMISSION GRANTED');
    }
    trackEvent('onboarding_notification_permission_granted');
  }

  void trackOnboardingNotificationPermissionDenied() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING NOTIFICATION PERMISSION DENIED');
    }
    trackEvent('onboarding_notification_permission_denied');
  }

  void trackOnboardingNotificationSkipped() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING NOTIFICATION SKIPPED');
    }
    trackEvent('onboarding_notification_skipped');
  }

  void trackOnboardingAntExplanationViewed() {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING ANT EXPLANATION VIEWED');
    }
    trackEvent('onboarding_ant_explanation_viewed');
  }

  void trackOnboardingStepNavigation({
    required int fromStep,
    required int toStep,
    required String direction,
  }) {
    if (kDebugMode) {
      print('[Analytics] >>> ONBOARDING NAVIGATION: Step $fromStep → $toStep ($direction)');
    }
    trackEvent(
      'onboarding_step_navigation',
      properties: {
        'from_step': fromStep,
        'to_step': toStep,
        'direction': direction,
      },
    );
  }

  void trackSettingsOpened() {
    if (kDebugMode) {
      print('[Analytics] >>> SETTINGS OPENED');
    }
    trackEvent('settings_opened');
  }

  void trackSettingsLanguageChanged({
    required String fromLanguage,
    required String toLanguage,
  }) {
    if (kDebugMode) {
      print('[Analytics] >>> SETTINGS LANGUAGE CHANGED: $fromLanguage → $toLanguage');
    }
    trackEvent(
      'settings_language_changed',
      properties: {
        'from_language': fromLanguage,
        'to_language': toLanguage,
      },
    );
  }
}
