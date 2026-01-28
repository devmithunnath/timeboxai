import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/timer_provider.dart';

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
  late AnimationController _positionController;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  late AnimationController _walkingController;
  late Animation<double> _walkBobAnimation;
  late Animation<double> _walkLeanAnimation;

  late AnimationController _celebrationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _sparkleAnimation;

  late AnimationController _confusedController;
  late Animation<double> _headTiltAnimation;

  double _currentDisplayProgress = 1.0;
  double _targetProgress = 1.0;
  int _lastMinute = -1;
  bool _hasPassedHalfway = false;

  static const double antWidth = 200;
  static const double antHeight = 150;
  static const double pathPadding = 40;
  static const double pathHeight = 50;

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

    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

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

    _targetProgress = widget.timer.progress;

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
    if (_lastMinute != -1 && currentMinute != _lastMinute) {}
    _lastMinute = currentMinute;
  }

  void _checkHalfwayPoint() {
    if (!_hasPassedHalfway && widget.timer.progress < 0.5) {
      _hasPassedHalfway = true;
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

  double _calculateAntPosition() {
    final pathWidth = widget.windowWidth - (pathPadding * 2) - antWidth;
    final startX = pathPadding;

    final speedMultiplier = _getSpeedMultiplier();
    _currentDisplayProgress =
        _currentDisplayProgress +
        (_targetProgress - _currentDisplayProgress) * 0.1 * speedMultiplier;

    return startX + (pathWidth * _currentDisplayProgress);
  }

  double _getSpeedMultiplier() {
    if (widget.timer.progress < 0.1) {
      return 1.2;
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

        double scale = 1.0;
        double rotation = 0.0;
        double yOffset = 0.0;

        if (widget.timer.isFinished) {
          yOffset = _bounceAnimation.value;
          scale = 1.0 + (_sparkleAnimation.value * 0.05);
        } else if (widget.timer.isPaused) {
          rotation = _headTiltAnimation.value;
          scale = _breathingAnimation.value;
        } else if (widget.timer.isRunning) {
          yOffset = _walkBobAnimation.value;
          rotation = -_walkLeanAnimation.value;
          scale = 1.0;
        } else {
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
}
