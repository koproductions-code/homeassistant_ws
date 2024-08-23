import 'package:homeassistant_ws/src/counter.dart';
import 'package:homeassistant_ws/src/types.dart';
import 'package:homeassistant_ws/src/websocket.dart';

class HARequest {
  HARequest({
    this.id,
    required this.type,
    this.data,
  }) {
    id ??= HARequestCounter.counter.newRequestId();
  }

  int? id;
  final HARequestType type;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'type': type.name,
    };
    json.addAll(data ?? {});

    return json;
  }

  void execute() {
    HAWebSocketService().send(toJson());
  }

/*
  Future<void> execute() async {
    Completer<void> completer = Completer();

    late StreamSubscription<HAResponse> subscription;
    subscription = HAWebSocketService().messages.listen((message) {
      if (message.id == id) {
        completer.complete();
        subscription.cancel();
      }
    });

    HAWebSocketService().send(toJson());
    return completer.future;
  }
 */
}
