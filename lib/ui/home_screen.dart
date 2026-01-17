import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/timer_provider.dart';
import '../services/analytics_service.dart';
import '../main.dart';
import 'theme.dart';
import 'widgets/media_player_control.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Consumer<TimerProvider>(
          builder: (context, timer, child) {
            final double windowWidth = 600;
            final double antWidth = 220; // Slightly scaled down (was 240)
            final double startRight = -20;
            final double endRight = windowWidth - antWidth + 20;

            final double currentRight =
                startRight + (endRight - startRight) * (1.0 - timer.progress);

            return Stack(
              children: [
                // Subtle floor gradient to anchor the ant
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.03),
                        ],
                      ),
                    ),
                  ),
                ),

                // Window Drag Area & Traffic Lights Placeholder
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: GestureDetector(
                    onPanStart: (_) => windowManager.startDragging(),
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(left: 16, top: 12),
                    ),
                  ),
                ),

                // Settings Icon - Top Right (softer styling)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _SettingsButton(onPressed: () => openSettingsWindow()),
                ),

                // Main Content
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: _TimerContent(),
                ),

                // Ant Character with shadow - moves from right to left
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: currentRight,
                  bottom: 35,
                  child: IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ant celebration animation when finished
                        AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: timer.isFinished ? 1.05 : 1.0,
                          child: Image.asset(
                            'assets/images/character.png',
                            width: antWidth,
                            height: 185, // Slightly scaled down
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Soft shadow under ant
                        Container(
                          width: antWidth * 0.6,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// SETTINGS BUTTON WITH HOVER EFFECTS
// =============================================================================

class _SettingsButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SettingsButton({required this.onPressed});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? MediaPlayerStyles.subtleBackground
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isHovered ? 1.0 : 0.6,
            child: Icon(
              Icons.settings_rounded,
              color: MediaPlayerStyles.mutedColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TIMER CONTENT
// =============================================================================

class _TimerContent extends StatelessWidget {
  const _TimerContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Column(
          children: [
            // Timer Display - NOW THE STAR!
            _EditableTimerDisplay(
              timer: timer,
              durationSeconds: timer.durationSeconds,
            ),

            const SizedBox(height: 20),

            // Play Button (with Stop button when active)
            MediaPlayerControl(
              isPlaying: timer.isRunning,
              isActive: timer.isRunning || timer.isPaused,
              onPlayPause: () {
                if (timer.isRunning) {
                  timer.pauseTimer();
                } else {
                  timer.startTimer();
                }
              },
              onStop: timer.resetTimer,
            ),

            const SizedBox(height: 28),

            // Presets with improved spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PresetButton(label: "5 min", seconds: 5 * 60, timer: timer),
                const SizedBox(width: 16),
                _PresetButton(label: "10 min", seconds: 10 * 60, timer: timer),
                const SizedBox(width: 16),
                _PresetButton(label: "15 min", seconds: 15 * 60, timer: timer),
              ],
            ),

            const Spacer(),

            // Footer Quote - lighter styling
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Small steps matter.",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: '.SF Pro Text',
                  fontWeight: FontWeight.w400,
                  color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

// =============================================================================
// PRESET BUTTON WITH IMPROVED STATES
// =============================================================================

class _PresetButton extends StatefulWidget {
  final String label;
  final int seconds;
  final TimerProvider timer;

  const _PresetButton({
    required this.label,
    required this.seconds,
    required this.timer,
  });

  @override
  State<_PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<_PresetButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.timer.durationSeconds == widget.seconds;
    bool isDisabled = widget.timer.isRunning || widget.timer.isPaused;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap:
            isDisabled
                ? null
                : () {
                  widget.timer.resetTimer();
                  widget.timer.setDuration(widget.seconds);
                  AnalyticsService().trackPresetSelected(widget.seconds);
                },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.4 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppTheme.accent
                      : _isHovered && !isDisabled
                      ? MediaPlayerStyles.subtleBackground
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isActive ? AppTheme.accent : MediaPlayerStyles.subtleBorder,
                width: 1.5,
              ),
              boxShadow:
                  _isHovered && !isDisabled && !isActive
                      ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: isActive ? Colors.white : MediaPlayerStyles.mutedColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                fontFamily: '.SF Pro Text',
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EDITABLE TIMER DISPLAY - THE FOCAL POINT
// =============================================================================

class _EditableTimerDisplay extends StatefulWidget {
  final TimerProvider timer;
  final int durationSeconds;

  const _EditableTimerDisplay({
    required this.timer,
    required this.durationSeconds,
  });

  @override
  State<_EditableTimerDisplay> createState() => _EditableTimerDisplayState();
}

class _EditableTimerDisplayState extends State<_EditableTimerDisplay>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatDuration(widget.durationSeconds),
    );

    // Subtle pulse animation for running state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_EditableTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.durationSeconds != oldWidget.durationSeconds) {
      String newText = _formatDuration(widget.durationSeconds);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }

    // Control pulse animation based on timer state
    if (widget.timer.isRunning && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.timer.isRunning && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Timer as the clear focal point - larger size, SF Pro Rounded style
    TextStyle timerStyle = TextStyle(
      fontSize: 72, // Increased from 56
      fontWeight: FontWeight.w600,
      fontFamily: '.SF Pro Rounded', // Friendlier rounded font
      color: AppTheme.accent,
      letterSpacing: 4, // Increased letter spacing
    );

    if (widget.timer.isRunning ||
        widget.timer.isPaused ||
        widget.timer.isFinished) {
      final duration = widget.timer.remainingDuration;
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(
        duration.inMinutes.remainder(60) + duration.inHours * 60,
      );
      final seconds = twoDigits(duration.inSeconds.remainder(60));

      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.timer.isRunning ? _pulseAnimation.value : 1.0,
            child: Text("$minutes:$seconds", style: timerStyle),
          );
        },
      );
    }

    return SizedBox(
      width: 280,
      child: TextField(
        textAlign: TextAlign.center,
        style: timerStyle,
        controller: _controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          final seconds = _parseDuration(val);
          if (seconds > 0) widget.timer.setDuration(seconds);
        },
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(
      duration.inMinutes.remainder(60) + duration.inHours * 60,
    );
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  int _parseDuration(String input) {
    final parts = input.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.isEmpty) return 0;
    if (parts.length == 1) return parts[0] * 60;
    if (parts.length == 2) return parts[0] * 60 + parts[1];
    return 0;
  }
}
