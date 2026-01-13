import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

/// Theme controller using ChangeNotifier for state management
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeController() : _themeMode = ThemeMode.system {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadTheme() {
    _themeMode = StorageService.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    // Cycle: System -> Light -> Dark -> System (or just Light <-> Dark for simplicity as requested often)
    // User asked to fix "isDark" bad practices.
    // Let's implement a simple Light <-> Dark toggle for the button,
    // effectively overriding system default once toggled.

    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _themeMode = brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    }

    await StorageService.saveThemeMode(_themeMode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.saveThemeMode(mode);
    notifyListeners();
  }

  static ThemeController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>()!
        .controller;
  }
}

class ThemeProvider extends InheritedWidget {
  final ThemeController controller;

  const ThemeProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
