import 'response.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class HAWebSocketService {
  static final HAWebSocketService _instance = HAWebSocketService._internal();
  WebSocketChannel? _channel;
  Uri? _uri;

  final StreamController<HAResponse> _messageController = StreamController.broadcast();
  Completer<void>? _authCompleter;

  bool get isConnected => _channel != null && _authCompleter != null && _authCompleter!.isCompleted;

  factory HAWebSocketService() {
    return _instance;
  }

  HAWebSocketService._internal();

  Future<void> connect(String host, int port, String accessToken) async {
    _uri = Uri.parse('wss://$host:$port/api/websocket');
    _channel = WebSocketChannel.connect(_uri!);
    _authCompleter = Completer<void>();

    _channel!.stream.listen((message) {
      var decodedMessage = jsonDecode(message);

      if (decodedMessage["type"] == 'auth_required') {
        send({'type': 'auth', 'access_token': accessToken});
      } else if (decodedMessage["type"] == 'auth_ok') {
        if (!_authCompleter!.isCompleted) {
          _authCompleter!.complete();
        }
      } else if (decodedMessage["type"] == 'auth_invalid') {
        if (!_authCompleter!.isCompleted) {
          _authCompleter!.completeError(Exception('Authentication failed'));
        }
      } else {
        HAResponse response = HAResponse.fromJson(decodedMessage);
        _messageController.add(response);
      }
    }, onDone: () {
      if (!_authCompleter!.isCompleted) {
        _authCompleter!.completeError(Exception('Could not authenticate. Check your access token.'));
      } else {
        throw Exception('WebSocket closed unexpectedly');
      }
    }, onError: (error) {
      if (!_authCompleter!.isCompleted) {
        _authCompleter!.completeError(Exception('$error'));
      } else {
        throw Exception('WebSocket closed unexpectedly: $error');
      }
    });

    return _authCompleter!.future;
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      throw Exception("WebSocket is not connected.");
    }
  }

  Stream<HAResponse> get messages => _messageController.stream;

  void dispose() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _messageController.close();
  }
}
