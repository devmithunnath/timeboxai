import 'package:flutter/material.dart';
import 'theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            'Settings',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.palette_rounded,
              title: 'Theme',
              subtitle: 'Default',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              onTap: () {
                // TODO: Open theme selector (Default, White)
              },
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 32),
            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              subtitle: '1.0.0+1',
            ),

            const Spacer(),

            // Footer
            Center(
              child: Text(
                'Made with ❤️ for focus',
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.accent, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (trailing == null && onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
