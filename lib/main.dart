import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'env/env.dart';
import 'providers/timer_provider.dart';
import 'services/analytics_service.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';
import 'services/supabase_service.dart';
import 'ui/home_screen.dart';
import 'ui/onboarding_screen.dart';
import 'ui/theme.dart';
import 'services/menubar_service.dart';

void main(List<String> args) async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization before other services
  await EasyLocalization.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      await windowManager.ensureInitialized();
      await hotKeyManager.unregisterAll(); // Clear any stale hotkeys
      
      final onboardingService = OnboardingService();
      final timerProvider = TimerProvider();
      
      // Start all initializations in parallel
      final initializationFuture = Future.wait([
        AnalyticsService().init(),
        SupabaseService().init(),
        NotificationService().init(),
        onboardingService.init(),
        MenuBarService().init(timerProvider),
      ]);

      const windowOptions = WindowOptions(
        size: Size(600, 580),
        minimumSize: Size(600, 580),
        maximumSize: Size(600, 580),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        title: "PipBox",
      );

      // Start waiting for the window to be ready
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        // Only show once all services and the window are ready
        await initializationFuture;
        await windowManager.show();
        await windowManager.focus();
      });

      await initializationFuture;

      runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('en'),
            Locale('zh', 'Hans'),
            Locale('zh', 'Hant'),
            Locale('ja'),
            Locale('de'),
            Locale('fr'),
            Locale('es'),
            Locale('es', 'MX'),
            Locale('pt', 'BR'),
            Locale('pt', 'PT'),
            Locale('hi'),
            Locale('ar'),
            Locale('ko'),
            Locale('it'),
            Locale('nl'),
            Locale('ru'),
            Locale('tr'),
            Locale('sv'),
            Locale('pl'),
            Locale('id'),
            Locale('th'),
            Locale('vi'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: const Locale(
            'en',
          ), // Default to English for clean install
          child: PipBoxApp(
            onboardingService: onboardingService,
            timerProvider: timerProvider,
          ),
        ),
      );
    },
  );
}

class PipBoxApp extends StatefulWidget {
  final OnboardingService onboardingService;
  final TimerProvider timerProvider;

  const PipBoxApp({
    super.key, 
    required this.onboardingService,
    required this.timerProvider,
  });

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
        ChangeNotifierProvider.value(value: widget.timerProvider),
        ChangeNotifierProvider.value(value: widget.onboardingService),
      ],
      child: MaterialApp(
        title: 'PipBox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,

        // Localization configuration
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

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
