import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await StorageService.init();

  runApp(const FallSafeApp());
}

class FallSafeApp extends StatefulWidget {
  const FallSafeApp({super.key});

  @override
  State<FallSafeApp> createState() => _FallSafeAppState();
}

class _FallSafeAppState extends State<FallSafeApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    // Update system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: _isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set initial system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        title: 'FallSafe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
