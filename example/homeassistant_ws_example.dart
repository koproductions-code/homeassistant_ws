import 'package:homeassistant_ws/homeassistant_ws.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  final socket = HomeAssistantSocket(
    host: "homeassistant.koproductions.dev",
    port: 443,
    entities: ["input_boolean.dummy"],
  );

  await socket.connect();

  socket.subscribe("input_boolean.dummy", (event) {
    print("Received event: ${event.toJson()}");
  });

  stdin.echoMode = false;
  stdin.lineMode = false;
  stdin.listen((List<int> data) {
    final input = utf8.decode(data).trim();
    if (input == 'q') {
      socket.disconnect();
      exit(0);
    } else if (input == 'c') {
      socket.unsubscribe("input_boolean.dummy");
    }
  });
}
