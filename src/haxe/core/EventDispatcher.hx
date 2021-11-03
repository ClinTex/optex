package core;

class Event {
    public var type:String;

    public function new(type:String) {
        this.type = type;
    }
}

class EventDispatcher<T:Event> {
    private var _listeners:Map<String, Array<T->Void>> = [];

    public function listen(type:String, listener:T->Void) {
        var list = _listeners.get(type);
        if (list == null) {
            list = [];
            _listeners.set(type, list);
        }
        list.push(listener);
    }

    public function unlisten(type:String, listener:T->Void) {
        var list = _listeners.get(type);
        if (list != null) {
            list.remove(listener);
        }
    }

    private function dispatch(event:T) {
        var list = _listeners.get(event.type);
        if (list != null) {
            for (l in list) {
                l(event);
            }
        }
    }
}