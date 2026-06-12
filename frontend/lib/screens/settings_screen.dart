import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_settings_provider.dart';
import '../services/api_service.dart';
import '../services/pet_status_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _titleController;
  bool _isSavingTitle = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(storageSettingsProvider);
    _titleController = TextEditingController(text: settings.spreadsheetTitle ?? 'MyPetHealth');

    // Attempt silent sign-in to restore credentials if using Google Sheets
    if (settings.mode == StorageMode.googleSheets && ref.read(googleUserProvider) == null) {
      ref.read(googleUserProvider.notifier).checkSilentSignIn();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _updateSheetTitle() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) return;

    setState(() {
      _isSavingTitle = true;
    });

    try {
      await ref.read(storageSettingsProvider.notifier).setSpreadsheetTitle(newTitle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('試算表檔名設定已更新！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingTitle = false;
        });
      }
    }
  }

  String _getStorageModeText(StorageMode mode) {
    switch (mode) {
      case StorageMode.local:
        return '本機 SQLite 資料庫 (離線)';
      case StorageMode.googleSheets:
        return 'Google 雲端試算表 (雲端同步)';
      case StorageMode.server:
        return '遠端 Spring Boot 伺服器';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(storageSettingsProvider);
    final googleUser = ref.watch(googleUserProvider);

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
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Pet Profile Card
                  Container(
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          const _CatAvatarWidget(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'O-Lulu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF35261D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '體重：4.8 kg | 貓咪',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFFE8875C),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('編輯資料功能即將推出！')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Database & Backup settings
                  _buildSettingsGroup(
                    context,
                    '資料庫與備份設定',
                    [
                      ListTile(
                        leading: const Icon(Icons.storage_outlined, color: Color(0xFFE8875C)),
                        title: Text(
                          '儲存模式',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF3A2A20),
                          ),
                        ),
                        subtitle: Text(
                          _getStorageModeText(settings.mode),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE8875C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            // Reset configured state to open onboarding setup screen
                            await ref.read(storageSettingsProvider.notifier).setConfigured(false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8875C).withOpacity(0.12),
                            foregroundColor: const Color(0xFFE8875C),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('切換模式', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (settings.mode == StorageMode.googleSheets) ...[
                        ListTile(
                          leading: const Icon(Icons.account_circle_outlined, color: Color(0xFFE8875C)),
                          title: Text(
                            'Google 帳號連線',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF3A2A20),
                            ),
                          ),
                          subtitle: Text(
                            googleUser != null ? googleUser.email : '未登入',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              if (googleUser != null) {
                                await ref.read(googleUserProvider.notifier).signOut();
                                ref.invalidate(careLogsProvider);
                                ref.read(petStatusProvider.notifier).refreshStatus();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已登出 Google 帳號。')),
                                );
                              } else {
                                final account = await ref.read(googleUserProvider.notifier).signIn();
                                if (account != null) {
                                  ref.invalidate(careLogsProvider);
                                  ref.read(petStatusProvider.notifier).refreshStatus();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('登入成功: ${account.email}')),
                                  );
                                }
                              }
                            },
                            child: Text(
                              googleUser != null ? '登出' : '登入',
                              style: const TextStyle(color: Color(0xFFE8875C), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '雲端試算表檔名設定',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : const Color(0xFF3A2A20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _titleController,
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE8875C), width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _isSavingTitle ? null : _updateSheetTitle,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE8875C),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSavingTitle
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('變更檔名', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Systems Settings
                  _buildSettingsGroup(
                    context,
                    '系統設定',
                    [
                      _buildSettingsTile(
                        context,
                        icon: Icons.pets_outlined,
                        title: '寵物資料設定',
                        subtitle: '編輯 O-Lulu 的基本資料與監測目標',
                        onTap: () {
                          _showFeaturePlaceholder(context, '寵物資料設定');
                        },
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.notifications_none_outlined,
                        title: '通知與警報管理',
                        subtitle: '自訂脫水警報與每日進食提醒',
                        onTap: () {
                          _showFeaturePlaceholder(context, '通知與警報管理');
                        },
                      ),
                      _buildSettingsTile(
                        context,
                        icon: Icons.share_outlined,
                        title: '家庭成員共享',
                        subtitle: '邀請其他家庭成員共同編輯聯絡簿',
                        onTap: () {
                          _showFeaturePlaceholder(context, '家庭成員共享');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildSettingsGroup(
                    context,
                    '關於',
                    [
                      _buildSettingsTile(
                        context,
                        icon: Icons.info_outline,
                        title: '關於智慧觀測站',
                        subtitle: '版本 v1.0.0 (已連接後端主機)',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: '智慧成長觀測站',
                            applicationVersion: 'v1.0.0',
                            applicationIcon: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0DC),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE8875C), width: 1.5),
                              ),
                              child: CustomPaint(
                                painter: _CatFacePainter(
                                  earColor: const Color(0xFFE8875C),
                                  faceColor: Colors.white,
                                  eyeColor: const Color(0xFF3A2A20),
                                  blushColor: const Color(0xFFFFD2C3),
                                ),
                              ),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text(
                                  '本系統提供寵物健康即時追蹤，包含體重監測、進食及飲水分析，並透過家庭聯絡簿串聯全家人的照護動態。',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String groupTitle, List<Widget> tiles) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            groupTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF8A7566),
            ),
          ),
        ),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFF5EBE6),
            ),
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isLast = index == tiles.length - 1;
              BorderRadius? borderRadius;
              if (isFirst && isLast) {
                borderRadius = BorderRadius.circular(24);
              } else if (isFirst) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(24));
              } else if (isLast) {
                borderRadius = const BorderRadius.vertical(bottom: Radius.circular(24));
              }
              return Material(
                color: Colors.transparent,
                clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
                borderRadius: borderRadius,
                child: tiles[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE8875C)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF3A2A20),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: isDark ? Colors.grey[600] : const Color(0xFFC7B1A5),
      ),
      onTap: onTap,
    );
  }

  void _showFeaturePlaceholder(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「$featureName」功能即將推出，敬請期待！')),
    );
  }
}

