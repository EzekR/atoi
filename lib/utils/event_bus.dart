typedef void EventCallback(arg);

class EventBus {
  EventBus._internal();

  static EventBus _singleton = new EventBus._internal();

  factory EventBus()=> _singleton;

  var _emap = new Map<String, EventCallback>();

  void on(eventName, EventCallback f) {
    if (eventName == null || f == null) return;
    _emap[eventName]=f;
  }

  void off(eventName) {
    _emap[eventName] = null;
  }

  void emit(eventName, [arg]) {
    var f = _emap[eventName];
    f(arg);
  }
}