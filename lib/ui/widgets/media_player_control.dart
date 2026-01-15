import 'package:flutter/material.dart';
import '../../services/sound_service.dart';

// =============================================================================
// CONSTANTS - Modern minimalist button styling
// =============================================================================

class MediaPlayerStyles {
  MediaPlayerStyles._();

  // Play/Pause button (circular)
  static const double playButtonSize = 80.0;

  // Stop button (smaller circular)
  static const double stopButtonSize = 52.0;

  // Colors - Primary accent (warm orange)
  static const Color primaryColor = Color(0xFFE85A3C);
  static const Color primaryColorLight = Color(0xFFF07052);

  // Colors - Muted (for stop button)
  static const Color mutedColor = Color(0xFF8B5A4A);
  static const Color mutedColorLight = Color(0xFFA06B5A);

  // Colors - Icons
  static const Color iconColor = Color(0xFFFFF8F0);

  // Shadows
  static const Color shadowColor = Color(0x40000000);
}

// =============================================================================
// MODERN PLAY/PAUSE BUTTON
// =============================================================================

class PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const PlayButton({super.key, this.isPlaying = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService().playClickSound();
        onTap?.call();
      },
      child: Container(
        width: MediaPlayerStyles.playButtonSize,
        height: MediaPlayerStyles.playButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MediaPlayerStyles.primaryColorLight,
              MediaPlayerStyles.primaryColor,
            ],
          ),
          boxShadow: [
            // Soft ambient shadow
            BoxShadow(
              color: MediaPlayerStyles.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            // Subtle inner glow effect at top
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 40,
            color: MediaPlayerStyles.iconColor,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODERN STOP BUTTON (Same style as Play button)
// =============================================================================

class StopButton extends StatelessWidget {
  final VoidCallback? onTap;

  const StopButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService().playClickSound();
        onTap?.call();
      },
      child: Container(
        width: MediaPlayerStyles.playButtonSize,
        height: MediaPlayerStyles.playButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MediaPlayerStyles.primaryColorLight,
              MediaPlayerStyles.primaryColor,
            ],
          ),
          boxShadow: [
            // Soft ambient shadow
            BoxShadow(
              color: MediaPlayerStyles.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            // Subtle inner glow effect at top
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.stop_rounded,
            size: 40,
            color: MediaPlayerStyles.iconColor,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MEDIA PLAYER CONTROL WIDGET
// =============================================================================

class MediaPlayerControl extends StatelessWidget {
  final bool isPlaying;
  final bool isActive;
  final VoidCallback? onPlayPause;
  final VoidCallback? onStop;

  const MediaPlayerControl({
    super.key,
    this.isPlaying = false,
    this.isActive = false,
    this.onPlayPause,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StopButton(onTap: onStop),
          const SizedBox(width: 20),
          PlayButton(isPlaying: isPlaying, onTap: onPlayPause),
        ],
      );
    }

    return PlayButton(isPlaying: isPlaying, onTap: onPlayPause);
  }
}
