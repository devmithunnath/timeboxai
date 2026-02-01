import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/onboarding_service.dart';
import '../services/voice_command_service.dart';
import 'widgets/toast.dart';
import '../providers/timer_provider.dart';
import 'settings_screen.dart';
import 'widgets/ant_progress_indicator.dart';
import 'widgets/settings_button.dart';
import 'widgets/timer_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSettings = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final VoiceCommandService _voiceCommandService = VoiceCommandService();
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initHotkey();
    _initSpeech();
    
    // Listen for hotkey changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboarding = Provider.of<OnboardingService>(context, listen: false);
      onboarding.addListener(_onOnboardingChanged);
    });
  }

  void _onOnboardingChanged() {
    _initHotkey();
  }

  Future<void> _initSpeech() async {
    final onboarding = Provider.of<OnboardingService>(context, listen: false);
    if (onboarding.microphoneEnabled) {
      try {
        await _speech.initialize(
          onStatus: _handleSpeechStatus,
          onError: _handleSpeechError,
        );
      } catch (e) {
        debugPrint('Pre-initializing speech failed: $e');
      }
    }
  }

  void _handleSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_isListening) {
        _stopListening();
      }
    }
  }

  void _handleSpeechError(dynamic error) {
    if (_isListening) {
      AppToast.show(
        context,
        'Speech Error: ${error.errorMsg}',
        isError: true,
      );
      _stopListening();
    }
  }

  @override
  void dispose() {
    final onboarding = Provider.of<OnboardingService>(context, listen: false);
    onboarding.removeListener(_onOnboardingChanged);
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  Future<void> _initHotkey() async {
    final onboarding = Provider.of<OnboardingService>(context, listen: false);
    await hotKeyManager.unregisterAll();

    // Map from onboarding service values
    final savedId = onboarding.hotkeyId;
    final savedModifiers = onboarding.hotkeyModifiers;

    // Resolve LogicalKeyboardKey from saved ID
    LogicalKeyboardKey keyCode = LogicalKeyboardKey(savedId);

    List<HotKeyModifier> modifiers = [];
    for (final modStr in savedModifiers) {
      final m = modStr.toLowerCase();
      if (m == 'shift') {
        modifiers.add(HotKeyModifier.shift);
      } else if (m == 'alt' || m == 'option') {
        modifiers.add(HotKeyModifier.alt);
      } else if (m == 'control' || m == 'ctrl') {
        modifiers.add(HotKeyModifier.control);
      } else if (m == 'meta' || m == 'command') {
        modifiers.add(HotKeyModifier.meta);
      }
    }

    HotKey hotKey = HotKey(
      key: keyCode,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        _startListening();
      },
      keyUpHandler: (hotKey) {
        _stopListening();
      },
    );
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    // Check if initialized, if not try once
    if (!_speech.isAvailable) {
      final available = await _speech.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );
      
      if (!available) {
        final hasPermission = await _speech.hasPermission;
        if (!hasPermission) {
          AppToast.show(context, 'Speech recognition permission denied. Please check System Settings.', isError: true);
        } else {
          AppToast.show(context, 'Speech recognition currently unavailable', isError: true);
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _lastWords = '';
    });
    
    // Sync with global state for Menubar
    Provider.of<TimerProvider>(context, listen: false).setListening(true);
    
    AppToast.show(
      context,
      'Listening...',
      duration: const Duration(seconds: 1),
    );
    
    await _speech.listen(
      onResult: (result) {
        setState(() => _lastWords = result.recognizedWords);
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    setState(() => _isListening = false);
    
    // Sync with global state for Menubar
    if (mounted) {
      Provider.of<TimerProvider>(context, listen: false).setListening(false);
    }

    if (_lastWords.isNotEmpty) {
      _processCommand(_lastWords);
    }
  }

  void _processCommand(String text) {
    if (text.isEmpty) return;
    final timer = Provider.of<TimerProvider>(context, listen: false);
    final onboarding = Provider.of<OnboardingService>(context, listen: false);

    _voiceCommandService.handleCommand(
      transcript: text,
      context: context,
      timer: timer,
      onboarding: onboarding,
    );
  }

  void _openSettings() {
    setState(() => _showSettings = true);
  }

  void _closeSettings() {
    setState(() => _showSettings = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Consumer<TimerProvider>(
              builder: (context, timer, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: GestureDetector(
                        onPanStart: (_) => windowManager.startDragging(),
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.only(left: 16, top: 12),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: SettingsButton(onPressed: _openSettings),
                    ),

                    Positioned(
                      top: 48,
                      left: 24,
                      right: 24,
                      bottom: 120,
                      child: const TimerContent(),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AntProgressIndicator(
                        timer: timer,
                        windowWidth: 750,
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: const Center(
                        child: Text(
                          "Small steps matter.",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: '.SF Pro Text',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    if (_isListening && _lastWords.isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 60,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _lastWords,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          if (_showSettings) SettingsScreen(onClose: _closeSettings),
        ],
      ),
    );
  }
}
