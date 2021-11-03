package views;

import haxe.ui.RuntimeComponentBuilder;
import components.Portlet;
import haxe.ui.events.UIEvent;
import core.data.DatabaseManager;
import haxe.ui.data.ArrayDataSource;
import sidebars.CreateDashboardSidebar;
import haxe.ui.events.MouseEvent;
import core.data.Table;
import core.data.DashboardManager;
import core.data.Dashboard;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/views/dashboards.xml"))
class DashboardsView extends VBox {
    private var _dashboardsTable:Table;

    public function new() {
        super();
        DatabaseManager.instance.listen(DatabaseEvent.Initialized, function(_) {
            refreshDashboardSelector();
        });
    }

    public function refreshDashboardSelector() {
        DashboardManager.instance.listDashboards().then(function(dashboards) {
            var ds = new ArrayDataSource<Dynamic>();
            for (d in dashboards) {
                ds.add({
                    name: d.name,
                    dashboard: d
                });
            }
            dashboardSelector.dataSource = ds;
        });
    }

    @:bind(addDashboardButton, MouseEvent.CLICK)
    private function onAddDataButton(e:MouseEvent) {
        var sidebar = new CreateDashboardSidebar();
        sidebar.position = "right";
        sidebar.modal = true;
        sidebar.show();
    }

    @:bind(updateLayoutDataButton, MouseEvent.CLICK)
    private function onUpdateLayoutDataButton(e:MouseEvent) {
        var selectedItem = dashboardSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var dashboard:Dashboard = selectedItem.dashboard;
        dashboard.layoutData = layoutDataField.text;
        dashboard.update().then(function(r) {
            trace(r);
        });
    }

    @:bind(dashboardSelector, UIEvent.CHANGE)
    private function onDashboardSelectorChanged(e:UIEvent) {
        var selectedItem = dashboardSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var dashboard:Dashboard = selectedItem.dashboard;
        layoutDataField.text = dashboard.layoutData;

        var portlet = new Portlet();

        var c = RuntimeComponentBuilder.fromString(dashboard.layoutData);
        previewTab.removeAllComponents();
        previewTab.addComponent(c);
    }

    @:bind(mainTabs, UIEvent.CHANGE)
    private function onMainTabsChange(e:UIEvent) {
        var selectedItem = dashboardSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var dashboard:Dashboard = selectedItem.dashboard;
        dashboard.layoutData = layoutDataField.text;
        
        var c = RuntimeComponentBuilder.fromString(dashboard.layoutData);
        previewTab.removeAllComponents();
        previewTab.addComponent(c);
    }
}