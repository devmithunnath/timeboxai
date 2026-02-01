import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../providers/timer_provider.dart';
import '../services/onboarding_service.dart';
import '../services/supabase_service.dart';
import '../services/localization_service.dart';
import '../ui/widgets/toast.dart';

enum VoiceCommandType {
  startTimer,
  pauseTimer,
  stopTimer,
  changeLanguage,
  toggleNotifications,
  submitFeedback,
  unrecognized,
}

class VoiceCommandIntent {
  final VoiceCommandType type;
  final int? durationSeconds;
  final Locale? locale;
  final bool? notificationsEnabled;
  final String? feedbackText;

  const VoiceCommandIntent({
    required this.type,
    this.durationSeconds,
    this.locale,
    this.notificationsEnabled,
    this.feedbackText,
  });
}

class VoiceCommandService {

  Future<void> handleCommand({
    required String transcript,
    required BuildContext context,
    required TimerProvider timer,
    required OnboardingService onboarding,
  }) async {
    final intent = await _interpretCommand(transcript);
    await _executeIntent(
      intent: intent,
      transcript: transcript,
      context: context,
      timer: timer,
      onboarding: onboarding,
    );
  }

  Future<VoiceCommandIntent> _interpretCommand(String transcript) async {
    // Advanced Semantic Reasoning (Mimics Apple's Natural Language logic)
    return _interpretWithSmartReasoning(transcript);
  }

  VoiceCommandIntent _interpretWithSmartReasoning(String transcript) {
    final normalized = transcript.toLowerCase();

    // Logic: Assign weights to different intents based on semantic markers
    final Map<VoiceCommandType, double> scores = {
      VoiceCommandType.startTimer: 0.0,
      VoiceCommandType.pauseTimer: 0.0,
      VoiceCommandType.stopTimer: 0.0,
      VoiceCommandType.changeLanguage: 0.0,
      VoiceCommandType.toggleNotifications: 0.0,
      VoiceCommandType.submitFeedback: 0.0,
    };

    // START TIMER markers
    if (_containsAny(normalized, [
      'start',
      'begin',
      'go',
      'create',
      'set',
      'time',
      'minutes',
      'seconds',
    ])) {
      _addScore(scores, VoiceCommandType.startTimer, 1.0);
    }
    if (_containsAny(normalized, ['new timer', 'focus', 'work'])) {
      _addScore(scores, VoiceCommandType.startTimer, 2.0);
    }
    if (RegExp(r'\d+').hasMatch(normalized)) {
      _addScore(scores, VoiceCommandType.startTimer, 0.5);
    }

    // PAUSE TIMER markers
    if (_containsAny(normalized, [
      'pause',
      'hold',
      'wait',
      'stay',
      'stop for a bit',
    ])) {
      _addScore(scores, VoiceCommandType.pauseTimer, 2.0);
    }
    if (_containsAny(normalized, ['resume', 'continue'])) {
      _addScore(scores, VoiceCommandType.pauseTimer, 1.5);
    }

    // STOP TIMER markers
    if (_containsAny(normalized, [
      'stop',
      'end',
      'cancel',
      'reset',
      'clear',
      'exit',
      'quit',
    ])) {
      _addScore(scores, VoiceCommandType.stopTimer, 2.0);
    }
    if (_containsAny(normalized, ['finish', 'done'])) {
      _addScore(scores, VoiceCommandType.stopTimer, 1.0);
    }

    // LANGUAGE markers
    if (_containsAny(normalized, [
      'language',
      'locale',
      'speak',
      'chinese',
      'english',
      'japanese',
      'german',
      'spanish',
    ])) {
      _addScore(scores, VoiceCommandType.changeLanguage, 2.0);
    }

    // NOTIFICATION markers
    if (_containsAny(normalized, [
      'notification',
      'notifications',
      'alert',
      'alerts',
      'ping',
    ])) {
      _addScore(scores, VoiceCommandType.toggleNotifications, 2.0);
    }

    // FEEDBACK markers
    if (_containsAny(normalized, [
      'feedback',
      'suggestion',
      'issue',
      'bug',
      "doesn't work",
      'wrong',
      'bad',
      'improve',
    ])) {
      _addScore(scores, VoiceCommandType.submitFeedback, 2.0);
    }
    if (normalized.length > 50) {
      _addScore(scores, VoiceCommandType.submitFeedback, 1.0);
    }

    // Find highest score
    var bestType = VoiceCommandType.unrecognized;
    var highestScore = 1.0; // Minimum threshold

    scores.forEach((type, score) {
      if (score > highestScore) {
        highestScore = score;
        bestType = type;
      }
    });

    // Extract details based on identified intent
    switch (bestType) {
      case VoiceCommandType.startTimer:
        return VoiceCommandIntent(
          type: VoiceCommandType.startTimer,
          durationSeconds: _parseDurationSeconds(normalized),
        );
      case VoiceCommandType.changeLanguage:
        return VoiceCommandIntent(
          type: VoiceCommandType.changeLanguage,
          locale: _resolveLocale(_extractLanguage(normalized) ?? ''),
        );
      case VoiceCommandType.toggleNotifications:
        return VoiceCommandIntent(
          type: VoiceCommandType.toggleNotifications,
          notificationsEnabled: _extractNotificationToggle(normalized),
        );
      case VoiceCommandType.submitFeedback:
        return VoiceCommandIntent(
          type: VoiceCommandType.submitFeedback,
          feedbackText: transcript,
        );
      default:
        // Final fallback to literal matches
        return _interpretWithHeuristics(transcript);
    }
  }


