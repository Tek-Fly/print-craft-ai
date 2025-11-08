import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }
  
  Future<void> _loadTheme() async {
    final savedTheme = await StorageService.getString(_themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    String themeString;
    switch (mode) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.light:
        themeString = 'light';
        break;
      default:
        themeString = 'system';
    }
    
    await StorageService.setString(_themeKey, themeString);
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, default to opposite of current system theme
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      await setThemeMode(
        brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light
      );
    }
  }
}
