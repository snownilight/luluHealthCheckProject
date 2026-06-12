import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/app_start_router.dart';
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
    return MaterialApp(
      title: '智慧成長觀測站',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Keep cozy warm cream theme consistent on all systems
      home: const AppStartRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}
