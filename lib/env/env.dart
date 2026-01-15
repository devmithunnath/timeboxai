import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'POSTHOG_API_KEY')
  static String posthogApiKey = _Env.posthogApiKey;

  @EnviedField(varName: 'POSTHOG_HOST')
  static String posthogHost = _Env.posthogHost;
}
