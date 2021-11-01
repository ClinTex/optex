package core.data;

import js.Browser;

class Logger {
    private static var _instance:Logger = null;
    public static var instance(get, null):Logger;
    private static function get_instance():Logger {
        if (_instance == null) {
            _instance = new Logger();
        }
        return _instance;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // INSTANCE
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    private function new() {
    }

    public function log(s:Any) {
        Browser.console.log(s);
    }
}
