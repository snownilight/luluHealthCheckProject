import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pet_status_provider.dart';
import '../services/api_service.dart';


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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFFFF8F0),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '早安，Luna 的家人',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFC49A7A) : const Color(0xFF8B5E3C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '智慧成長觀測站',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF39291F),
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
                        child: _StatGridCard(
                          title: '活動',
                          value: '${status.todayActivityMin.toStringAsFixed(0)}分',
                          status: status.todayActivityMin >= 30 ? '活躍' : '偏低',
                          backgroundColor: const Color(0xFFE6F7EA),
                          titleColor: const Color(0xFF39845C),
                          statusColor: const Color(0xFF7B6759),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Preventative Care Card
                  _PreventativeCareCard(waterIntake: status.todayWaterIntakeMl),
                  const SizedBox(height: 24),

                  // 家庭照護聯絡簿 Title
                  Text(
                    '家庭照護聯絡簿',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D291E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    color: isDark ? Colors.white24 : const Color(0xFFFFE9D6),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Timeline list
                  const _CareTimelineList(),
                  const SizedBox(height: 24),

                  // 成長觀測 Title & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '成長觀測',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF3D291E),
                        ),
                      ),
                      Text(
                        '7 天體重',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFFFA27A) : const Color(0xFFE8875C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weight Trend Card
                  _WeightTrendCard(currentWeight: status.lastWeightKg),
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
      height: 86,
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
      height: 176,
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

class _CareTimelineList extends ConsumerWidget {
  const _CareTimelineList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(careLogsProvider);

    return logsAsync.when(
      data: (logs) {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfToday = startOfToday.add(const Duration(days: 1));

        final todayLogs = logs.where((log) {
          final timestampStr = log['eventTimestamp'] ?? '';
          final timestamp = DateTime.tryParse(timestampStr)?.toLocal();
          if (timestamp == null) return false;
          return timestamp.isAtSameMomentAs(startOfToday) ||
              (timestamp.isAfter(startOfToday) && timestamp.isBefore(endOfToday));
        }).toList();

        if (todayLogs.isEmpty) {
          return const _EmptyCareTimeline();
        }

        // Show the latest 5 logs of today
        final displayLogs = todayLogs.take(5).toList();
        return Column(
          children: List.generate(displayLogs.length, (index) {
            final log = displayLogs[index];
            final type = log['eventType'] ?? 'Unknown';
            final value = log['value'];
            final unit = log['unit'] ?? '';
            final note = log['note'] ?? '';
            final timestampStr = log['eventTimestamp'] ?? '';
            final timestamp = DateTime.tryParse(timestampStr)?.toLocal() ?? DateTime.now();
            final formattedTime = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

            // Translate type
            String title = '';
            switch (type.toString().toUpperCase()) {
              case 'FEEDING':
                title = '進食時間';
                break;
              case 'DRINKING':
                title = '飲水時間';
                break;
              case 'WEIGHT':
                title = '體重測量';
                break;
              case 'EXCRETION':
                title = '排泄紀錄';
                break;
              case 'ACTIVITY':
                title = '活動時間';
                break;
              default:
                title = type.toString();
            }

            // Construct description
            String description = '';
            if (value != null) {
              description += '$value$unit';
            }
            if (note.toString().isNotEmpty) {
              if (description.isNotEmpty) {
                description += '，';
              }
              description += note.toString();
            }
            if (description.isEmpty) {
              description = '無備註';
            }

            return _TimelineItem(
              time: formattedTime,
              title: title,
              description: description,
              isLast: index == displayLogs.length - 1,
            );
          }),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8875C)),
          ),
        ),
      ),
      error: (err, stack) => const _EmptyCareTimeline(),
    );
  }
}

class _EmptyCareTimeline extends StatelessWidget {
  const _EmptyCareTimeline();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF261D1A) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFFFE9D6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFFFF0DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFE8875C),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '今日尚未有任何紀錄',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3A2A20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '點擊底部的「聯絡簿」頁面新增一筆照顧紀錄吧！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : const Color(0xFF8A7566),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final String description;
  final bool isLast;

  const _TimelineItem({
    required this.time,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: dot & dashed line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 6),
                // Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8875C),
                    shape: BoxShape.circle,
                  ),
                ),
                // Dotted line
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      size: const Size(1.5, double.infinity),
                      painter: _DashedLinePainter(
                        color: const Color(0xFFFFE9D6),
                        strokeWidth: 1.5,
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Right side: title and description
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$time $title',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3A2A20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A7566),
                    ),
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

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedLinePainter({
    required this.color,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double dashHeight = 2.0;
    const double dashGap = 2.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreventativeCareCard extends StatelessWidget {
  final double waterIntake;

  const _PreventativeCareCard({required this.waterIntake});

  @override
  Widget build(BuildContext context) {
    final bool lowWater = waterIntake < 150;
    final String tipTitle = lowWater ? '建議可放置「副食罐」或「肉泥」' : '今日水分攝取充足！';
    final String tipDesc = lowWater ? '增加貓咪的被動水分攝取，目前水位偏低。' : '非常棒！繼續保持良好的飲水習慣，可適度給予主食罐獎勵。';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE9D6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0DC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFD56C44),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '防禦性照顧提醒',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D291E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '依據今日飲水狀態推薦',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB08F79),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D291E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipDesc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7E6A5C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightTrendCard extends StatelessWidget {
  final double currentWeight;

  const _WeightTrendCard({required this.currentWeight});

  @override
  Widget build(BuildContext context) {
    // Generate a beautiful mock trend list where the last element matches currentWeight
    final List<double> weights = [
      currentWeight - 0.2,
      currentWeight - 0.18,
      currentWeight - 0.15,
      currentWeight - 0.16,
      currentWeight - 0.12,
      currentWeight - 0.10,
      currentWeight,
    ];

    return Container(
      width: double.infinity,
      height: 114,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF35261D).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left text details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '目前體重',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB08F79),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${currentWeight.toStringAsFixed(1)}kg',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF33261D),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '較上週 -0.1kg',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B9D70),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Right Sparkline graph
          SizedBox(
            width: 158,
            height: 58,
            child: CustomPaint(
              painter: _SparklinePainter(values: weights),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;

  _SparklinePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double valRange = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final int len = values.length;
    final double dx = size.width / (len - 1);

    final path = Path();
    final fillPath = Path();

    // Map each value to a point
    // Note: visually higher means lower y coordinate in Flutter canvas
    List<Offset> points = [];
    for (int i = 0; i < len; i++) {
      final double x = i * dx;
      // Normalize value to 0..1, then map to size.height (leaving some padding top and bottom)
      final double normalized = (values[i] - minVal) / valRange;
      // Invert since higher value is higher up (smaller y)
      final double y = size.height - (normalized * (size.height - 10) + 5);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < len; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw background gradient
    fillPath.moveTo(points[0].dx, size.height);
    for (int i = 0; i < len; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points[len - 1].dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE8875C).withOpacity(0.25),
          const Color(0xFFE8875C).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw main path
    final linePaint = Paint()
      ..color = const Color(0xFFE8875C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Draw last point circle
    final lastPoint = points.last;
    final dotPaint = Paint()
      ..color = const Color(0xFFE8875C)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(lastPoint, 4, dotPaint);
    canvas.drawCircle(lastPoint, 4, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
