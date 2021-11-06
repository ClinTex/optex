package core.dashboards;

import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;
import core.data.Dashboard;
import haxe.ui.RuntimeComponentBuilder;

class DashboardInstanceEvent extends UIEvent {
    public static inline var FILTER_CHANGED:String = "filterChanged";
}

class DashboardInstance extends Box {
    private var _container:Box = new Box();

    public function new() {
        super();

        _container.percentWidth = 100;
        _container.percentHeight = 100;
        addComponent(_container);
    }

    public function buildDashboard(dashboard:Dashboard) {
        var c = RuntimeComponentBuilder.fromString(dashboard.layoutData);

        _container.removeAllComponents();
        _container.addComponent(c);
    }

    public var portlets(get, null):Array<Portlet>;
    private function get_portlets():Array<Portlet> {
        var list = findComponents(Portlet);
        return list;
    }

    public function refreshAllPortlets() {
        for (p in portlets) {
            p.refresh();
        }
    }

    public function onFilterChanged() {
        refreshAllPortlets();
    }
}
