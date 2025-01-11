import 'package:homeassistant_ws/src/response.dart';
import 'package:logger/logger.dart';

import 'websocket.dart';
import 'types.dart';
import 'request.dart';

import 'dart:async';
import 'dart:developer';

class HomeAssistantSocket {
  final String host;
  final int port;
  final String accessToken;
  final List<String> entities;

  int _subscriptionCounter = 0;
  final Map<String, List<int>> _callbackMap = {};
  final Map<int, Function(HAEntityState)> _subscriptions = {};

  HomeAssistantSocket({
    required this.host,
    required this.port,
    required this.entities,
    this.accessToken = const String.fromEnvironment("HA_TOKEN"),
  }) {
    Logger.level = Level.debug;

    if (accessToken.isEmpty) {
      throw Exception("Access token must be provided or set via HA_TOKEN environment variable.");
    }
  }

  Future<void> connect() async {
    try {
      await HAWebSocketService().connect(host, port, accessToken);

      HAWebSocketService().messages.listen(onReceive);
      fetchInitialStates();
      startEventStream();
    } catch (e) {
      rethrow;
    }
  }

  void startEventStream() {
    HARequest request = HARequest(type: HARequestType.subscribeEvents, data: {"event_type": "state_changed"});
    request.execute();
  }

  void fetchInitialStates() {
    HARequest request = HARequest(type: HARequestType.getStates);
    request.execute();
  }

  void onReceive(HAResponse response) async {
    switch (response.type) {
      case 'event':
        var eventResponse = response as HAEventResponse;
        if (_callbackMap.containsKey(eventResponse.entityId)) {
          for (var id in _callbackMap[eventResponse.entityId]!) {
            _subscriptions[id]?.call(eventResponse.state);
          }
        }
        break;
      case 'result':
        var resultResponse = response as HAResultResponse;
        if (resultResponse.success) {
	  print(resultResponse.result.runtimeType);
          if (resultResponse.id == 1) {
            var entityStates = resultResponse.result as List<HAEntityState>;
            entityStates.retainWhere((HAEntityState state) => entities.contains(state.entityId));
            for (var state in entityStates) {
              if (_callbackMap.containsKey(state.entityId)) {
                for (var id in _callbackMap[state.entityId]!) {
                  _subscriptions[id]?.call(state);
                }
              }
            }
          }
        } else {
          throw Exception("Error fetching initial states: ${resultResponse.error}");
        }
        break;
      default:
        break;
    }
  }

  void disconnect() {
    HAWebSocketService().dispose();
  }

  int subscribe(String entity, Function(HAEntityState) onResponse) {
    if (!HAWebSocketService().isConnected) {
      throw Exception("Make sure the socket is initialized before creating a subscription.");
    }

    int newId = ++_subscriptionCounter;
    _subscriptions[newId] = onResponse;

    if (!_callbackMap.containsKey(entity)) {
      _callbackMap[entity] = [];
    }
    _callbackMap[entity]!.add(newId);

    return newId;
  }

  void unsubscribe(String entity) {
    if (!_callbackMap.containsKey(entity)) {
      throw Exception("No subscription found for entity: $entity");
    }

    List<int> ids = _callbackMap[entity]!;
    for (var id in ids) {
      _subscriptions.remove(id);
    }
    _callbackMap.remove(entity);
  }
}
