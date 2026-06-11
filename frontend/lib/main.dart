import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_layout.dart';
import 'screens/storage_setup_screen.dart';
import 'services/storage_settings_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PetHealthApp(),
    ),
  );
}

class PetHealthApp extends ConsumerWidget {
  const PetHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storageSettingsProvider);

    return MaterialApp(
      title: '智慧成長觀測站',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Keep cozy warm cream theme consistent on all systems
      home: settings.isConfigured ? const MainLayout() : const StorageSetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