  VoiceCommandIntent _interpretWithHeuristics(String transcript) {
    final normalized = transcript.toLowerCase();

    if (_containsAny(normalized, ['pause', 'resume', 'hold', 'wait', 'stay'])) {
      return const VoiceCommandIntent(type: VoiceCommandType.pauseTimer);
    }

    if (_containsAny(normalized, [
      'stop',
      'end',
      'cancel',
      'reset',
      'clear',
      'exit',
    ])) {
      return const VoiceCommandIntent(type: VoiceCommandType.stopTimer);
    }

    if (_containsAny(normalized, [
      'start',
      'begin',
      'new timer',
      'create',
      'set a timer',
      'go',
    ])) {
      final durationSeconds = _parseDurationSeconds(normalized);
      return VoiceCommandIntent(
        type: VoiceCommandType.startTimer,
        durationSeconds: durationSeconds,
      );
    }

    if (_containsAny(normalized, ['language', 'locale'])) {
      final language = _extractLanguage(normalized);
      final locale = language != null ? _resolveLocale(language) : null;
      return VoiceCommandIntent(
        type: VoiceCommandType.changeLanguage,
        locale: locale,
      );
    }

    if (_containsAny(normalized, ['notification', 'notifications'])) {
      final enabled = _extractNotificationToggle(normalized);
      return VoiceCommandIntent(
        type: VoiceCommandType.toggleNotifications,
        notificationsEnabled: enabled,
      );
    }

    if (_containsAny(normalized, [
      'feedback',
      'suggestion',
      'issue',
      'bug',
      'doesn\'t work',
      'don\'t work',
      'problem',
      'report',
    ])) {
      return VoiceCommandIntent(
        type: VoiceCommandType.submitFeedback,
        feedbackText: transcript,
      );
    }

    return const VoiceCommandIntent(type: VoiceCommandType.unrecognized);
  }

