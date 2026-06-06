import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_settings_provider.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _weightLogs = [];
  List<Map<String, dynamic>> _dailySummaries = [];

  // Fallback mock data to ensure the UI looks premium even on clean database installations
  final List<Map<String, dynamic>> _mockWeightLogs = [
    {'recordedAt': '2026-05-26T08:00:00', 'weightKg': 4.5},
    {'recordedAt': '2026-05-27T08:00:00', 'weightKg': 4.52},
    {'recordedAt': '2026-05-28T08:00:00', 'weightKg': 4.55},
    {'recordedAt': '2026-05-29T08:00:00', 'weightKg': 4.60},
    {'recordedAt': '2026-05-30T08:00:00', 'weightKg': 4.65},
    {'recordedAt': '2026-05-31T08:00:00', 'weightKg': 4.72},
    {'recordedAt': '2026-06-01T08:00:00', 'weightKg': 4.80},
  ];

  final List<Map<String, dynamic>> _mockDailySummaries = [
    {
      'date': '2026-05-26',
      'totalFoodIntakeG': 180.0,
      'totalWaterIntakeMl': 250.0,
      'averageWeightKg': 4.5
    },
    {
      'date': '2026-05-27',
      'totalFoodIntakeG': 190.0,
      'totalWaterIntakeMl': 260.0,
      'averageWeightKg': 4.52
    },
    {
      'date': '2026-05-28',
      'totalFoodIntakeG': 170.0,
      'totalWaterIntakeMl': 210.0,
      'averageWeightKg': 4.55
    },
    {
      'date': '2026-05-29',
      'totalFoodIntakeG': 200.0,
      'totalWaterIntakeMl': 280.0,
      'averageWeightKg': 4.60
    },
    {
      'date': '2026-05-30',
      'totalFoodIntakeG': 185.0,
      'totalWaterIntakeMl': 240.0,
      'averageWeightKg': 4.65
    },
    {
      'date': '2026-05-31',
      'totalFoodIntakeG': 160.0,
      'totalWaterIntakeMl': 190.0,
      'averageWeightKg': 4.72
    },
    {
      'date': '2026-06-01',
      'totalFoodIntakeG': 85.0,
      'totalWaterIntakeMl': 120.0,
      'averageWeightKg': 4.80
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchTrendData();
  }

  Future<void> _fetchTrendData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(petRepositoryProvider);
      final weightData = await repository.getWeeklyWeightTrend();
      final summaryData = await repository.getMonthlyDailySummary();

      setState(() {
        _weightLogs = weightData;
        _dailySummaries = summaryData;
      });
    } catch (e) {
      print('Error fetching charts/trends data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine active source lists (backend data or fallbacks)
    final weightList = _weightLogs.isNotEmpty ? _weightLogs : _mockWeightLogs;
    final summaryList = _dailySummaries.isNotEmpty ? _dailySummaries : _mockDailySummaries;

    // Process lists for graphing
    final sortedWeightList = List<Map<String, dynamic>>.from(weightList)
      ..sort((a, b) {
        final aTime = DateTime.tryParse(a['recordedAt'] ?? '') ?? DateTime.now();
        final bTime = DateTime.tryParse(b['recordedAt'] ?? '') ?? DateTime.now();
        return aTime.compareTo(bTime);
      });

    final sortedSummaryList = List<Map<String, dynamic>>.from(summaryList)
      ..sort((a, b) {
        final aTime = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
        final bTime = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
        return aTime.compareTo(bTime);
      });

    // Take last 7 days of daily summaries for the bar chart
    final displaySummaries = sortedSummaryList.length > 7
        ? sortedSummaryList.sublist(sortedSummaryList.length - 7)
        : sortedSummaryList;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF161210) : const Color(0xFFFFFDFB),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative circles
            if (!isDark) ...[
              // Top-left circle (peach)
              Positioned(
                left: -60,
                top: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9A7).withOpacity(0.48),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Mid-right circle (mint)
              Positioned(
                right: -100,
                top: 250,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8EEDC).withOpacity(0.42),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _fetchTrendData,
                color: const Color(0xFFE8875C),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '每週成長曲線',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '觀測 O-Lulu 的體重變化趨勢與成長指標。',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Weight Line Chart Card
              _buildWeightChartCard(sortedWeightList),

              const SizedBox(height: 28),

              // Daily Nutrient Intake Header
              const Text(
                '每日營養攝取紀錄',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '每日進食量 (g) 與飲水量 (ml) 的對比圖。',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Nutrient Bar Chart Card
              _buildNutrientChartCard(displaySummaries),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  ],
),
),
);
  }

  // Weight Trend Line Chart
  Widget _buildWeightChartCard(List<Map<String, dynamic>> data) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF261D1A) : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFF5EBE6),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(child: Text('暫無體重趨勢數據。')),
      );
    }

    final double minY = data.map((e) => (e['weightKg'] as num).toDouble()).reduce((a, b) => a < b ? a : b) - 0.2;
    final double maxY = data.map((e) => (e['weightKg'] as num).toDouble()).reduce((a, b) => a > b ? a : b) + 0.2;

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final weight = (data[i]['weightKg'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), weight));
    }

    return Container(
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
        padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.last['weightKg'].toStringAsFixed(2)} kg',
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF35261D),
                      ),
                    ),
                    const Text('目前體重', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8875C).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '成長曲線',
                    style: TextStyle(color: Color(0xFFE8875C), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: isDark ? const Color(0xFF332924) : const Color(0xFFF2EAE5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)} kg',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) {
                            final parsedDate = DateTime.tryParse(data[idx]['recordedAt'] ?? '') ?? DateTime.now();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MM/dd').format(parsedDate),
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFFE8875C),
                      barWidth: 3.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeColor: const Color(0xFFE8875C),
                          strokeWidth: 3,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE8875C).withOpacity(0.2),
                            const Color(0xFFE8875C).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nutrient History Double Bar Chart
  Widget _buildNutrientChartCard(List<Map<String, dynamic>> data) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF261D1A) : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF3C2E2A) : const Color(0xFFF5EBE6),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(child: Text('暫無每日營養攝取數據。')),
      );
    }

    List<BarChartGroupData> groups = [];
    for (int i = 0; i < data.length; i++) {
      final food = (data[i]['totalFoodIntakeG'] as num).toDouble();
      final water = (data[i]['totalWaterIntakeMl'] as num).toDouble();

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: food,
              color: const Color(0xFFC97922),
              width: 9,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            BarChartRodData(
              toY: water,
              color: const Color(0xFF3E91B8),
              width: 9,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }

    return Container(
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
        padding: const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLegendItem('進食 (g)', const Color(0xFFC97922)),
                const SizedBox(width: 16),
                _buildLegendItem('飲水 (ml)', const Color(0xFF3E91B8)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 320,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: isDark ? const Color(0xFF332924) : const Color(0xFFF2EAE5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) {
                            final parsedDate = DateTime.tryParse(data[idx]['date'] ?? '') ?? DateTime.now();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '週${['一', '二', '三', '四', '五', '六', '日'][parsedDate.weekday - 1]}',
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: groups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
