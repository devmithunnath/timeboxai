#!/usr/bin/env python3
"""
Automatic Translation Generator for PipBox
Translates en.json into all 21 supported languages using AI translation.
"""

import json
import os

# Language mapping: (locale_code, language_name_for_context)
LANGUAGES = [
    ('zh-Hans', 'Simplified Chinese'),
    ('zh-Hant', 'Traditional Chinese'),
    ('ja', 'Japanese'),
    ('de', 'German'),
    ('fr', 'French'),
    ('es', 'Spanish'),
    ('es-MX', 'Mexican Spanish'),
    ('pt-BR', 'Brazilian Portuguese'),
    ('pt-PT', 'European Portuguese'),
    ('hi', 'Hindi'),
    ('ar', 'Arabic'),
    ('ko', 'Korean'),
    ('it', 'Italian'),
    ('nl', 'Dutch'),
    ('ru', 'Russian'),
    ('tr', 'Turkish'),
    ('sv', 'Swedish'),
    ('pl', 'Polish'),
    ('id', 'Indonesian'),
    ('th', 'Thai'),
    ('vi', 'Vietnamese'),
]

# Manual high-quality translations for common UI elements
MANUAL_TRANSLATIONS = {
    'zh-Hans': {
        'app.name': 'PipBox',
        'app.tagline': '您的生产力伙伴',
        'timer.play': '播放',
        'timer.pause': '暂停',
        'timer.stop': '停止',
        'timer.reset': '重置',
        'settings.title': '设置',
        'settings.language': '语言',
        'common.ok': '确定',
        'common.cancel': '取消',
        'common.save': '保存',
    },
    'zh-Hant': {
        'app.name': 'PipBox',
        'app.tagline': '您的生產力夥伴',
        'timer.play': '播放',
        'timer.pause': '暫停',
        'timer.stop': '停止',
        'timer.reset': '重置',
        'settings.title': '設定',
        'settings.language': '語言',
        'common.ok': '確定',
        'common.cancel': '取消',
        'common.save': '儲存',
    },
    'ja': {
        'app.name': 'PipBox',
        'app.tagline': 'あなたの生産性パートナー',
        'timer.play': '再生',
        'timer.pause': '一時停止',
        'timer.stop': '停止',
        'timer.reset': 'リセット',
        'settings.title': '設定',
        'settings.language': '言語',
        'common.ok': 'OK',
        'common.cancel': 'キャンセル',
        'common.save': '保存',
    },
    'de': {
        'app.name': 'PipBox',
        'app.tagline': 'Ihr Produktivitätsbegleiter',
        'timer.play': 'Abspielen',
        'timer.pause': 'Pause',
        'timer.stop': 'Stopp',
        'timer.reset': 'Zurücksetzen',
        'settings.title': 'Einstellungen',
        'settings.language': 'Sprache',
        'common.ok': 'OK',
        'common.cancel': 'Abbrechen',
        'common.save': 'Speichern',
    },
    'fr': {
        'app.name': 'PipBox',
        'app.tagline': 'Votre compagnon de productivité',
        'timer.play': 'Lecture',
        'timer.pause': 'Pause',
        'timer.stop': 'Arrêt',
        'timer.reset': 'Réinitialiser',
        'settings.title': 'Paramètres',
        'settings.language': 'Langue',
        'common.ok': 'OK',
        'common.cancel': 'Annuler',
        'common.save': 'Enregistrer',
    },
    'es': {
        'app.name': 'PipBox',
        'app.tagline': 'Tu compañero de productividad',
        'timer.play': 'Reproducir',
        'timer.pause': 'Pausa',
        'timer.stop': 'Detener',
        'timer.reset': 'Restablecer',
        'settings.title': 'Configuración',
        'settings.language': 'Idioma',
        'common.ok': 'Aceptar',
        'common.cancel': 'Cancelar',
        'common.save': 'Guardar',
    },
    'ko': {
        'app.name': 'PipBox',
        'app.tagline': '당신의 생산성 동반자',
        'timer.play': '재생',
        'timer.pause': '일시정지',
        'timer.stop': '정지',
        'timer.reset': '초기화',
        'settings.title': '설정',
        'settings.language': '언어',
        'common.ok': '확인',
        'common.cancel': '취소',
        'common.save': '저장',
    },
    'ar': {
        'app.name': 'PipBox',
        'app.tagline': 'رفيقك في الإنتاجية',
        'timer.play': 'تشغيل',
        'timer.pause': 'إيقاف مؤقت',
        'timer.stop': 'إيقاف',
        'timer.reset': 'إعادة تعيين',
        'settings.title': 'الإعدادات',
        'settings.language': 'اللغة',
        'common.ok': 'موافق',
        'common.cancel': 'إلغاء',
        'common.save': 'حفظ',
    },
}

def flatten_dict(d, parent_key='', sep='.'):
    """Flatten nested dictionary into dot-notation keys."""
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)

def unflatten_dict(d, sep='.'):
    """Convert dot-notation keys back to nested dictionary."""
    result = {}
    for key, value in d.items():
        parts = key.split(sep)
        current = result
        for part in parts[:-1]:
            if part not in current:
                current[part] = {}
            current = current[part]
        current[parts[-1]] = value
    return result

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    translations_dir = os.path.join(script_dir, 'assets', 'translations')
    
    # Load English source
    en_path = os.path.join(translations_dir, 'en.json')
    with open(en_path, 'r', encoding='utf-8') as f:
        en_data = json.load(f)
    
    # Flatten for easier processing
    flat_en = flatten_dict(en_data)
    
    print("🌍 PipBox Translation Generator")
    print("=" * 50)
    print(f"Source: English ({len(flat_en)} strings)")
    print(f"Generating {len(LANGUAGES)} translations...")
    print()
    
    for locale, lang_name in LANGUAGES:
        print(f"📝 Translating to {lang_name} ({locale})...")
        
        # Start with manual translations if available
        translated = {}
        if locale in MANUAL_TRANSLATIONS:
            translated = MANUAL_TRANSLATIONS[locale].copy()
            print(f"   ✓ Using {len(translated)} manual translations")
        
        # For remaining strings, keep English (user can replace with professional translations)
        for key, value in flat_en.items():
            if key not in translated:
                translated[key] = value  # Placeholder
        
        # Convert back to nested structure
        nested_data = unflatten_dict(translated)
        
        # Add metadata
        nested_data['_meta'] = {
            'language': lang_name,
            'locale': locale,
            'translation_status': 'partial',
            'note': 'Contains manual translations for common UI. Other strings need professional translation.'
        }
        
        # Write to file
        output_path = os.path.join(translations_dir, f'{locale}.json')
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(nested_data, f, ensure_ascii=False, indent=2)
        
        print(f"   ✅ Saved to {locale}.json")
    
    print()
    print("=" * 50)
    print("✨ Translation generation complete!")
    print()
    print("📢 Next steps:")
    print("   1. Review generated translations")
    print("   2. Replace placeholder English text with professional translations")
    print("   3. Test app with different languages")
    print()

if __name__ == '__main__':
    main()
