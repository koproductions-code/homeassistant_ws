import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeAssistantSocket {
  HomeAssistantSocket({
    required this.host,
    required this.port,
    required this.accessToken,
  })  : _subscriptions = {},
        _subscriptionCounter = 0;

  final String host;
  final int port;
  final String accessToken;

  WebSocketChannel? channel;
  int _subscriptionCounter;
  final Map<int, Function(Map<String, dynamic>)> _subscriptions;
  Completer<void>? _authCompleter;

  Future<void> connect() async {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://$host/api/websocket'),
    );

    _authCompleter = Completer<void>();
    channel!.stream.listen((message) => onReceive(message));

    channel!.sink.done.then((value) {
      _authCompleter!.completeError(
          'Channel disconnected. Did you supply the correct access token?');
    });

    return _authCompleter!.future;
  }

  void onReceive(message) {
    var decodedMessage = jsonDecode(message);

    if (decodedMessage['type'] == 'auth_required') {
      channel!.sink.add(
        jsonEncode({
          'type': 'auth',
          'access_token': accessToken,
        }),
      );
    } else if (decodedMessage['type'] == 'auth_ok') {
      if (!_authCompleter!.isCompleted) {
        _authCompleter!.complete();
      }
    } else if (decodedMessage['type'] == 'event' ||
        decodedMessage['type'] == 'result') {
      int? id = decodedMessage['id'];
      _subscriptions[id]?.call(decodedMessage);
    }
  }

  void disconnect() {
    print('Disconnecting from $host:$port');
    channel?.sink.close();
  }

  int subscribe(String entity, Function(Map<String, dynamic>) onEvent) {
    if (channel == null) {
      throw Exception(
          "Please make a connection before creating a subscription.");
    }

    int newId = ++_subscriptionCounter;
    _subscriptions[newId] = onEvent;
    channel!.sink.add(jsonEncode({
      'id': newId,
      'type': 'subscribe_entities',
      'entity_ids': [entity]
    }));

    return newId;
  }

  void unsubscribe(int id) {
    _subscriptions.remove(id);
    // Optionally send an unsubscribe message to the server if necessary
    channel!.sink.add(jsonEncode({
      'id': _subscriptionCounter + 1,
      'type': 'unsubscribe_events',
      'subscription': id
    }));
  }
}
