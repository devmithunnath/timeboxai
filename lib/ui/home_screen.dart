import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/timer_provider.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (_) => windowManager.startDragging(),
        child: Container(
          color: AppTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10), // Safe area shim
              // Timer Logic Consumer
              const Expanded(child: _TimerContent()),
            ],
          ),
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
            // Progress Squircle & Toggle
            Expanded(
              flex: 3,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Painter
                    SizedBox(
                      width: 220,
                      height: 160,
                      child: CustomPaint(
                        painter: SquircleProgressPainter(
                          progress: timer.progress,
                          color: AppTheme.accent,
                          emptyColor: AppTheme.card,
                        ),
                      ),
                    ),
                    // Play/Pause Button Area
                    GestureDetector(
                      onTap: () {
                        if (timer.isRunning) {
                          timer.pauseTimer();
                        } else {
                          timer.startTimer();
                        }
                      },
                      child: Container(
                        color: Colors.transparent, // Hitbox
                        width: 100,
                        height: 80,
                        alignment: Alignment.center,
                        child: Icon(
                          timer.isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Timer Text
            Text("Timer", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            _EditableTimerDisplay(
              timer: timer,
              durationSeconds: timer.durationSeconds,
            ),

            const SizedBox(height: 32),

            // Stop Button
            if (timer.isRunning || timer.isPaused || timer.isFinished)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: timer.resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Stop", style: TextStyle(fontSize: 18)),
                ),
              )
            else
              const SizedBox(height: 56),

            const SizedBox(height: 32),

            // Presets
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PresetButton(label: "5 min", seconds: 5 * 60, timer: timer),
                const SizedBox(width: 8),
                _PresetButton(label: "10 min", seconds: 10 * 60, timer: timer),
                const SizedBox(width: 8),
                _PresetButton(label: "15 min", seconds: 15 * 60, timer: timer),
              ],
            ),
            const SizedBox(height: 20),
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
        // Reset first to stop any running timer and clear progress
        timer.resetTimer();
        timer.setDuration(seconds);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color(0xFF4A5228)
                  : AppTheme.card, // Dark olive if active
          borderRadius: BorderRadius.circular(12),
          border:
              isActive
                  ? Border.all(color: AppTheme.accent.withOpacity(0.5))
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
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
    if (widget.timer.isRunning ||
        widget.timer.isPaused ||
        widget.timer.isFinished) {
      final duration = widget.timer.remainingDuration;
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours =
          duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return Text(
        "$hours$minutes:$seconds",
        style: Theme.of(context).textTheme.displayLarge,
      );
    }

    return SizedBox(
      width: 300,
      child: TextField(
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayLarge,
        controller: _controller,
        decoration: const InputDecoration(
          hintText: "00:25:00",
          hintStyle: TextStyle(color: Color(0xFF444444)),
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
    if (totalSeconds == 0) return "";
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) return "$minutes:$seconds";
    return "$hours:$minutes:$seconds";
  }

  int _parseDuration(String input) {
    final parts = input.split(':').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.isEmpty) return 0;
    if (parts.length == 1) return parts[0] * 60;
    if (parts.length == 2) return parts[0] * 60 + parts[1];
    if (parts.length == 3) return parts[0] * 3600 + parts[1] * 60 + parts[2];
    return 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SquircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color emptyColor;

  SquircleProgressPainter({
    required this.progress,
    required this.color,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = emptyColor;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(50));

    canvas.drawRRect(rrect, paint);

    if (progress > 0) {
      paint.color = color;
      Path path = Path()..addRRect(rrect);

      var metrics = path.computeMetrics();
      for (var metric in metrics) {
        double drawLength = metric.length * progress;
        Path extract = metric.extractPath(0, drawLength);
        canvas.drawPath(extract, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SquircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
