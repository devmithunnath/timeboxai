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
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../providers/timer_provider.dart';
import 'widgets/ant_progress_indicator.dart';
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

  // New state for enhanced onboarding
  String? _selectedUseCase;
  bool _hasTrackedValueDemo = false;
  bool _hasTrackedProgressSeed = false;

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
    // Step 0: Language Selection
    if (_currentStep == 0) {
      if (_selectedLanguage != null) {
        final languages = LocalizationService().getSupportedLanguages();
        final selectedLang = languages.firstWhere(
          (lang) => lang.locale == _selectedLanguage,
          orElse: () => languages.first,
        );
        AnalyticsService().trackOnboardingLanguageSelected(
          _selectedLanguage!.toString(),
          selectedLang.nativeName,
        );
        context.setLocale(_selectedLanguage!);
        LocalizationService().saveLocale(_selectedLanguage!);
        SupabaseService().updateUserLanguage(_selectedLanguage!.toString());
      }
      setState(() => _currentStep = 1);
    }
    // Step 1: Value Demo - just continue
    else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    }
    // Step 2: Use Case Selection
    else if (_currentStep == 2) {
      if (_selectedUseCase != null) {
        AnalyticsService().trackOnboardingUseCaseSelected(_selectedUseCase!);
        SupabaseService().updateUseCase(_selectedUseCase!);
      }
      setState(() => _currentStep = 3);
    }
    // Step 3: Name Input
    else if (_currentStep == 3) {
      if (_nameController.text.trim().isNotEmpty) {
        final name = _nameController.text.trim();
        widget.onboardingService.setUserName(name);
        AnalyticsService().trackOnboardingNameEntered(name);
        setState(() => _currentStep = 4);
      }
    }
    // Step 4: Presets
    else if (_currentStep == 4) {
      if (_customPresets.isNotEmpty) {
        widget.onboardingService.setPresetTimers(_customPresets);
        setState(() => _currentStep = 5);
      }
    }
    // Step 5: Demo Timer - just continue after completion
    else if (_currentStep == 5) {
      setState(() => _currentStep = 6);
    }
    // Step 6: Notifications
    else if (_currentStep == 6) {
      setState(() => _currentStep = 7);
    }
    // Step 7: Progress Seed - Complete onboarding
    else if (_currentStep == 7) {
      widget.onboardingService.completeOnboarding();
      AnalyticsService().trackOnboardingCompleted(_customPresets.length);
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
    // Navigate immediately so user sees responsiveness
    _nextStep();

    // Then request permissions and show test notification in background
    try {
      await NotificationService().init(); // Ensure initialization
      final result = await NotificationService().requestPermissions();
      debugPrint('Notification permission result: $result');

      // Show a test notification
      await NotificationService().showNotification(
        id: 1,
        title: 'Notifications Enabled!',
        body: 'You will be notified when your timer completes.',
      );
    } catch (e) {
      debugPrint('Error enabling notifications: $e');
    }
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
        return _buildValueDemoStep();
      case 2:
        return _buildUseCaseStep();
      case 3:
        return _buildNameStep();
      case 4:
        return _buildPresetsStep();
      case 5:
        return _buildDemoTimerStep();
      case 6:
        return _buildNotificationStep();
      case 7:
        return _buildProgressSeedStep();
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
                        // Apply locale immediately so UI updates
                        context.setLocale(locale);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildProgressDots(1), _buildNextButton(text: 'Next')],
          ),
        ],
      ),
    );
  }

  // NEW: Value Demo Step - Shows animated ant preview
  Widget _buildValueDemoStep() {
    if (!_hasTrackedValueDemo) {
      _hasTrackedValueDemo = true;
      AnalyticsService().trackOnboardingValueDemoViewed();
    }

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(),
          // Animated ant preview container
          Container(
            width: 280,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated ant moving across
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      return Positioned(
                        left: 20 + (value * 160),
                        child: SvgPicture.asset(
                          'assets/images/character-orange-crop.svg',
                          width: 80,
                          height: 60,
                        ),
                      );
                    },
                  ),
                  // Path line
                  Positioned(
                    bottom: 25,
                    left: 30,
                    right: 30,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'onboarding.valueDemo.title'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'onboarding.valueDemo.description'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: '.SF Pro Text',
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDots(2),
              _buildNextButton(text: 'onboarding.next'.tr()),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Use Case Selection Step
  Widget _buildUseCaseStep() {
    final useCases = [
      {
        'id': 'studying',
        'icon': '🎓',
        'label': 'onboarding.useCase.studying'.tr(),
      },
      {
        'id': 'deep_work',
        'icon': '💼',
        'label': 'onboarding.useCase.deepWork'.tr(),
      },
      {
        'id': 'creative',
        'icon': '🎨',
        'label': 'onboarding.useCase.creative'.tr(),
      },
      {
        'id': 'general',
        'icon': '⏰',
        'label': 'onboarding.useCase.general'.tr(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'onboarding.useCase.title'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'onboarding.useCase.subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children:
                useCases.map((useCase) {
                  final isSelected = _selectedUseCase == useCase['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUseCase = useCase['id'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.accent.withValues(alpha: 0.15)
                                : MediaPlayerStyles.subtleBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppTheme.accent
                                  : MediaPlayerStyles.subtleBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            useCase['icon'] as String,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            useCase['label'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? AppTheme.accent
                                      : MediaPlayerStyles.mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDots(3),
              Row(
                children: [
                  _buildPreviousButton(),
                  const SizedBox(width: 16),
                  _buildNextButton(
                    text: 'onboarding.next'.tr(),
                    enabled: _selectedUseCase != null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Demo Timer Step - 10 second quick focus sprint
  Widget _buildDemoTimerStep() {
    return _DemoTimerWidget(
      onComplete: () {
        AnalyticsService().trackOnboardingDemoTimerCompleted(10000);
        _nextStep();
      },
      onSkip: _nextStep,
      progressDots: _buildProgressDots(6),
    );
  }

  // NEW: Progress Seed Step - Day 1 of journey
  Widget _buildProgressSeedStep() {
    if (!_hasTrackedProgressSeed) {
      _hasTrackedProgressSeed = true;
      AnalyticsService().trackOnboardingProgressSeedViewed();
    }

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(),
          // Day 1 Badge
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accent,
                  AppTheme.accent.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: '.SF Pro Rounded',
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'onboarding.progressSeed.title'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'onboarding.progressSeed.subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: '.SF Pro Text',
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDots(8),
              _buildNextButton(text: 'onboarding.startFocusing'.tr()),
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
              _buildProgressDots(5),
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
              _buildProgressDots(7),
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

  Widget _buildNextButton({String text = 'Next', bool? enabled}) {
    // If enabled is explicitly passed, use it; otherwise compute based on step
    final isEnabled =
        enabled ??
        (_currentStep == 0
            ? true // Language step
            : _currentStep == 1
            ? true // Value demo
            : _currentStep == 2
            ? _selectedUseCase !=
                null // Use case
            : _currentStep == 3
            ? _nameController.text
                .trim()
                .isNotEmpty // Name
            : _currentStep == 4
            ? _customPresets
                .isNotEmpty // Presets
            : true // All other steps
            );

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

class _DemoTimerWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final Widget progressDots;

  const _DemoTimerWidget({
    required this.onComplete,
    required this.onSkip,
    required this.progressDots,
  });

  @override
  State<_DemoTimerWidget> createState() => _DemoTimerWidgetState();
}

class _DemoTimerWidgetState extends State<_DemoTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late MockTimerProvider _mockTimer;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _mockTimer = MockTimerProvider();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isComplete = true);
        _mockTimer.update(1.0, 0, false, true); // Finished
        SoundService().playCompletionSound();
      }
    });
    
    _controller.addListener(() {
      if (_controller.isAnimating) {
        final progress = _controller.value;
        final remaining = 10 - (10 * progress).floor();
        _mockTimer.update(progress, remaining, true, false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    // No need to dispose mock timer as it's just a data holder essentially, 
    // but good practice if we attached listeners.
    _mockTimer.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _mockTimer.update(0.0, 10, true, false);
    AnalyticsService().trackOnboardingDemoTimerStarted();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'onboarding.demoTimer.title'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Rounded',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'onboarding.demoTimer.subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.7),
            ),
          ),
          
          const Spacer(),
          
          // Timer display with AntProgressIndicator
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final remaining = 10 - (10 * _controller.value).floor();
              return Column(
                children: [
                  Text(
                    _isComplete ? '🎉' : '${remaining}s',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                      fontFamily: '.SF Pro Rounded',
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 40), // Add space between timer and ant
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: AntProgressIndicator(
                      timer: _mockTimer,
                      windowWidth: MediaQuery.of(context).size.width - 80, // Account for padding
                    ),
                  ),
                ],
              );
            },
          ),
          
          const Spacer(),
          
          // Start / Complete button
          if (!_isRunning)
            GestureDetector(
              onTap: _startTimer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Text(
                  'onboarding.demoTimer.start'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else if (_isComplete)
            GestureDetector(
              onTap: widget.onComplete,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'onboarding.demoTimer.complete'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Text(
              'onboarding.demoTimer.focusMessage'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.progressDots,
              if (!_isRunning)
                GestureDetector(
                  onTap: widget.onSkip,
                  child: Text(
                    'onboarding.skip'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: MediaPlayerStyles.mutedColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mock Provider for Demo
class MockTimerProvider extends ChangeNotifier implements TimerProvider {
  double _progress = 0.0;
  bool _isRunning = false;
  bool _isFinished = false;
  Duration _remainingDuration = const Duration(seconds: 10);

  void update(double progress, int remainingSeconds, bool isRunning, bool isFinished) {
    _progress = progress;
    _remainingDuration = Duration(seconds: remainingSeconds);
    _isRunning = isRunning;
    _isFinished = isFinished;
    notifyListeners();
  }

  @override
  double get progress => _progress;
  @override
  bool get isRunning => _isRunning;
  @override
  bool get isFinished => _isFinished;
  @override
  bool get isPaused => false;
  @override
  Duration get remainingDuration => _remainingDuration;
  
  // Stubs for other members to satisfy interface
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
