import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/timer_provider.dart';

class MenuBarService with TrayListener {
  static final MenuBarService _instance = MenuBarService._internal();
  factory MenuBarService() => _instance;
  MenuBarService._internal();

  TimerProvider? _timerProvider;
  Timer? _animationTimer;
  int _waveFrame = 0;
  final List<String> _waveFrames = ['▖', '▘', '▝', '▗']; // Spinning block effect
  final List<String> _listeningFrames = ['▃', '▅', '▇', '▆', '▄'];

  Future<void> init(TimerProvider timerProvider) async {
    _timerProvider = timerProvider;
    
    await trayManager.setIcon(
      'assets/images/app_icon.png', // Fallback to app icon
    );
    
    trayManager.addListener(this);
    
    // Start monitoring state
    _startMonitoring();
  }

  void _startMonitoring() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_timerProvider == null) return;
      _updateTray();
    });
  }

  void _updateTray() async {
    if (_timerProvider == null) return;

    String title = '';
    
    if (_timerProvider!.isListening) {
      // Animated waveform effect
      _waveFrame = (_waveFrame + 1) % _listeningFrames.length;
      final wave = _listeningFrames[_waveFrame];
      title = ' Listening $wave ';
    } else if (_timerProvider!.isRunning || _timerProvider!.isPaused) {
      final duration = _timerProvider!.remainingDuration;
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      final prefix = _timerProvider!.isPaused ? 'Ⅱ' : ''; // Pause symbol
      title = ' $prefix$minutes:$seconds ';
    } else {
      title = ' PipBox '; // Small brand presence
    }

    await trayManager.setTitle(title);
  }

  @override
  void onTrayIconMouseDown() {
    _handleTrayClick();
  }

  @override
  void onTrayIconRightMouseDown() async {
    final menu = Menu(
      items: [
        MenuItem(
          label: 'Show PipBox',
          onClick: (_) => _handleTrayClick(),
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Quit',
          onClick: (_) => windowManager.close(),
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
    await trayManager.popUpContextMenu();
  }

  void _handleTrayClick() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }
}
