import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_tracker/config/environment_config.dart';

void main() {
  test('environment config provides local defaults', () {
    expect(EnvironmentConfig.apiBaseUrl, isNotEmpty);
    expect(EnvironmentConfig.webSocketUrl, endsWith('/ws-pet'));
  });
}
