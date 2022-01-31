package core.dashboards;

import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;
import haxe.ui.RuntimeComponentBuilder;
import core.data.DashboardData;

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

    public function buildDashboard(dashboard:DashboardData) {
        var xml = Xml.parse(dashboard.layoutData).firstElement();
        var layoutNode = xml.elementsNamed("layout").next();
        var layoutDataNode = layoutNode.firstElement();
        var layoutData = layoutDataNode.toString();

        var c = RuntimeComponentBuilder.fromString(layoutData);

        _container.removeAllComponents();
        _container.addComponent(c);
        for (p in portlets) {
            p.onFilterChanged(_filter);
        }
    }

    public function clearDashboard() {
        _container.removeAllComponents();
    }

    public var portlets(get, null):Array<Portlet>;
    private function get_portlets():Array<Portlet> {
        var list = findComponents(Portlet, 20);
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


    // TODO: temp
    public var onTempFilterChanged:Map<String, Any>->Void = null;

    private var _filter:Map<String, Any> = [];
    public var filter(get, null):Map<String, Any>;
    private function get_filter():Map<String, Any> {
        return _filter;
    }

    public function addFilterItem(field:String, value:Any) {
        if (_filter.exists(field) && _filter.get(field) == value) {
            return;
        }
        trace("adding filter item: " + field + " = " + value);
        _filter.set(field, value);
        for (p in portlets) {
            p.onFilterChanged(_filter);
        }

        if (onTempFilterChanged != null) {
            onTempFilterChanged(_filter);
        }
    }

    public function removeFilterItem(field:String) {
        if (_filter.exists(field) == false) {
            return;
        }
        trace("removing filter item: " + field);
        _filter.remove(field);
        for (p in portlets) {
            p.onFilterChanged(_filter);
        }

        if (onTempFilterChanged != null) {
            onTempFilterChanged(_filter);
        }
    }
}
