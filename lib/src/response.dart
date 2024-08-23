abstract class HAResponse {
  final String type;
  final int? id;

  HAResponse({required this.type, this.id});

  factory HAResponse.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'result':
        return HAResultResponse.fromJson(json);
      case 'event':
        return HAEventResponse.fromJson(json);
      default:
        throw Exception('Unsupported response type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}

class HAResultResponse extends HAResponse {
  final bool success;
  final dynamic result;

  final dynamic error;

  HAResultResponse({required super.type, super.id, required this.success, this.error, this.result});

  factory HAResultResponse.fromJson(Map<String, dynamic> json) {
    try {
      var resultList = json["result"] as List<dynamic>;
      List<HAEntityState> entityStates =
          resultList.map((e) => HAEntityState.fromJson(e as Map<String, dynamic>)).toList();

      return HAResultResponse(
        type: json['type'],
        id: json['id'],
        success: json['success'],
        result: entityStates,
      );
    } on Error catch (_) {
      return HAResultResponse(
        type: json['type'],
        id: json['id'],
        success: json['success'],
        error: json['error'],
        result: json['result'],
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var json = {
      'type': type,
      'id': id,
      'success': success,
      'result': result,
    };
    json.addAll(error != null ? {'error': error} : {});
    return json;
  }
}

class HAEventResponse extends HAResponse {
  final String eventType;
  final String entityId;
  final HAEntityState oldState;
  final HAEntityState state;
  final Map<String, dynamic> context;
  final String origin;
  final DateTime timeFired;

  HAEventResponse({
    required super.type,
    required super.id,
    required this.eventType,
    required this.entityId,
    required this.oldState,
    required this.state,
    required this.context,
    required this.origin,
    required this.timeFired,
  });

  factory HAEventResponse.fromJson(Map<String, dynamic> json) {
    var event = json['event'];
    return HAEventResponse(
      type: json['type'],
      id: json['id'],
      eventType: event['event_type'],
      entityId: event['data']['entity_id'],
      oldState: HAEntityState.fromJson(event['data']['old_state']),
      state: HAEntityState.fromJson(event['data']['new_state']),
      context: event['context'],
      origin: event['origin'],
      timeFired: DateTime.parse(event['time_fired']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'event_type': eventType,
      'entity_id': entityId,
      'old_state': oldState.toJson(),
      'state': state.toJson(),
      'context': context,
      'origin': origin,
      'time_fired': timeFired.toIso8601String(),
    };
  }
}

class HAEntityState {
  final String entityId;
  final String state;
  final Map<String, dynamic> attributes;

  HAEntityState({
    required this.entityId,
    required this.state,
    required this.attributes,
  });

  factory HAEntityState.fromJson(Map<String, dynamic> json) {
    return HAEntityState(
      entityId: json['entity_id'],
      state: json['state'],
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_id': entityId,
      'state': state,
      'attributes': attributes,
    };
  }
}
