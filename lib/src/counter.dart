class HARequestCounter {
  static HARequestCounter counter = HARequestCounter();

  int _requestCounter = 0;

  int newRequestId() {
    _requestCounter += 1;
    return _requestCounter;
  }
}