package core.data;

import js.lib.Reflect;
import haxe.Json;

class PortletInstancePortletData {
    public var data:Dynamic = {};

    public function new() {
    }

    public var portletClassName(get, set):String;
    private function get_portletClassName():String {
        return getStringValue("portletClassName");
    }
    private function set_portletClassName(value:String):String {
        return setValue("portletClassName", value);
    }

    public var dataSourceId(get, set):Null<Int>;
    private function get_dataSourceId():Null<Int> {
        return getIntValue("dataSourceId");
    }
    private function set_dataSourceId(value:Null<Int>):Null<Int> {
        return setValue("dataSourceId", value);
    }

    public var transform(get, set):String;
    private function get_transform():String {
        return getStringValue("transform");
    }
    private function set_transform(value:String):String {
        return setValue("transform", value);
    }

    public function getObjectValue(name:String, defaultValue:Dynamic = null):Dynamic {
        if (data == null) {
            data = {};
        }

        if (!Reflect.hasField(data, name)) {
            return defaultValue;
        }

        return Reflect.field(data, name);
    }

    public function getStringValue(name:String, defaultValue:String = null):String {
        if (data == null) {
            data = {};
        }

        if (!Reflect.hasField(data, name)) {
            return defaultValue;
        }

        return Std.string(Reflect.field(data, name));
    }

    public function getIntValue(name:String, defaultValue:Null<Int> = null):Null<Int> {
        var s = getStringValue(name, null);
        if (s == null) {
            return defaultValue;
        }
        return Std.parseInt(s);
    }

    public function getBoolValue(name:String, defaultValue:Null<Bool> = false):Null<Bool> {
        var s = getStringValue(name, null);
        if (s == null) {
            return defaultValue;
        }
        return (s == "true");
    }

    public function setValue(name:String, value:Any):Any {
        if (data == null) {
            data = {};
        }
        Reflect.setField(data, name, value);
        return value;
    }

    public static function fromJsonString(s:String):PortletInstancePortletData {
        var data = new PortletInstancePortletData();
        var object:Dynamic = Json.parse(s);
        data.data = object;
        return data;
    }

    public static function fromJsonObject(o:Dynamic):PortletInstancePortletData {
        var data = new PortletInstancePortletData();
        data.data = o;
        return data;
    }

    public static function toJsonString(o:PortletInstancePortletData):String {
        return Json.stringify(o.data);
    }
}