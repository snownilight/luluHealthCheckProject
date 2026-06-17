import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_tracker/models/pet_status.dart';

void main() {
  group('PetStatus.fromJson edge cases', () {
    test('uses zero defaults for missing numeric fields', () {
      final status = PetStatus.fromJson({});

      expect(status.lastWeightKg, 0);
      expect(status.todayWaterIntakeMl, 0);
      expect(status.todayFoodIntakeG, 0);
      expect(status.todayActivityMin, 0);
      expect(status.lastActiveTime, isNull);
    });

    test('accepts integer numeric values and ignores malformed timestamps', () {
      final status = PetStatus.fromJson({
        'lastWeightKg': 5,
        'todayWaterIntakeMl': 120,
        'todayFoodIntakeG': 80,
        'todayActivityMin': 15,
        'lastActiveTime': 'not-a-date',
      });

      expect(status.lastWeightKg, 5.0);
      expect(status.todayWaterIntakeMl, 120.0);
      expect(status.todayFoodIntakeG, 80.0);
      expect(status.todayActivityMin, 15.0);
      expect(status.lastActiveTime, isNull);
    });
  });
}
