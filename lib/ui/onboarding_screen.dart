import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/analytics_service.dart';
import '../services/onboarding_service.dart';
import 'theme.dart';
import 'widgets/media_player_control.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingService onboardingService;
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onboardingService,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  List<int> _customPresets = [];

  late AnimationController _welcomeController;
  late Animation<double> _welcomeFadeAnimation;
  late Animation<double> _welcomeScaleAnimation;

  late AnimationController _contentController;
  late Animation<double> _contentFadeAnimation;

  bool _showWelcome = true;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _customPresets = List.from(widget.onboardingService.presetTimers);

    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _welcomeScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _nameController.addListener(() => setState(() {}));

    AnalyticsService().trackOnboardingStarted();
    _startWelcomeSequence();
  }

  void _startWelcomeSequence() {
    _welcomeController.forward();
    AnalyticsService().trackOnboardingWelcomeViewed();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _welcomeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showWelcome = false;
              _showContent = true;
            });
            _contentController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _welcomeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isNotEmpty) {
        final name = _nameController.text.trim();
        widget.onboardingService.setUserName(name);
        AnalyticsService().trackOnboardingNameEntered(name);
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_customPresets.isNotEmpty) {
        widget.onboardingService.setPresetTimers(_customPresets);
        widget.onboardingService.completeOnboarding();
        AnalyticsService().trackOnboardingCompleted(_customPresets.length);
        widget.onComplete();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep = _currentStep - 1);
    }
  }

  void _addPreset() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    if (totalSeconds > 0 && !_customPresets.contains(totalSeconds)) {
      setState(() {
        _customPresets.add(totalSeconds);
        _customPresets.sort();
      });
      AnalyticsService().trackOnboardingPresetAdded(totalSeconds);
      _minutesController.clear();
      _secondsController.clear();
    }
  }

  void _removePreset(int seconds) {
    setState(() {
      _customPresets.remove(seconds);
    });
    AnalyticsService().trackOnboardingPresetRemoved(seconds);
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_showWelcome) _buildWelcomeScreen(),
          if (_showContent) _buildContentScreen(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return AnimatedBuilder(
      animation: _welcomeController,
      builder: (context, child) {
        return Center(
          child: Opacity(
            opacity: _welcomeFadeAnimation.value,
            child: Transform.scale(
              scale: _welcomeScaleAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      fontFamily: '.SF Pro Text',
                      color: MediaPlayerStyles.mutedColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PipBox',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      fontFamily: '.SF Pro Rounded',
                      color: AppTheme.accent,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SvgPicture.asset(
                    'assets/images/character-orange-crop.svg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    placeholderBuilder:
                        (context) => const SizedBox(width: 120, height: 120),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentScreen() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: _currentStep == 0 ? _buildNameStep() : _buildPresetsStep(),
        );
      },
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            "What do I call you?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              autofocus: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                fontFamily: '.SF Pro Text',
                color: MediaPlayerStyles.mutedColor,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                  color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.4),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: MediaPlayerStyles.subtleBorder,
                    width: 2,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accent, width: 2),
                ),
              ),
              onSubmitted: (_) => _nextStep(),
            ),
          ),
          const Spacer(flex: 3),
          Align(alignment: Alignment.bottomRight, child: _buildNextButton()),
        ],
      ),
    );
  }

  Widget _buildPresetsStep() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Set Your Timer Presets',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your favorite focus durations',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: '.SF Pro Text',
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildPresetInput(),
          const SizedBox(height: 24),
          _buildPresetBadges(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildPreviousButton(), _buildStartButton()],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          child: TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              fontFamily: '.SF Pro Rounded',
              color: MediaPlayerStyles.mutedColor,
            ),
            decoration: InputDecoration(
              hintText: '00',
              hintStyle: TextStyle(
                color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.25),
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        Text(
          ':',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(
          width: 56,
          child: TextField(
            controller: _secondsController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              fontFamily: '.SF Pro Rounded',
              color: MediaPlayerStyles.mutedColor,
            ),
            decoration: InputDecoration(
              hintText: '00',
              hintStyle: TextStyle(
                color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.25),
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _addPreset(),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: _addPreset,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MediaPlayerStyles.primaryColorLight,
                  MediaPlayerStyles.primaryColor,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MediaPlayerStyles.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),
      ],
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

  Widget _buildPresetBadges() {
    if (_customPresets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Add at least one timer preset to continue',
          style: TextStyle(
            fontSize: 14,
            color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
            fontFamily: '.SF Pro Text',
          ),
        ),
      );
    }

    // Limit to 4 presets per row strictly
    final rows = _chunkList(_customPresets, 4);

    return Column(
      children:
          rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children:
                    row.asMap().entries.map((entry) {
                      final index = entry.key;
                      final seconds = entry.value;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDuration(seconds),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accent,
                                    fontFamily: '.SF Pro Text',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removePreset(seconds),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index < row.length - 1) const SizedBox(width: 12),
                        ],
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = _nameController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: isEnabled ? _nextStep : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MediaPlayerStyles.primaryColorLight,
                MediaPlayerStyles.primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: MediaPlayerStyles.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousButton() {
    return GestureDetector(
      onTap: _previousStep,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: MediaPlayerStyles.subtleBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: MediaPlayerStyles.mutedColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MediaPlayerStyles.mutedColor,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final isEnabled = _customPresets.isNotEmpty;

    return GestureDetector(
      onTap: isEnabled ? _nextStep : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MediaPlayerStyles.primaryColorLight,
                MediaPlayerStyles.primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: MediaPlayerStyles.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Start',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
