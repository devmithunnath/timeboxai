import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import 'theme.dart';

/// Screen for selecting app language from 22 supported options
class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  final _localizationService = LocalizationService();
  late List<LocaleInfo> _languages;

  @override
  void initState() {
    super.initState();
    _languages = _localizationService.getSupportedLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('settings.selectLanguage'.tr()),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          return _buildLanguageTile(language);
        },
      ),
    );
  }

  Widget _buildLanguageTile(LocaleInfo language) {
    final isSelected = context.locale == language.locale;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accent.withOpacity(0.2) : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.accent : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Text(language.flag, style: const TextStyle(fontSize: 32)),
        title: Text(
          language.nativeName,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing:
            isSelected
                ? const Icon(
                  Icons.check_circle,
                  color: AppTheme.accent,
                  size: 24,
                )
                : null,
        onTap: () async {
          // Change locale
          await context.setLocale(language.locale);
          // Save to preferences
          await _localizationService.saveLocale(language.locale);
          // Optionally close the screen after selection
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
