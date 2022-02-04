package core.dashboards.portlets;

import core.data.GenericTable;
import haxe.ui.containers.VBox;

class PortletInstance extends VBox {
    public function new() {
        super();
    }

    private var _additionalConfigParams:Map<String, String> = [];
    public var additionalConfigParams(get, set):Map<String, String>;
    private function get_additionalConfigParams() {
        return _additionalConfigParams;
    }
    private function set_additionalConfigParams(value:Map<String, String>):Map<String, String> {
        _additionalConfigParams = value;
        onConfigChanged();
        return value;
    }

    private function onConfigChanged() {

    }

    public function refresh() {

    }

    public function clearData() {

    }

    public function onDataRefreshed(table:GenericTable) {
    }

    public function onFilterChanged(filter:Map<String, Any>) {
    }

    public function config(name:String, defaultValue:String = null):String {
        if (additionalConfigParams.exists(name) == false) {
            return defaultValue;
        }
        return additionalConfigParams.get(name);
    }

    public function configBool(name:String, defaultValue:Bool = false):Bool {
        if (additionalConfigParams.exists(name) == false) {
            return defaultValue;
        }
        return additionalConfigParams.get(name) == "true";
    }

    public var dashboardInstance(get, null):DashboardInstance;
    private function get_dashboardInstance():DashboardInstance {
        return findAncestor(DashboardInstance);
    }
}