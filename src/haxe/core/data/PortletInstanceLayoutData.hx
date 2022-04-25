package core.data;

import haxe.Json;

class PortletInstanceLayoutData {
    public var data:Dynamic = {};

    public function new() {
    }

    public var portletContainerId(get, set):String;
    private function get_portletContainerId():String {
        if (data == null) {
            return null;
        }
        if (data.portletContainerId == null) {
            return null;
        }
        return data.portletContainerId;
    }
    private function set_portletContainerId(value:String):String {
        if (data == null) {
            data = {};
        }

        data.portletContainerId = value;

        return value;
    }

    public static function fomJsonString(s:String):PortletInstanceLayoutData {
        var data = new PortletInstanceLayoutData();
        var object:Dynamic = Json.parse(s);
        data.data = object;
        return data;
    }

    public static function toJsonString(o:PortletInstanceLayoutData):String {
        return Json.stringify(o.data);
    }
}