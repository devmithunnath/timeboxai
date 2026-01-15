import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/timer_provider.dart';
import '../services/analytics_service.dart';
import 'theme.dart';
import 'widgets/media_player_control.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<TimerProvider>(
          builder: (context, timer, child) {
            // Calculate ant position: progress 1.0 = start (right), 0.0 = end (left)
            // Window width is 600, ant is 240 wide.
            // Start position: right edge (right: -20)
            // End position: left edge (left: ~20, which means right: 600 - 240 - 20 = 340)
            // As progress goes from 1.0 to 0.0, ant moves from right to left
            final double windowWidth = 600;
            final double antWidth = 240;
            final double startRight = -20; // Starting position (right side)
            final double endRight =
                windowWidth - antWidth + 20; // Ending position (left side)

            // Lerp from start to end based on inverse progress (1.0 = start, 0.0 = end)
            final double currentRight =
                startRight + (endRight - startRight) * (1.0 - timer.progress);

            return Stack(
              children: [
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

                // Main Content
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: _TimerContent(),
                ),

                // Ant Character - moves from right to left based on progress
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: currentRight,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/character.png',
                      width: antWidth,
                      height: 240,
                      fit: BoxFit.contain,
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

class _TimerContent extends StatelessWidget {
  const _TimerContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Column(
          children: [
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

            const SizedBox(height: 10),

            // "Focus Run" Label
            Text(
              "Focus Run",
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 4),

            // Timer Display
            _EditableTimerDisplay(
              timer: timer,
              durationSeconds: timer.durationSeconds,
            ),

            const SizedBox(height: 24),

            // Presets
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PresetButton(label: "5 mins", seconds: 5 * 60, timer: timer),
                const SizedBox(width: 12),
                _PresetButton(label: "10 mins", seconds: 10 * 60, timer: timer),
                const SizedBox(width: 12),
                _PresetButton(label: "15 mins", seconds: 15 * 60, timer: timer),
              ],
            ),

            const Spacer(),

            // Footer Quote
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Small steps matter.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
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

class _PresetButton extends StatelessWidget {
  final String label;
  final int seconds;
  final TimerProvider timer;

  const _PresetButton({
    required this.label,
    required this.seconds,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = timer.durationSeconds == seconds;
    return GestureDetector(
      onTap: () {
        timer.resetTimer();
        timer.setDuration(seconds);
        AnalyticsService().trackPresetSelected(seconds);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

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

class _EditableTimerDisplayState extends State<_EditableTimerDisplay> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatDuration(widget.durationSeconds),
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
  }

  @override
  Widget build(BuildContext context) {
    TextStyle timerStyle = const TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w600,
      fontFamily: '.SF Pro Display',
      color: AppTheme.textPrimary,
      letterSpacing: 2,
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
      return Text("$minutes:$seconds", style: timerStyle);
    }

    return SizedBox(
      width: 240,
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
