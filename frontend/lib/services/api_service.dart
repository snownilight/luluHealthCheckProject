import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_status.dart';
import 'storage_settings_provider.dart';

final apiServiceProvider = Provider((ref) => ApiService(
  baseUrl: kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080',
));

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Fetch latest pet status
  Future<PetStatus?> getPetStatus() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/care-logs/pet-status');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] != null) {
          return PetStatus.fromJson(body['data']);
        }
      }
    } catch (e) {
      print('[ApiService] Error fetching pet status: $e');
    }
    return null;
  }

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
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  // Fetch monthly daily summary
  Future<List<Map<String, dynamic>>> getMonthlyDailySummary() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/trends/monthly-summary');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  // Fetch care logs
  Future<List<Map<String, dynamic>>> getCareLogs() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/care-logs');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }
}

final careLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Watch storageSettingsProvider so the list re-fetches when storage mode or sheet ID changes
  ref.watch(storageSettingsProvider);
  final repository = ref.watch(petRepositoryProvider);
  final logs = await repository.getCareLogs();
  // Sort descending by eventTimestamp
  logs.sort((a, b) {
    final aTime = DateTime.tryParse(a['eventTimestamp'] ?? '') ?? DateTime.now();
    final bTime = DateTime.tryParse(b['eventTimestamp'] ?? '') ?? DateTime.now();
    return bTime.compareTo(aTime);
  });
  return logs;
});
