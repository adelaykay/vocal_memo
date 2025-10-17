import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocal_memo/providers/settings_provider.dart';
import 'package:vocal_memo/screens/settings_screen.dart';
import 'package:vocal_memo/services/settings_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await SettingsService.init();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Vocal Memo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _toThemeMode(settings.themeMode),
      home: _showOnboarding
          ? OnboardingScreen(
              onComplete: () => setState(() => _showOnboarding = false),
            )
          : const HomeScreen(),
      routes: {'/settings': (context) => const SettingsScreen()},
    );
  }
  ThemeMode _toThemeMode(String mode) {
    switch (mode) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
