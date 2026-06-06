import '../models/pet_status.dart';

abstract class PetRepository {
  /// Saves a care log event (feeding, drinking, weight update, activity)
  Future<bool> saveCareLog(Map<String, dynamic> careLogData);

  /// Fetches all care logs
  Future<List<Map<String, dynamic>>> getCareLogs();

  /// Fetches weekly weight trends
  Future<List<Map<String, dynamic>>> getWeeklyWeightTrend();

  /// Fetches monthly daily summaries (daily totals for food/water/avg weight)
  Future<List<Map<String, dynamic>>> getMonthlyDailySummary();

  /// Fetches the current pet health status
  Future<PetStatus> getPetStatus();
}
