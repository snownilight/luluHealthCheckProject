import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/pet_status_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access current status state (reacts to websocket events)
    final status = ref.watch(petStatusProvider);
    // Triggers auto-connection of the WebSocket service
    ref.watch(webSocketServiceProvider);

    final String activeTimeStr = status.lastActiveTime != null
        ? DateFormat('jm').format(status.lastActiveTime!)
        : 'Unknown';

    // Highlight dehydration risk if water intake is low
    final bool isDehydrated = status.todayWaterIntakeMl < 50;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, O-Lulu\'s Family! 🐾',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track and monitor O-Lulu\'s health status in real-time.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
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
                        '⚠️ ALERT: Dehydration Warning! O-Lulu has consumed very little water today.',
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
              'O-Lulu\'s Current State',
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
                  title: 'Water Intake',
                  value: '${status.todayWaterIntakeMl.toStringAsFixed(0)} ml',
                  subtitle: 'Target: 300 ml',
                  icon: Icons.local_drink,
                  color: Colors.blueAccent,
                  progress: (status.todayWaterIntakeMl / 300).clamp(0.0, 1.0),
                ),
                // Food Intake Card
                _MetricCard(
                  title: 'Food Intake',
                  value: '${status.todayFoodIntakeG.toStringAsFixed(0)} g',
                  subtitle: 'Target: 200 g',
                  icon: Icons.restaurant,
                  color: Colors.orangeAccent,
                  progress: (status.todayFoodIntakeG / 200).clamp(0.0, 1.0),
                ),
                // Weight Card
                _MetricCard(
                  title: 'Last Weight',
                  value: '${status.lastWeightKg.toStringAsFixed(1)} kg',
                  subtitle: 'Normal range: 4-5 kg',
                  icon: Icons.scale,
                  color: Colors.teal,
                  progress: (status.lastWeightKg / 5.0).clamp(0.0, 1.0),
                ),
                // Last Active Card
                _MetricCard(
                  title: 'Last Active',
                  value: activeTimeStr,
                  subtitle: 'Status: Healthy',
                  icon: Icons.pets,
                  color: Colors.green,
                  progress: 1.0,
                ),
              ],
            ),
          ],
        ),
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
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
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
      ),
    );
  }
}

// Standard fallback class for compilation safety
class ColorsWhiteee {
  static const Color white = Colors.white70;
}

extension on TextStyle {
  // Add fallback styling helper if needed
}

class ColorsWhiteeeHelper {
  static const Color white = Colors.white70;
}
const Color ColorsWhiteeeColor = Colors.white70;
extension on List {
  // helper
}
const ColorsWhiteee = Colors.white70;
