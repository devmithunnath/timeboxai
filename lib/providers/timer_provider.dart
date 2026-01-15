import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // Getters
  int get durationSeconds => _durationSeconds;
  Duration get remainingDuration => _remainingDuration;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isFinished => _isFinished;

  double get progress {
    if (_durationSeconds == 0) return 0.0;
    if (!_isRunning && !_isPaused && !_isFinished) return 1.0;
    return _remainingDuration.inMilliseconds / (_durationSeconds * 1000);
  }

  TimerProvider() {
    _notificationService.init();
  }

  void setDuration(int seconds) {
    if (_isRunning) return;
    if (seconds > 0) {
      _durationSeconds = seconds;
      _remainingDuration = Duration(seconds: seconds);
      notifyListeners();
    }
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;
    _isFinished = false;

    // If we are starting fresh (not paused), reset duration
    if (_remainingDuration == Duration.zero ||
        _remainingDuration.inSeconds == _durationSeconds) {
      _remainingDuration = Duration(seconds: _durationSeconds);
    }
    // If paused, we use existing _remainingDuration

    _endTime = DateTime.now().add(_remainingDuration);

    notifyListeners();

    // Track timer started
    AnalyticsService().trackTimerStarted(_durationSeconds);

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
    notifyListeners();

    // Track timer paused
    AnalyticsService().trackTimerPaused(_remainingDuration.inSeconds);
  }

  void _finishTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = true;
    _remainingDuration = Duration.zero;
    _endTime = null;
    notifyListeners();

    _notificationService.showNotification(
      id: 0,
      title: 'Time is up!',
      body: 'Your session has finished.',
    );

    _playNotificationSound();

    // Track timer completed
    AnalyticsService().trackTimerCompleted(_durationSeconds);
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
    // Resetted state implies remaining = total
    _remainingDuration = Duration(seconds: _durationSeconds);
    _endTime = null;
    notifyListeners();

    // Track timer stopped
    AnalyticsService().trackTimerStopped();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
