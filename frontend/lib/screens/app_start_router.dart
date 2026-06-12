import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_settings_provider.dart';
import 'main_layout.dart';
import 'storage_setup_screen.dart';
import 'welcome_auth_screen.dart';

class AppStartRouter extends ConsumerStatefulWidget {
  const AppStartRouter({super.key});

  @override
  ConsumerState<AppStartRouter> createState() => _AppStartRouterState();
}

class _AppStartRouterState extends ConsumerState<AppStartRouter> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check for saved Google credentials silently
      await ref.read(googleUserProvider.notifier).checkSilentSignIn();
    } catch (e) {
      print('[AppStartRouter] Silent sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const _SplashLoadingScreen();
    }

    final settings = ref.watch(storageSettingsProvider);
    final googleUser = ref.watch(googleUserProvider);

    // If Google Sheets mode is selected and was previously configured
    if (settings.isConfigured && settings.mode == StorageMode.googleSheets) {
      if (googleUser == null) {
        // Session expired or needs authorization on reload
        return const _GoogleReauthScreen();
      } else if (settings.spreadsheetId != null) {
        return const MainLayout();
      } else {
        return const StorageSetupScreen();
      }
    }

    // 1-1. Google login is active (e.g. during fresh onboarding setup)
    if (googleUser != null) {
      if (settings.mode == StorageMode.googleSheets && settings.spreadsheetId != null) {
        // 1-1-1. Has Google Sheet linked, load data and show main layout
        return const MainLayout();
      } else {
        // 1-1-2. No Google Sheet configured, guide to storage onboarding
        return const StorageSetupScreen();
      }
    }

    // 1-2. Google login is NOT active
    if (settings.isConfigured && settings.mode == StorageMode.local) {
      // User has explicitly chosen local SQLite storage offline
      return const MainLayout();
    }

    // New user with no configuration and no Google session
    return const WelcomeAuthScreen();
  }
}

class _GoogleReauthScreen extends ConsumerStatefulWidget {
  const _GoogleReauthScreen();

  @override
  ConsumerState<_GoogleReauthScreen> createState() => _GoogleReauthScreenState();
}

class _GoogleReauthScreenState extends ConsumerState<_GoogleReauthScreen> {
  bool _isConnecting = false;

  Future<void> _handleReauth() async {
    setState(() {
      _isConnecting = true;
    });
    try {
      final user = await ref.read(googleUserProvider.notifier).signIn();
      if (user != null) {
        print('[GoogleReauth] Successfully signed in interactively.');
      }
    } catch (e) {
      print('[GoogleReauth] Interactive sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161210) : const Color(0xFFFFF8F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261D1A) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFFFE9D6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF35261D).withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFFFF0DC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Color(0xFFE8875C),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '需要驗證 Google 帳戶',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF3A2A20),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '您目前設定的儲存庫為 Google 試算表。為了讀取最新資料，請點擊下方按鈕以重新連結您的 Google 帳戶。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isConnecting ? null : _handleReauth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8875C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isConnecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(
                      _isConnecting ? '正在連結...' : '驗證並登入 Google',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    // Reset configuration so they can choose a different storage type if they wish
                    await ref.read(storageSettingsProvider.notifier).setConfigured(false);
                    await ref.read(storageSettingsProvider.notifier).setStorageMode(StorageMode.local);
                  },
                  child: Text(
                    '切換為其他儲存模式',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFE8875C) : const Color(0xFFC86C43),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLoadingScreen extends StatelessWidget {
  const _SplashLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161210) : const Color(0xFFFFF8F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF261D1A) : const Color(0xFFFFF0DC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE8875C),
                  width: 2.0,
                ),
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 48,
                color: Color(0xFFE8875C),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8875C)),
            ),
            const SizedBox(height: 16),
            Text(
              '正在確認登入與儲存庫狀態...',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
