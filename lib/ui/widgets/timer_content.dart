import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';
import 'editable_timer_display.dart';
import 'media_player_control.dart';
import 'preset_button.dart';

class TimerContent extends StatelessWidget {
  const TimerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            EditableTimerDisplay(
              timer: timer,
              durationSeconds: timer.durationSeconds,
            ),

            const SizedBox(height: 20),

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PresetButton(label: "5 min", seconds: 5 * 60, timer: timer),
                const SizedBox(width: 16),
                PresetButton(label: "10 min", seconds: 10 * 60, timer: timer),
                const SizedBox(width: 16),
                PresetButton(label: "15 min", seconds: 15 * 60, timer: timer),
              ],
            ),
          ],
        );
      },
    );
  }
}
