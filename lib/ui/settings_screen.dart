import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/section_header.dart';
import 'widgets/settings_tile.dart';

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
            const SectionHeader(title: 'Appearance'),
            const SizedBox(height: 12),
            SettingsTile(
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
            const SectionHeader(title: 'About'),
            const SizedBox(height: 12),
            const SettingsTile(
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
}
