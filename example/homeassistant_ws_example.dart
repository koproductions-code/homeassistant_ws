import 'package:homeassistant_ws/homeassistant_ws.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  final socket = HomeAssistantSocket(
      host: "YOUR-HOMEASSISTANT-URL", port: 8123, accessToken: const String.fromEnvironment('HA_TOKEN'));

  await socket.connect();

  int timeId = socket.subscribe("input_boolean.dummy", (event) {
    print(event);
  });

  stdin.echoMode = false;
  stdin.lineMode = false;
  stdin.listen((List<int> data) {
    final input = utf8.decode(data).trim();
    if (input == 'q') {
      socket.disconnect();
      exit(0);
    } else if (input == 'c') {
      socket.unsubscribe(timeId);
    }
  });
}
