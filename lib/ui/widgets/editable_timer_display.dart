import 'package:flutter/material.dart';
import '../../providers/timer_provider.dart';
import '../theme.dart';

class EditableTimerDisplay extends StatefulWidget {
  final TimerProvider timer;
  final int durationSeconds;

  const EditableTimerDisplay({
    super.key,
    required this.timer,
    required this.durationSeconds,
  });

  @override
  State<EditableTimerDisplay> createState() => _EditableTimerDisplayState();
}

class _EditableTimerDisplayState extends State<EditableTimerDisplay>
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(EditableTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.durationSeconds != oldWidget.durationSeconds) {
      String newText = _formatDuration(widget.durationSeconds);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }

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
    TextStyle timerStyle = TextStyle(
      fontSize: 100,
      fontWeight: FontWeight.w600,
      fontFamily: '.SF Pro Rounded',
      color: AppTheme.accent,
      letterSpacing: 4,
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
      width: 400,
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
