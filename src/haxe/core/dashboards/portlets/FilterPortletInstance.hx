package core.dashboards.portlets;

import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.DropDown;

class FilterPortletInstance extends PortletInstance {
    public function new() {
        super();

        var dd = new DropDown();
        var ds = new ArrayDataSource<Dynamic>();
        ds.add({
            text: "Filter Item 1"
        });
        ds.add({
            text: "Filter Item 2"
        });
        ds.add({
            text: "Filter Item 3"
        });
        ds.add({
            text: "Filter Item 4"
        });
        ds.add({
            text: "Filter Item 5"
        });
        dd.dataSource = ds;

        addComponent(dd);

        dd.onChange = function(_) {
            trace("filter changed");
            if (dashboardInstance != null) {
                dashboardInstance.onFilterChanged();
            }
        }
    }
}