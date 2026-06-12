import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_status.dart';
import 'websocket_service.dart';
import 'storage_settings_provider.dart';
import 'api_service.dart';

class PetStatusNotifier extends StateNotifier<PetStatus> {
  final Ref _ref;

  PetStatusNotifier(this._ref)
      : super(PetStatus(
          lastWeightKg: 4.8,
          todayWaterIntakeMl: 0.0,
          todayFoodIntakeG: 0.0,
          todayActivityMin: 0.0,
          lastActiveTime: DateTime.now().subtract(const Duration(minutes: 15)),
        )) {
    // Listen to storage setting changes, refresh status upon change
    _ref.listen<StorageSettings>(storageSettingsProvider, (previous, next) {
      refreshStatus();
    });
    // Initial fetch from repository
    Future.microtask(() => refreshStatus());
  }

  void updateStatus(PetStatus newStatus) {
    state = newStatus;
  }

  Future<void> refreshStatus() async {
    try {
      final repository = _ref.read(petRepositoryProvider);
      
      // 1. Fetch latest raw status (mainly for current weight & last active fallback)
      final latestStatus = await repository.getPetStatus();
      
      // 2. Fetch care logs to compute timezone-accurate statistics for today (00:00:00 ~ 23:59:59 local)
      final logs = await repository.getCareLogs();
      
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = startOfToday.add(const Duration(days: 1));

      double water = 0.0;
      double food = 0.0;
      double activity = 0.0;
      DateTime? lastActive;

      for (final log in logs) {
        final timestampStr = log['eventTimestamp'] ?? '';
        final timestamp = DateTime.tryParse(timestampStr)?.toLocal();
        if (timestamp == null) continue;

        // Check if log is within today (00:00:00 to 23:59:59 local time)
        final isToday = timestamp.isAtSameMomentAs(startOfToday) ||
            (timestamp.isAfter(startOfToday) && timestamp.isBefore(endOfToday));

        if (isToday) {
          final type = (log['eventType'] ?? '').toString().toUpperCase();
          final value = (log['value'] as num?)?.toDouble() ?? 0.0;

          if (type == 'DRINKING') {
            water += value;
          } else if (type == 'FEEDING') {
            food += value;
          } else if (type == 'ACTIVITY') {
            activity += value;
          }
          
          if (lastActive == null || timestamp.isAfter(lastActive)) {
            lastActive = timestamp;
          }
        }
      }

      // 3. Fallback to latest weight & last active from repository if needed, then update state
      final updatedStatus = latestStatus.copyWith(
        todayWaterIntakeMl: water,
        todayFoodIntakeG: food,
        todayActivityMin: activity,
        lastActiveTime: lastActive ?? latestStatus.lastActiveTime,
      );

      updateStatus(updatedStatus);
      print('[PetStatus] Status updated from logs successfully! (Water: $water ml, Food: $food g, Activity: $activity min)');
    } catch (e) {
      print('[PetStatus] Error refreshing status from repository: $e');
    }
  }
}

final petStatusProvider = StateNotifierProvider<PetStatusNotifier, PetStatus>((ref) {
  return PetStatusNotifier(ref);
});

// Stomp client websocket provider
final webSocketServiceProvider = Provider<WebSocketService?>((ref) {
  final settings = ref.watch(storageSettingsProvider);
  if (settings.mode != StorageMode.server) {
    return null; // Don't run WebSocket in local or sheets mode
  }

  final wsService = WebSocketService(
    wsUrl: kIsWeb ? 'ws://localhost:8080/ws-pet' : 'ws://10.0.2.2:8080/ws-pet',
    onStatusReceived: (status) {
      // Invalidate logs so timeline matches, then refreshStatus to compute timezone-aware stats
      ref.invalidate(careLogsProvider);
      ref.read(petStatusProvider.notifier).refreshStatus();
    },
    onConnect: () async {
      print('[WebSocket] Connected/Reconnected, triggering state synchronization...');
      ref.invalidate(careLogsProvider);
      ref.read(petStatusProvider.notifier).refreshStatus();
      print('[WebSocket] State synchronization completed successfully!');
    },
  );

  // Auto-connect upon initialization
  wsService.connect();

  // Handle disposal
  ref.onDispose(() {
    wsService.disconnect();
  });

  return wsService;
});
