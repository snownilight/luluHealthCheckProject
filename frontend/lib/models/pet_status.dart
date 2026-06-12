class PetStatus {
  final double lastWeightKg;
  final double todayWaterIntakeMl;
  final double todayFoodIntakeG;
  final double todayActivityMin;
  final DateTime? lastActiveTime;

  PetStatus({
    required this.lastWeightKg,
    required this.todayWaterIntakeMl,
    required this.todayFoodIntakeG,
    this.todayActivityMin = 0.0,
    this.lastActiveTime,
  });

  factory PetStatus.fromJson(Map<String, dynamic> json) {
    return PetStatus(
      lastWeightKg: (json['lastWeightKg'] as num?)?.toDouble() ?? 0.0,
      todayWaterIntakeMl: (json['todayWaterIntakeMl'] as num?)?.toDouble() ?? 0.0,
      todayFoodIntakeG: (json['todayFoodIntakeG'] as num?)?.toDouble() ?? 0.0,
      todayActivityMin: (json['todayActivityMin'] as num?)?.toDouble() ?? 0.0,
      lastActiveTime: json['lastActiveTime'] != null
          ? DateTime.tryParse(json['lastActiveTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastWeightKg': lastWeightKg,
      'todayWaterIntakeMl': todayWaterIntakeMl,
      'todayFoodIntakeG': todayFoodIntakeG,
      'todayActivityMin': todayActivityMin,
      'lastActiveTime': lastActiveTime?.toIso8601String(),
    };
  }

  PetStatus copyWith({
    double? lastWeightKg,
    double? todayWaterIntakeMl,
    double? todayFoodIntakeG,
    double? todayActivityMin,
    DateTime? lastActiveTime,
  }) {
    return PetStatus(
      lastWeightKg: lastWeightKg ?? this.lastWeightKg,
      todayWaterIntakeMl: todayWaterIntakeMl ?? this.todayWaterIntakeMl,
      todayFoodIntakeG: todayFoodIntakeG ?? this.todayFoodIntakeG,
      todayActivityMin: todayActivityMin ?? this.todayActivityMin,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
    );
  }
}
