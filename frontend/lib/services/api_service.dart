import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Post a care log event
  Future<bool> sendCareLog(Map<String, dynamic> careLogData) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/care-logs');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(careLogData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Log or handle error
      return false;
    }
  }

  // Fetch weekly weight trend
  Future<List<Map<String, dynamic>>> getWeeklyWeightTrend() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/trends/weight');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
    return [];
  }

  // Fetch monthly daily summary
  Future<List<Map<String, dynamic>>> getMonthlyDailySummary() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/trends/summary');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
    return [];
  }
}
