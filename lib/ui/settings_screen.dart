import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/onboarding_service.dart';
import 'language_selector_screen.dart';
import 'theme.dart';
import 'widgets/section_header.dart';
import 'widgets/media_player_control.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsScreen({super.key, required this.onClose});

  String _getCurrentLanguageName(BuildContext context) {
    final locale = context.locale;
    final Map<String, String> languageNames = {
      'en': 'English',
      'zh_Hans': '简体中文',
      'zh_Hant': '繁體中文',
      'ja': '日本語',
      'de': 'Deutsch',
      'fr': 'Français',
      'es': 'Español',
      'es_MX': 'Español (México)',
      'pt_BR': 'Português (Brasil)',
      'pt_PT': 'Português (Portugal)',
      'hi': 'हिन्दी',
      'ar': 'العربية',
      'ko': '한국어',
      'it': 'Italiano',
      'nl': 'Nederlands',
      'ru': 'Русский',
      'tr': 'Türkçe',
      'sv': 'Svenska',
      'pl': 'Polski',
      'id': 'Bahasa Indonesia',
      'th': 'ไทย',
      'vi': 'Tiếng Việt',
    };

    final key =
        locale.countryCode != null
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;
    return languageNames[key] ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'settings.title'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: '.SF Pro Rounded',
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const SectionHeader(title: 'APPEARANCE'),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.palette_rounded,
                  title: 'Theme',
                  subtitle: 'Default',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.language_rounded,
                  title: 'settings.language'.tr(),
                  subtitle: _getCurrentLanguageName(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSelectorScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                const SectionHeader(title: 'ABOUT'),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  subtitle: '1.0.0+1',
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'DEBUG'),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.refresh_rounded,
                    title: 'Reset Onboarding',
                    subtitle: 'Test the onboarding flow again',
                    onTap: () async {
                      final onboarding = context.read<OnboardingService>();
                      await onboarding.resetOnboarding();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding reset! Restart the app.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],

                const Spacer(),

                Center(
                  child: Text(
                    'Made with ❤️ for focus',
                    style: TextStyle(
                      fontSize: 12,
                      color: MediaPlayerStyles.mutedColor.withValues(
                        alpha: 0.5,
                      ),
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: _CloseButton(onPressed: onClose),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    BuildContext? context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: MediaPlayerStyles.subtleBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MediaPlayerStyles.subtleBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: MediaPlayerStyles.mutedColor,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: MediaPlayerStyles.mutedColor.withValues(
                          alpha: 0.6,
                        ),
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? MediaPlayerStyles.subtleBackground
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isHovered ? 1.0 : 0.6,
            child: Icon(
              Icons.close_rounded,
              color: MediaPlayerStyles.mutedColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
