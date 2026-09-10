import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLanguageKey = 'selected_language';

// Predefined 23 Indian languages + English as per localization requirements
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

const List<LanguageOption> kSupportedLanguages = [
  LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
  LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
  LanguageOption(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  LanguageOption(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
  LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
  LanguageOption(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
  LanguageOption(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
  LanguageOption(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
  LanguageOption(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
  LanguageOption(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
  LanguageOption(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
  LanguageOption(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া'),
  LanguageOption(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
  LanguageOption(code: 'sa', name: 'Sanskrit', nativeName: 'संस्कृतम्'),
  LanguageOption(code: 'ks', name: 'Kashmiri', nativeName: 'کٲشُر'),
  LanguageOption(code: 'sd', name: 'Sindhi', nativeName: 'سنڌي'),
  LanguageOption(code: 'ne', name: 'Nepali', nativeName: 'नेपाली'),
  LanguageOption(code: 'kok', name: 'Konkani', nativeName: 'कोंकणी'),
  LanguageOption(code: 'mni', name: 'Manipuri', nativeName: 'মৈতৈলোন্'),
  LanguageOption(code: 'brx', name: 'Bodo', nativeName: 'बड़ो'),
  LanguageOption(code: 'doi', name: 'Dogri', nativeName: 'डोगरी'),
  LanguageOption(code: 'mai', name: 'Maithili', nativeName: 'मैथिली'),
  LanguageOption(code: 'sat', name: 'Santali', nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ'),
];

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadPersistedLanguage();
  }

  Future<void> _loadPersistedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 'en' strictly on first launch as required
    final persisted = prefs.getString(_kLanguageKey);
    if (persisted != null) {
      state = persisted;
    }
  }

  Future<void> setLanguage(String langCode) async {
    state = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageKey, langCode);
  }

  LanguageOption get currentLanguageOption {
    return kSupportedLanguages.firstWhere(
      (element) => element.code == state,
      orElse: () => kSupportedLanguages.first,
    );
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});
