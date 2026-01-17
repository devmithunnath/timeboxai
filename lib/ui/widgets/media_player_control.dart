import 'package:flutter/material.dart';
import '../../services/sound_service.dart';

// =============================================================================
// CONSTANTS - Modern minimalist button styling
// =============================================================================

class MediaPlayerStyles {
  MediaPlayerStyles._();

  // Play/Pause button (circular) - reduced from 80 to 64
  static const double playButtonSize = 64.0;

  // Stop button (smaller circular)
  static const double stopButtonSize = 48.0;

  // Colors - Primary accent (warm orange)
  static const Color primaryColor = Color(0xFFE85A3C);
  static const Color primaryColorLight = Color(0xFFF07052);

  // Colors - Muted (for stop button and secondary elements)
  static const Color mutedColor = Color(0xFF8B5A4A);
  static const Color mutedColorLight = Color(0xFFA06B5A);

  // Colors - Icons
  static const Color iconColor = Color(0xFFFFF8F0);

  // Colors - Subtle backgrounds for unselected states
  static const Color subtleBackground = Color(0xFFF5EDE8);
  static const Color subtleBorder = Color(0xFFE0D5CC);

  // Shadows
  static const Color shadowColor = Color(0x40000000);
}

// =============================================================================
// MODERN PLAY/PAUSE BUTTON WITH HOVER EFFECTS
// =============================================================================

class PlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const PlayButton({super.key, this.isPlaying = false, this.onTap});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTap: () {
          SoundService().playClickSound();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                    // Soft ambient shadow - enhanced on hover
                    BoxShadow(
                      color: MediaPlayerStyles.primaryColor.withValues(
                        alpha: _isHovered ? 0.5 : 0.3,
                      ),
                      blurRadius: _isHovered ? 24 : 16,
                      offset: Offset(0, _isHovered ? 10 : 6),
                      spreadRadius: 0,
                    ),
                    // Subtle inner glow effect at top
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      widget.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey(widget.isPlaying),
                      size: 32,
                      color: MediaPlayerStyles.iconColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// MODERN STOP BUTTON WITH HOVER EFFECTS
// =============================================================================

class StopButton extends StatefulWidget {
  final VoidCallback? onTap;

  const StopButton({super.key, this.onTap});

  @override
  State<StopButton> createState() => _StopButtonState();
}

class _StopButtonState extends State<StopButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTap: () {
          SoundService().playClickSound();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: MediaPlayerStyles.stopButtonSize,
                height: MediaPlayerStyles.stopButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _isHovered
                          ? MediaPlayerStyles.mutedColor
                          : MediaPlayerStyles.subtleBackground,
                  border: Border.all(
                    color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MediaPlayerStyles.mutedColor.withValues(
                        alpha: _isHovered ? 0.3 : 0.1,
                      ),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 4 : 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.stop_rounded,
                    size: 24,
                    color:
                        _isHovered
                            ? MediaPlayerStyles.iconColor
                            : MediaPlayerStyles.mutedColor,
                  ),
                ),
              ),
            );
          },
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
          const SizedBox(width: 16),
          PlayButton(isPlaying: isPlaying, onTap: onPlayPause),
        ],
      );
    }

    return PlayButton(isPlaying: isPlaying, onTap: onPlayPause);
  }
}
