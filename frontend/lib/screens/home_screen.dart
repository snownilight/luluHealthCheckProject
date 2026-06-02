import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pet_status_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access current status state (reacts to websocket events)
    final status = ref.watch(petStatusProvider);
    // Triggers auto-connection of the WebSocket service
    ref.watch(webSocketServiceProvider);

    // Highlight dehydration risk if water intake is low
    final bool isDehydrated = status.todayWaterIntakeMl < 50;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          // Top-right warm orange circle: cx=318, cy=56, r=110, fill=#FFD9A7, opacity=.56
          Positioned(
            top: -54, // cy - r = 56 - 110
            right: -38, // (390 - cx) - r = 72 - 110
            child: Opacity(
              opacity: 0.56,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD9A7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Center-left mint green circle: cx=44, cy=190, r=75, fill=#C8EEDC, opacity=.44
          Positioned(
            top: 115, // cy - r = 190 - 75
            left: -31, // cx - r = 44 - 75
            child: Opacity(
              opacity: 0.44,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFFC8EEDC),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Bottom-right coral red circle: cx=342, cy=470, r=48, fill=#FFD2C3, opacity=.38
          Positioned(
            top: 422, // cy - r = 470 - 48
            right: 0, // (390 - cx) - r = 48 - 48
            child: Opacity(
              opacity: 0.38,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD2C3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title block
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '早安，Luna 的家人',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8B5E3C),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '智慧成長觀測站',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF39291F),
                            ),
                          ),
                        ],
                      ),
                      // Notification & Profile block
                      Row(
                        children: [
                          // Notification Box
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.94),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Styled mail/notification box
                                Container(
                                  width: 12,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9865B),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                // Red dot
                                Positioned(
                                  top: 10,
                                  right: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF45C50),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Avatar Container
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBFEAD8),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  // Face: r=9 (diameter=18). Center x=21, y=18.
                                  Positioned(
                                    top: 9,
                                    left: 12,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFE0C2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  // Body/Collar: width=24, height=12. Center x=21, y=31.
                                  Positioned(
                                    top: 31,
                                    left: 9,
                                    child: Container(
                                      width: 24,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6DAA91),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Warning Banner for Dehydration
                  if (isDehydrated)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '⚠️ 警報：脫水警告！O-Lulu 今天攝取的水分非常少。',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Real-time Status Card
                  const _RealTimeStatusCard(),
                  const SizedBox(height: 24),

                  // 3-Column Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatGridCard(
                          title: '飲水',
                          value: '${status.todayWaterIntakeMl.toStringAsFixed(0)}ml',
                          status: status.todayWaterIntakeMl >= 150 ? '安全' : '偏低',
                          backgroundColor: const Color(0xFFDDF4FF),
                          titleColor: const Color(0xFF3E91B8),
                          statusColor: const Color(0xFF7B6759),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _StatGridCard(
                          title: '進食',
                          value: '${(status.todayFoodIntakeG / 200 * 100).toStringAsFixed(0)}%',
                          status: '正常',
                          backgroundColor: const Color(0xFFFFF0D7),
                          titleColor: const Color(0xFFC97922),
                          statusColor: const Color(0xFF7B6759),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: const _StatGridCard(
                          title: '活動',
                          value: '38分',
                          status: '活躍',
                          backgroundColor: Color(0xFFE6F7EA),
                          titleColor: Color(0xFF39845C),
                          statusColor: Color(0xFF7B6759),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGridCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final Color backgroundColor;
  final Color titleColor;
  final Color statusColor;

  const _StatGridCard({
    required this.title,
    required this.value,
    required this.status,
    required this.backgroundColor,
    required this.titleColor,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF33261D),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RealTimeStatusCard extends StatelessWidget {
  const _RealTimeStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 158,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DC),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF35261D).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left side content
          Positioned(
            left: 20,
            top: 20,
            bottom: 16,
            right: 140, // leave space for cat illustration on the right
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '即時狀態',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD56C44),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Luna 今天很\n穩定',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF35261D),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '飲水、進食與活動量都在安全區間。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B6759),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // 剛剛同步 badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F7EE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF35B77D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '剛剛同步',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E7D5A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right side illustration
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 140,
            child: CustomPaint(
              painter: LunaIllustrationPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class LunaIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Orange background circle (cx = size.width - 92, cy=12, r=56, fill=#FFE1A8, opacity=.8)
    final bgPaint = Paint()
      ..color = const Color(0xFFFFE1A8).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 92, 12), 56, bgPaint);

    // 2. Ears: Left (cx = size.width - 148, cy=7, rx=14, ry=19) & Right (cx = size.width - 84, cy=7, rx=14, ry=19)
    final earPaint = Paint()
      ..color = const Color(0xFFD98757)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 148, 7), width: 28, height: 38), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 84, 7), width: 28, height: 38), earPaint);

    // 3. Bottom detail (cx = size.width - 108, cy=91, rx=34, ry=31)
    final bodyPaint = Paint()
      ..color = const Color(0xFFF2B879)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 108, 91), width: 68, height: 62), bodyPaint);

    // 4. Head/Face (cx = size.width - 118, cy=28, rx=43, ry=37)
    final headPaint = Paint()
      ..color = const Color(0xFFFFD29D)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 118, 28), width: 86, height: 74), headPaint);

    // 5. Muzzle/Mouth area (cx = size.width - 119, cy=63, rx=18, ry=12)
    final muzzlePaint = Paint()
      ..color = const Color(0xFFFFF5E8)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 119, 63), width: 36, height: 24), muzzlePaint);

    // 6. Eyes (cx = size.width - 135, cy=50, r=3) & (cx = size.width - 105, cy=50, r=3)
    final eyePaint = Paint()
      ..color = const Color(0xFF443226)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 135, 50), 3, eyePaint);
    canvas.drawCircle(Offset(size.width - 105, 50), 3, eyePaint);

    // 7. Nose (cx = size.width - 119, cy=65, rx=5, ry=4)
    final nosePaint = Paint()
      ..color = const Color(0xFF443226)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 119, 65), width: 10, height: 8), nosePaint);

    // 8. Fish/Tag detail (x = size.width - 54, y=94, width=28, height=11, rx=6)
    final tagPaint = Paint()
      ..color = const Color(0xFFF2B879)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 54, 94, 28, 11), const Radius.circular(6)), tagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
