import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/supabase_service.dart';

class TimerProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  // Configuration
  int _durationSeconds = 25 * 60; // Default 25 minutes

  // State
  Duration _remainingDuration = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFinished = false;
  DateTime? _endTime;
  bool _isListening = false;

  // Supabase Session State
  String? _currentSessionId;
  bool _wasPausedInSession = false;
  int _pauseCount = 0;

  // Getters
  int get durationSeconds => _durationSeconds;
  Duration get remainingDuration => _remainingDuration;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isFinished => _isFinished;
  bool get isListening => _isListening;

  double get progress {
    if (_durationSeconds == 0) return 0.0;
    if (!_isRunning && !_isPaused && !_isFinished) return 1.0;
    return _remainingDuration.inMilliseconds / (_durationSeconds * 1000);
  }

  void setListening(bool value) {
    _isListening = value;
    notifyListeners();
  }

  TimerProvider();

  void setDuration(int seconds) {
    if (_isRunning) return;
    if (seconds > 0) {
      _durationSeconds = seconds;
      _remainingDuration = Duration(seconds: seconds);
      notifyListeners();
    }
  }

  Future<void> startTimer() async {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;
    _isFinished = false;

    // If we are starting fresh (not paused), reset duration
    if (_remainingDuration == Duration.zero ||
        _remainingDuration.inSeconds == _durationSeconds) {
      _remainingDuration = Duration(seconds: _durationSeconds);

      // Reset session state
      _wasPausedInSession = false;
      _pauseCount = 0;

      // Start new Supabase session
      _currentSessionId = await SupabaseService().startSession(
        plannedDurationSeconds: _durationSeconds,
        platform: 'macos',
        sessionSource: 'main_timer',
      );

      // Track timer started in Analytics
      AnalyticsService().trackTimerStarted(
        durationSeconds: _durationSeconds,
        platform: 'macos',
        sessionSource: 'main_timer',
      );
    }
    // If paused, we use existing _remainingDuration

    _endTime = DateTime.now().add(_remainingDuration);

    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isRunning || _endTime == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final difference = _endTime!.difference(now);

      if (difference.isNegative || difference.inSeconds == 0) {
        _finishTimer();
      } else {
        _remainingDuration = difference;
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    _endTime = null;

    // Update session state
    _wasPausedInSession = true;
    _pauseCount++;

    notifyListeners();

    // Track timer paused
    AnalyticsService().trackTimerPaused(_remainingDuration.inSeconds);
  }

  Future<void> _finishTimer() async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = true;
    _remainingDuration = Duration.zero;
    _endTime = null;
    notifyListeners();

    // Attempt to show notification
    await _notificationService.showNotification(
      id: 0,
      title: 'Time is up!',
      body: 'Your session has finished.',
    );

    // In current implementation, we assume notification logic ran if we called it.
    // Ideally NotificationService would return success, but locally it basically always succeeds if permissions allowed.
    // For tracking purpose, we mark it true here as we triggered it.
    const notificationDisplayed = true;

    _playNotificationSound();

    // Track timer completed in Analytics
    AnalyticsService().trackTimerCompleted(
      durationSeconds: _durationSeconds,
      completionReason: 'completed',
      pauseCount: _pauseCount,
      wasPaused: _wasPausedInSession,
      notificationDisplayed: notificationDisplayed,
    );

    // End Supabase session
    if (_currentSessionId != null) {
      SupabaseService().endSession(
        sessionId: _currentSessionId!,
        durationSeconds: _durationSeconds, // Full duration completed
        completionReason: 'completed',
        wasPaused: _wasPausedInSession,
        pauseCount: _pauseCount,
        notificationDisplayed: notificationDisplayed,
      );
      _currentSessionId = null;
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      // Play system sound "Glass"
      await _audioPlayer.play(
        DeviceFileSource('/System/Library/Sounds/Glass.aiff'),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error playing sound: $e");
      }
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = false;

    // Calculate actual elapsed time before resetting
    final elapsedSeconds = _durationSeconds - _remainingDuration.inSeconds;

    // Resetted state implies remaining = total
    _remainingDuration = Duration(seconds: _durationSeconds);
    _endTime = null;
    notifyListeners();

    // Track timer stopped in Analytics
    AnalyticsService().trackTimerStopped(
      durationSeconds: elapsedSeconds,
      completionReason: 'user_stopped',
      pauseCount: _pauseCount,
      wasPaused: _wasPausedInSession,
      notificationDisplayed: false, // Notification not shown on user stop
    );

    // End Supabase session as stopped
    if (_currentSessionId != null) {
      SupabaseService().endSession(
        sessionId: _currentSessionId!,
        durationSeconds: elapsedSeconds,
        completionReason: 'user_stopped',
        wasPaused: _wasPausedInSession,
        pauseCount: _pauseCount,
        notificationDisplayed: false,
      );
      _currentSessionId = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
