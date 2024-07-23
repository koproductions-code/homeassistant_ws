import 'package:test/test.dart';

void main() {
  group('Tests', () {
    String token = "";

    setUp(() {
      token = const String.fromEnvironment("HA_TOKEN");
    });

    test('token_supplied', () {
      expect(token, isNotEmpty, reason: "HA_TOKEN must be set");
    });
  });
}
