import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service to play UI feedback sounds with minimal latency
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  SoundService._internal() {
    _init();
  }

  final AudioPlayer _clickPlayer = AudioPlayer();
  bool _isReady = false;

  // Preload the sound for instant playback
  void _init() {
    // Use "Pop" sound - short and snappy like an old mouse click
    _clickPlayer
        .setSource(DeviceFileSource('/System/Library/Sounds/Pop.aiff'))
        .then((_) {
          _clickPlayer.setReleaseMode(ReleaseMode.stop);
          _isReady = true;
        })
        .catchError((e) {
          if (kDebugMode) {
            print("Error initializing click sound: $e");
          }
        });
  }

  /// Play a click sound - fire and forget (non-blocking)
  void playClickSound() {
    if (!_isReady) return;

    // Fire and forget - don't block UI thread
    _clickPlayer.seek(Duration.zero).then((_) {
      _clickPlayer.resume();
    });
  }

  /// Dispose resources when no longer needed
  void dispose() {
    _clickPlayer.dispose();
  }
}
