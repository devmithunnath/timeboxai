import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
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

  static const double _antAreaHeight = 0;
  static const double _footerTextHeight = 40;
  static const double _bottomReserved = _antAreaHeight + _footerTextHeight;

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

                    if (kDebugMode)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: SettingsButton(onPressed: _openSettings),
                      ),

                    Positioned(
                      top: 48,
                      left: 24,
                      right: 24,
                      bottom: _bottomReserved,
                      child: const TimerContent(),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AntProgressIndicator(
                        timer: timer,
                        windowWidth: 600,
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: _antAreaHeight,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8),
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
