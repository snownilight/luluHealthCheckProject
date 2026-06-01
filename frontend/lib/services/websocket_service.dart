import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/pet_status.dart';

class WebSocketService {
  final String wsUrl;
  StompClient? _client;
  final void Function(PetStatus) onStatusReceived;

  WebSocketService({
    required this.wsUrl,
    required this.onStatusReceived,
  });

  void connect() {
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (error) => print('[WebSocket] Error: $error'),
        onStompError: (error) => print('[STOMP] Error: $error'),
      ),
    );
    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('[WebSocket] Connected');
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

  void disconnect() {
    _client?.deactivate();
  }
}
