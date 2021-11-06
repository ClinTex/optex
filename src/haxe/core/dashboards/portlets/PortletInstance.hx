package core.dashboards.portlets;

import haxe.ui.containers.Box;

class PortletInstance extends Box {
    public function new() {
        super();
    }

    public function refresh() {

    }

    public var dashboardInstance(get, null):DashboardInstance;
    private function get_dashboardInstance():DashboardInstance {
        return findAncestor(DashboardInstance);
    }
}