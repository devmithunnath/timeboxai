import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/timer_provider.dart';
import 'services/analytics_service.dart';
import 'services/onboarding_service.dart';
import 'ui/home_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/theme.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await AnalyticsService().init();

  final onboardingService = OnboardingService();
  await onboardingService.init();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 580),
    minimumSize: Size(600, 580),
    maximumSize: Size(600, 580),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: "PipBox",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(PipBoxApp(onboardingService: onboardingService));
}

class PipBoxApp extends StatefulWidget {
  final OnboardingService onboardingService;

  const PipBoxApp({super.key, required this.onboardingService});

  @override
  State<PipBoxApp> createState() => _PipBoxAppState();
}

class _PipBoxAppState extends State<PipBoxApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.onboardingService.hasCompletedOnboarding;
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider.value(value: widget.onboardingService),
      ],
      child: MaterialApp(
        title: 'PipBox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home:
            _showOnboarding
                ? OnboardingScreen(
                  onboardingService: widget.onboardingService,
                  onComplete: _onOnboardingComplete,
                )
                : const HomeScreen(),
      ),
    );
  }
}
