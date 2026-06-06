import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_status.dart';
import 'websocket_service.dart';
import 'storage_settings_provider.dart';

class PetStatusNotifier extends StateNotifier<PetStatus> {
  final Ref _ref;

  PetStatusNotifier(this._ref)
      : super(PetStatus(
          lastWeightKg: 4.8,
          todayWaterIntakeMl: 120.0,
          todayFoodIntakeG: 85.0,
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
      final latestStatus = await repository.getPetStatus();
      updateStatus(latestStatus);
      print('[PetStatus] Status updated from repository successfully!');
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
      ref.read(petStatusProvider.notifier).updateStatus(status);
    },
    onConnect: () async {
      print('[WebSocket] Connected/Reconnected, triggering state synchronization...');
      final repository = ref.read(petRepositoryProvider);
      final latestStatus = await repository.getPetStatus();
      ref.read(petStatusProvider.notifier).updateStatus(latestStatus);
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
