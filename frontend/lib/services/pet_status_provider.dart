import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_status.dart';
import 'websocket_service.dart';
import 'api_service.dart';

class PetStatusNotifier extends StateNotifier<PetStatus> {
  PetStatusNotifier()
      : super(PetStatus(
          lastWeightKg: 4.8,
          todayWaterIntakeMl: 120.0,
          todayFoodIntakeG: 85.0,
          lastActiveTime: DateTime.now().subtract(const Duration(minutes: 15)),
        ));

  void updateStatus(PetStatus newStatus) {
    state = newStatus;
  }
}

final petStatusProvider = StateNotifierProvider<PetStatusNotifier, PetStatus>((ref) {
  return PetStatusNotifier();
});

// Stomp client websocket provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  // Use http://localhost:8080 or ws://localhost:8080/ws-pet for WebSocket STOMP
  final wsService = WebSocketService(
    wsUrl: kIsWeb ? 'ws://localhost:8080/ws-pet' : 'ws://10.0.2.2:8080/ws-pet',
    onStatusReceived: (status) {
      ref.read(petStatusProvider.notifier).updateStatus(status);
    },
    onConnect: () async {
      print('[WebSocket] Connected/Reconnected, triggering state synchronization...');
      final apiService = ref.read(apiServiceProvider);
      final latestStatus = await apiService.getPetStatus();
      if (latestStatus != null) {
        ref.read(petStatusProvider.notifier).updateStatus(latestStatus);
        print('[WebSocket] State synchronization completed successfully!');
      }
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
