import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';
import '../../services/onboarding_service.dart';
import '../theme.dart';
import 'add_preset_modal.dart';
import 'editable_timer_display.dart';
import 'media_player_control.dart';
import 'preset_button.dart';

class TimerContent extends StatefulWidget {
  const TimerContent({super.key});

  @override
  State<TimerContent> createState() => _TimerContentState();
}

class _TimerContentState extends State<TimerContent> {
  static const int _maxPresetsPerRow = 6;
  bool _isAddHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, OnboardingService>(
      builder: (context, timer, onboarding, _) {
        final presets = onboarding.presetTimers;

        // Create list of preset buttons
        final List<Widget> presetWidgets = [];
        for (var i = 0; i < presets.length; i++) {
          presetWidgets.add(
            PresetButton(
              label: _formatDuration(presets[i]),
              seconds: presets[i],
              timer: timer,
            ),
          );
        }

        // Add the "+" button
        presetWidgets.add(_buildAddButton(context, onboarding, timer));

        final rows = _chunkWidgets(presetWidgets, _maxPresetsPerRow);

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
                        final widget = entry.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget,
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

  Widget _buildAddButton(
    BuildContext context,
    OnboardingService onboarding,
    TimerProvider timer,
  ) {
    bool isDisabled = timer.isRunning || timer.isPaused;

    return MouseRegion(
      onEnter: (_) => setState(() => _isAddHovered = true),
      onExit: (_) => setState(() => _isAddHovered = false),
      child: GestureDetector(
        onTap:
            isDisabled
                ? null
                : () {
                  showDialog(
                    context: context,
                    builder:
                        (context) =>
                            AddPresetModal(onboardingService: onboarding),
                  );
                },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.4 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  _isAddHovered && !isDisabled
                      ? MediaPlayerStyles.subtleBackground
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MediaPlayerStyles.subtleBorder,
                width: 1.5,
              ),
              boxShadow:
                  _isAddHovered && !isDisabled
                      ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: MediaPlayerStyles.mutedColor,
            ),
          ),
        ),
      ),
    );
  }

  List<List<Widget>> _chunkWidgets(List<Widget> list, int chunkSize) {
    final chunks = <List<Widget>>[];
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
