import 'package:flutter/material.dart';

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
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'FallSafe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          // Provide controller to children via a builder or provider if not using a library.
          // Since we aren't using Provider package, we can just pass it or use a simple InheritedWidget wrapper.
          // Given the size, I'll wrap HomeScreen in a simple InheritedWidget or just pass it?
          // Actually, let's keep the InheritedWidget approach but wrapping the ChangeNotifier.
          builder: (context, child) {
            return ThemeProvider(controller: _themeController, child: child!);
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
