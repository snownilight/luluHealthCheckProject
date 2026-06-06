import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_settings_provider.dart';

class StorageSetupScreen extends ConsumerStatefulWidget {
  const StorageSetupScreen({super.key});

  @override
  ConsumerState<StorageSetupScreen> createState() => _StorageSetupScreenState();
}

class _StorageSetupScreenState extends ConsumerState<StorageSetupScreen> {
  bool _isLoading = false;
  String? _loadingMessage;

  void _showLoading(String message) {
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });
  }

  Future<void> _setupLocalStorage() async {
    _showLoading('正在初始化本地資料庫...');
    try {
      await ref.read(storageSettingsProvider.notifier).setStorageMode(StorageMode.local);
      await ref.read(storageSettingsProvider.notifier).setConfigured(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('成功啟用本地 SQLite 儲存！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定失敗: $e')),
        );
      }
    } finally {
      _hideLoading();
    }
  }

  Future<void> _setupCreateNewSheet() async {
    _showLoading('正在登入 Google 帳號...');
    try {
      final googleRepo = ref.read(googleSheetsPetRepositoryProvider);
      final account = await googleRepo.signIn();
      if (account == null) {
        _hideLoading();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google 登入取消或失敗。')),
          );
        }
        return;
      }

      setState(() {
        _loadingMessage = '正在雲端硬碟建立試算表...';
      });

      final settings = ref.read(storageSettingsProvider);
      final sheetTitle = settings.spreadsheetTitle ?? 'MyPetHealth';
      final spreadsheetId = await googleRepo.createNewSpreadsheet(sheetTitle);

      if (spreadsheetId == null) {
        _hideLoading();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('無法在 Google Drive 建立試算表，請確認權限。')),
          );
        }
        return;
      }

      await ref.read(storageSettingsProvider.notifier).setSpreadsheetId(spreadsheetId);
      await ref.read(storageSettingsProvider.notifier).setStorageMode(StorageMode.googleSheets);
      await ref.read(storageSettingsProvider.notifier).setConfigured(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功建立雲端試算表：$sheetTitle！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定失敗: $e')),
        );
      }
    } finally {
      _hideLoading();
    }
  }

  void _showLinkSheetBottomSheet() {
    final TextEditingController urlController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String? extractSpreadsheetId(String urlOrId) {
      if (urlOrId.contains('docs.google.com/spreadsheets/d/')) {
        final parts = urlOrId.split('docs.google.com/spreadsheets/d/');
        if (parts.length > 1) {
          final subParts = parts[1].split('/');
          if (subParts.isNotEmpty) {
            return subParts[0];
          }
        }
      }
      return urlOrId.trim();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1715) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '連結已有 Google 試算表',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF35261D),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '請登入含有該試算表共用權限的 Google 帳號，並貼上試算表連結或 ID。我們會自動驗證您是否擁有編輯（寫入）權限。',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: urlController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Google 試算表網址或 ID',
                    labelStyle: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF8A7566)),
                    hintText: 'https://docs.google.com/spreadsheets/d/...',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8875C), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '請輸入網址或 ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(context); // Close sheet

                    final input = urlController.text.trim();
                    final sheetId = extractSpreadsheetId(input);

                    _showLoading('正在登入 Google 帳號...');
                    try {
                      final googleRepo = ref.read(googleSheetsPetRepositoryProvider);
                      final account = await googleRepo.signIn();
                      if (account == null) {
                        _hideLoading();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google 登入取消或失敗。')),
                          );
                        }
                        return;
                      }

                      if (sheetId == null || sheetId.isEmpty) {
                        _hideLoading();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('無效的試算表連結或 ID。')),
                          );
                        }
                        return;
                      }

                      setState(() {
                        _loadingMessage = '正在檢查試算表寫入權限...';
                      });

                      final hasWritePermission = await googleRepo.checkWritePermission(sheetId);
                      if (!hasWritePermission) {
                        _hideLoading();
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('權限驗證失敗'),
                              content: const Text('您對該試算表不具備編輯（寫入）權限，請確認是否為該檔案的擁有者或共同編輯者，或確認連結是否正確。'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('確定', style: TextStyle(color: Color(0xFFE8875C))),
                                ),
                              ],
                            ),
                          );
                        }
                        return;
                      }

                      await ref.read(storageSettingsProvider.notifier).setSpreadsheetId(sheetId);
                      await ref.read(storageSettingsProvider.notifier).setStorageMode(StorageMode.googleSheets);
                      await ref.read(storageSettingsProvider.notifier).setConfigured(true);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('成功連結雲端試算表！')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('設定失敗: $e')),
                        );
                      }
                    } finally {
                      _hideLoading();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8875C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('驗證並連結', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161210) : const Color(0xFFFFFDFB),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative circles
            if (!isDark) ...[
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8EEDC).withOpacity(0.44),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -80,
                bottom: -20,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9A7).withOpacity(0.48),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],

            // Main Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Logo/Greeting
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0DC),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE8875C), width: 2),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 32,
                          color: Color(0xFFE8875C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '設定儲存庫來源',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF35261D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '選擇您喜好的照護與體重資料儲存方式',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Cards options
                    Expanded(
                      child: ListView(
                        children: [
                          _buildOptionCard(
                            title: '儲存於此裝置',
                            description: '將所有照護紀錄儲存於本地 SQLite 資料庫。無需網路連線，資料隱私百分百安全。',
                            icon: Icons.phonelink_ring_outlined,
                            accentColor: const Color(0xFF76C893),
                            onTap: _setupLocalStorage,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildOptionCard(
                            title: '建立線上 Google 試算表',
                            description: '登入 Google 帳號，為您在 Google 雲端硬碟建立一個新的 MyPetHealth 試算表，方便與家人共享。',
                            icon: Icons.grid_on_outlined,
                            accentColor: const Color(0xFFE8875C),
                            onTap: _setupCreateNewSheet,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildOptionCard(
                            title: '連結已有 Google 試算表',
                            description: '貼上已存在的 Google 試算表連結。我們會驗證您帳號的編輯寫入權限，與家人共用同一份資料。',
                            icon: Icons.link_outlined,
                            accentColor: const Color(0xFF9B5DE5),
                            onTap: _showLinkSheetBottomSheet,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading HUD
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Card(
                      color: isDark ? const Color(0xFF261D1A) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8875C)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _loadingMessage ?? '請稍候...',
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

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF261D1A) : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFF5EBE6),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: const Color(0xFF35261D).withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF35261D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[600] : const Color(0xFFC7B1A5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
