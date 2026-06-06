import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/pet_status.dart';

class WebSocketService {
  final String wsUrl;
  StompClient? _client;
  final void Function(PetStatus) onStatusReceived;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  WebSocketService({
    required this.wsUrl,
    required this.onStatusReceived,
    this.onConnect,
    this.onDisconnect,
  });

  void connect() {
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (error) => print('[WebSocket] Error: $error'),
        onStompError: (error) => print('[STOMP] Error: $error'),
        reconnectDelay: const Duration(seconds: 5),
        connectionTimeout: const Duration(seconds: 10),
      ),
    );
    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('[WebSocket] Connected');
    onConnect?.call();
    _client?.subscribe(
      destination: '/topic/status',
      callback: (frame) {
        if (frame.body != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(frame.body!);
            final status = PetStatus.fromJson(data);
            onStatusReceived(status);
          } catch (e) {
            print('[WebSocket] Error parsing message body: $e');
          }
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    print('[WebSocket] Disconnected');
    onDisconnect?.call();
  }

  void disconnect() {
    _client?.deactivate();
  }
}