  Future<void> _executeIntent({
    required VoiceCommandIntent intent,
    required String transcript,
    required BuildContext context,
    required TimerProvider timer,
    required OnboardingService onboarding,
  }) async {
    switch (intent.type) {
      case VoiceCommandType.startTimer:
        final durationSeconds = intent.durationSeconds;
        if (durationSeconds != null && durationSeconds > 0) {
          timer.resetTimer();
          timer.setDuration(durationSeconds);
          await timer.startTimer();
          AppToast.show(
            context,
            'Timer started for ${_formatDuration(durationSeconds)}',
          );
          return;
        }

        if (!timer.isRunning) {
          await timer.startTimer();
          AppToast.show(context, 'Timer started');
        } else {
          AppToast.show(context, 'Timer already running');
        }
        return;

      case VoiceCommandType.pauseTimer:
        if (timer.isRunning) {
          timer.pauseTimer();
          AppToast.show(context, 'Timer paused');
        } else {
          AppToast.show(context, 'No active timer to pause', isError: true);
        }
        return;

      case VoiceCommandType.stopTimer:
        if (timer.isRunning || timer.isPaused) {
          timer.resetTimer();
          AppToast.show(context, 'Timer stopped');
        } else {
          AppToast.show(context, 'No active timer to stop', isError: true);
        }
        return;

      case VoiceCommandType.changeLanguage:
        final locale = intent.locale;
        if (locale == null) {
          AppToast.show(context, 'Language not recognized', isError: true);
          return;
        }
        context.setLocale(locale);
        await SupabaseService().updateUserLanguage(locale.languageCode);
        AppToast.show(context, 'Language updated');
        return;

      case VoiceCommandType.toggleNotifications:
        final enabled = intent.notificationsEnabled;
        if (enabled == null) {
          AppToast.show(
            context,
            'Notification command not recognized',
            isError: true,
          );
          return;
        }
        await onboarding.toggleNotifications(enabled);
        AppToast.show(
          context,
          enabled ? 'Notifications enabled' : 'Notifications disabled',
        );
        return;

      case VoiceCommandType.submitFeedback:
        final feedbackText = intent.feedbackText ?? transcript;
        try {
          await SupabaseService().submitFeedback(
            title: 'Voice feedback',
            description: feedbackText,
          );
          AppToast.show(context, 'Feedback submitted. Thank you!');
        } catch (_) {
          AppToast.show(context, 'Failed to submit feedback', isError: true);
        }
        return;

      case VoiceCommandType.unrecognized:
        AppToast.show(context, 'Command unrecognized', isError: true);
        return;
    }
  }


  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }

  void _addScore(
    Map<VoiceCommandType, double> scores,
    VoiceCommandType type,
    double value,
  ) {
    scores[type] = (scores[type] ?? 0) + value;
  }


  int? _parseDurationSeconds(String text) {
    final timeMatch = RegExp(r'\b(\d{1,2}):(\d{1,2})\b').firstMatch(text);
    if (timeMatch != null) {
      final minutes = int.tryParse(timeMatch.group(1) ?? '');
      final seconds = int.tryParse(timeMatch.group(2) ?? '');
      if (minutes != null && seconds != null) {
        return (minutes * 60) + seconds;
      }
    }

    final minutesMatch = RegExp(
      r'(\d+)\s*(minute|minutes|min|mins|m)',
    ).firstMatch(text);
    final secondsMatch = RegExp(
      r'(\d+)\s*(second|seconds|sec|secs|s)',
    ).firstMatch(text);

    final minutes =
        minutesMatch != null ? int.tryParse(minutesMatch.group(1) ?? '') : null;
    final seconds =
        secondsMatch != null ? int.tryParse(secondsMatch.group(1) ?? '') : null;

    if (minutes != null || seconds != null) {
      return (minutes ?? 0) * 60 + (seconds ?? 0);
    }

    return null;
  }

  String? _extractLanguage(String text) {
    final match = RegExp(
      r'language\s*(to|as)?\s*([a-zA-Z-]+)',
    ).firstMatch(text);
    if (match != null) {
      return match.group(2)?.toLowerCase();
    }
    return null;
  }

  bool? _extractNotificationToggle(String text) {
    if (_containsAny(text, ['enable', 'turn on', 'allow'])) return true;
    if (_containsAny(text, ['disable', 'turn off', 'block'])) return false;
    return null;
  }

  Locale? _resolveLocale(String languageToken) {
    final normalized = languageToken.toLowerCase();
    final languageAliases = <String, String>{
      'english': 'en',
      'chinese': 'zh',
      'japanese': 'ja',
      'german': 'de',
      'french': 'fr',
      'spanish': 'es',
      'portuguese': 'pt',
      'hindi': 'hi',
      'arabic': 'ar',
      'korean': 'ko',
      'italian': 'it',
      'dutch': 'nl',
      'russian': 'ru',
      'turkish': 'tr',
      'swedish': 'sv',
      'polish': 'pl',
      'indonesian': 'id',
      'thai': 'th',
      'vietnamese': 'vi',
    };

    final code = languageAliases[normalized] ?? normalized;
    final supported = LocalizationService().getSupportedLanguages();
    for (final localeInfo in supported) {
      if (localeInfo.locale.languageCode.toLowerCase() == code ||
          localeInfo.nativeName.toLowerCase() == normalized) {
        return localeInfo.locale;
      }
    }

    return null;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (remaining == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remaining}s';
  }
}