class _CatAvatarWidget extends StatefulWidget {
  const _CatAvatarWidget();

  @override
  State<_CatAvatarWidget> createState() => _CatAvatarWidgetState();
}

class _CatAvatarWidgetState extends State<_CatAvatarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0DC),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE8875C),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8875C).withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CatFacePainter(
            earColor: const Color(0xFFE8875C),
            faceColor: Colors.white,
            eyeColor: const Color(0xFF3A2A20),
            blushColor: const Color(0xFFFFD2C3),
          ),
        ),
      ),
    );
  }
}

class _CatFacePainter extends CustomPainter {
  final Color earColor;
  final Color faceColor;
  final Color eyeColor;
  final Color blushColor;

  _CatFacePainter({
    required this.earColor,
    required this.faceColor,
    required this.eyeColor,
    required this.blushColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw Ears
    final earPathLeft = Path()
      ..moveTo(cx - 20, cy - 10)
      ..lineTo(cx - 22, cy - 28)
      ..lineTo(cx - 6, cy - 18)
      ..close();
    paint.color = earColor;
    canvas.drawPath(earPathLeft, paint);

    final earPathRight = Path()
      ..moveTo(cx + 20, cy - 10)
      ..lineTo(cx + 22, cy - 28)
      ..lineTo(cx + 6, cy - 18)
      ..close();
    canvas.drawPath(earPathRight, paint);

    // Inner ears
    final innerEarLeft = Path()
      ..moveTo(cx - 18, cy - 12)
      ..lineTo(cx - 19, cy - 24)
      ..lineTo(cx - 8, cy - 17)
      ..close();
    paint.color = blushColor;
    canvas.drawPath(innerEarLeft, paint);

    final innerEarRight = Path()
      ..moveTo(cx + 18, cy - 12)
      ..lineTo(cx + 19, cy - 24)
      ..lineTo(cx + 8, cy - 17)
      ..close();
    canvas.drawPath(innerEarRight, paint);

    // 2. Draw Face Shape
    paint.color = faceColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 3), width: 44, height: 34),
      paint,
    );

    // 3. Draw Eyes
    paint.color = eyeColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 8, cy + 2), 2.0, paint);
    canvas.drawCircle(Offset(cx + 8, cy + 2), 2.0, paint);

    // 4. Draw Blush
    paint.color = blushColor.withOpacity(0.7);
    canvas.drawCircle(Offset(cx - 13, cy + 6), 3.5, paint);
    canvas.drawCircle(Offset(cx + 13, cy + 6), 3.5, paint);

    // 5. Draw Nose & Mouth
    paint.color = earColor;
    // Small triangle nose
    final nosePath = Path()
      ..moveTo(cx - 1.5, cy + 3)
      ..lineTo(cx + 1.5, cy + 3)
      ..lineTo(cx, cy + 4.5)
      ..close();
    paint.style = PaintingStyle.fill;
    canvas.drawPath(nosePath, paint);

    // Mouth line (w)
    final mouthPaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(cx - 2, cy + 6)
      ..quadraticBezierTo(cx - 1, cy + 7.5, cx, cy + 6)
      ..quadraticBezierTo(cx + 1, cy + 7.5, cx + 2, cy + 6);
    canvas.drawPath(mouthPath, mouthPaint);

    // Whiskers
    final whiskerPaint = Paint()
      ..color = eyeColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    // Left whiskers
    canvas.drawLine(Offset(cx - 18, cy + 3), Offset(Offset(cx - 18, cy + 3).dx - 5, Offset(cx - 18, cy + 3).dy - 1), whiskerPaint);
    canvas.drawLine(Offset(cx - 18, cy + 5), Offset(Offset(cx - 18, cy + 5).dx - 5, Offset(cx - 18, cy + 5).dy + 1), whiskerPaint);
    // Right whiskers
    canvas.drawLine(Offset(cx + 18, cy + 3), Offset(Offset(cx + 18, cy + 3).dx + 5, Offset(cx + 18, cy + 3).dy - 1), whiskerPaint);
    canvas.drawLine(Offset(cx + 18, cy + 5), Offset(Offset(cx + 18, cy + 5).dx + 5, Offset(cx + 18, cy + 5).dy + 1), whiskerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
