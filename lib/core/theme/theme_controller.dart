import 'package:flutter/material.dart';

/// Theme controller that can be accessed from anywhere in the widget tree
class ThemeController extends InheritedWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const ThemeController({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeController>();
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}
