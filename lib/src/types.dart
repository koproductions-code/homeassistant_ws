enum HARequestType {
  auth,
  getStates,
  callService,
  subscribeEvents,
  unsubscribeEvents;

  int get value {
    switch (this) {
      case HARequestType.auth:
        return 100;
      case HARequestType.getStates:
        return 200;
      case HARequestType.callService:
        return 300;
      case HARequestType.subscribeEvents:
        return 400;
      case HARequestType.unsubscribeEvents:
        return 500;
      default:
        return 1;
    }
  }

  String get name {
    switch (this) {
      case HARequestType.auth:
        return 'auth';
      case HARequestType.getStates:
        return 'get_states';
      case HARequestType.callService:
        return 'call_service';
      case HARequestType.subscribeEvents:
        return 'subscribe_events';
      case HARequestType.unsubscribeEvents:
        return 'unsubscribe_events';
      default:
        return 'unknown';
    }
  }

  static HARequestType fromString(String value) {
    switch (value) {
      case 'auth':
        return HARequestType.auth;
      case 'get_states':
        return HARequestType.getStates;
      case 'call_service':
        return HARequestType.callService;
      case 'subscribe_events':
        return HARequestType.subscribeEvents;
      case 'unsubscribe_events':
        return HARequestType.unsubscribeEvents;
      default:
        return HARequestType.auth;
    }
  }

  bool includes(int value) {
    return this.value == value - (value - this.value);
  }
}
