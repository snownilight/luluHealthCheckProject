import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              // Top-right circle (mint green)
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
              // Bottom-left circle (peach)
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

          // Settings Options
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
            itemBuilder: (context, index) => tiles[index],
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
