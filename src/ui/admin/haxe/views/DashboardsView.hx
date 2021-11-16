package views;

import haxe.ui.util.Timer;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.ToolkitAssets;
import haxe.ui.components.Button;
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
    public static var instance:DashboardsView;

    private var _dashboardsTable:Table;

    public function new() {
        super();
        instance = this;
        DatabaseManager.instance.listen(DatabaseEvent.Initialized, function(_) {
            refreshDashboardSelector();
        });
    }

    private var _dashboardToSelect = null;
    public function refreshDashboardSelector(dashboardSelection:String = null) {
        _dashboardToSelect = dashboardSelection;
        DashboardManager.instance.listDashboards().then(function(dashboards) {
            var indexToSelect = 0;
            var ds = new ArrayDataSource<Dynamic>();
            var n = 0;
            for (d in dashboards) {
                if (d.name == _dashboardToSelect) {
                    indexToSelect = n;
                }
                ds.add({
                    name: d.name,
                    dashboard: d
                });
                n++;
            }
            dashboardSelector.dataSource = ds;
            dashboardSelector.selectedIndex = indexToSelect;
            _dashboardToSelect = null;
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

    private var _firstLoad:Bool = true;
    @:bind(dashboardSelector, UIEvent.CHANGE)
    private function onDashboardSelectorChanged(e:UIEvent) {
        var selectedItem = dashboardSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var dashboard:Dashboard = selectedItem.dashboard;
        //dashboard.layoutData = ToolkitAssets.instance.getText("data/dummy-dashboard.xml");
        layoutDataField.text = dashboard.layoutData;
        if (_firstLoad == true) {
            _firstLoad = false;
            Timer.delay(function() {
                dashboardPreviewInstance.buildDashboard(dashboard);
            }, 3000);
        } else {
            dashboardPreviewInstance.buildDashboard(dashboard);
        }
    }

    @:bind(mainTabs, UIEvent.CHANGE)
    private function onMainTabsChange(e:UIEvent) {
        var selectedItem = dashboardSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var dashboard:Dashboard = selectedItem.dashboard;
        dashboard.layoutData = layoutDataField.text;
        dashboardPreviewInstance.buildDashboard(dashboard);
    }
}