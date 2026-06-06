import '../models/pet_status.dart';
import '../services/api_service.dart';
import 'pet_repository.dart';

class ServerPetRepository implements PetRepository {
  final ApiService _apiService;

  ServerPetRepository(this._apiService);

  @override
  Future<bool> saveCareLog(Map<String, dynamic> careLogData) async {
    return await _apiService.sendCareLog(careLogData);
  }

  @override
  Future<List<Map<String, dynamic>>> getCareLogs() async {
    return await _apiService.getCareLogs();
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyWeightTrend() async {
    return await _apiService.getWeeklyWeightTrend();
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyDailySummary() async {
    return await _apiService.getMonthlyDailySummary();
  }

  @override
  Future<PetStatus> getPetStatus() async {
    final status = await _apiService.getPetStatus();
    if (status != null) {
      return status;
    }
    return PetStatus(
      lastWeightKg: 4.8,
      todayWaterIntakeMl: 0.0,
      todayFoodIntakeG: 0.0,
      lastActiveTime: DateTime.now().subtract(const Duration(minutes: 15)),
    );
  }
}
