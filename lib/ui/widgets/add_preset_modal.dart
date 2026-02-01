import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  int _minutes = 1;
  int _seconds = 0;
  bool _isDuplicate = false;
  Timer? _duplicateTimer;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(text: '01');
    _secondsController = TextEditingController(text: '00');

    _minutesController.addListener(_onMinutesChanged);
    _secondsController.addListener(_onSecondsChanged);
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _duplicateTimer?.cancel();
    super.dispose();
  }

  void _onMinutesChanged() {
    final val = int.tryParse(_minutesController.text) ?? 0;
    if (val != _minutes) {
      setState(() {
        _minutes = val;
        _isDuplicate = false;
      });
    }
  }

  void _onSecondsChanged() {
    final val = int.tryParse(_secondsController.text) ?? 0;
    if (val != _seconds) {
      setState(() {
        _seconds = val;
        _isDuplicate = false;
      });
    }
  }

  void _incrementMinutes() {
    if (_minutes < 99) {
      setState(() {
        _minutes++;
        _minutesController.text = _minutes.toString().padLeft(2, '0');
        _isDuplicate = false;
      });
    }
  }

  void _decrementMinutes() {
    if (_minutes > 0) {
      setState(() {
        _minutes--;
        _minutesController.text = _minutes.toString().padLeft(2, '0');
        _isDuplicate = false;
      });
    }
  }

  void _incrementSeconds() {
    setState(() {
      _seconds += 15;
      if (_seconds >= 60) {
        _seconds = 0;
        if (_minutes < 99) {
          _minutes++;
          _minutesController.text = _minutes.toString().padLeft(2, '0');
        }
      }
      _secondsController.text = _seconds.toString().padLeft(2, '0');
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
          _minutesController.text = _minutes.toString().padLeft(2, '0');
        } else {
          _seconds = 0;
        }
      }
      _secondsController.text = _seconds.toString().padLeft(2, '0');
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
            Container(height: 1, color: const Color(0xFFF2F2F7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                children: [
                  _buildCounterSection(
                    label: 'Minutes',
                    controller: _minutesController,
                    onIncrement: _incrementMinutes,
                    onDecrement: _decrementMinutes,
                    maxValue: 99,
                  ),
                  const SizedBox(height: 24),
                  _buildCounterSection(
                    label: 'Seconds',
                    controller: _secondsController,
                    onIncrement: _incrementSeconds,
                    onDecrement: _decrementSeconds,
                    maxValue: 59,
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
                            final min = int.tryParse(_minutesController.text) ?? 0;
                            final sec = int.tryParse(_secondsController.text) ?? 0;
                            final totalSeconds = (min * 60) + sec;
                            
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
    required TextEditingController controller,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required int maxValue,
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
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: '.SF Pro Rounded',
                  color: _isDuplicate ? Colors.red : const Color(0xFF1D1D1F),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RangeTextInputFormatter(0, maxValue),
                ],
                onSubmitted: (_) {
                  // Pad with zero if needed when finishing typing
                  if (controller.text.isNotEmpty) {
                    controller.text = int.parse(controller.text).toString().padLeft(2, '0');
                  }
                },
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
          child: Icon(icon, size: 22, color: const Color(0xFF1D1D1F)),
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
        height: 44,
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
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

class _RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _RangeTextInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final int? value = int.tryParse(newValue.text);
    if (value == null) return oldValue;
    if (value < min) return TextEditingValue(text: min.toString());
    if (value > max) return TextEditingValue(text: max.toString());
    return newValue;
  }
}
