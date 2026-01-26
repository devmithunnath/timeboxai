import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/onboarding_service.dart';
import 'editable_timer_display.dart';
import 'media_player_control.dart';
import 'preset_button.dart';

class TimerContent extends StatelessWidget {
  const TimerContent({super.key});

  static const int _maxPresetsPerRow = 6;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, OnboardingService>(
      builder: (context, timer, onboarding, _) {
        final presets = onboarding.presetTimers;
        final rows = _chunkList(presets, _maxPresetsPerRow);

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

            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      row.asMap().entries.map((entry) {
                        final index = entry.key;
                        final seconds = entry.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PresetButton(
                              label: _formatDuration(seconds),
                              seconds: seconds,
                              timer: timer,
                            ),
                            if (index < row.length - 1)
                              const SizedBox(width: 10),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<List<int>> _chunkList(List<int> list, int chunkSize) {
    final chunks = <List<int>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
