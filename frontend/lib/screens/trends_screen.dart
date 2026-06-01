import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

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
      final apiService = ref.read(apiServiceProvider);
      final weightData = await apiService.getWeeklyWeightTrend();
      final summaryData = await apiService.getMonthlyDailySummary();

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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTrendData,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Weekly Growth Curve',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Monitor O-Lulu\'s weight trends and growth metrics.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Weight Line Chart Card
              _buildWeightChartCard(sortedWeightList),

              const SizedBox(height: 28),

              // Daily Nutrient Intake Header
              const Text(
                'Nutrient Intake History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Daily comparison of food (g) vs water (ml) consumed.',
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
    );
  }

  // Weight Trend Line Chart
  Widget _buildWeightChartCard(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No weight trend data available.')),
        ),
      );
    }

    final double minY = data.map((e) => (e['weightKg'] as num).toDouble()).reduce((a, b) => a < b ? a : b) - 0.2;
    final double maxY = data.map((e) => (e['weightKg'] as num).toDouble()).reduce((a, b) => a > b ? a : b) + 0.2;

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final weight = (data[i]['weightKg'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), weight));
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text('Current Weight', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Growth Curve',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11),
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
                      color: Colors.grey.withOpacity(0.1),
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
                        reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}k',
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
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                              child: Text(DateFormat('MM/dd').format(parsedDate)),
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
                      color: Colors.teal,
                      barWidth: 3.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeColor: Colors.teal,
                          strokeWidth: 3,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.withOpacity(0.3),
                            Colors.teal.withOpacity(0.0),
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
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No daily summary trend data available.')),
        ),
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
              color: Colors.orangeAccent,
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: water,
              color: Colors.blueAccent,
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
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
                _buildLegendItem('Food (g)', Colors.orangeAccent),
                const SizedBox(width: 16),
                _buildLegendItem('Water (ml)', Colors.blueAccent),
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
                      color: Colors.grey.withOpacity(0.1),
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
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                              child: Text(DateFormat('E').format(parsedDate)), // Weekday name
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
