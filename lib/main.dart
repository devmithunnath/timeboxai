import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'providers/timer_provider.dart';
import 'services/analytics_service.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';
import 'ui/settings_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if this is a sub-window (settings window)
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument =
        args.length > 2
            ? jsonDecode(args[2]) as Map<String, dynamic>
            : <String, dynamic>{};

    runApp(
      SettingsWindowApp(
        windowController: WindowController.fromWindowId(windowId),
        args: argument,
      ),
    );
    return;
  }

  // Main window initialization
  await windowManager.ensureInitialized();

  // Initialize PostHog analytics
  await AnalyticsService().init();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 580),
    minimumSize: Size(600, 580),
    maximumSize: Size(600, 580),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: "Timebox",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const TimeboxApp());
}

class TimeboxApp extends StatelessWidget {
  const TimeboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: MaterialApp(
        title: 'Timebox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

/// Separate app for the settings window
class SettingsWindowApp extends StatelessWidget {
  final WindowController windowController;
  final Map<String, dynamic> args;

  const SettingsWindowApp({
    super.key,
    required this.windowController,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SettingsScreen(),
    );
  }
}

/// Helper function to open settings in a new window
Future<void> openSettingsWindow() async {
  final window = await DesktopMultiWindow.createWindow(
    jsonEncode({'window': 'settings'}),
  );

  window
    ..setFrame(const Offset(100, 100) & const Size(400, 500))
    ..setTitle('Settings')
    ..show();
}
