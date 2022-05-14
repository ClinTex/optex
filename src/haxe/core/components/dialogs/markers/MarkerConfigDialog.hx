package core.components.dialogs.markers;

import haxe.ui.containers.dialogs.Dialog;

class MarkerConfigDialog extends Dialog {
    private var _markerParams:Array<String> = [];
    public var markerParams(get, set):Array<String>;
    private function get_markerParams():Array<String> {
        return _markerParams;
    }
    private function set_markerParams(value:Array<String>):Array<String> {
        _markerParams = value;
        return value;
    }
}