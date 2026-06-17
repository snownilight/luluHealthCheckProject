import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _webSocketUrl = String.fromEnvironment('WEBSOCKET_URL');
  static const String googleSignInClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_CLIENT_ID',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrl.isNotEmpty) {
      return _apiBaseUrl;
    }
    return kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
  }

  static String get webSocketUrl {
    if (_webSocketUrl.isNotEmpty) {
      return _webSocketUrl;
    }
    return kIsWeb ? 'ws://localhost:8080/ws-pet' : 'ws://10.0.2.2:8080/ws-pet';
  }

  static String? get optionalGoogleSignInClientId {
    return googleSignInClientId.isEmpty ? null : googleSignInClientId;
  }
}
