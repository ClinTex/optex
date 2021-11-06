package;

import core.dashboards.Portlet;
import haxe.ui.containers.HBox;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.events.UIEvent;
import core.data.Dashboard;
import haxe.ui.components.Button;
import core.data.DashboardManager;
import core.data.DatabaseManager;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();

        ComponentClassMap.instance.registerClassName("vbox", Type.getClassName(VBox));
        ComponentClassMap.instance.registerClassName("hbox", Type.getClassName(HBox));
        ComponentClassMap.instance.registerClassName("portlet", Type.getClassName(Portlet));

        DatabaseManager.instance.init().then(function(r) {
            trace("database manager ready");
        });
        
        DatabaseManager.instance.listen(DatabaseEvent.Initialized, function(_) {
            refreshDashboardSelector();
        });
    }

    public function refreshDashboardSelector() {
        DashboardManager.instance.listDashboards().then(function(dashboards) {
            dashboardSelector.removeAllComponents();

            for (d in dashboards) {
                var button = new Button();
                button.text = d.name;
                button.icon = "icons/icons8-dashboard-48.png";
                button.userData = d;
                dashboardSelector.addComponent(button);
            }
            
            dashboardSelector.registerInternalEvents(true);
            dashboardSelector.selectedIndex = -1;
            dashboardSelector.selectedIndex = 0;
        });
    }

    @:bind(dashboardSelector, UIEvent.CHANGE)
    private function onDashboardSelectorChange(_) {
        var selectedButton = dashboardSelector.selectedButton;
        if (selectedButton == null) {
            return;
        }
        var dashboard:Dashboard = cast(selectedButton.userData, Dashboard);
        dashboardInstance.buildDashboard(dashboard);
    }
}