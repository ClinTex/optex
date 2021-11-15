package core.dashboards.portlets;

import haxe.ui.containers.VBox;
import core.data.CoreData.TableFragment;

class PortletInstance extends VBox {
    public var additionalConfigParams:Map<String, String> = [];

    public function new() {
        super();
    }

    public function refresh() {

    }

    public function onDataRefreshed(fragment:TableFragment) {
    }

    public function onFilterChanged(filter:Map<String, Any>) {
    }

    public function config(name:String, defaultValue:String = null):String {
        if (additionalConfigParams.exists(name) == false) {
            return defaultValue;
        }
        return additionalConfigParams.get(name);
    }

    public var dashboardInstance(get, null):DashboardInstance;
    private function get_dashboardInstance():DashboardInstance {
        return findAncestor(DashboardInstance);
    }
}