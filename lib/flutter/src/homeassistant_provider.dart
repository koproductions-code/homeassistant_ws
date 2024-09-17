import 'package:homeassistant_ws/homeassistant_ws.dart';
import 'package:flutter/material.dart';

class HomeAssistantProvider with ChangeNotifier {
  HomeAssistantSocket? socket;

  HomeAssistantProvider(
      {required String host, required int port, required List<String> entities, String? accessToken}) {
    if (accessToken != null) {
      socket = HomeAssistantSocket(host: host, port: port, entities: entities, accessToken: accessToken);
    } else {
      socket = HomeAssistantSocket(host: host, port: port, entities: entities);
    }
  }

  Future<void> connect() async {
    await socket?.disconnect();
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
