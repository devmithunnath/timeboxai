import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'POSTHOG_API_KEY')
  static String posthogApiKey = _Env.posthogApiKey;

  @EnviedField(varName: 'POSTHOG_HOST')
  static String posthogHost = _Env.posthogHost;

  @EnviedField(varName: 'SUPABASE_URL')
  static String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'SENTRY_DSN')
  static String sentryDsn = _Env.sentryDsn;
}
