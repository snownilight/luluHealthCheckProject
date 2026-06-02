import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/pet_status_provider.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access current status state (reacts to websocket events)
    final status = ref.watch(petStatusProvider);
    // Triggers auto-connection of the WebSocket service
    ref.watch(webSocketServiceProvider);

    final String activeTimeStr = status.lastActiveTime != null
        ? DateFormat('HH:mm').format(status.lastActiveTime!)
        : '無紀錄';

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

                  // Section Title
                  const Text(
                    'O-Lulu 的即時狀態',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metrics Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      // Water Intake Card
                      _MetricCard(
                        title: '今日飲水',
                        value: '${status.todayWaterIntakeMl.toStringAsFixed(0)} ml',
                        subtitle: '目標：300 ml',
                        icon: Icons.local_drink,
                        color: Colors.blueAccent,
                        progress: (status.todayWaterIntakeMl / 300).clamp(0.0, 1.0),
                      ),
                      // Food Intake Card
                      _MetricCard(
                        title: '今日進食',
                        value: '${status.todayFoodIntakeG.toStringAsFixed(0)} g',
                        subtitle: '目標：200 g',
                        icon: Icons.restaurant,
                        color: Colors.orangeAccent,
                        progress: (status.todayFoodIntakeG / 200).clamp(0.0, 1.0),
                      ),
                      // Weight Card
                      _MetricCard(
                        title: '目前體重',
                        value: '${status.lastWeightKg.toStringAsFixed(1)} kg',
                        subtitle: '正常範圍：4-5 kg',
                        icon: Icons.scale,
                        color: Colors.teal,
                        progress: (status.lastWeightKg / 5.0).clamp(0.0, 1.0),
                      ),
                      // Last Active Card
                      _MetricCard(
                        title: '最後活動',
                        value: activeTimeStr,
                        subtitle: '狀態：良好',
                        icon: Icons.pets,
                        color: Colors.green,
                        progress: 1.0,
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

// Custom widget representing a metric card
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Linear Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
              ),
            ),
          ],
        ),
    );
  }
}
