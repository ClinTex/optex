package core.data;

import haxe.Json;

class PortletInstancePortletData {
    public var data:Dynamic = {};

    public function new() {
    }

    public var portletClassName(get, set):String;
    private function get_portletClassName():String {
        if (data == null) {
            return null;
        }
        if (data.portletClassName == null) {
            return null;
        }
        return data.portletClassName;
    }
    private function set_portletClassName(value:String):String {
        if (data == null) {
            data = {};
        }

        data.portletClassName = value;

        return value;
    }

    public static function fomJsonString(s:String):PortletInstancePortletData {
        var data = new PortletInstancePortletData();
        var object:Dynamic = Json.parse(s);
        data.data = object;
        return data;
    }

    public static function toJsonString(o:PortletInstancePortletData):String {
        return Json.stringify(o.data);
    }
}