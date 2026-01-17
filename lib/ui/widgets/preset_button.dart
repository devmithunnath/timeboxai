import 'package:flutter/material.dart';
import '../../providers/timer_provider.dart';
import '../../services/analytics_service.dart';
import '../theme.dart';
import 'media_player_control.dart';

/// Preset button with improved states and hover effects
class PresetButton extends StatefulWidget {
  final String label;
  final int seconds;
  final TimerProvider timer;

  const PresetButton({
    super.key,
    required this.label,
    required this.seconds,
    required this.timer,
  });

  @override
  State<PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<PresetButton> {
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
