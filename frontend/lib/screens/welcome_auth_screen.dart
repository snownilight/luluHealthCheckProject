import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_settings_provider.dart';

class WelcomeAuthScreen extends ConsumerStatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  ConsumerState<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends ConsumerState<WelcomeAuthScreen> {
  bool _isLoading = false;

  Future<void> _handleLocalMode() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final settingsNotifier = ref.read(storageSettingsProvider.notifier);
      await settingsNotifier.setStorageMode(StorageMode.local);
      await settingsNotifier.setConfigured(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已啟用本地 SQLite 儲存！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定本地模式失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await ref.read(googleUserProvider.notifier).signIn();
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google 登入取消或失敗。')),
          );
        }
        return;
      }
      
      // If login succeeded, AppStartRouter will automatically redirect the user:
      // - To MainLayout if they already have a sheet linked in settings.
      // - To StorageSetupScreen if they don't have a sheet linked yet.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登入成功: ${user.email}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 登入失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161210) : const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative circles
            if (!isDark) ...[
              // Top-right orange circle
              Positioned(
                right: -80,
                top: -80,
                child: Opacity(
                  opacity: 0.56,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD9A7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Center-left mint green circle
              Positioned(
                left: -60,
                bottom: 120,
                child: Opacity(
                  opacity: 0.44,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC8EEDC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],

            // Main Content Layout
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    
                    // Logo and Brand Name
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF261D1A) : const Color(0xFFFFF0DC),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8875C),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8875C).withOpacity(isDark ? 0.08 : 0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          size: 64,
                          color: Color(0xFFE8875C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '智慧成長觀測站',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF39291F),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '串聯全家人的貓咪照護聯絡簿\n輕鬆監測體重、進食與飲水狀況',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Option Buttons
                    _buildOptionButton(
                      title: '登入 Google 雲端同步',
                      subtitle: '資料儲存於雲端試算表，方便家人共用',
                      icon: Icons.cloud_done_outlined,
                      backgroundColor: const Color(0xFFE8875C),
                      foregroundColor: Colors.white,
                      onPressed: _handleGoogleLogin,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionButton(
                      title: '離線使用（本機模式）',
                      subtitle: '資料僅存於此裝置，安全無須網路',
                      icon: Icons.phonelink_lock_outlined,
                      backgroundColor: isDark ? const Color(0xFF261D1A) : Colors.white,
                      foregroundColor: isDark ? Colors.white : const Color(0xFF39291F),
                      borderColor: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFF5EBE6),
                      onPressed: _handleLocalMode,
                      isDark: isDark,
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      '隨時可在「設定」中變更資料庫儲存來源',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[600] : const Color(0xFFC7B1A5),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Loading Mask
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Card(
                      color: isDark ? const Color(0xFF261D1A) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8875C)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '請稍候...',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF35261D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          if (backgroundColor == Colors.white)
            BoxShadow(
              color: const Color(0xFF35261D).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: foregroundColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: foregroundColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: foregroundColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: foregroundColor.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
