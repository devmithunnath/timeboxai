import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/onboarding_service.dart';
import '../services/supabase_service.dart';
import 'theme.dart';
import 'widgets/section_header.dart';
import 'widgets/media_player_control.dart';
import 'widgets/feedback_modal.dart';
import 'widgets/toast.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Slightly off-white for premium feel
      body: Stack(
        children: [
          Consumer<OnboardingService>(
            builder: (context, onboarding, _) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: '.SF Pro Rounded',
                          color: AppTheme.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    const SectionHeader(title: 'NOTIFICATIONS'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildToggleTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        value: onboarding.notificationsEnabled,
                        onChanged: (val) {
                          onboarding.toggleNotifications(val);
                          AppToast.show(context, 'Settings saved');
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),
                    const SectionHeader(title: 'FEEDBACK'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildActionTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Provide Feedback',
                        subtitle: 'Share your feedback and requests',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const FeedbackModal(),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),
                    const SectionHeader(title: 'LANGUAGE'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildActionTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        trailingText: _getLanguageName(context.locale.languageCode),
                        onTap: () async {
                          _showLanguagePicker(context);
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),
                    const SectionHeader(title: 'ABOUT'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      _buildInfoTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        trailingText: '1.0.0+1',
                      ),
                      if (kDebugMode) ...[
                        const Divider(height: 1, indent: 50, color: Color(0xFFF2F2F7)),
                        _buildActionTile(
                          icon: Icons.refresh_rounded,
                          title: 'Reset Session',
                          subtitle: 'Reset onboarding and start fresh',
                          onTap: () async {
                            await onboarding.resetOnboarding();
                            if (context.mounted) {
                              AppToast.show(context, 'Session reset! Restarting...');
                            }
                          },
                        ),
                      ],
                    ]),

                    const SizedBox(height: 60),

                    Center(
                      child: Text(
                        'Made with ❤️ for focus',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            top: 20,
            right: 20,
            child: _CloseButton(onPressed: onClose),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'zh': return 'Chinese';
      case 'ja': return 'Japanese';
      default: return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: '.SF Pro Rounded',
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageTile(context, 'English', const Locale('en')),
                _buildLanguageTile(context, 'Chinese (Simplified)', const Locale('zh', 'Hans')),
                _buildLanguageTile(context, 'Chinese (Traditional)', const Locale('zh', 'Hant')),
                _buildLanguageTile(context, 'Japanese', const Locale('ja')),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, String title, Locale locale) {
    final isSelected = context.locale == locale;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF1D1D1F),
        ),
      ),
      trailing: isSelected 
        ? Icon(Icons.check_rounded, color: AppTheme.accent) 
        : null,
      onTap: () {
        context.setLocale(locale);
        SupabaseService().updateUserLanguage(locale.languageCode);
        Navigator.pop(context);
        AppToast.show(context, 'Language updated');
      },
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconCircle(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconCircle(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 15,
                  color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildIconCircle(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          Text(
            trailingText,
            style: TextStyle(
              fontSize: 15,
              color: MediaPlayerStyles.mutedColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 28), // Matchchevron width
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppTheme.accent, size: 20),
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
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF8E8E93),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
