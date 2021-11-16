package;

import haxe.ui.containers.HorizontalSplitter;
import haxe.ui.containers.VerticalSplitter;
import haxe.ui.components.Spacer;
import haxe.ui.components.Label;
import haxe.ui.components.Link;
import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import core.dashboards.Portlet;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Card;
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
        ComponentClassMap.instance.registerClassName("box", Type.getClassName(Box));
        ComponentClassMap.instance.registerClassName("portlet", Type.getClassName(Portlet));
        ComponentClassMap.instance.registerClassName("card", Type.getClassName(Card));
        ComponentClassMap.instance.registerClassName("image", Type.getClassName(Image));
        ComponentClassMap.instance.registerClassName("link", Type.getClassName(Link));
        ComponentClassMap.instance.registerClassName("label", Type.getClassName(Label));
        ComponentClassMap.instance.registerClassName("spacer", Type.getClassName(Spacer));
        ComponentClassMap.instance.registerClassName("vertical-splitter", Type.getClassName(VerticalSplitter));
        ComponentClassMap.instance.registerClassName("horizontal-splitter", Type.getClassName(HorizontalSplitter));
        ComponentClassMap.instance.registerClassName("vsplitter", Type.getClassName(VerticalSplitter));
        ComponentClassMap.instance.registerClassName("hsplitter", Type.getClassName(HorizontalSplitter));

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
                var icon = d.icon;
                if (icon == null || icon == "") {
                    icon = "icons/icons8-dashboard-layout-48.png";
                }
                var button = new Button();
                button.text = d.name;
                button.icon = icon;
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