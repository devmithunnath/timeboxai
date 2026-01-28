import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../theme.dart';
import 'media_player_control.dart';

class AddPresetModal extends StatefulWidget {
  final OnboardingService onboardingService;

  const AddPresetModal({super.key, required this.onboardingService});

  @override
  State<AddPresetModal> createState() => _AddPresetModalState();
}

class _AddPresetModalState extends State<AddPresetModal> {
  int _minutes = 1;
  int _seconds = 0;
  bool _isDuplicate = false;
  Timer? _duplicateTimer;

  @override
  void dispose() {
    _duplicateTimer?.cancel();
    super.dispose();
  }

  void _incrementMinutes() {
    setState(() {
      if (_minutes < 99) _minutes++;
      _isDuplicate = false;
    });
  }

  void _decrementMinutes() {
    setState(() {
      if (_minutes > 0) _minutes--;
      _isDuplicate = false;
    });
  }

  void _incrementSeconds() {
    setState(() {
      _seconds += 15;
      if (_seconds >= 60) {
        _seconds = 0;
        if (_minutes < 99) _minutes++;
      }
      _isDuplicate = false;
    });
  }

  void _decrementSeconds() {
    setState(() {
      _seconds -= 15;
      if (_seconds < 0) {
        if (_minutes > 0) {
          _seconds = 45;
          _minutes--;
        } else {
          _seconds = 0;
        }
      }
      _isDuplicate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Create New Preset',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: '.SF Pro Rounded',
                  color: Color(0xFF1D1D1F),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              height: 1,
              color: const Color(0xFFF2F2F7),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                children: [
                  _buildCounterSection(
                    label: 'Minutes',
                    value: _minutes,
                    onIncrement: _incrementMinutes,
                    onDecrement: _decrementMinutes,
                  ),
                  const SizedBox(height: 24),
                  _buildCounterSection(
                    label: 'Seconds',
                    value: _seconds,
                    onIncrement: _incrementSeconds,
                    onDecrement: _decrementSeconds,
                  ),
                  if (_isDuplicate)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Preset already exists',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Add',
                          onPressed: () {
                            final totalSeconds = (_minutes * 60) + _seconds;
                            if (totalSeconds > 0) {
                              if (widget.onboardingService.presetTimers
                                  .contains(totalSeconds)) {
                                setState(() => _isDuplicate = true);
                                _duplicateTimer?.cancel();
                                _duplicateTimer = Timer(
                                  const Duration(seconds: 2),
                                  () {
                                    if (mounted) {
                                      setState(() => _isDuplicate = false);
                                    }
                                  },
                                );
                              } else {
                                widget.onboardingService.addPresetTimer(
                                  totalSeconds,
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.7),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCounterButton(Icons.remove_rounded, onDecrement),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _isDuplicate
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: '.SF Pro Rounded',
                    color: _isDuplicate ? Colors.red : const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ),
            _buildCounterButton(Icons.add_rounded, onIncrement),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF1D1D1F),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44, // Smaller height
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.accent : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(14),
          boxShadow:
              isPrimary
                  ? [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF1D1D1F),
            fontWeight: FontWeight.w700,
            fontSize: 15, // Smaller font
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
