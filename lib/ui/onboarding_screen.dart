import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/analytics_service.dart';
import '../services/onboarding_service.dart';
import '../services/notification_service.dart';
import '../services/localization_service.dart';
import '../services/supabase_service.dart';
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
  Locale? _selectedLanguage;
  bool _hasTrackedLanguageView = false;

  late AnimationController _welcomeController;
  late Animation<double> _welcomeFadeAnimation;
  late Animation<double> _welcomeScaleAnimation;

  late AnimationController _contentController;
  late Animation<double> _contentFadeAnimation;

  bool _showWelcome = true;
  bool _showContent = false;
  int _countdownValue = 5;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _customPresets = List.from(widget.onboardingService.presetTimers);

    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdownValue--;
      });

      if (_countdownValue <= 0) {
        timer.cancel();
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
    _countdownTimer?.cancel();
    _nameController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _welcomeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Language selection step - always allow continuing
      if (_selectedLanguage != null) {
        final languages = LocalizationService().getSupportedLanguages();
        final selectedLang = languages.firstWhere(
          (lang) => lang.locale == _selectedLanguage,
          orElse: () => languages.first,
        );

        // Track analytics
        AnalyticsService().trackOnboardingLanguageSelected(
          _selectedLanguage!.toString(),
          selectedLang.nativeName,
        );

        // Set locale and save
        context.setLocale(_selectedLanguage!);
        LocalizationService().saveLocale(_selectedLanguage!);

        // Save to Supabase
        SupabaseService().updateUserLanguage(_selectedLanguage!.toString());
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_nameController.text.trim().isNotEmpty) {
        final name = _nameController.text.trim();
        widget.onboardingService.setUserName(name);
        AnalyticsService().trackOnboardingNameEntered(name);
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      if (_customPresets.isNotEmpty) {
        widget.onboardingService.setPresetTimers(_customPresets);
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      widget.onboardingService.completeOnboarding();
      AnalyticsService().trackOnboardingCompleted(_customPresets.length);
      
      // Update Supabase with completion timestamp and presets
      SupabaseService().updateOnboardingCompleted();
      SupabaseService().updatePresetTimers(_customPresets);
      
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      AnalyticsService().trackOnboardingStepNavigation(
        fromStep: _currentStep,
        toStep: _currentStep - 1,
        direction: 'back',
      );
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

  Future<void> _enableNotifications() async {
    final result = await NotificationService().requestPermissions();
    debugPrint('Notification permission result: $result');

    // Show a test notification to trigger macOS permission prompt if needed
    await NotificationService().showNotification(
      id: 1,
      title: 'Notifications Enabled!',
      body: 'You will be notified when your timer completes.',
    );

    _nextStep();
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
        return Stack(
          children: [
            Center(
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
                            (context) =>
                                const SizedBox(width: 120, height: 120),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Opacity(
                opacity: _welcomeFadeAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: MediaPlayerStyles.mutedColor.withValues(
                        alpha: 0.2,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$_countdownValue',
                    style: TextStyle(
                      fontFamily: '.SF Pro Rounded',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MediaPlayerStyles.mutedColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 40,
              child: Opacity(
                opacity: _welcomeFadeAnimation.value,
                child: _buildProgressDots(0),
              ),
            ),
          ],
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
          child: _buildCurrentStep(),
        );
      },
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildLanguageStep();
      case 1:
        return _buildNameStep();
      case 2:
        return _buildPresetsStep();
      case 3:
        return _buildNotificationStep();
      case 4:
        return _buildAntExplanationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCommonExplanationScreen({
    required Widget content,
    required int stepIndex,
    String nextLabel = 'Next',
    String title = 'The Pomodoro technique',
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: SingleChildScrollView(child: content)),
          const SizedBox(height: 20),
          Text(
            'Stay focused... Small steps matter.',
            style: TextStyle(
              fontSize: 14,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDots(stepIndex),
              stepIndex == 1
                  ? _buildNextButton(text: nextLabel)
                  : Row(
                    children: [
                      _buildPreviousButton(),
                      const SizedBox(width: 16),
                      _buildNextButton(text: nextLabel),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots(int activeIndex) {
    return Row(
      children: List.generate(6, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color:
                index == activeIndex
                    ? AppTheme.accent
                    : AppTheme.accent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "onboarding.whatToCallYou".tr(),
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
                        hintText: 'onboarding.enterName'.tr(),
                        hintStyle: TextStyle(
                          color: MediaPlayerStyles.mutedColor.withValues(
                            alpha: 0.4,
                          ),
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
                          borderSide: BorderSide(
                            color: AppTheme.accent,
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _nextStep(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildProgressDots(2), _buildNextButton()],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep() {
    final languages = LocalizationService().getSupportedLanguages();
    _selectedLanguage ??= context.locale;

    final selectedLanguage = languages.firstWhere(
      (lang) => lang.locale == _selectedLanguage,
      orElse: () => languages.first,
    );

    // Track analytics once when language screen is first viewed
    if (!_hasTrackedLanguageView) {
      _hasTrackedLanguageView = true;
      AnalyticsService().trackOnboardingLanguageViewed();
    }

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'onboarding.chooseLanguage'.tr(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      fontFamily: '.SF Pro Rounded',
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'onboarding.changeAnytime'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: '.SF Pro Text',
                      color: MediaPlayerStyles.mutedColor.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 320,
                    child: _LanguageDropdown(
                      languages: languages,
                      selectedLanguage: selectedLanguage,
                      onLanguageSelected: (locale) {
                        setState(() {
                          _selectedLanguage = locale;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDots(1),
              Row(
                children: [
                  _buildPreviousButton(),
                  const SizedBox(width: 16),
                  _buildNextButton(text: 'Next'),
                ],
              ),
            ],
          ),
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
            'onboarding.setPresets'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'onboarding.addFavoriteDurations'.tr(),
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
            children: [
              _buildProgressDots(3),
              Row(
                children: [
                  _buildPreviousButton(),
                  const SizedBox(width: 16),
                  _buildNextButton(text: 'Next'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStep() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 64,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Stay on Track',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get notified when your timer completes,\neven if the app is in the background.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: '.SF Pro Text',
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDots(4),
              Row(
                children: [
                  GestureDetector(
                    onTap: _nextStep,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Maybe Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MediaPlayerStyles.mutedColor,
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enableNotifications,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accent,
                            AppTheme.accent.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Enable Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

  Widget _buildNextButton({String text = 'Next'}) {
    final isEnabled =
        _currentStep == 0
            ? true // Language step - always enabled
            : _currentStep == 1
            ? _nameController.text.trim().isNotEmpty
            : _currentStep == 2
            ? _customPresets.isNotEmpty
            : true;

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
              Text(
                text,
                style: const TextStyle(
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

  Widget _buildAntExplanationStep() {
    return _buildCommonExplanationScreen(
      stepIndex: 5,
      nextLabel: 'Start focusing',
      title: 'The ant is your progress',
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 2,
                          color: AppTheme.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 20,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: AppTheme.accent,
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: Icon(
                          Icons.flag_rounded,
                          size: 16,
                          color: AppTheme.accent,
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        child: SvgPicture.asset(
                          'assets/images/character-orange-crop.svg',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Your progress is visual',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                    fontFamily: '.SF Pro Rounded',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'As the timer runs, your ant moves forward.\nWhen the journey ends, the session is complete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: MediaPlayerStyles.mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal, modern language selector with type-ahead search
class _LanguageDropdown extends StatefulWidget {
  final List<LocaleInfo> languages;
  final LocaleInfo selectedLanguage;
  final Function(Locale) onLanguageSelected;

  const _LanguageDropdown({
    required this.languages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<_LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<_LanguageDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  List<LocaleInfo> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = widget.languages;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = widget.languages;
      } else {
        _filteredLanguages =
            widget.languages.where((lang) {
              return lang.nativeName.toLowerCase().contains(query) ||
                  lang.locale.languageCode.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
        _searchController.clear();
      }
    });
  }

  void _selectLanguage(LocaleInfo language) {
    widget.onLanguageSelected(language.locale);
    setState(() {
      _isExpanded = false;
      _searchController.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected language display (like the name field)
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      _isExpanded
                          ? AppTheme.accent
                          : MediaPlayerStyles.subtleBorder,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.selectedLanguage.nativeName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontFamily: '.SF Pro Text',
                    color: MediaPlayerStyles.mutedColor,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.6),
                  size: 28,
                ),
              ],
            ),
          ),
        ),

        // Dropdown list with search
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 16),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: '.SF Pro Text',
                      color: MediaPlayerStyles.mutedColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search languages...',
                      hintStyle: TextStyle(
                        color: MediaPlayerStyles.mutedColor.withValues(
                          alpha: 0.4,
                        ),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: MediaPlayerStyles.mutedColor.withValues(
                          alpha: 0.4,
                        ),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MediaPlayerStyles.subtleBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: MediaPlayerStyles.subtleBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.accent.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Language list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final language = _filteredLanguages[index];
                      final isSelected =
                          language.locale == widget.selectedLanguage.locale;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectLanguage(language),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.accent.withValues(alpha: 0.08)
                                      : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      index == _filteredLanguages.length - 1
                                          ? Colors.transparent
                                          : MediaPlayerStyles.subtleBorder
                                              .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    language.nativeName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          isSelected
                                              ? AppTheme.accent
                                              : MediaPlayerStyles.mutedColor,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.accent,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
