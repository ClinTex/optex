package core.dashboards.portlets;

import core.data.GenericTable;
import haxe.ui.containers.VBox;

class PortletInstance extends VBox {
    public var additionalConfigParams:Map<String, String> = [];

    public function new() {
        super();
    }

    public function refresh() {

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