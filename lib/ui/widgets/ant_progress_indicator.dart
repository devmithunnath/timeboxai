import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/timer_provider.dart';

/// Ant progress indicator that shows the ant's journey across the screen
/// with personality, smooth animation, and clear visual feedback.
class AntProgressIndicator extends StatefulWidget {
  final TimerProvider timer;
  final double windowWidth;

  const AntProgressIndicator({
    super.key,
    required this.timer,
    required this.windowWidth,
  });

  @override
  State<AntProgressIndicator> createState() => _AntProgressIndicatorState();
}

class _AntProgressIndicatorState extends State<AntProgressIndicator>
    with TickerProviderStateMixin {
  // Smooth position animation
  late AnimationController _positionController;

  // Breathing/idle animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Walking bob animation
  late AnimationController _walkingController;
  late Animation<double> _walkBobAnimation;
  late Animation<double> _walkLeanAnimation;

  // Celebration animation
  late AnimationController _celebrationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _sparkleAnimation;

  // Confused/paused animation
  late AnimationController _confusedController;
  late Animation<double> _headTiltAnimation;

  // Track progress for smooth interpolation
  double _currentDisplayProgress = 1.0;
  double _targetProgress = 1.0;
  int _lastMinute = -1;
  bool _hasPassedHalfway = false;

  // Layout constants
  static const double antWidth = 200;
  static const double antHeight = 150;
  static const double pathPadding = 40;
  static const double pathHeight = 50; // Height of the path area

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startIdleAnimation();
  }

  void _initAnimations() {
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Breathing animation (idle state)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Walking animation (running state)
    _walkingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _walkBobAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _walkingController, curve: Curves.easeInOut),
    );
    _walkLeanAnimation = Tween<double>(begin: 0, end: 0.03).animate(
      CurvedAnimation(parent: _walkingController, curve: Curves.easeInOut),
    );

    // Celebration animation (finished state)
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -15, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut),
    );
    _sparkleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut),
    );

    // Confused animation (paused state)
    _confusedController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headTiltAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _confusedController, curve: Curves.easeInOut),
    );
  }

  void _startIdleAnimation() {
    _breathingController.repeat(reverse: true);
  }

  void _startWalkingAnimation() {
    if (!_walkingController.isAnimating) {
      _walkingController.repeat(reverse: true);
    }
  }

  void _stopWalkingAnimation() {
    _walkingController.stop();
    _walkingController.reset();
  }

  void _triggerCelebration() {
    _celebrationController.forward(from: 0);
  }

  void _triggerConfused() {
    _confusedController.forward(from: 0);
  }

  @override
  void didUpdateWidget(AntProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update target progress for smooth interpolation
    _targetProgress = widget.timer.progress;

    // Check for state changes
    if (widget.timer.isRunning) {
      _startWalkingAnimation();
      _checkMinuteChange();
      _checkHalfwayPoint();
    } else {
      _stopWalkingAnimation();
    }

    if (widget.timer.isPaused && !oldWidget.timer.isPaused) {
      _triggerConfused();
    }

    if (widget.timer.isFinished && !oldWidget.timer.isFinished) {
      _triggerCelebration();
    }
  }

  void _checkMinuteChange() {
    final currentMinute = widget.timer.remainingDuration.inMinutes;
    if (_lastMinute != -1 && currentMinute != _lastMinute) {
      // Minute changed - could add a subtle step animation here
    }
    _lastMinute = currentMinute;
  }

  void _checkHalfwayPoint() {
    if (!_hasPassedHalfway && widget.timer.progress < 0.5) {
      _hasPassedHalfway = true;
      // Halfway point reached - ant could look back
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _breathingController.dispose();
    _walkingController.dispose();
    _celebrationController.dispose();
    _confusedController.dispose();
    super.dispose();
  }

  // Calculate ant's horizontal position
  double _calculateAntPosition() {
    final pathWidth = widget.windowWidth - (pathPadding * 2) - antWidth;
    final startX = pathPadding; // Start on the left (goal)

    // Smooth interpolation towards target with speed multiplier
    final speedMultiplier = _getSpeedMultiplier();
    _currentDisplayProgress =
        _currentDisplayProgress +
        (_targetProgress - _currentDisplayProgress) * 0.1 * speedMultiplier;

    // Progress 1.0 = start (right), 0.0 = finish (left)
    return startX + (pathWidth * _currentDisplayProgress);
  }

  // Get speed multiplier for last 10%
  double _getSpeedMultiplier() {
    if (widget.timer.progress < 0.1) {
      return 1.2; // Speed up in last 10%
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: antHeight + pathHeight + 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [_buildPath(), _buildAnt()],
      ),
    );
  }

  Widget _buildPath() {
    return Positioned(
      left: pathPadding,
      right: pathPadding,
      bottom: pathHeight,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE85A3C).withValues(alpha: 0.0),
              const Color(0xFFE85A3C).withValues(alpha: 0.08),
              const Color(0xFFE85A3C).withValues(alpha: 0.08),
              const Color(0xFFE85A3C).withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5A4A).withValues(alpha: 0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnt() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _walkingController,
        _celebrationController,
        _confusedController,
      ]),
      builder: (context, child) {
        final antX = _calculateAntPosition();

        // Determine current state modifiers
        double scale = 1.0;
        double rotation = 0.0;
        double yOffset = 0.0;

        if (widget.timer.isFinished) {
          // Celebration: bounce and slight scale
          yOffset = _bounceAnimation.value;
          scale = 1.0 + (_sparkleAnimation.value * 0.05);
        } else if (widget.timer.isPaused) {
          // Confused: head tilt
          rotation = _headTiltAnimation.value;
          scale = _breathingAnimation.value;
        } else if (widget.timer.isRunning) {
          // Walking: bob and lean forward
          yOffset = _walkBobAnimation.value;
          rotation =
              -_walkLeanAnimation.value; // Lean forward (negative = left)
          scale = 1.0;
        } else {
          // Idle: breathing
          scale = _breathingAnimation.value;
        }

        return Positioned(
          left: antX,
          bottom: pathHeight + yOffset,
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform:
                Matrix4.identity()
                  ..scale(scale)
                  ..rotateZ(rotation),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/character-orange-crop.svg',
                  width: antWidth,
                  height: antHeight,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final antX = _calculateAntPosition();
        final sparkleOpacity = (1 - _sparkleAnimation.value).clamp(0.0, 1.0);

        return Positioned(
          left: antX + antWidth / 2 - 40,
          bottom: pathHeight + antHeight - 20,
          child: Opacity(
            opacity: sparkleOpacity,
            child: SizedBox(
              width: 80,
              height: 60,
              child: Stack(
                children: List.generate(6, (index) {
                  final angle = (index * 60) * (math.pi / 180);
                  final radius = 20 + (_sparkleAnimation.value * 30);
                  final x = 40 + math.cos(angle) * radius;
                  final y = 30 + math.sin(angle) * radius;

                  return Positioned(
                    left: x - 4,
                    top: y - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE85A3C).withValues(
                          alpha: (0.8 - _sparkleAnimation.value * 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE85A3C,
                            ).withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
