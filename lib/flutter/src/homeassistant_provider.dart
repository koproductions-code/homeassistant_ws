import 'package:homeassistant_ws/homeassistant_ws.dart';
import 'package:flutter/material.dart';

class HomeAssistantProvider with ChangeNotifier {
  HomeAssistantSocket? socket;

  HomeAssistantProvider({required String host, required int port, String? accessToken}) {
    var token = String.fromEnvironment('HA_TOKEN', defaultValue: accessToken ?? "");
    if (token.isEmpty || token == "") {
      throw Exception("HA_TOKEN must be set as an environment variable or passed as an argument.");
    }
    socket = HomeAssistantSocket(host: host, port: port, accessToken: token);
  }

  Future<void> connect() async {
    await socket!.connect();
    notifyListeners();
  }

  void disconnectFromSocket() {
    socket?.disconnect();
    socket = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectFromSocket();
    super.dispose();
  }
}
