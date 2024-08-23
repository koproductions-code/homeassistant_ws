import 'package:test/test.dart';
import 'package:homeassistant_ws/homeassistant_ws.dart';

void main() {
  group('Tests', () {
    String token = "";

    setUp(() {
      token = const String.fromEnvironment("HA_TOKEN");
    });

    HomeAssistantSocket socket = HomeAssistantSocket(
      host: "homeassistant.local",
      port: 8123,
      entities: ["light.kitchen"],
    );

    test('token_supplied', () {
      expect(socket.accessToken, isNotEmpty, reason: "HA_TOKEN must be set");
      //expect(socket.accessToken, equals("test"), reason: "HA_TOKEN is not set via parameter");
      expect(socket.accessToken, equals(token), reason: "HA_TOKEN is not set via environment variable");
    });
  });
}
