package components;

import components.portlets.TableDataPortletInstance;
import components.portlets.FilterPortletInstance;
import components.portlets.BarGraphPortletInstance;
import components.portlets.PortletInstance;
import haxe.ui.containers.Box;

class Portlet extends Box {
    private var _instance:PortletInstance;

    public override function onReady() {
        super.onReady();

        trace(_border);
        if (_border == false) {
            addClass("no-border");
        }

        addComponent(_instance);
    }

    private var _type:String;
    public var type(get, set):String;
    private function get_type():String {
        return _type;
    }
    private function set_type(value:String):String {
        if (value == _type) {
            return value;
        }

        _type = value;
        switch (_type) {
            case "chart-bar":
                _instance = new BarGraphPortletInstance();
                _instance.percentWidth = 100;
                _instance.percentHeight = 100;
            case "filter":    
                _instance = new FilterPortletInstance();
            case "table":
                _instance = new TableDataPortletInstance();
                _instance.percentWidth = 100;
                _instance.percentHeight = 100;
        }

        return value;
    }

    private var _border:Bool = true;
    public var border(get, set):Bool;
    private function get_border():Bool {
        return _border;
    }
    private function set_border(value:Bool):Bool {
        if (value == _border) {
            return value;
        }

        _border = value;

        return value;
    }
}